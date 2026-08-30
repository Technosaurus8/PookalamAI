// lib/screens/leaderboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream),
        title: Text('Leaderboard', style: AppText.heading(size: 20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true)
            .orderBy(
              'createdAt',
            ) // tiebreaker: keeps ordering stable when scores match
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StateMessage(
              icon: Icons.error_outline,
              iconColor: AppColors.red,
              text: 'Error loading leaderboard: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return _StateMessage(
              icon: Icons.emoji_events_outlined,
              iconColor: AppColors.gold,
              text: 'No submissions yet — be the first!',
            );
          }

          final entries = docs.map((d) => LeaderboardEntry.fromDoc(d)).toList();

          // Dense ranking: tied scores share a rank, and the rank after a
          // tie increments by 1 regardless of how many entries were tied
          // (1, 2, 2, 3 — not 1, 2, 2, 4). Query order already breaks ties
          // by createdAt, so this only needs the score comparison.
          final ranks = <int>[];
          for (var i = 0; i < entries.length; i++) {
            if (i == 0) {
              ranks.add(1);
            } else if (entries[i].score == entries[i - 1].score) {
              ranks.add(ranks[i - 1]);
            } else {
              ranks.add(ranks[i - 1] + 1);
            }
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _LeaderboardTile(entry: entry, rank: ranks[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.body(color: AppColors.creamHint),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rank-specific accent color: gold/silver/bronze for the top 3, a muted
/// green-on-cream neutral for everyone else.
Color _rankColor(int rank) {
  switch (rank) {
    case 1:
      return AppColors.gold;
    case 2:
      return const Color(0xFFC0C4C9); // silver
    case 3:
      return const Color(0xFFCD7F32); // bronze
    default:
      return AppColors.green.withOpacity(0.15);
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardTile({required this.entry, required this.rank});

  Widget _thumbnail({double size = 64}) {
    if (entry.imageBase64.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(size >= 200 ? 16 : 10),
        ),
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.green.withOpacity(0.4),
          size: size >= 200 ? 48 : 24,
        ),
      );
    }
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size >= 200 ? 16 : 10),
        child: Image.memory(
          base64Decode(entry.imageBase64),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      // Corrupted base64 shouldn't crash the tile.
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(size >= 200 ? 16 : 10),
        ),
        child: Icon(
          Icons.broken_image,
          color: AppColors.green.withOpacity(0.4),
          size: size >= 200 ? 48 : 24,
        ),
      );
    }
  }

  Widget _rankBadge({double size = 30, double fontSize = 13}) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _rankColor(rank),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: AppText.button(size: fontSize, color: AppColors.green),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => AppDecor.themedDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rankBadge(size: 26, fontSize: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.playerName,
                style: AppText.button(size: 17, color: AppColors.green),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _thumbnail(size: 240)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Score', style: AppText.label(color: AppColors.green)),
                    const Spacer(),
                    Text(
                      '${entry.score}',
                      style: AppText.heading(size: 26, color: AppColors.green),
                    ),
                  ],
                ),
                if (entry.comment.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    entry.comment,
                    style: AppText.body(
                      size: 14,
                      color: AppColors.green.withOpacity(0.75),
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: AppText.button(size: 14, color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecor.card(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _rankBadge(),
                const SizedBox(width: 12),
                _thumbnail(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.playerName,
                        style: AppText.button(size: 15, color: AppColors.green),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.comment.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.comment,
                          style: AppText.body(
                            size: 13,
                            color: AppColors.green.withOpacity(0.65),
                            weight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.score}',
                  style: AppText.heading(size: 22, color: AppColors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
