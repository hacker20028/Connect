import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:flutter/material.dart';

class WordChainWidget extends StatefulWidget {
  final ChatUser opponent;

  const WordChainWidget({Key? key, required this.opponent}) : super(key: key);

  @override
  State<WordChainWidget> createState() => _WordChainWidgetState();
}

class _WordChainWidgetState extends State<WordChainWidget> {
  final TextEditingController _controller = TextEditingController();
  List<String> wordChain = ['Apple'];
  int streak = 0;
  String? errorMessage;

  void _submitWord() {
    final word = _controller.text.trim().toLowerCase();

    if (word.isEmpty) return;

    final lastWord = wordChain.last.toLowerCase();
    final requiredLetter = lastWord[lastWord.length - 1];

    if (word[0] != requiredLetter) {
      setState(() {
        errorMessage = 'Word must start with "${requiredLetter.toUpperCase()}"';
      });
      return;
    }

    if (wordChain.map((w) => w.toLowerCase()).contains(word)) {
      setState(() {
        errorMessage = 'Word already used';
      });
      return;
    }

    setState(() {
      wordChain.add(word[0].toUpperCase() + word.substring(1));
      streak++;
      errorMessage = null;
      _controller.clear();
    });
  }

  void _reset() {
    setState(() {
      wordChain = ['Apple'];
      streak = 0;
      errorMessage = null;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastWord = wordChain.last;
    final nextLetter = lastWord[lastWord.length - 1].toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFD79A8), Color(0xFFFFB347)],
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
                'Word Chain',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Streak: $streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Word chain display
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: wordChain.map((word) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Next letter hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Next word must start with: $nextLetter',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Enter word...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submitWord(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _submitWord,
                  icon: const Icon(Icons.send, color: Color(0xFFFD79A8)),
                ),
              ),
            ],
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}