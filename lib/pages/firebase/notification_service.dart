import 'dart:convert';
import 'dart:io';

import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/utils.dart';
import '../model/bpms_notification_model.dart';
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
    debugPrint(
        'Remote message for simple message is Notification_service - $message');
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
        'bigimage': message != null ? (message.data['bigimage'] ?? '') : '',
        'webViewLink':
            message != null ? (message.data['webViewLink'] ?? '') : '',
        'id': message != null ? (message.data['id'] ?? '') : '',
        'employee_code':
            message != null ? (message.data['employee_code'] ?? '') : ''
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
              'bigimage':
                  message != null ? (message.data['bigimage'] ?? '') : '',
              'id': message != null ? (message.data['id'] ?? '') : '',
              'employee_code':
                  message != null ? (message.data['employee_code'] ?? '') : ''
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
              'bigimage':
                  message != null ? (message.data['bigimage'] ?? '') : '',
              'id': message != null ? (message.data['id'] ?? '') : '',
              'employee_code':
                  message != null ? (message.data['employee_code'] ?? '') : ''
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
      // androidAllowWhileIdle: true,
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

  void parseNotification(RemoteMessage message) {
    print('parse Notification 217');
    String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    String? imsageUrl = '';
    if (kIsWeb) {
      print('its web Notification 220');
    } else if (Platform.isAndroid) {
      imsageUrl = message.notification?.android?.imageUrl.toString();
    } else if (Platform.isIOS) {
      imsageUrl = message.notification?.apple?.imageUrl.toString();
    }
    DBHelper helper = DBHelper();
    Map<String, String> data = {};
    if (message.notification != null) {
      print('its simple Notification 12');
      data.putIfAbsent('title', () => message.notification?.title as String);
      data.putIfAbsent(
          'description', () => message.notification?.body as String);
      data.putIfAbsent('type', () => 'push');
      data.putIfAbsent('date', () => cdate);
      data.putIfAbsent('imageurl', () => imsageUrl as String);
      data.putIfAbsent(
          'logoUrl',
          () => message.data.containsKey('logo')
              ? message.data['logo'] as String
              : '');
      data.putIfAbsent(
          'bigImageUrl',
          () => message.data.containsKey('bigimage')
              ? message.data['bigimage'] as String
              : '');
      data.putIfAbsent(
          'webViewLink',
          () => message.data.containsKey('url')
              ? message.data['url'] as String
              : '');
      helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
      // NotificationService notificationService = NotificationService();
      // notificationService.showSimpleNotification(
      //     message.notification?.title as String,
      //     message.notification?.body as String,
      //     message);
    } else {
      print('its data Notification 143');
      if (message.data.containsKey('type') && message.data['type'] == 'td') {
        print('Identifying notification');
        identifySaathiNotification(message);
      } else if (message.data.containsKey('topic')) {
        print('Identifying notification');
        identifyNotification(message);
      } else {
        data.putIfAbsent('title', () => message.data['title']);
        data.putIfAbsent('description', () => message.data['body']);
        data.putIfAbsent(
            'type',
            () => message.data.containsKey('type')
                ? message.data['type']
                : 'push');
        data.putIfAbsent('date', () => cdate);
        data.putIfAbsent(
            'imageurl',
            () => message.data.containsKey('imageurl')
                ? message.data['imageurl']
                : '');
        data.putIfAbsent(
            'logoUrl',
            () => message.data.containsKey('logoUrl')
                ? message.data['logoUrl']
                : '');
        data.putIfAbsent(
            'bigImageUrl',
            () => message.data.containsKey('bigimage')
                ? message.data['bigimage'] as String
                : '');
        data.putIfAbsent(
            'webViewLink',
            () => message.data.containsKey('url')
                ? message.data['url'] as String
                : '');
        helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
        print('insert in database ${data}');
        if (message.data.containsKey('type') &&
            message.data['type'] == 'BPMS') {
          BpmsNotificationModelList list = BpmsNotificationModelList.fromJson(
            json.decode(
                    '{"data":${message.data['body'].toString().replaceAll(',]', ']')}}')
                as Map<String, dynamic>,
          );
          NotificationService notificationService = NotificationService();
          notificationService.showSimpleNotification(
              message.data['title'], list.getBody(), message);
        } else if (message.data.containsKey('topic') &&
            message.data['topic'] != '') {
          //identifyNotification(message);
          //showNotification(message);
          NotificationService notificationService = NotificationService();
          notificationService.showSimpleNotification(
              message.data['title'], message.data['body'], message);
        } else {
          //showNotification(message);
          NotificationService notificationService = NotificationService();
          notificationService.showSimpleNotification(
              message.data['title'], message.data['body'], message);
        }
      }
    }
  }
}

