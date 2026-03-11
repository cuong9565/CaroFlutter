import 'package:frontend/core/services/service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message_model.dart';
class SocketService {
  static final String _apiUrl = Service.apiUrl;

  static late io.Socket socket;

  static void init() {
    socket = io.io(
      _apiUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Socket Connected: ${socket.id}');
    });

    // Khi mất kết nối
    socket.onDisconnect((_) {
      print('Socket Disconnected');
    });

    // Khi lỗi
    socket.onConnectError((data) {
      print('Socket Connect Error: $data');
    });
    socket.onError((data) {
      print('Socket Error: $data');
    });
  }

  void Function(Message)? onMessageReceived;
  void Function(String, String)? onTyping; 
  void Function(String, bool)? onUserStatusChanged;  // userId, isOnline

  void sendMessage(Message message) {
    socket.emit('send_message', message.toJson());
  }

  void joinConversation(String conversationId) {
    socket.emit('join_conversation', { 'conversationId': conversationId });
  }

  void sendTyping(String conversationId, String userId, bool isTyping) {
    socket.emit('typing', { 'conversationId': conversationId, 'userId': userId, 'isTyping': isTyping });
  }

  static void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}
