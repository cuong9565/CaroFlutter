import 'dart:async';

import '../models/match_history.dart';

class HistoryService {
  // Simulate network delay and return fake data
  Future<List<MatchHistory>> fetchHistory({int page = 1, int pageSize = 30}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now().toUtc();
    return List<MatchHistory>.generate(12, (i) {
      final started = now.subtract(Duration(days: i, minutes: i * 5 + 3));
      final ended = started.add(Duration(minutes: 10 + i));
      final id = 'match-${page}-${i}';
      final playerA = 'Minh${i}';
      final playerB = 'An${i}';
      final winner = (i % 3 == 0) ? 'A' : (i % 3 == 1) ? 'B' : 'draw';
      final moves = List<String>.generate(10 + i, (m) => 'M${m + 1}');
      return MatchHistory(
        id: id,
        startedAt: started,
        endedAt: ended,
        playerA: playerA,
        playerB: playerB,
        winner: winner,
        moves: moves,
        rows: 15,
        cols: 15,
        resultSummary: winner == 'draw' ? 'Hoà' : (winner == 'A' ? 'Thắng $playerA' : 'Thắng $playerB'),
        roomId: 'room-$id',
      );
    });
  }

  Future<void> deleteMatch(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // fake delete
    return;
  }

  Future<MatchHistory?> getMatchById(String id) async {
    final list = await fetchHistory();
    try {
      return list.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
