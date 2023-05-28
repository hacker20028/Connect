import 'package:connect/api/apis.dart';
import 'package:connect/helper/my_date_until.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../main.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {

            final data = snapshot.data?.docs;
            final list = data
                ?.map((e) => Message.fromJson(e.data()))
                .toList() ?? [];
            if(list.isNotEmpty){_message = list[0];}

            return ListTile(
              //User Profile Picture
              // leading: const CircleAvatar(child: Icon(CupertinoIcons.person, ),),
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.width * .088,
                      height: mq.height * .088,
                      //fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      //placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person, ),),
                    ),
                  ),
                ),

                //User Name
                title: (Text(widget.user.name)),

                //User Last Message
                subtitle: Text( _message != null ?
                    _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                        : widget.user.about,
                  maxLines: 1,
                ),

                //Last Message Time
                trailing: _message == null ? null :
                _message!.read.isEmpty && _message!.fromid != APIs.user.uid ?
                Container(width: 15, height: 15,
                  decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),)
                    :
                Text(
                  MyDateUntil.getLastMessageTime(context: context, time: _message!.sent),
                  style: TextStyle(color: Colors.black54),),

              // trailing: const Text('9:00 PM', style: TextStyle(color: Colors.black54),),

            );
          }
          ,)
      ),
    );
  }
}


