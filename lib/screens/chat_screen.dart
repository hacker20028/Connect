import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/helper/my_date_until.dart';
import 'package:connect/models/chat_user.dart';
import 'package:connect/screens/view_profile_screen.dart';
import 'package:connect/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  //const ChatScreen({Key, required this.user? key}) : super(key: key);

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   List <Message> _list = [];

   // For handling text messages
   final _textController = TextEditingController();

  // static final bool isIOS = (_operatingSystem == "ios");

   // _showEmoji -- For storing value whether to show or hide emoji
   // _isUploading -- For checking if images are uploading or not?
   bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // If Emoji is on & back is pressed then close only Emoji
          // or else simply close current screen on back button click
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }

          },
          child: Scaffold(
            // App Bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: Colors.white,

            // Chat Screen Body
            body: Column(children: [
              Expanded(
                child: StreamBuilder(
                 stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {

                    switch (snapshot.connectionState){
                    // If Data is Loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator(),);
                        ///Can use the code below to hide the progress indicator while loading chats
                        //return cosnt SizedBox();

                    // If some or all Data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:


                        final data = snapshot.data?.docs;
                        //log('Data: ${jsonEncode(data![0].data())}');
                        _list = data
                            ?.map((e) => Message.fromJson(e.data()))
                            .toList() ?? [];

                        if (_list.isNotEmpty){
                          return ListView.builder(
                            reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index){
                                 return MessageCard(message: _list[index]);
                                   //Text('Message: ${_list[index]}');
                              });
                        }else{
                          return const Center(
                            child: Text('Say Hii! 👋',
                              style: TextStyle(
                                fontSize: 20,
                              ),),
                          );
                        }
                    }


                  },
                ),
              ),

              if (_isUploading)
              const Align(
                alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )),

              // Chat input field
              _chatInput(),

              // Show images on keyboard emoji button click & vice-versa
              if(_showEmoji)
              SizedBox(
                height: mq.height * .35,
                child: EmojiPicker(
                onBackspacePressed: () {
                // Do something when the user taps the backspace button (optional)
                // Set it to null to hide the Backspace-Button
                },
                textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                config: Config(
                columns: 8,
                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
      //       verticalSpacing: 0,
      //       horizontalSpacing: 0,
      //       gridPadding: EdgeInsets.zero,
      // initCategory: Category.RECENT,
      // bgColor: Color(0xFFF2F2F2),
      // indicatorColor: Colors.blue,
      // iconColor: Colors.grey,
      // iconColorSelected: Colors.blue,
      // backspaceColor: Colors.blue,
      // skinToneDialogBgColor: Colors.white,
      // skinToneIndicatorColor: Colors.grey,
      // enableSkinTones: true,
      // showRecentsTab: true,
      // recentsLimit: 28,
      // noRecents: const Text(
      // 'No Recents',
      // style: TextStyle(fontSize: 20, color: Colors.black26),
      // textAlign: TextAlign.center,
      // ), // Needs to be const Widget
      // loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
      // tabIndicatorAnimDuration: kTabScrollDuration,
      // categoryIcons: const CategoryIcons(),
      // buttonMode: ButtonMode.MATERIAL,
      ),
      ),
              )
            ],),
          ),
        ),
      ),
    );
  }
  // App Bar Widget
  Widget _appBar(){
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(stream: APIs.getUserInfo(widget.user), builder: (context, snapshot){

        final data = snapshot.data?.docs;
        final list = data
            ?.map((e) => ChatUser.fromJson(e.data()))
            .toList() ?? [];

        return Row(children: [
          // Back Button
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: Colors.black54,)),

          // User Profile Picture
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              //fit: BoxFit.fill,
              imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person, ),),
            ),
          ),

          // For Adding Some Space
          const SizedBox(width: 10,),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // To show Username
              Text( list.isNotEmpty ? list[0].name : widget.user.name,
                style: const TextStyle(fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),),

              // For Adding Some Space
              const SizedBox(height: 2,),

              // To show Last seen of the user
               Text(list.isNotEmpty
                   ? list[0].isOnline
                   ? 'Online'
                   : MyDateUntil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                   : MyDateUntil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                  style: const TextStyle(fontSize: 14,
                    color: Colors.black54,
                  )),
            ],),
        ],);
        
    })   );
  }


  //Bottom Chat input feild
Widget _chatInput(){
    // Input Field & Button
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                //Emoji Button
                IconButton(onPressed: (){
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _showEmoji = !_showEmoji;
                  });
                },
                    icon: Icon(Icons.emoji_emotions, color: Colors.deepOrange,size: 25,)),

                //Input Field
                 Expanded(child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onTap: (){
                    setState(() {
                      if (_showEmoji)
                      _showEmoji = !_showEmoji;
                    });
                  },
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.deepOrange),
                    hintText: 'Type Something...',
                    border: InputBorder.none,
                  ),
                )),

                // Pick image form Gallery Button
                IconButton(onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Picking Multiple Images
                  final List<XFile>  images =
                      await picker.pickMultiImage(imageQuality: 70);

                  // Uploading and sending images one by one
                  for (var i in images){
                    log('Image Path: ${i.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImage(widget.user ,File(i.path));}
                  setState(() => _isUploading = false);
                },
                    icon: Icon(Icons.image, color: Colors.deepOrange,size: 26,)),

                // Take image form Camera Button
                IconButton(onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image.
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if(image != null){
                    log('Image Path: ${image.path}');
                    setState(() => _isUploading = true);
                   await APIs.sendChatImage(widget.user ,File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
                    icon: Icon(Icons.camera_alt_rounded, color: Colors.deepOrange, size: 26,)),

                //For Adding Some Space
                SizedBox(width: mq.width * .015,),
              ],),
            ),
          ),

          //Send Messdage Button
          MaterialButton(onPressed: (){
            if(_textController.text.isNotEmpty){
              if(_list.isEmpty){
                // On first Message add user to my_user collection of chat
                APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
              }else {
                // Simply send message
                APIs.sendMessage(widget.user, _textController.text, Type.text);
              }
              _textController.text = '';
            }
          },
            minWidth: 0,
            shape: CircleBorder(),
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            color: Colors.deepOrange,
          child: Icon(Icons.send,
          color: Colors.white,
          size: 28,),)
        ],
      ),
    );
}
}
