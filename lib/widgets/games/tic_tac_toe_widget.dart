import 'package:connect/api/apis.dart';
import 'package:connect/api/games_api.dart';
import 'package:connect/config/app_colors.dart';
import 'package:connect/models/chat_user.dart';
import 'package:connect/models/game_message.dart';
import 'package:flutter/material.dart';

class TicTacToeWidget extends StatefulWidget {
  final ChatUser opponent;
  final GameMessage? gameData;

  const TicTacToeWidget({
    Key? key,
    required this.opponent,
    this.gameData,
  }) : super(key: key);

  @override
  State<TicTacToeWidget> createState() => _TicTacToeWidgetState();
}

class _TicTacToeWidgetState extends State<TicTacToeWidget> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String? winner;
  bool isMyTurn = true;

  @override
  void initState() {
    super.initState();
    if (widget.gameData != null) {
      _loadGameState();
    } else {
      _initializeGame();
    }
  }

  void _loadGameState() {
    final data = widget.gameData!.gameData;
    setState(() {
      board = List<String>.from(data['board'] ?? List.filled(9, ''));
      currentPlayer = data['current_player'] ?? 'X';
      winner = data['winner'];
      isMyTurn = data['current_turn_id'] == APIs.user.uid;
    });
  }

  void _initializeGame() {
    GamesAPI.createGame(
      chatUserId: widget.opponent.id,
      gameType: GameType.ticTacToe,
      gameData: {
        'board': board,
        'current_player': currentPlayer,
        'current_turn_id': APIs.user.uid,
        'player_x': APIs.user.uid,
        'player_o': widget.opponent.id,
      },
    );
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && winner == null && isMyTurn) {
      setState(() {
        board[index] = currentPlayer;
        winner = _checkWinner();
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        isMyTurn = false;
      });

      GamesAPI.updateGame(
        chatUserId: widget.opponent.id,
        gameId: widget.gameData?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        gameData: {
          'board': board,
          'current_player': currentPlayer,
          'current_turn_id': widget.opponent.id,
          'player_x': APIs.user.uid,
          'player_o': widget.opponent.id,
          'winner': winner,
        },
        status: winner != null ? 'completed' : 'active',
        winnerId: winner != null ? (winner == 'X' ? APIs.user.uid : widget.opponent.id) : null,
      );
    }
  }

  String? _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }

    if (!board.contains('')) {
      return 'Draw';
    }

    return null;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = null;
      isMyTurn = true;
    });
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                'Tic-Tac-Toe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (winner != null)
                IconButton(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
            ],
          ),

          const SizedBox(height: 16),

          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _makeMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: board[index] == 'X'
                                ? AppColors.primary
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              winner != null
                  ? winner == 'Draw'
                  ? "Draw"
                  : winner == 'X'
                  ? 'You Won'
                  : '${widget.opponent.name} Won'
                  : isMyTurn
                  ? 'Your Turn'
                  : '${widget.opponent.name}\'s Turn',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}