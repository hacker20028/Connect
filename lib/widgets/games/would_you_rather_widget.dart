import 'dart:math';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/material.dart';

class WouldYouRatherWidget extends StatefulWidget {
  final ChatUser opponent;

  const WouldYouRatherWidget({Key? key, required this.opponent}) : super(key: key);

  @override
  State<WouldYouRatherWidget> createState() => _WouldYouRatherWidgetState();
}

class _WouldYouRatherWidgetState extends State<WouldYouRatherWidget> {
  String? selectedOption;
  Map<String, String>? currentQuestion;

  final List<Map<String, String>> questions = [
    {
      'option1': 'Have the ability to fly',
      'option2': 'Have the ability to be invisible',
    },
    {
      'option1': 'Live without music',
      'option2': 'Live without movies',
    },
    {
      'option1': 'Always be 10 minutes late',
      'option2': 'Always be 20 minutes early',
    },
    {
      'option1': 'Have a rewind button for life',
      'option2': 'Have a pause button for life',
    },
    {
      'option1': 'Be able to read minds',
      'option2': 'Be able to see the future',
    },
    {
      'option1': 'Never use social media again',
      'option2': 'Never watch another movie or TV show',
    },
    {
      'option1': 'Have unlimited money',
      'option2': 'Have unlimited time',
    },
    {
      'option1': 'Be famous',
      'option2': 'Be the best friend of someone famous',
    },
    {
      'option1': 'Live in the past',
      'option2': 'Live in the future',
    },
    {
      'option1': 'Never eat your favorite food again',
      'option2': 'Only eat your favorite food',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getNewQuestion();
  }

  void _getNewQuestion() {
    setState(() {
      currentQuestion = questions[Random().nextInt(questions.length)];
      selectedOption = null;
    });
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withOpacity(0.3),
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
                'Would You Rather',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _getNewQuestion,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildOptionCard(
            option: currentQuestion!['option1']!,
            isSelected: selectedOption == 'option1',
            onTap: () => _selectOption('option1'),
          ),

          const SizedBox(height: 12),

          const Text(
            'OR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildOptionCard(
            option: currentQuestion!['option2']!,
            isSelected: selectedOption == 'option2',
            onTap: () => _selectOption('option2'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00B894) : Colors.white,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}