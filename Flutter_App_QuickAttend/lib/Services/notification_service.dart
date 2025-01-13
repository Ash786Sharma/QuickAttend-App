import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;



class NotificationService{

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@drawable/ic_notification");

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

    //print("Scheduled time : $scheduledDate");

    //print('tz.local :${tz.local}');
    //print('tz.TZDateTime :${tz.TZDateTime(tz.local)}');

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id", 
        "channel_Name",
             importance: Importance.max,
             priority: Priority.max
        ),
        iOS: DarwinNotificationDetails()
    );
    //print("notification time : ${tz.TZDateTime.from(scheduledDate, tz.local)}");
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body, tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
  }


  static Future<void> scheduleDailyNotification(
    String title, String body, TimeOfDay time) async {
  // Get the current local time
  final now = DateTime.now();

  //print('Current Time (local): $now');

  // Create a scheduled time based on the selected TimeOfDay in local time
  final scheduledLocalTime = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  //print('Scheduled Time (local): $scheduledLocalTime');

  // If the scheduled time is in the past, move it to the next day
  final adjustedLocalTime = scheduledLocalTime.isBefore(now)
      ? scheduledLocalTime.add(const Duration(days: 1))
      : scheduledLocalTime;

  //print('Adjusted Scheduled Time (local): $adjustedLocalTime');

  // Convert local time to UTC for notification scheduling
  final notificationTime = tz.TZDateTime.from(
    adjustedLocalTime,
    tz.local,
  );

  //print('Notification Time (UTC): $notificationTime');

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