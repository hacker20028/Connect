import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/api/apis.dart';
import 'package:connect/config/app_colors.dart';
import 'package:connect/helper/my_date_until.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gal/gal.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    required this.message,
    this.onReply,
  }) : super(key: key);

  final Message message;
  final Function(Message)? onReply;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _showReactions = false;

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromid;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      key: ValueKey(widget.message.sent),
      startActionPane: !isMe
          ? ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (widget.onReply != null) {
                widget.onReply!(widget.message);
              }
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: CupertinoIcons.reply,
            label: 'Reply',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      )
          : null,
      endActionPane: isMe
          ? ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _showBottomSheet(isMe);
            },
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            icon: CupertinoIcons.ellipsis,
            label: 'More',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      )
          : null,
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _showReactions = !_showReactions;
          });
        },
        child: Column(
          children: [
            // Reply indicator if this is a reply
            if (widget.message.replyTo != null &&
                widget.message.replyToMessage != null)
              _buildReplyIndicator(isDarkMode, isMe),

            // Main message
            isMe ? _sentMessage(isDarkMode) : _receivedMessage(isDarkMode),

            // Reactions
            if (widget.message.reactions != null &&
                widget.message.reactions!.isNotEmpty)
              _buildReactionsDisplay(isDarkMode, isMe),

            // Quick reaction picker
            if (_showReactions) _buildQuickReactions(isMe),
          ],
        ),
      ),
    );
  }

  // Reply indicator widget
  Widget _buildReplyIndicator(bool isDarkMode, bool isMe) {
    return Container(
      margin: EdgeInsets.only(
        left: isMe ? mq.width * 0.3 : mq.width * 0.04,
        right: isMe ? mq.width * 0.04 : mq.width * 0.3,
        bottom: 4,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.5)
            : AppColors.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        widget.message.replyToMessage!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: isDarkMode
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  // Quick reactions picker
  Widget _buildQuickReactions(bool isMe) {
    final reactions = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? mq.width * 0.3 : mq.width * 0.04,
        right: isMe ? mq.width * 0.04 : mq.width * 0.3,
        top: 4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((emoji) {
          return GestureDetector(
            onTap: () {
              APIs.addReaction(widget.message, emoji);
              setState(() {
                _showReactions = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Display reactions under message
  Widget _buildReactionsDisplay(bool isDarkMode, bool isMe) {
    Map<String, int> emojiCount = {};

    widget.message.reactions!.forEach((key, value) {
      String emoji = value['emoji'] ?? '👍';
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
    });

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? mq.width * 0.3 : mq.width * 0.04,
        right: isMe ? mq.width * 0.04 : mq.width * 0.3,
        top: 4,
      ),
      child: Wrap(
        spacing: 6,
        children: emojiCount.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${entry.value}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Received message bubble
  Widget _receivedMessage(bool isDarkMode) {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        margin: EdgeInsets.only(
          left: mq.width * 0.04,
          right: mq.width * 0.3,
          top: 6,
          bottom: 6,
        ),
        padding: EdgeInsets.all(
          widget.message.type == Type.image ? 8 : 14,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.receivedMessageDark
              : AppColors.receivedMessageLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode
                    ? AppColors.darkText
                    : AppColors.lightText,
                height: 1.4,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.image_not_supported_rounded,
                  size: 70,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              MyDateUntil.getFormattedTime(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(
                fontSize: 11,
                color: (isDarkMode
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sent message bubble
  Widget _sentMessage(bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: mq.width * 0.75),
        margin: EdgeInsets.only(
          left: mq.width * 0.3,
          right: mq.width * 0.04,
          top: 6,
          bottom: 6,
        ),
        padding: EdgeInsets.all(
          widget.message.type == Type.image ? 8 : 14,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D3436),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.image_not_supported_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.message.read.isNotEmpty)
                  const Icon(
                    Icons.done_all_rounded,
                    color: Color(0xFF2D3436),
                    size: 16,
                  ),
                const SizedBox(width: 4),
                Text(
                  MyDateUntil.getFormattedTime(
                    context: context,
                    time: widget.message.sent,
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Copy/Save option
              widget.message.type == Type.text
                  ? _OptionItem(
                icon: const Icon(
                  CupertinoIcons.doc_on_doc,
                  color: AppColors.primary,
                  size: 24,
                ),
                name: 'Copy Text',
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.message.msg),
                  ).then((value) {
                    Navigator.pop(context);
                    Dialogs.showSnackBar(context, 'Text Copied!');
                  });
                },
              )
                  : _OptionItem(
                icon: const Icon(
                  CupertinoIcons.arrow_down_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
                name: 'Save Image',
                onTap: () async {
                  try {
                    await Gal.putImage(widget.message.msg);
                    Navigator.pop(context);
                    Dialogs.showSnackBar(
                      context,
                      'Image saved to gallery!',
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    Dialogs.showSnackBar(
                      context,
                      'Failed to save image',
                    );
                  }
                },
              ),

              if (isMe) const Divider(height: 1),

              // Edit option (only for text messages sent by user)
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                ),

              // Delete option
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    CupertinoIcons.trash,
                    color: Colors.red,
                    size: 24,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message);
                    Navigator.pop(context);
                  },
                ),

              const Divider(height: 1),

              // Message info
              _OptionItem(
                icon: const Icon(
                  CupertinoIcons.time,
                  color: AppColors.lightTextSecondary,
                  size: 24,
                ),
                name:
                'Sent: ${MyDateUntil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {},
              ),

              _OptionItem(
                icon: Icon(
                  widget.message.read.isEmpty
                      ? CupertinoIcons.checkmark_circle
                      : CupertinoIcons.checkmark_circle_fill,
                  color: widget.message.read.isEmpty
                      ? AppColors.lightTextSecondary
                      : AppColors.online,
                  size: 24,
                ),
                name: widget.message.read.isEmpty
                    ? 'Not seen yet'
                    : 'Read: ${MyDateUntil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.pencil,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Edit Message'),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: const InputDecoration(
            hintText: 'Type your message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}