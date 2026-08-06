import 'dart:convert';
import 'dart:io';

import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/utils/toast_utility.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
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
  }

  showSimpleNotification(String title, String body,
      [RemoteMessage? message]) async {
    String channel = LocalConstant.NOTIFICATION_CHANNEL;
    if (kIsWeb) {
      final url = message?.data['url'] as String?;
      ToastUtilityIntranet.showInfoToast(
        '${message?.data['title'] ?? ''}\n${message?.data['body'] ?? ''}',
        onTap: () async {
          if (url != null && url.isNotEmpty) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
      );
    } else {
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
    }
  }

  showBigNotification(String title, String body, String logo, String imageUrl,
      bool showBigTextNotification,
      [RemoteMessage? message]) async {
    String channel = LocalConstant.NOTIFICATION_CHANNEL;
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

  void parseNotification(
    RemoteMessage message, {
    BuildContext? context,
  }) async {
    debugPrint(
        'parseNotification called in Intranet with message: ${message.data}');
    String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    String? imsageUrl = '';
    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      imsageUrl = message.notification?.android?.imageUrl.toString();
    } else if (Platform.isIOS) {
      imsageUrl = message.notification?.apple?.imageUrl.toString();
    }
    DBHelper helper = DBHelper();
    Map<String, String> data = {};
    if (message.notification != null) {
      debugPrint('parseNotification SKIPPING NOTIFICATION ');
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
      //helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
      // NotificationService notificationService = NotificationService();
      // notificationService.showSimpleNotification(
      //     message.notification?.title as String,
      //     message.notification?.body as String,
      //     message);
    } else {
      if (message.data.containsKey('type') && message.data['type'] == 'td') {
        debugPrint('parseNotification identifySaathiNotification called');
        identifySaathiNotification(message);
      } else if (message.data.containsKey('type') &&
          message.data['type']?.toString().toLowerCase() == 'expense') {
        handleExpenseNotificatin(message);
      } else if (message.data.containsKey('topic')) {
        debugPrint('parseNotification identifyNotification topic called');
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
        //helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
        if (message.data.containsKey('type') &&
            message.data['type'] == 'BPMS') {
          debugPrint(
              'parseNotification BPMS notification detected. Processing body.');
          BpmsNotificationModelList list = BpmsNotificationModelList.fromJson(
            json.decode(
                    '{"data":${message.data['body'].toString().replaceAll(',]', ']')}}')
                as Map<String, dynamic>,
          );
          helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
          NotificationService notificationService = NotificationService();
          notificationService.showSimpleNotification(
              message.data['title'], list.getBody(), message);
        } else if (message.data.containsKey('topic') &&
            message.data['topic'] != '') {
          var hiveBox = await Utility.openBox();

          String employeeCode =
              hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
          String empId = hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
          if ((message.data.containsKey('employee_code') &&
                  message.data['employee_code'] != employeeCode) ||
              (message.data.containsKey('empid') &&
                  message.data['empid'] != empId)) {
            helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
            NotificationService notificationService = NotificationService();
            notificationService.showSimpleNotification(
                message.data['title'], message.data['body'], message);
          } else {
            debugPrint(
                'parseNotification: Employee code or empid does not match. Notification ignored.');
          }
        } else {
          var hiveBox = await Utility.openBox();

          String employeeCode =
              hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
          String empId = hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
          if ((message.data.containsKey('employee_code') &&
                  message.data['employee_code'] == employeeCode) ||
              (message.data.containsKey('empid') &&
                  message.data['empid'] == empId)) {
            //showNotification(message);
            helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
            NotificationService notificationService = NotificationService();
            notificationService.showSimpleNotification(
                message.data['title'], message.data['body'], message);
          } else {
            debugPrint(
                'parseNotification: Employee code or empid does not match. Notification ignored.');
          }
        }
      }
    }
  }
}

void identifySaathiNotification(RemoteMessage message,
    [WidgetRef? ref, BuildContext? context]) async {
  var hiveBox = await Utility.openBox();
  var hive = Hive.box(LocalConstant.KidzeeDB);
  String employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
  if (employeeCode.isNotEmpty &&
      message.data.containsKey('employee_code') &&
      message.data['employee_code'] == employeeCode) {
    debugPrint(
        'identifySaathiNotification: Employee code matches. Processing notification.');
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
  } else {
    debugPrint(
        'identifySaathiNotification: Employee code does not match. Notification ignored.');
  }
}

void handleExpenseNotificatin(
  RemoteMessage message,
) async {
  var hiveBox = await Utility.openBox();

  String employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
  String empId = hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
  if ((message.data.containsKey('employee_code') &&
          message.data['employee_code'] == employeeCode) ||
      (message.data.containsKey('empid') && message.data['empid'] == empId)) {
    DBHelper helper = DBHelper();
    Map<String, String> data = {};
    String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    data.putIfAbsent('title', () => message.data['title']);
    data.putIfAbsent('description', () => message.data['body']);
    data.putIfAbsent('type',
        () => message.data.containsKey('type') ? message.data['type'] : '');
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
    NotificationService notificationService = NotificationService();
    notificationService.showSimpleNotification(
        message.data['title'], message.data['body'], message);
  } else {
    debugPrint(
        'parseNotification: Employee code or empid does not match. Notification ignored.');
  }
}

void identifyNotification(RemoteMessage message, [WidgetRef? ref]) async {
  var box = await Utility.openBox();
  String userName = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
  if (userName.isNotEmpty &&
      message.data.containsKey('user_id') &&
      message.data['user_id'] == userName) {
    debugPrint(
        'identifyNotification: User ID matches. Processing notification.');
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
