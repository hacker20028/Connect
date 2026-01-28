import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/config/app_config.dart';
import 'package:connect/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import '../models/chat_user.dart';

class APIs {
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
    try {
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
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  // for sending push notification (NOW USES SECURE ENV VARIABLE)
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats",
          "sound": "default"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=${AppConfig.fcmServerKey}',
        },
        body: jsonEncode(body),
      ).timeout(AppConfig.messageTimeout);

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // For checking if user exists or not
  static Future<bool> userExists() async {
    try {
      return (await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get())
          .exists;
    } catch (e) {
      log('Error checking if user exists: $e');
      return false;
    }
  }

  // for adding a chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    try {
      final data = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      log('data: ${data.docs}');

      if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
        log('user exists: ${data.docs.first.data()}');

        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('my_users')
            .doc(data.docs.first.id)
            .set({});

        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error adding chat user: $e');
      return false;
    }
  }

  // For getting current user info
  static Future<void> getSelfInfo() async {
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).get().then(
              (user) async {
            if (user.exists) {
              me = ChatUser.fromJson(user.data()!);
              await getFirebaseMessagingToken();
              await updateActiveStatus(true);
              log('My Data: ${user.data()}');
            } else {
              await createUser().then((value) => getSelfInfo());
            }
          });
    } catch (e) {
      log('Error getting self info: $e');
    }
  }

  // For creating a new user
  static Future<void> createUser() async {
    try {
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
        email: user.email.toString(),
      );

      return await firestore
          .collection('users')
          .doc(user.uid)
          .set(chatUser.toJson());
    } catch (e) {
      log('Error creating user: $e');
    }
  }

  // For getting ID of known users from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // For getting all Users from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    try {
      await firestore
          .collection('users')
          .doc(chatUser.id)
          .collection('my_users')
          .doc(user.uid)
          .set({}).then((value) => sendMessage(chatUser, msg, type));
    } catch (e) {
      log('Error sending first message: $e');
    }
  }

  // For Updating User Info
  static Future<void> updateUserInfo() async {
    try {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'name': me.name,
        'about': me.about,
      });
    } catch (e) {
      log('Error updating user info: $e');
    }
  }

  // Update Profile Picture of the user
  static Future<void> updateProfilePicture(File file) async {
    try {
      final ext = file.path.split('.').last;
      log('Extension: $ext');

      final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

      await ref
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      me.image = await ref.getDownloadURL();
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'image': me.image
      });
    } catch (e) {
      log('Error updating profile picture: $e');
    }
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
    try {
      await firestore.collection('users').doc(user.uid).update({
        'is_online': isOnline,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'push_token': me.pushToken,
      });
    } catch (e) {
      log('Error updating active status: $e');
    }
  }

  // For getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // For getting all Messages of a Specific Conversation from Firestore Database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // For sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final Message message = Message(
        toid: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromid: user.uid,
        sent: time,
      );

      final ref = firestore
          .collection('chats/${getConversationId(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then(
              (value) => sendPushNotification(
              chatUser, type == Type.text ? msg : 'image'));
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  // Update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    try {
      await firestore
          .collection('chats/${getConversationId(message.fromid)}/messages/')
          .doc(message.sent)
          .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
    } catch (e) {
      log('Error updating read status: $e');
    }
  }

  // Get last message of that specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    try {
      final ext = file.path.split('.').last;

      final ref = storage.ref().child(
          'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      await ref
          .putFile(file, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      final imageUrl = await ref.getDownloadURL();
      await sendMessage(chatUser, imageUrl, Type.image);
    } catch (e) {
      log('Error sending chat image: $e');
    }
  }

  // delete message
  static Future<void> deleteMessage(Message message) async {
    try {
      await firestore
          .collection('chats/${getConversationId(message.toid)}/messages/')
          .doc(message.sent)
          .delete();

      if (message.type == Type.image) {
        await storage.refFromURL(message.msg).delete();
      }
    } catch (e) {
      log('Error deleting message: $e');
    }
  }

  // update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    try {
      await firestore
          .collection('chats/${getConversationId(message.toid)}/messages/')
          .doc(message.sent)
          .update({'msg': updatedMsg});
    } catch (e) {
      log('Error updating message: $e');
    }
  }

  // For updating typing status
  static Future<void> updateTypingStatus(String chatUserId, bool isTyping) async {
    try {
      await firestore
          .collection('chats/${getConversationId(chatUserId)}/typing/')
          .doc(user.uid)
          .set({
        'is_typing': isTyping,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      log('Error updating typing status: $e');
    }
  }

  // For getting typing status
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getTypingStatus(
      String chatUserId) {
    return firestore
        .collection('chats/${getConversationId(chatUserId)}/typing/')
        .doc(chatUserId)
        .snapshots();
  }

  // ADD THESE FUNCTIONS TO THE END OF YOUR APIs CLASS (before the closing brace)

  // For sending reply message
  static Future<void> sendReplyMessage(
      ChatUser chatUser, String msg, Type type, String replyToId, String replyToMsg) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final Message message = Message(
        toid: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromid: user.uid,
        sent: time,
        replyTo: replyToId,
        replyToMessage: replyToMsg,
      );

      final ref = firestore
          .collection('chats/${getConversationId(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then(
              (value) => sendPushNotification(
              chatUser, type == Type.text ? msg : 'image'));
    } catch (e) {
      log('Error sending reply message: $e');
    }
  }

  // For adding reaction to message
  static Future<void> addReaction(
      Message message, String emoji) async {
    try {
      final reactionKey = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      await firestore
          .collection('chats/${getConversationId(message.toid)}/messages/')
          .doc(message.sent)
          .update({
        'reactions.$reactionKey': {
          'emoji': emoji,
          'user_id': user.uid,
          'user_name': me.name,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        }
      });
    } catch (e) {
      log('Error adding reaction: $e');
    }
  }

  // For removing reaction from message
  static Future<void> removeReaction(
      Message message, String reactionKey) async {
    try {
      await firestore
          .collection('chats/${getConversationId(message.toid)}/messages/')
          .doc(message.sent)
          .update({
        'reactions.$reactionKey': FieldValue.delete(),
      });
    } catch (e) {
      log('Error removing reaction: $e');
    }
  }
}