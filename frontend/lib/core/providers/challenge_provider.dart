import 'package:flutter/material.dart';
import 'package:frontend/core/providers/user_provider.dart';
import 'package:frontend/core/services/socket_service.dart';
import 'package:frontend/widgets/router.dart';

class ChallengeProvider with ChangeNotifier {
  bool _isInitialized = false;
  bool _isDialogOpen = false;
  String _currentUserId = '';

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    await _ensureUserId();
    _initSocket();
    _isInitialized = true;
  }

  Future<void> _ensureUserId() async {
    if (_currentUserId.isNotEmpty) {
      return;
    }
    final data = await UserProvider.loadUser();
    final user = data['user'];
    final userId = (user is Map) ? user['id']?.toString() : null;
    if (userId != null && userId.isNotEmpty) {
      _currentUserId = userId;
    }
  }

  void _initSocket() {
    if (_currentUserId.isEmpty) {
      return;
    }
    SocketService.init(_currentUserId);
    SocketService.off('challenge-received');
    SocketService.off('challenge-start');
    SocketService.off('challenge-error');
    SocketService.off('challenge-rejected');

    SocketService.on('challenge-received', (data) {
      final roomId = data['roomId']?.toString() ?? '';
      final requesterName = data['requesterName']?.toString() ?? 'Nguoi choi';
      if (roomId.isEmpty) {
        return;
      }
      _showChallengeDialog(roomId, requesterName);
    });

    SocketService.on('challenge-start', (data) {
      final roomId = data['roomId']?.toString();
      if (roomId != null && roomId.isNotEmpty) {
        router.go('/play/$roomId');
      }
    });

    SocketService.on('challenge-error', (data) {
      final message = data['message']?.toString() ?? 'Không gửi được thách đấu';
      _showSnackBar(message);
    });

    SocketService.on('challenge-rejected', (data) {
      _showSnackBar('Lời mời thách đấu bị từ chối');
    });
  }

  Future<void> sendChallenge(String targetId) async {
    await _ensureUserId();
    if (_currentUserId.isEmpty) {
      throw Exception('Missing user id');
    }
    SocketService.init(_currentUserId);
    SocketService.emit('challenge-request', {
      'requesterId': _currentUserId,
      'targetId': targetId,
    });
    _showSnackBar('Đã gửi lời mời thách đấu');
  }

  void _showChallengeDialog(String roomId, String requesterName) {
    if (_isDialogOpen) {
      return;
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thách đấu'),
          content: Text('$requesterName muốn thách đâu bạn. Chấp nhận?'),
          actions: [
            TextButton(
              onPressed: () {
                SocketService.emit('challenge-reject', {
                  'roomId': roomId,
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Từ chối'),
            ),
            TextButton(
              onPressed: () {
                SocketService.emit('challenge-accept', {
                  'roomId': roomId,
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      _isDialogOpen = false;
    });
  }

  void _showSnackBar(String message) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
