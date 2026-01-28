import 'dart:math';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/material.dart';

class TruthOrDareWidget extends StatefulWidget {
  final ChatUser opponent;

  const TruthOrDareWidget({Key? key, required this.opponent}) : super(key: key);

  @override
  State<TruthOrDareWidget> createState() => _TruthOrDareWidgetState();
}

class _TruthOrDareWidgetState extends State<TruthOrDareWidget> {
  String? selectedType;
  String? currentQuestion;

  final List<String> truths = [
    "What's your biggest fear?",
    "What's the most embarrassing thing you've done?",
    "Who was your first crush?",
    "What's a secret you've never told anyone?",
    "What's your biggest regret?",
    "What's the worst lie you've ever told?",
    "What's your guilty pleasure?",
    "What's something you've done that you're not proud of?",
    "Who do you have a crush on right now?",
    "What's the most trouble you've been in?",
  ];

  final List<String> dares = [
    "Send a voice message singing your favorite song",
    "Change your profile picture to something funny for 1 hour",
    "Send a selfie making a funny face",
    "Text your crush something nice",
    "Do 20 push-ups and send proof",
    "Record yourself doing a silly dance",
    "Call someone and tell them a joke",
    "Post an embarrassing photo on your story",
    "Speak in an accent for the next 10 minutes",
    "Let the other person write your status for a day",
  ];

  void _selectTruth() {
    setState(() {
      selectedType = 'Truth';
      currentQuestion = truths[Random().nextInt(truths.length)];
    });
  }

  void _selectDare() {
    setState(() {
      selectedType = 'Dare';
      currentQuestion = dares[Random().nextInt(dares.length)];
    });
  }

  void _reset() {
    setState(() {
      selectedType = null;
      currentQuestion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
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
                'Truth or Dare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedType != null)
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (currentQuestion == null)
            Column(
              children: [
                const Text(
                  'Choose your challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectTruth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Truth',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectDare,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Dare',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedType!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
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