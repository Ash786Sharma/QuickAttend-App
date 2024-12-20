import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/apply_attendance_screen.dart';
import 'package:flutter_application_1/Screens/delete_user_screen.dart';
import 'package:flutter_application_1/Screens/report_generation_screen.dart';
import 'package:flutter_application_1/Screens/set_weeklyoffs_screen.dart';
import 'Screens/set_holiday_screen.dart';
import 'Screens/admin_screen.dart';
import 'Screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'Screens/update_user_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/admin-settings': (context) => const AdminSettingsScreen(),
        '/set-holiday': (context) => const SetHolidayScreen(),
        '/set-weekly-offs': (context) => const SetWeeklyOffScreen(),
        '/apply-attendance': (context) => const ApplyAttendanceScreen(),
        '/update-user': (context) => const UpdateUserScreen(),
        '/delete-user': (context) => const DeleteUserScreen(),
        '/generate-report': (context) => const ReportGenerationScreen()
      };
}