void identifySaathiNotification(RemoteMessage message, [WidgetRef? ref]) async {
  var hiveBox = await Utility.openBox();
  var hive = Hive.box(LocalConstant.KidzeeDB);
  String employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
  print(' 291 Intranet user Name ${employeeCode}');
  if (employeeCode.isNotEmpty &&
      message.data.containsKey('employee_code') &&
      message.data['employee_code'] == employeeCode) {
    DBHelper helper = DBHelper();
    Map<String, String> data = {};
    String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    data.putIfAbsent('title', () => message.data['title']);
    data.putIfAbsent('description', () => message.data['body']);
    data.putIfAbsent('type',
        () => message.data.containsKey('type') ? message.data['type'] : 'push');
    data.putIfAbsent('date', () => cdate);
    data.putIfAbsent(
        'imageurl',
        () => message.data.containsKey('imageurl')
            ? message.data['imageurl']
            : '');
    data.putIfAbsent(
        'logoUrl',
        () =>
            message.data.containsKey('logoUrl') ? message.data['logoUrl'] : '');
    data.putIfAbsent(
        'bigImageUrl',
        () => message.data.containsKey('bigimage')
            ? message.data['bigimage'] as String
            : '');
    data.putIfAbsent(
        'webViewLink',
        () =>
            message.data.containsKey('id') ? message.data['id'] as String : '');
    helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
    NotificationService notificationService = NotificationService();
    notificationService.showSimpleNotification(
        message.data['title'], message.data['body'], message);
  }
}

void identifyNotification(RemoteMessage message, [WidgetRef? ref]) async {
  var box = await Utility.openBox();
  String userName = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
  print('Intranet user Name ${userName}');
  if (userName.isNotEmpty &&
      message.data.containsKey('user_id') &&
      message.data['user_id'] == userName) {
    print('notificaiton found...');
    DBHelper helper = DBHelper();
    Map<String, String> data = {};
    String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    data.putIfAbsent('title', () => message.data['title']);
    data.putIfAbsent('description', () => message.data['body']);
    data.putIfAbsent('type',
        () => message.data.containsKey('type') ? message.data['type'] : 'push');
    data.putIfAbsent('date', () => cdate);
    data.putIfAbsent(
        'imageurl',
        () => message.data.containsKey('imageurl')
            ? message.data['imageurl']
            : '');
    data.putIfAbsent(
        'logoUrl',
        () =>
            message.data.containsKey('logoUrl') ? message.data['logoUrl'] : '');
    data.putIfAbsent(
        'bigImageUrl',
        () => message.data.containsKey('bigimage')
            ? message.data['bigimage'] as String
            : '');
    data.putIfAbsent(
        'webViewLink',
        () => message.data.containsKey('url')
            ? message.data['url'] as String
            : '');
    helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
    if (message.data.containsKey('type') && message.data['type'] == 'BPMS') {
      BpmsNotificationModelList list = BpmsNotificationModelList.fromJson(
        json.decode(
                '{"data":${message.data['body'].toString().replaceAll(',]', ']')}}')
            as Map<String, dynamic>,
      );
      NotificationService notificationService = NotificationService();
      notificationService.showSimpleNotification(
          message.data['title'], list.getBody(), message);
    } else if (message.data.containsKey('topic') &&
        message.data['topic'] != '') {
      //identifyNotification(message);
      //showNotification(message);
      NotificationService notificationService = NotificationService();
      notificationService.showSimpleNotification(
          message.data['title'], message.data['body'], message);
    } else {
      //showNotification(message);
      NotificationService notificationService = NotificationService();
      notificationService.showSimpleNotification(
          message.data['title'], message.data['body'], message);
    }
  }
}

Future<void> onSelectNotification(String? payload) async {
  await MyApp.navigatorKey.currentState
      ?.push(MaterialPageRoute(builder: (_) => DetailsPage(payload: payload)));
}
