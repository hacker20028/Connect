import 'dart:async';
import 'dart:math';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/material.dart';

class TypingChallengeWidget extends StatefulWidget {
  final ChatUser opponent;

  const TypingChallengeWidget({Key? key, required this.opponent})
      : super(key: key);

  @override
  State<TypingChallengeWidget> createState() => _TypingChallengeWidgetState();
}

class _TypingChallengeWidgetState extends State<TypingChallengeWidget> {
  final TextEditingController _controller = TextEditingController();
  String targetText = '';
  bool isStarted = false;
  bool isCompleted = false;
  int seconds = 0;
  Timer? timer;
  int wpm = 0;

  final List<String> sentences = [
    'The quick brown fox jumps over the lazy dog',
    'Practice makes perfect',
    'Time flies when you are having fun',
    'A journey of a thousand miles begins with a single step',
    'Actions speak louder than words',
    'Better late than never',
    'Every cloud has a silver lining',
    'Knowledge is power',
    'The early bird catches the worm',
    'Where there is a will there is a way',
  ];

  @override
  void initState() {
    super.initState();
    _getNewSentence();
    _controller.addListener(_checkProgress);
  }

  void _getNewSentence() {
    setState(() {
      targetText = sentences[Random().nextInt(sentences.length)];
      isStarted = false;
      isCompleted = false;
      seconds = 0;
      wpm = 0;
      _controller.clear();
    });
  }

  void _checkProgress() {
    if (!isStarted && _controller.text.isNotEmpty) {
      _startTimer();
    }

    if (_controller.text == targetText && !isCompleted) {
      _completeChallenge();
    }
  }

  void _startTimer() {
    setState(() {
      isStarted = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        seconds++;
      });
    });
  }

  void _completeChallenge() {
    timer?.cancel();
    setState(() {
      isCompleted = true;
      wpm = ((targetText.split(' ').length / (seconds / 60))).round();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFD79A8), Color(0xFFFFB3BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFD79A8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Typing Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCompleted)
                IconButton(
                  onPressed: _getNewSentence,
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Target text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              targetText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Input field
          if (!isCompleted)
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Start typing...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
            ),

          if (isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Challenge Complete',
                    style: TextStyle(
                      color: Color(0xFFFD79A8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${seconds}s | WPM: $wpm',
                    style: const TextStyle(
                      color: Color(0xFFFD79A8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isStarted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Time: ${seconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}