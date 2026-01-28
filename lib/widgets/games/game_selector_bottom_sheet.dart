import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:connect/widgets/games/emoji_riddle_widget.dart';
import 'package:connect/widgets/games/quick_draw_widget.dart';
import 'package:connect/widgets/games/tic_tac_toe_widget.dart';
import 'package:connect/widgets/games/truth_or_dare_widget.dart';
import 'package:connect/widgets/games/typing_challenge_widget.dart';
import 'package:connect/widgets/games/word_chain_widget.dart';
import 'package:connect/widgets/games/would_you_rather_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameSelectorBottomSheet extends StatelessWidget {
  final ChatUser opponent;

  const GameSelectorBottomSheet({Key? key, required this.opponent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Choose a Game',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Game options
          _GameOption(
            icon: Icons.grid_3x3,
            title: 'Tic-Tac-Toe',
            description: 'Classic strategy game',
            color: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              _showGame(context, TicTacToeWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.question_circle,
            title: 'Truth or Dare',
            description: 'Answer truths or do dares',
            color: AppColors.accent,
            onTap: () {
              Navigator.pop(context);
              _showGame(context, TruthOrDareWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.arrow_right_arrow_left,
            title: 'Would You Rather',
            description: 'Choose between two options',
            color: const Color(0xFF00B894),
            onTap: () {
              Navigator.pop(context);
              _showGame(context, WouldYouRatherWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.keyboard,
            title: 'Typing Challenge',
            description: 'Test your typing speed',
            color: const Color(0xFFFD79A8),
            onTap: () {
              Navigator.pop(context);
              _showGame(context, TypingChallengeWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.link,
            title: 'Word Chain',
            description: 'Link words together',
            color: const Color(0xFFFFB347),
            onTap: () {
              Navigator.pop(context);
              _showGame(context, WordChainWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.smiley,
            title: 'Emoji Riddle',
            description: 'Guess from emoji clues',
            color: const Color(0xFF6C5CE7),
            onTap: () {
              Navigator.pop(context);
              _showGame(context, EmojiRiddleWidget(opponent: opponent));
            },
          ),

          _GameOption(
            icon: CupertinoIcons.paintbrush,
            title: 'Quick Draw',
            description: 'Draw and share',
            color: const Color(0xFF00CEC9),
            onTap: () {
              Navigator.pop(context);
              _showGame(context, QuickDrawWidget(opponent: opponent));
            },
          ),
        ],
      ),
    );
  }

  void _showGame(BuildContext context, Widget gameWidget) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: gameWidget,
      ),
    );
  }
}

class _GameOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _GameOption({
    required this.icon,
    required this.title,
    required this.description,
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}