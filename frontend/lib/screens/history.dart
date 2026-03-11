import 'package:flutter/material.dart';

import '../core/models/match_history.dart';
import '../core/services/history_service.dart';
import '../widgets/match_tile.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final HistoryService _service = HistoryService();
  late Future<List<MatchHistory>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.fetchHistory(page: 1, pageSize: 30);
    setState(() {});
  }

  Future<void> _refresh() async {
    _load();
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Header card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Match History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text('Review your past games and performance', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // list
            Expanded(
              child: FutureBuilder<List<MatchHistory>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(child: Text('Chưa có trận đấu nào'));
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final m = list[i];
                      return MatchTile(
                        match: m,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => _DetailPlaceholder(match: m)));
                        },
                        onViewDetails: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => _DetailPlaceholder(match: m)));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  final MatchHistory match;
  const _DetailPlaceholder({required this.match, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết trận đấu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${match.id}'),
            const SizedBox(height: 8),
            Text('Players: ${match.playerA} vs ${match.playerB}'),
            const SizedBox(height: 8),
            Text('Result: ${match.resultSummary}'),
            const SizedBox(height: 8),
            Text('Moves (${match.moveCount}): ${match.moves.join(', ')}'),
          ],
        ),
      ),
    );
  }
}