import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';
import '../helper/utils.dart';
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

  static final DarwinNotificationDetails _iOSNotificationDetails =
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

    debugPrint(FirebaseMessaging.instance.getToken().toString());
  }

  showSimpleNotification(String title, String body,
      [RemoteMessage? message]) async {
    String channel = LocalConstant.NOTIFICATION_CHANNEL;
    print('showSimpleNotification Kidzee $channel');
    debugPrint('Remote message for simple message is - $message');
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: channel,
          title: title,
          body: Utility.removeAllHtmlTags(body),
          notificationLayout: NotificationLayout.BigText,
          // summary: body,
          autoDismissible: true,
          payload: {
            'url': message != null ? (message.data['url'] ?? '') : '',
            'type': message != null ? (message.data['type'] ?? '') : '',
            'topic': message != null ? (message.data['topic'] ?? '') : '',
            'bigimage': message != null ? (message.data['bigimage'] ?? '') : ''
          },
        ));
    print('showSimpleNotification');
  }


  showBigNotification(String title, String body, String logo, String imageUrl,
      bool showBigTextNotification,
      [RemoteMessage? message]) async {
    String channel = LocalConstant.NOTIFICATION_CHANNEL;
    print('showBigNotification kid $channel');
    if (showBigTextNotification) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1,
            channelKey: 'big_picture',
            title: title,
            body: Utility.removeAllHtmlTags(body),
            badge: 4,
            // summary: body,
            autoDismissible: true,
            icon: 'resource://drawable/app_logo',
            backgroundColor: Colors.white54,
            largeIcon: imageUrl,
            payload: {
              'url': message != null ? (message.data['url'] ?? '') : '',
              'type': message != null ? (message.data['type'] ?? '') : '',
              'topic': message != null ? (message.data['topic'] ?? '') : '',
              'bigimage': message != null ? (message.data['bigimage'] ?? '') : ''
            },
            notificationLayout: NotificationLayout.BigText,
            bigPicture: imageUrl),
      );
    } else {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1,
            channelKey: 'big_picture',
            title: title,
            body: Utility.removeAllHtmlTags(body),
            badge: 4,
            // summary: body,
            autoDismissible: true,
            icon: 'resource://drawable/app_logo',
            backgroundColor: Colors.white54,
            largeIcon: imageUrl,
            notificationLayout: NotificationLayout.BigPicture,
            payload: {
              'url': message != null ? (message.data['url'] ?? '') : '',
              'type': message != null ? (message.data['type'] ?? '') : '',
              'topic': message != null ? (message.data['topic'] ?? '') : '',
              'bigimage': message != null ? (message.data['bigimage'] ?? '') : ''
            },
            bigPicture: imageUrl),
      );
    }
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
      Utility.removeAllHtmlTags(body),
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
  await MyApp.navigatorKey.currentState
      ?.push(MaterialPageRoute(builder: (_) => DetailsPage(payload: payload)));
}