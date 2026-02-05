import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> initialize();
  Future<bool> hasNotificationPermission();
  Future<bool> requestNotificationPermission();
  Future<void> scheduleNudgeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  });
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
}

class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  @override
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await initialize();
    final status = await Permission.notification.request();

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    }

    return status.isGranted;
  }

  @override
  Future<void> scheduleNudgeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await initialize();
    final scheduled = tz.TZDateTime.from(scheduledTime, tz.local);
    const androidDetails = AndroidNotificationDetails(
      'nudges',
      'Nudges',
      channelDescription: 'Light reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
