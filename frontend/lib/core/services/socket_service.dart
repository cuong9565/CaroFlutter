import 'package:frontend/core/services/service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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

  static void disconnect() {
    socket.disconnect();
    socket.dispose();
  }
}
