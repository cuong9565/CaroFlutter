class MatchHistory {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final String playerA;
  final String playerB;
  final String winner; // 'A' | 'B' | 'draw'
  final List<String> moves;
  final int rows;
  final int cols;
  final String resultSummary;
  final String roomId;

  MatchHistory({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.playerA,
    required this.playerB,
    required this.winner,
    required this.moves,
    required this.rows,
    required this.cols,
    required this.resultSummary,
    required this.roomId,
  });

  factory MatchHistory.fromJson(Map<String, dynamic> j) {
    return MatchHistory(
      id: j['id']?.toString() ?? '',
      startedAt: j['startedAt'] != null
          ? DateTime.parse(j['startedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: j['endedAt'] != null
          ? DateTime.parse(j['endedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      playerA: j['playerA'] ?? '',
      playerB: j['playerB'] ?? '',
      winner: j['winner'] ?? 'draw',
      moves: j['moves'] != null ? List<String>.from(j['moves']) : <String>[],
      rows: j['rows'] ?? 15,
      cols: j['cols'] ?? 15,
      resultSummary: j['resultSummary'] ?? '',
      roomId: j['roomId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'playerA': playerA,
        'playerB': playerB,
        'winner': winner,
        'moves': moves,
        'rows': rows,
        'cols': cols,
        'resultSummary': resultSummary,
        'roomId': roomId,
      };

  int get durationSeconds => endedAt.difference(startedAt).inSeconds;

  int get moveCount => moves.length;

  MatchHistory copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    String? playerA,
    String? playerB,
    String? winner,
    List<String>? moves,
    int? rows,
    int? cols,
    String? resultSummary,
    String? roomId,
  }) {
    return MatchHistory(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      playerA: playerA ?? this.playerA,
      playerB: playerB ?? this.playerB,
      winner: winner ?? this.winner,
      moves: moves ?? this.moves,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      resultSummary: resultSummary ?? this.resultSummary,
      roomId: roomId ?? this.roomId,
    );
  }
}
