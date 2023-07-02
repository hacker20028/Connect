import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import '../models/chat_user.dart';

class APIs{
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For accessing Cloud Firestore Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For accessing Firestore Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // For storing Self Information
  static late ChatUser me;

  // To return Current User
  static User get user => auth.currentUser!;

  // For accessing Firebase Messaging or Push Notifications
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
  });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats",
          "sound": "default"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAkdJ76o4:APA91bGsgzxBbzv3FGNHId0ffX_-oe22l4_i-l0PhzMGmcYSgvub2zeY9-DbQYN5U2r2GqLrU-dA9Tq8CzU0j0vEHRwkgy7n5yWUYbVIubr7xwtbqrJv1lo8x6bE8GzkKysRLP9AATqu'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // For checking if user exists or not
  static Future<bool> userExists()async{
    return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists;
  }

  // for adding a chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // For getting current user info
  static Future<void> getSelfInfo()async{
     await firestore.collection('users').doc(auth.currentUser!.uid).get()
         .then((user) async {
           if(user.exists){
             me = ChatUser.fromJson(user.data()!);
             getFirebaseMessagingToken();
             // For setting user status to active
             APIs.updateActiveStatus(true);
             log('My Data:  ${user.data()}');
           }else{
             await createUser().then((value) => getSelfInfo());
           }
     });
  }

  // For creating a new user
  static Future<void> createUser()async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I'm using Connect!",
        name: user.displayName.toString(),
        createdAt: time,
        lastActive: time,
        isOnline: false,
        id: user.uid,
        pushToken: '',
        email: user.email.toString());
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  // For getting ID of known users from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return APIs.firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // For getting all Users from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds){
    log('\nUserIds: $userIds');
    return APIs.firestore
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
        // .where('id', whereIn: userIds) // Was causing the error
        //.where('id', isNotEqualTo: user.uid)
        .snapshots();
}

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // For Updating User Info
  static Future<void> updateUserInfo()async{
     await firestore.collection('users').doc(auth.currentUser!.uid).update(
         {
           'name' : me.name,
           'about' : me.about,
         });
  }

  // Update Profile Picture of the user
  static Future<void> updateProfilePicture(File file)async{
    // For getting Image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    // Storing file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    // Uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    // Updating image in Firestore Database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(auth.currentUser!.uid).update(
        {
          'image' : me.image
        });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIS *******************

  // Chats (collection) --> conversation_id (docs) --> messages (collection) --> message (docs)

  // For getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // For getting all Messages of a Specific Conversation from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent' , descending: true)
        .snapshots();
  }

  // For sending message
static Future<void> sendMessage(ChatUser chatUser, String msg, Type type)async{

    // For sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // Message to send
    final Message message = Message(
        toid: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromid: user.uid,
        sent: time);

    final ref = firestore.collection('chats/${getConversationId(chatUser.id)}/messages/');
       await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
}

  // Update read status of message
static Future<void> updateMessageReadStatus(Message message) async {
  firestore
      .collection('chats/${getConversationId(message.fromid)}/messages/')
      .doc(message.sent)
      .update({'read' : DateTime.now().millisecondsSinceEpoch.toString()});
}

// Get last message of that specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent' , descending: true)
        .limit(1)
        .snapshots();
}

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //delete message
  static Future<void> deleteMessageTest(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .update({'msg' : 'Yaha par bhi Delete hi kar tu 😒'});

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

}