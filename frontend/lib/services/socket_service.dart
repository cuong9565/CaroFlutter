import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/UserModel.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // Callbacks
  Function(Message)? onMessageReceived;
  Function(String conversationId, String userId)? onTyping;
  Function(String userId, bool isOnline)? onUserStatusChanged;
  Function(bool)? onConnectionChanged;

  bool get isConnected => _isConnected;

  void connect(String serverUrl, String userId) {
    if (_socket != null && _isConnected) {
      return;
    }

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'userId': userId})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to socket server');
      _isConnected = true;
      onConnectionChanged?.call(true);
      
      // Join user's room
      _socket!.emit('user:join', {'userId': userId});
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from socket server');
      _isConnected = false;
      onConnectionChanged?.call(false);
    });

    _socket!.on('message:new', (data) {
      try {
        final message = Message.fromJson(data);
        onMessageReceived?.call(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });

    _socket!.on('user:typing', (data) {
      try {
        final conversationId = data['conversationId'] as String;
        final userId = data['userId'] as String;
        onTyping?.call(conversationId, userId);
      } catch (e) {
        print('Error parsing typing event: $e');
      }
    });

    _socket!.on('user:status', (data) {
      try {
        final userId = data['userId'] as String;
        final isOnline = data['isOnline'] as bool;
        onUserStatusChanged?.call(userId, isOnline);
      } catch (e) {
        print('Error parsing user status: $e');
      }
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });
  }

  void sendMessage(Message message) {
    if (_socket != null && _isConnected) {
      _socket!.emit('message:send', message.toJson());
    } else {
      print('Socket not connected');
    }
  }

  void sendTyping(String conversationId, String userId, bool isTyping) {
    if (_socket != null && _isConnected) {
      _socket!.emit('user:typing', {
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
      });
    }
  }

  void markAsRead(String conversationId, String messageId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('message:read', {
        'conversationId': conversationId,
        'messageId': messageId,
      });
    }
  }

  void joinConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('conversation:join', {'conversationId': conversationId});
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('conversation:leave', {'conversationId': conversationId});
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }
}
