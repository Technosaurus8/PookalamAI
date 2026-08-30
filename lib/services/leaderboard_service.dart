// lib/services/leaderboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static Future<void> submitEntry({
    required String playerName,
    required String imageBase64,
    required int score,
    required String comment,
  }) async {
    final entry = LeaderboardEntry.newSubmission(
      playerName: playerName,
      imageBase64: imageBase64,
      score: score,
      comment: comment,
    );
    await FirebaseFirestore.instance
        .collection('leaderboard')
        .add(entry.toSubmissionMap());
  }
}
