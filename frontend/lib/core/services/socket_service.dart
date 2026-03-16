import 'package:frontend/core/services/service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message_model.dart';
class SocketService {
  static final String _apiUrl = Service.apiUrl;

  static late io.Socket socket;

  static void init(String userId) {
    socket = io.io(
      _apiUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'userId': userId})
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

  static void disconnect() {
    socket.disconnect();
  }

  static void sendMessage(String conversationId, String content, String senderId) {
    socket.emit('send_message', {'conversationId': conversationId, 'content': content, 'senderId': senderId});
  }

  static void joinConversation(String conversationId) {
    socket.emit('join_conversation', {'conversationId': conversationId});
  }

  static void sendTyping(String conversationId, String userId, bool isTyping) {
    socket.emit('typing', {'conversationId': conversationId, 'isTyping': isTyping, 'senderId': userId});
  }

  static void onNewMessage(Function(Message) callback) {
    socket.on('new_message', (data) {
      callback(Message.fromJson(data));
    });
  }

  static void onConversationHistory(Function(List<Message>) callback) {
    socket.on('conversation_history', (data) {
      callback((data as List).map((m) => Message.fromJson(m)).toList());
    });
  }
}
