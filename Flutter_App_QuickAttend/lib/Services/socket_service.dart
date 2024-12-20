import '../Utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) async {
      print("Connected to Socket.IO server");
    });

    socket.onDisconnect((_) {
      print("Disconnected from Socket.IO server");
    });
  }

  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    socket.dispose();
  }
}
