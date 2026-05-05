import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/services/history_service.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:frontend/widgets/charts/linear_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class History extends ConsumerStatefulWidget {
  const History({super.key});

  @override
  ConsumerState<History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  Map<String, dynamic>? _stats;
  List<dynamic>? _rooms;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await UserProvider.storage.read(key: 'uid');
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final stats = await HistoryService.getOverallStats(userId);
      final rooms = await HistoryService.getMatchHistory(userId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_stats == null || _rooms == null) {
      return const Scaffold(body: Center(child: Text("Không thể tải dữ liệu")));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(_stats!),
              _buildStats(_stats!),
              const Text(
                "Lịch sử phòng đấu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildRoomList(_rooms!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tổng số trận",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "Lịch sử đấu",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${stats['total_games'] ?? 0}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> stats) {
    return Column(
      spacing: 15,
      children: [
        _buildModeStats("Chơi với bạn", stats['FRIEND']),
        _buildModeStats("Chơi với máy", stats['AI']),
        _buildModeStats("Chơi Online", stats['ONLINE']),
      ],
    );
  }

  Widget _buildModeStats(String title, Map<String, dynamic>? modeStats) {
    final wins = modeStats?['wins'] ?? 0;
    final losses = modeStats?['losses'] ?? 0;
    final draws = modeStats?['draws'] ?? 0;
    final total = wins + losses + draws;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: LinearChart(
                  title: "Thắng",
                  number: wins,
                  total: total == 0 ? 1 : total,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: LinearChart(
                  title: "Thua",
                  number: losses,
                  total: total == 0 ? 1 : total,
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: LinearChart(
                  title: "Hòa",
                  number: draws,
                  total: total == 0 ? 1 : total,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomList(List<dynamic> rooms) {
    if (rooms.isEmpty) {
      return const Center(child: Text("Chưa có trận đấu nào"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final gameMode = room['gameMode'] as String;
        final opponent = (room['opponent'] ?? 'Unknown') as String;
        final wins = room['wins'] as int;
        final losses = room['losses'] as int;
        final draws = room['draws'] as int;
        final raw = room['timeCreate'];
        final fixed = raw.replaceFirst(' ', 'T'); // thêm chữ T
        final time = DateTime.parse(fixed).toLocal();
        
        IconData modeIcon = FontAwesomeIcons.userGroup;
        if (gameMode == 'AI') modeIcon = FontAwesomeIcons.robot;
        if (gameMode == 'ONLINE') modeIcon = FontAwesomeIcons.globe;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () => context.push('/history/${room['id']}'),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Icon(modeIcon, size: 18, color: Colors.blue),
            ),
            title: Text(
              opponent,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${DateFormat('dd/MM/yyyy HH:mm').format(time)}\nThắng: $wins | Thua: $losses | Hòa: $draws",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}