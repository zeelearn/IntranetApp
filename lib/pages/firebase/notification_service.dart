import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';
import 'DetailsPage.dart';



class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
  NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channelId = "1";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final AndroidNotificationDetails _androidNotificationDetails =
  AndroidNotificationDetails(
    channelId,
    "Intranet",
    channelDescription:
    "This channel is responsible for all the local notifications",
    playSound: true,
    icon: '@mipmap/ic_launcher',
    priority: Priority.high,
    importance: Importance.high,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
  DarwinNotificationDetails();

  final NotificationDetails notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iOSNotificationDetails,
  );

  Future<void> init() async {
    final AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("ic_launcher");

    final DarwinInitializationSettings iOSInitializationSettings =
    DarwinInitializationSettings(
      defaultPresentAlert: false,
      defaultPresentBadge: false,
      defaultPresentSound: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    // *** Initialize timezone here ***
    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    print(FirebaseMessaging.instance.getToken());
  }

  Future<void> requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification(
      int id, String title, String body, String payload) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification(int id, String title, String body,
      DateTime eventDate, TimeOfDay eventTime, String payload,
      [DateTimeComponents? dateTimeComponents]) async {
    final scheduledTime = eventDate.add(Duration(
      hours: eventTime.hour,
      minutes: eventTime.minute,
    ));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: payload,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

Future<void> onSelectNotification(String? payload) async {
  await navigatorKey.currentState
      ?.push(MaterialPageRoute(builder: (_) => DetailsPage(payload: payload)));
}