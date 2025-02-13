import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize Android settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);

    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

  }

  static Future<void> showNotification(
      int id, String title, String body, DateTime scheduleTime) async {
    // Ensure the scheduled time is in the future
    if (scheduleTime.isBefore(DateTime.now())) {
      return; // Don't schedule for past times
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      // Use local time for scheduling
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for Android 12+
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
