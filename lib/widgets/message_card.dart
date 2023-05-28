import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/api/apis.dart';
import 'package:connect/helper/my_date_until.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromid ? _greenMessage() : _blueMessage();
  }

  // Sender side Message
  Widget _blueMessage(){

    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      //log('message read updated');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Message Content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .03 : mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              // M
                border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
            child:
            widget.message.type == Type.text ?
                // Show text
            Text(widget.message.msg,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),) :
                // SHow Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                //fit: BoxFit.fill,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_rounded, size: 70, ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUntil.getFormattedTime(context: context,
                time: widget.message.sent),
            style: const TextStyle(fontSize: 13,
            color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // Our side Message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Message Content

        Row(
          children: [
            // For adding some space
            SizedBox(width: mq.width * .02,),

            // Double tick blue icon for message read
            if(widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20,),

            // For adding some space
            const SizedBox(width: 2,),

            // Sent Time
            Text(
              MyDateUntil.getFormattedTime(context: context,
                  time: widget.message.sent),
              style: const TextStyle(fontSize: 13,
                  color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.width * .03 : mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                //
                border: Border.all(color: Colors.deepOrangeAccent),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child:  widget.message.type == Type.text ?
            // Show text
            Text(widget.message.msg,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),) :
            // SHow Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                //fit: BoxFit.fill,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child:  CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_rounded, size: 70, ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
