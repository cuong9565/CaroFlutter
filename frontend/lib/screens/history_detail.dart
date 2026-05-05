import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/notifiers/user_notifier.dart';
import 'package:frontend/core/services/history_service.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HistoryDetail extends ConsumerStatefulWidget {
  final String roomId;
  const HistoryDetail({super.key, required this.roomId});

  @override
  ConsumerState<HistoryDetail> createState() => _HistoryDetailState();
}

class _HistoryDetailState extends ConsumerState<HistoryDetail> {
  List<dynamic>? _matches;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
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
      final matches = await HistoryService.getRoomMatches(widget.roomId, userId);
      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading history matches: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng đấu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches == null || _matches!.isEmpty
              ? const Center(child: Text('Không có dữ liệu trận đấu'))
              : RefreshIndicator(
                  onRefresh: _loadMatches,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _matches!.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final match = _matches![index];
                      final result = match['result'] as String;
                      final time = DateTime.parse(match['timeCreate']).toLocal();

                      Color resultColor = Colors.grey;
                      IconData resultIcon = FontAwesomeIcons.minus;
                      String resultText = 'Hòa';

                      if (result == 'WIN') {
                        resultColor = Colors.green;
                        resultIcon = FontAwesomeIcons.trophy;
                        resultText = 'Thắng';
                      } else if (result == 'LOOSE') {
                        resultColor = Colors.red;
                        resultIcon = FontAwesomeIcons.skull;
                        resultText = 'Thua';
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: resultColor.withValues(alpha: 0.1),
                          child: Icon(resultIcon, color: resultColor, size: 16),
                        ),
                        title: Text('Trận ${index + 1} - $resultText'),
                        subtitle:
                            Text(DateFormat('HH:mm - dd/MM/yyyy').format(time)),
                        trailing: Text(
                          resultText,
                          style: TextStyle(
                            color: resultColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
