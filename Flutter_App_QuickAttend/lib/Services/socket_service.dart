import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../Utils/constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  Map<String, dynamic>? userData;

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
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(3000)
          .build(),
    );

    socket.onConnect((_) async {
      debugPrint("Connected to Socket.IO server");
      final FlutterSecureStorage storage = const FlutterSecureStorage();
      final userToken = await storage.read(key: 'jwt_token');
    if (userToken != null) {
      try {
        final userMap = JwtDecoder.decode(userToken);
        userData = await userMap['userData'];
        //debugPrint('$userData');
        SocketService().emit('register_user', (userData?['employeeId']));
      } catch (e) {
        debugPrint('Error decoding userJson: $e');
      }
    }
    });

    socket.onDisconnect((_) {
      debugPrint("Disconnected from Socket.IO server");
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
