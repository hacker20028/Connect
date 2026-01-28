import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/config/app_colors.dart';
import 'package:connect/helper/my_date_until.dart';
import 'package:connect/models/chat_user.dart';
import 'package:connect/screens/view_profile_screen.dart';
import 'package:connect/widgets/games/game_selector_bottom_sheet.dart';
import 'package:connect/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  bool _isTyping = false;
  Message? _replyingTo;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isTyping = _textController.text.isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });
      APIs.updateTypingStatus(widget.user.id, isTyping);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    APIs.updateTypingStatus(widget.user.id, false);
    super.dispose();
  }

  void _handleReply(Message message) {
    setState(() {
      _replyingTo = message;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _showAttachmentMenu(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            _AttachmentOption(
              icon: CupertinoIcons.photo,
              title: 'Gallery',
              color: AppColors.primary,
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final List<XFile> images =
                await picker.pickMultiImage(imageQuality: 70);
                for (var i in images) {
                  setState(() => _isUploading = true);
                  await APIs.sendChatImage(widget.user, File(i.path));
                }
                setState(() => _isUploading = false);
              },
            ),

            _AttachmentOption(
              icon: CupertinoIcons.camera,
              title: 'Camera',
              color: AppColors.accent,
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (image != null) {
                  setState(() => _isUploading = true);
                  await APIs.sendChatImage(widget.user, File(image.path));
                  setState(() => _isUploading = false);
                }
              },
            ),

            _AttachmentOption(
              icon: CupertinoIcons.smiley,
              title: 'Emoji',
              color: const Color(0xFFFFD93D),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showEmoji = !_showEmoji;
                });
              },
            ),

            _AttachmentOption(
              icon: CupertinoIcons.game_controller,
              title: 'Games',
              color: const Color(0xFF00D25B),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => GameSelectorBottomSheet(opponent: widget.user),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(isDarkMode),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                      AppColors.darkBackground,
                      AppColors.darkBackground.withOpacity(0.95),
                    ]
                        : [
                      AppColors.lightBackground,
                      AppColors.lightBackground.withOpacity(0.95),
                    ],
                  ),
                ),
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                            ?.map((e) => Message.fromJson(e.data()))
                            .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: _list[index],
                                onReply: _handleReply,
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.chat_bubble,
                                  size: 80,
                                  color: isDarkMode
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Say Hi! 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            ),

            // Typing indicator
            StreamBuilder(
              stream: APIs.getTypingStatus(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  final isTyping = data?['is_typing'] ?? false;
                  if (isTyping) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.typing.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${widget.user.name} is typing',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 20,
                                  height: 12,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: List.generate(3, (index) {
                                      return Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: AppColors.typing,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

            if (_isUploading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Reply preview
            if (_replyingTo != null) _buildReplyPreview(isDarkMode),

            // Chat input
            _chatInput(isDarkMode),

            // Emoji picker
            if (_showEmoji)
              SafeArea(
                top: false,
                child: SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    onBackspacePressed: () {},
                    textEditingController: _textController,
                    config: const Config(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _replyingTo!.msg,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _cancelReply,
            icon: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.lightTextSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(bool isDarkMode) {
    return SafeArea(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewProfileScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      CupertinoIcons.back,
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  Hero(
                    tag: 'profile_${widget.user.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                          errorWidget: (context, url, error) =>
                          const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          list.isNotEmpty ? list[0].name : widget.user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                              ? 'Online'
                              : MyDateUntil.getLastActiveTime(
                            context: context,
                            lastActive: list[0].lastActive,
                          )
                              : MyDateUntil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: list.isNotEmpty && list[0].isOnline
                                ? AppColors.online
                                : (isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chatInput(bool isDarkMode) {
    return SafeArea(
        top: false,
        child: Container(
        padding: EdgeInsets.symmetric(
        horizontal: mq.width * .02,
        vertical: mq.height * .01,
    ),
    decoration: BoxDecoration(
    color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
    boxShadow: [
    BoxShadow(
    color: isDarkMode
    ? Colors.black.withOpacity(0.2)
        : Colors.grey.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, -2),
    ),
    ],
    ),
    child: Row(
    children: [
    // Plus button for attachments
    IconButton(
    onPressed: () {
    FocusScope.of(context).unfocus();
    _showAttachmentMenu(isDarkMode);
    },
    icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
    ),
    child: const Icon(
    Icons.add,
    color: Colors.white,
    size: 22,
    ),
    ),
    ),

    // Input field
    Expanded(
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
    color: isDarkMode
    ? const Color(0xFF2A2A2A)
        : const Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(26),
    ),
    child: TextField(
    textCapitalization: TextCapitalization.sentences,
    controller: _textController,
    keyboardType: TextInputType.multiline,
    maxLines: null,
    onTap: () {
    if (_showEmoji) {
    setState(() {
    _showEmoji = false;
    });
    }
    },
    style: TextStyle(
    color: isDarkMode ? AppColors.darkText : AppColors.lightText,
    fontSize: 16,
    ),
    decoration: InputDecoration(
    hintText: 'Message...',
    hintStyle: TextStyle(
    color: isDarkMode
    ? AppColors.darkTextSecondary.withOpacity(0.6)
        : AppColors.lightTextSecondary.withOpacity(0.6),
    fontSize: 16,
    ),
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    ),
    ),
    ),
    ),

    // Send button
    Container(
    margin: const EdgeInsets.only(left: 4),
    decoration: BoxDecoration(
    gradient: _textController.text.isNotEmpty
    ? AppColors.primaryGradient
        : null,
    color: _textController.text.isEmpty
    ? (isDarkMode
    ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary)
        : null,
    shape: BoxShape.circle,
    boxShadow: _textController.text.isNotEmpty
    ? [
    BoxShadow(
    color: AppColors.primary.withOpacity(0.3),
    blurRadius: 8,
    offset: const Offset(0, 4),
    ),
    ]
        : null,
    ),
    child: IconButton(
    onPressed: () {
    if (_textController.text.isNotEmpty) {
    if (_replyingTo != null) {
    // Send reply message
    if (_list.isEmpty) {
    APIs.sendFirstMessage(
    widget.user,
    _textController.text,
    Type.text,
    );
    } else {
    APIs.sendReplyMessage(
    widget.user,
    _textController.text,
    Type.text,
    _replyingTo!.sent,
    _replyingTo!.msg,
    );
    }
    _cancelReply();
    } else {
    // Send normal message
    if (_list.isEmpty) {
    APIs.sendFirstMessage(
    widget.user,
    _textController.text,
    Type.text,
    );
    } else {
    APIs.sendMessage(
    widget.user,
    _textController.text,
    Type.text,
    );
    }
    }
    _textController.clear();
    }
    },
    icon: Icon(
    CupertinoIcons.arrow_up_circle_fill,
    color: _textController.text.isNotEmpty
    ? Colors.white
        : (isDarkMode ? AppColors.darkText : AppColors.lightText)
        .withOpacity(0.5),
    size: 32,
    ),
    ),
    ),
    ],
    ),
    ));
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}