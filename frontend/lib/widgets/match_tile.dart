import 'package:flutter/material.dart';
import '../core/models/match_history.dart';

class MatchTile extends StatelessWidget {
  final MatchHistory match;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  const MatchTile({required this.match, this.onTap, this.onViewDetails, super.key});

  Color _badgeColor(String winner) {
    if (winner == 'A') return const Color(0xFF4CAF50); // green
    if (winner == 'B') return const Color(0xFFEF5350); // red
    return const Color(0xFF90A4AE); // grey/blue
  }

  String _badgeText() {
    if (match.winner == 'A') return 'WIN';
    if (match.winner == 'B') return 'LOSS';
    return 'DRAW';
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().toUtc().difference(dt.toUtc());
    if (d.inDays >= 1) return '${d.inDays} day${d.inDays > 1 ? 's' : ''} ago';
    if (d.inHours >= 1) return '${d.inHours} hour${d.inHours > 1 ? 's' : ''} ago';
    if (d.inMinutes >= 1) return '${d.inMinutes} min ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final opponent = match.playerB.isNotEmpty ? match.playerB : match.playerA;
    final matchesPlayed = (match.moveCount % 5) + 1; // small derived stat

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // icon circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events, color: Color(0xFFFB8C00)),
                ),
                const SizedBox(width: 12),
                // main texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('vs $opponent',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _badgeColor(match.winner),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _badgeText(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined, size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text('Matches played: $matchesPlayed', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text('Room created: ${match.startedAt.toLocal().toString().split('.').first}',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
                // right column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_timeAgo(match.startedAt), style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onViewDetails,
                      child: const Text('View Details', style: TextStyle(color: Color(0xFF1976D2))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
