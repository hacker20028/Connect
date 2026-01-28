import 'dart:math';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/material.dart';

class EmojiRiddleWidget extends StatefulWidget {
  final ChatUser opponent;

  const EmojiRiddleWidget({Key? key, required this.opponent}) : super(key: key);

  @override
  State<EmojiRiddleWidget> createState() => _EmojiRiddleWidgetState();
}

class _EmojiRiddleWidgetState extends State<EmojiRiddleWidget> {
  final TextEditingController _controller = TextEditingController();
  Map<String, String>? currentRiddle;
  bool showAnswer = false;
  bool isCorrect = false;
  int score = 0;

  final List<Map<String, String>> riddles = [
    {'emoji': '🎬🦁👑', 'answer': 'lion king'},
    {'emoji': '⚡👦🪄', 'answer': 'harry potter'},
    {'emoji': '🕷️👨', 'answer': 'spider man'},
    {'emoji': '🌟⚔️', 'answer': 'star wars'},
    {'emoji': '🍔👑', 'answer': 'burger king'},
    {'emoji': '☕⭐', 'answer': 'starbucks'},
    {'emoji': '🍎📱', 'answer': 'apple'},
    {'emoji': '🎮🏃', 'answer': 'subway surfers'},
    {'emoji': '😴👸', 'answer': 'sleeping beauty'},
    {'emoji': '🧊👑', 'answer': 'frozen'},
    {'emoji': '🏴‍☠️🌊', 'answer': 'pirates'},
    {'emoji': '🦇🃏', 'answer': 'batman'},
  ];

  @override
  void initState() {
    super.initState();
    _getNewRiddle();
  }

  void _getNewRiddle() {
    setState(() {
      currentRiddle = riddles[Random().nextInt(riddles.length)];
      showAnswer = false;
      isCorrect = false;
      _controller.clear();
    });
  }

  void _checkAnswer() {
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = currentRiddle!['answer']!.toLowerCase();

    setState(() {
      isCorrect = userAnswer == correctAnswer;
      showAnswer = true;
      if (isCorrect) score++;
    });
  }

  void _showHint() {
    final answer = currentRiddle!['answer']!;
    setState(() {
      _controller.text = answer[0];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentRiddle == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emoji Riddle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Emoji display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              currentRiddle!['emoji']!,
              style: const TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Input field
          if (!showAnswer)
            Column(
              children: [
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Your guess...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _checkAnswer(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showHint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hint'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C5CE7),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Result
          if (showAnswer)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCorrect ? 'Correct' : 'Wrong',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Answer: ${currentRiddle!['answer']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _getNewRiddle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next Riddle',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}