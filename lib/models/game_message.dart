enum GameType {
  ticTacToe,
  truthOrDare,
  wouldYouRather,
  typingChallenge,
  wordChain,
  emojiRiddle,
  quickDraw,
}

class GameMessage {
  final String id;
  final GameType gameType;
  final String fromId;
  final String toId;
  final Map<String, dynamic> gameData;
  final String status; // 'pending', 'active', 'completed'
  final String? winnerId;
  final String timestamp;

  GameMessage({
    required this.id,
    required this.gameType,
    required this.fromId,
    required this.toId,
    required this.gameData,
    required this.status,
    this.winnerId,
    required this.timestamp,
  });

  factory GameMessage.fromJson(Map<String, dynamic> json) {
    return GameMessage(
      id: json['id'] ?? '',
      gameType: GameType.values.firstWhere(
            (e) => e.toString() == json['game_type'],
        orElse: () => GameType.ticTacToe,
      ),
      fromId: json['from_id'] ?? '',
      toId: json['to_id'] ?? '',
      gameData: json['game_data'] ?? {},
      status: json['status'] ?? 'pending',
      winnerId: json['winner_id'],
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_type': gameType.toString(),
      'from_id': fromId,
      'to_id': toId,
      'game_data': gameData,
      'status': status,
      'winner_id': winnerId,
      'timestamp': timestamp,
    };
  }
}