import 'package:frontend/core/services/service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message_model.dart';

class SocketService {
  static final String _apiUrl = Service.apiUrl;

  static io.Socket? _socket;
  static String? _currentUserId;

  static bool get isInitialized => _socket != null;
  static io.Socket? get socket => _socket;

  static void init(String userId) {
    if (_socket != null && _currentUserId == userId) {
      if (!(_socket!.connected)) {
        _socket!.connect();
      }
      return;
    }

    _socket?.disconnect();
    _currentUserId = userId;

    _socket = io.io(
      _apiUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'userId': userId})
          .disableAutoConnect()
          .build(),
    );

    final socket = _socket!;

    socket.connect();

    socket.onConnect((_) {
      print('Socket Connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('Socket Disconnected');
    });

    socket.onConnectError((data) {
      print('Socket Connect Error: $data');
    });
    socket.onError((data) {
      print('Socket Error: $data');
    });
  }

  static void disconnect() {
    _socket?.disconnect();
  }

  static void emit(String event, [dynamic data]) {
    if (data == null) {
      _socket?.emit(event);
      return;
    }
    _socket?.emit(event, data);
  }

  static void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  static void once(String event, Function(dynamic) callback) {
    _socket?.once(event, callback);
  }

  static void off(String event, [Function(dynamic)? callback]) {
    if (callback == null) {
      _socket?.off(event);
      return;
    }
    _socket?.off(event, callback);
  }

  static void onConnect(Function(dynamic) callback) {
    _socket?.onConnect(callback);
  }

  static void onDisconnect(Function(dynamic) callback) {
    _socket?.onDisconnect(callback);
  }

  static void onConnectError(Function(dynamic) callback) {
    _socket?.onConnectError(callback);
  }

  static void onError(Function(dynamic) callback) {
    _socket?.onError(callback);
  }

  static String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    final micro = local.microsecond.toString().padLeft(6, '0');
    return '$year-$month-$day $hour:$minute:$second.$micro';
  }

  static void sendMessage(
    String conversationId,
    String content,
    String senderId, {
    DateTime? timestamp,
  }) {
    emit('send_message', {
      'conversationId': conversationId,
      'content': content,
      'senderId': senderId,
      'timestamp': _formatTimestamp(timestamp ?? DateTime.now()),
    });
  }

  static void joinConversation(String conversationId) {
    emit('join_conversation', {'conversationId': conversationId});
  }

  static void sendTyping(String conversationId, String userId, bool isTyping) {
    emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
      'senderId': userId,
    });
  }

  static void onNewMessage(Function(Message) callback) {
    off('new_message');
    on('new_message', (data) {
      callback(Message.fromJson(data));
    });
  }

  static void onConversationHistory(Function(List<Message>) callback) {
    off('conversation_history');
    on('conversation_history', (data) {
      callback((data as List).map((m) => Message.fromJson(m)).toList());
    });
  }

  static void onFriendRequestReceived(Function(dynamic) callback) {
    off('friend_request_received');
    on('friend_request_received', (data) {
      callback(data);
    });
  }

  static void onFriendRequestAccepted(Function(dynamic) callback) {
    off('friend_request_accepted');
    on('friend_request_accepted', (data) {
      callback(data);
    });
  }
}
