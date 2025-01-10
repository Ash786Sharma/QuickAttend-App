import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:quickattend/Services/notification_service.dart';
import 'package:quickattend/Services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'routes.dart';
import 'Utils/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization
  SocketService();
  tz.initializeTimeZones();
  await NotificationService.init();
  const storage = FlutterSecureStorage();
  final String initialRoute;
  try {
    // Read token safely with proper null handling
    final token = await storage.read(key: 'jwt_token');
    if(token != null && token.isNotEmpty){
      bool hasExpired = JwtDecoder.isExpired(token);
      debugPrint('$hasExpired');
      if(hasExpired) await storage.delete(key: 'jwt_token');
      initialRoute = (!hasExpired) ? '/home' : '/login';
      debugPrint(token);
    }else {
      initialRoute = '/login';
    }

    runApp(MyApp(initialRoute: initialRoute));
  } catch (e) {
    // Handle potential errors during storage read
    runApp(const MyApp(initialRoute: '/login'));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Attend',
      theme: AppColorScheme.lightTheme,
      darkTheme: AppColorScheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switch between light and dark
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
