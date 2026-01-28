import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/api/apis.dart';
import 'package:connect/models/game_message.dart';

class GamesAPI {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create a new game
  static Future<void> createGame({
    required String chatUserId,
    required GameType gameType,
    required Map<String, dynamic> gameData,
  }) async {
    try {
      final gameId = DateTime.now().millisecondsSinceEpoch.toString();

      final game = GameMessage(
        id: gameId,
        gameType: gameType,
        fromId: APIs.user.uid,
        toId: chatUserId,
        gameData: gameData,
        status: 'pending',
        timestamp: gameId,
      );

      await firestore
          .collection('chats/${APIs.getConversationId(chatUserId)}/games/')
          .doc(gameId)
          .set(game.toJson());
    } catch (e) {
      log('Error creating game: $e');
    }
  }

  // Update game state
  static Future<void> updateGame({
    required String chatUserId,
    required String gameId,
    required Map<String, dynamic> gameData,
    String? status,
    String? winnerId,
  }) async {
    try {
      Map<String, dynamic> updates = {'game_data': gameData};

      if (status != null) updates['status'] = status;
      if (winnerId != null) updates['winner_id'] = winnerId;

      await firestore
          .collection('chats/${APIs.getConversationId(chatUserId)}/games/')
          .doc(gameId)
          .update(updates);
    } catch (e) {
      log('Error updating game: $e');
    }
  }

  // Get active games stream
  static Stream<QuerySnapshot<Map<String, dynamic>>> getActiveGames(
      String chatUserId) {
    return firestore
        .collection('chats/${APIs.getConversationId(chatUserId)}/games/')
        .where('status', whereIn: ['pending', 'active'])
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  // Get specific game
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getGame(
      String chatUserId, String gameId) {
    return firestore
        .collection('chats/${APIs.getConversationId(chatUserId)}/games/')
        .doc(gameId)
        .snapshots();
  }

  // Delete game
  static Future<void> deleteGame(String chatUserId, String gameId) async {
    try {
      await firestore
          .collection('chats/${APIs.getConversationId(chatUserId)}/games/')
          .doc(gameId)
          .delete();
    } catch (e) {
      log('Error deleting game: $e');
    }
  }
}