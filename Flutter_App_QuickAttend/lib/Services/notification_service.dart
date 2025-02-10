import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';



class NotificationService{

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@drawable/ic_launcher_monochrome");

    const DarwinInitializationSettings iOSinitializationSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSinitializationSettings,
    );


    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    //await flutterLocalNotificationsPlugin
    //    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() ?.requestExactAlarmsPermission();
    
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) {
        debugPrint('Schedule Exact Alarm permission granted');
        return;
      }
      final result = await Permission.scheduleExactAlarm.request();
      if (result.isGranted) {
        debugPrint('Schedule Exact Alarm permission granted');
        return;
      }
      debugPrint('Schedule Exact Alarm permission denied');
    }

  }


  static Future<void> showInstantNotification(String title, String body) async{

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id", 
        "channel_Name",
             importance: Importance.max,
             priority: Priority.max
        ),
        iOS: DarwinNotificationDetails()
    );
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> scheduleNotification(String title, String body, DateTime scheduledDate) async{

    //debugPrint("Scheduled time : $scheduledDate");

    //debugPrint('tz.local :${tz.local}');
    //debugPrint('tz.TZDateTime :${tz.TZDateTime(tz.local)}');

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id", 
        "channel_Name",
             importance: Importance.max,
             priority: Priority.max
        ),
        iOS: DarwinNotificationDetails()
    );
    //debugPrint("notification time : ${tz.TZDateTime.from(scheduledDate, tz.local)}");
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body, tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
  }


  static Future<void> scheduleDailyNotification(
    String title, String body, TimeOfDay time) async {
  // Get the current local time
  final now = DateTime.now();

  debugPrint('Current Time (local): $now');

  // Create a scheduled time based on the selected TimeOfDay in local time
  final scheduledLocalTime = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  debugPrint('Scheduled Time (local): $scheduledLocalTime');

  // If the scheduled time is in the past, move it to the next day
  final adjustedLocalTime = scheduledLocalTime.isBefore(now)
      ? scheduledLocalTime.add(const Duration(days: 1))
      : scheduledLocalTime;

  debugPrint('Adjusted Scheduled Time (local): $adjustedLocalTime');
  debugPrint('tz.local: ${tz.local}');
  // Convert local time to UTC for notification scheduling
  final notificationTime = tz.TZDateTime.from(
    adjustedLocalTime,
    tz.local,
  );

  debugPrint('Notification Time (UTC): $notificationTime');

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      "daily_channel",
      "Daily Notifications",
      importance: Importance.max,
      priority: Priority.max,
    ),
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    notificationTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

static Future<void> cancelAllNotifications() async {

  await flutterLocalNotificationsPlugin.cancelAll();

}


}