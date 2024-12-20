import 'package:flutter/material.dart';

class AppColorScheme {
  // Light Theme
  static final lightTheme = ThemeData(
    colorScheme: const ColorScheme(
      primary: Color(0xFFE21B5A), // Primary buttons & key actions
      secondary: Color(0xFF9E0C39), // App background
      surface: Color(0xFFFBFFE3), // Cards & containers
      onPrimary: Colors.white, // Text color on primary buttons
      onSecondary: Colors.white, // Text color on secondary buttons
      onSurface: Color(0xFF333333), // Text on background
      error: Colors.red, // Error color
      onError: Colors.white, // Text on error color
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFFBFFE3),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF9E0C39), // AppBar color
      foregroundColor: Colors.white, // Text/Icon color in AppBar
      elevation: 0, // Flat AppBar
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE21B5A), // Button background
        foregroundColor: Colors.white, // Button text color
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF333333)),
      bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF333333)),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    ),
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    colorScheme: const ColorScheme(
      primary: Color(0xFF9E0C39), // Primary buttons & key actions
      secondary: Color(0xFFE21B5A), // App background
      surface: Color(0xFF1E1E1E), // Cards & containers
      onPrimary: Colors.white, // Text color on primary buttons
      onSecondary: Colors.white, // Text color on secondary buttons
      onSurface: Color(0xFFFBFFE3), // Text on background
      error: Colors.red, // Error color
      onError: Colors.white, // Text on error color
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850], // AppBar color
      foregroundColor: Colors.white, // Text/Icon color in AppBar
      elevation: 0, // Flat AppBar
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9E0C39), // Button background
        foregroundColor: Colors.white, // Button text color
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Color(0xFFFBFFE3)),
      bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFFBFFE3)),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFBFFE3),
      ),
    ),
  );
}
