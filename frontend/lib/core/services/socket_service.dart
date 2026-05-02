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

  static void sendMessage(String conversationId, String content, String senderId) {
    emit('send_message', {
      'conversationId': conversationId,
      'content': content,
      'senderId': senderId,
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
}
