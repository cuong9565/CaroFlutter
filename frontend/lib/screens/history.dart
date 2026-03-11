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
    // Không gọi setState trong quá trình khởi tạo
    _future = _service.fetchHistory(page: 1, pageSize: 30);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.fetchHistory(page: 1, pageSize: 30);
    });
    await _future;
  }

  void _goToDetails(MatchHistory match) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _DetailPlaceholder(match: match)),
    );
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
        // Dùng CustomScrollView để toàn bộ màn hình có thể pull-to-refresh mượt mà
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
            ),
            
            FutureBuilder<List<MatchHistory>>(
              future: _future,
              builder: (context, snapshot) {
                // SỬA LỖI UX: Chỉ hiện loading spinner khi KHÔNG CÓ DATA cũ
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Lỗi: ${snapshot.error}')),
                  );
                }
                
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Chưa có trận đấu nào')),
                  );
                }
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final m = list[i];
                      return MatchTile(
                        match: m,
                        onTap: () => _goToDetails(m),
                        onViewDetails: () => _goToDetails(m),
                      );
                    },
                    childCount: list.length,
                  ),
                );
              },
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