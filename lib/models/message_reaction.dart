class MessageReaction {
  final String emoji;
  final String userId;
  final String userName;
  final String timestamp;

  MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'user_id': userId,
      'user_name': userName,
      'timestamp': timestamp,
    };
  }

  // Create from JSON
  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] ?? '👍',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}