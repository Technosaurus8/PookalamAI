// lib/models/leaderboard_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String id;
  final String playerName;
  final String imageBase64;
  final int score;
  final String comment;
  final Timestamp? createdAt;

  LeaderboardEntry({
    required this.id,
    required this.playerName,
    required this.imageBase64,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      id: doc.id,
      playerName: data['playerName'] as String? ?? 'Unknown',
      imageBase64: data['imageBase64'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// For a brand-new submission that doesn't have a Firestore id/timestamp yet.
  factory LeaderboardEntry.newSubmission({
    required String playerName,
    required String imageBase64,
    required int score,
    required String comment,
  }) {
    return LeaderboardEntry(
      id: '',
      playerName: playerName,
      imageBase64: imageBase64,
      score: score,
      comment: comment,
      createdAt: null,
    );
  }

  /// Serializes for writing — server sets the real timestamp, id is
  /// assigned by Firestore itself so it's intentionally excluded here.
  Map<String, dynamic> toSubmissionMap() {
    return {
      'playerName': playerName,
      'imageBase64': imageBase64,
      'score': score,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
