import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, Platform;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:Intranet/pages/firebase/firebase_options.dart';
import 'package:Intranet/pages/firebase/notification_service.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/PermissionHandler.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/intro/splash.dart';
import 'package:Intranet/pages/model/NotificationDataModel.dart';
import 'package:Intranet/pages/notification/UserNotification.dart';
import 'package:Intranet/pages/outdoor/cubit/getplandetailscubit/getplandetails_cubit.dart';
import 'package:Intranet/pages/pjp/cvf/CheckInModel.dart';
import 'package:Intranet/pages/theme/extention.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/widget/VideoPlayer.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:saathi/core/hiveDatabase/hiveConstant.dart';
import 'package:saathi/dependency_Injection/dependency_injection.dart';
import 'package:saathi/model/notificationModel/notificationModel.dart';
import 'package:saathi/model/ticketModel/ticket_model.dart';
import 'package:saathi/zllsaathi.dart';

import 'api/APIService.dart';
import 'api/request/cvf/update_cvf_status_request.dart';
import 'api/request/leave/leave_approve_request.dart';
import 'api/response/apply_leave_response.dart';
import 'api/response/approve_attendance_response.dart';
import 'api/response/cvf/update_status_response.dart';
import 'pages/pjp/cvf/getVisitplannerCvfcubit/cubit/getvisitplannercvf_cubit.dart';

part 'main.g.dart';

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
        name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Handling a background message');
    DBHelper helper = new DBHelper();
    if (message.data != null) {
      debugPrint(message.data.toString());
      String type = "";
      String title = "";
      String imageUrl = "";
      String body = "";
      try {
        String mData = message.data.toString();
        if (!message.data.containsKey("URL")) {
          NotificationActionModel model = NotificationActionModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = '';
          body = model.message;
        } else if (message.data.containsKey('Status')) {
          mData = mData.replaceAll('Purpose:', 'Purpose');
          mData = mData.replaceAll('Status:', 'Status');
          NotificationDataModel model = NotificationDataModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = model.image;
          body = model.message;
          helper.insertNotification(message.messageId as String,
              json.decode(mData), type, '', json.decode(mData), 0, imageUrl);
        } else {
          debugPrint('in else data ${mData}');
          NotificationDataModel model = NotificationDataModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = model.image;
          body = model.message;
          helper.insertNotification(message.messageId as String,
              json.decode(mData), type, '', json.decode(mData), 0, imageUrl);
        }
        _showNotificationWithDefaultSound(message, title, body);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (message.notification != null) {
      debugPrint(message.notification.toString());
      helper.insertNotification(
          message.messageId as String,
          message.notification!.title as String,
          message.notification!.title as String,
          message.notification!.body as String,
          '',
          0,
          '');
      _showNotificationWithDefaultSound(
          message,
          message.notification!.title as String,
          message.notification!.body as String);
    }
  } catch (e) {}
}*/

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      'A new onMessageOpenedApp event was published! main 125 ${message.data.toString()}');
  NotificationService().parseNotification(message);
}

showNotification(RemoteMessage message) async {
  String cdate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
  DBHelper helper = DBHelper();
  Map<String, String> data = {};
  String type = "";
  String title = "";
  String imageUrl = "";
  String body = "";
  debugPrint(message.data.toString());
  try {
    String mData = message.data.toString();
    if (!message.data.containsKey("URL")) {
      NotificationActionModel model = NotificationActionModel.fromJson(
        json.decode(mData),
      );
      type = model.type;
      title = model.title;
      imageUrl = '';
      body = model.message;
    } else if (message.data.containsKey('Status')) {
      mData = mData.replaceAll('Purpose:', 'Purpose');
      mData = mData.replaceAll('Status:', 'Status');
      NotificationDataModel model = NotificationDataModel.fromJson(
        json.decode(mData),
      );
      type = model.type;
      title = model.title;
      imageUrl = model.image;
      body = model.message;
    } else {
      debugPrint('in else data $mData');
      NotificationDataModel model = NotificationDataModel.fromJson(
        json.decode(mData),
      );
      type = model.type;
      title = model.title;
      imageUrl = model.image;
      body = model.message;
    }
    _showNotificationWithDefaultSound(message, title, body);
  } catch (e) {
    debugPrint(e.toString());
  }
  data.putIfAbsent('title',
      () => title.isNotEmpty ? title : message.data['title'] as String);
  data.putIfAbsent(
      'description',
      () => body.isNotEmpty
          ? body
          : message.data.containsKey('body')
              ? message.data['body'] as String
              : '');
  data.putIfAbsent(
      'type',
      () => type.isNotEmpty
          ? type
          : message.data.containsKey('type')
              ? message.data['type'] as String
              : '');
  data.putIfAbsent('date', () => cdate);
  data.putIfAbsent(
      'imageurl',
      () =>
          message.data.containsKey('url') ? message.data['url'] as String : '');
  data.putIfAbsent('logoUrl', () => message.data['logo'] as String);
  data.putIfAbsent('bigImageUrl', () => message.data['bigimage'] as String);
  data.putIfAbsent('webViewLink', () => message.data['url'] as String);
  helper.insert(LocalConstant.TABLE_NOTIFICATION, data);
  /*var count = (int.parse(await KidzeePref().getString(LocalConstant.KEY_NOTIFICATION_COUNT) ??'0') +1);
  KidzeePref().setString(LocalConstant.KEY_NOTIFICATION_COUNT, count.toString());
  KidzeePref().setString(LocalConstant.KEY_SHOWNOTIFICATION_COUNT, 'true');
  if (ref != null) {
    ref.read(countProvider.notifier).update((state) => count);
  }*/
  NotificationService notificationService = NotificationService();
  if (message.data.containsKey('bigimage') &&
      (message.data['bigimage'] != null &&
          message.data['bigimage'].toString().isNotEmpty)) {
    notificationService.showBigNotification(
        message.data['title'],
        message.data['body'],
        message.data['logo'],
        message.data['bigimage'],
        message.data['showBigText'] == 'true' ? true : false,
        message);
  } else {
    notificationService.showSimpleNotification(
        message.data['title'], message.data['body'], message);
  }
}

updateCounter() async {
  var box = await Utility.openBox();
  var counter = box.get(LocalConstant.KEY_COUNTER) as int ?? 0;
  var count = (counter + 1);
}

AndroidNotificationChannel? channel;

late ServiceInstance mService;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

Future<bool> getInitNotif() async {
  ReceivedAction? receivedAction = await AwesomeNotifications()
      .getInitialNotificationAction(removeFromActionEvents: true);
  if (receivedAction?.buttonKeyPressed == 'ACCEPT') {
    return true;
  }
  return false;
}

Future<Box> _openBox() async {
  if (!kIsWeb && !Hive.isBoxOpen(LocalConstant.KidzeeDB)) {
    Hive.init((await getApplicationDocumentsDirectory()).path);
  }
  return await Hive.openBox(LocalConstant.KidzeeDB);
}
final localhostServer = InAppLocalhostServer(documentRoot: 'assets');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _openBox();

   if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  if (!kIsWeb) {
   // await localhostServer.start();
  }

  if(!kIsWeb && Platform.isAndroid) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }
  }

  NotificationController.startListeningNotificationEvents();

  if (!kIsWeb) {
    await NotificationController.initializeLocalNotifications();
    await NotificationController.initializeIsolateReceivePort();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("intranet");
    messaging.subscribeToTopic("saathi");
    print('saathi topic subscribed');
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.push(MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const UserNotification()));
    });
  }
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
        'intranet', // id
        'intranet', // title
        importance: Importance.defaultImportance,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    NotificationService notificationService = NotificationService();
    /*await notificationService.init();
    await notificationService.requestIOSPermissions();*/

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  //_requestPermission();
  await PermissionUtil.requestPermission();

  await Hive.initFlutter();
  await Hive.openBox(LocalConstant.communicationKey); // settings
  await Hive.openBox(LocalConstant.authStorageKey);
  await Hive.openBox(LocalConstant.indent);
  DependencyInjection.init();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TicketModelAdapter());
    Hive.registerAdapter(NotificationModelAdapter());
  }
  await Hive.openBox<TicketModel>(HiveConstant.key_TicketListData);
  //await Hive.openBox<NotificationModel>(HiveConstant.key_NotificationList);
  await Hive.openBox(HiveConstant.box_SSOUser);
  await Hive.openBox(HiveConstant.key_logindetails);

  //await initializeService();
  //runApp(const MyApp());
  bool acceptedNotification = await getInitNotif();
  runApp(MultiBlocProvider(
    providers = [
      BlocProvider<GetplandetailsCubit>(
        create: (BuildContext context) => GetplandetailsCubit(),
      ),
      BlocProvider<GetvisitplannercvfCubit>(
        create: (BuildContext context) => GetvisitplannercvfCubit(),
      ),
    ],
    child = ProviderScope(
      child: acceptedNotification ? const UserNotification() : const MyApp(),
    ),
  ));
}

_requestPermission() async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  locationData = await location.getLocation();
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'INTRANET FOREGROUND SERVICE', // title
    description:
        'This channel is used for sync Data with Server.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Intranet Application is Running',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}
/*
Future<void> leaveService(int action) async {
  final leaveService = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'INTRANET FOREGROUND SERVICE', // title
    description:
        'This channel is used for sync Data with Server.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: IOSInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await leaveService.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Intranet Application is Running',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  //leaveService.startService();
}*/

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  debugPrint('onStart Service');
  DartPluginRegistrant.ensureInitialized();
  mService = service;
  // For flutter prior to version 3.0.0
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  service.on('stopService').listen((event) {
    debugPrint('onStart Service onStop');
    service.stopSelf();
  });

  flutterLocalNotificationsPlugin.show(
    888,
    'Intranet App is Running',
    'Sync Data with Server process started',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'Intranet FOREGROUND SERVICE',
        icon: 'ic_bg_service_small',
        ongoing: true,
      ),
    ),
  );
  checkPendingLeaveApprovals(0);

  /*// test using external plugin
  final deviceInfo = DeviceInfoPlugin();
  String? device;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    device = androidInfo.model;
  }

  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    device = iosInfo.model;
  }

  */
}

checkPendingLeaveApprovals(int action) async {
  bool isInternet = await Utility.isInternet();
  if (isInternet) {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    String userId = hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
    DBHelper helper = DBHelper();
    List<ApproveLeaveRequestManager> list = await helper.getUnSyncData(userId);
    List<CheckInModel> checkInList = await DBHelper().getOfflineCheckInStatus();
    if ((checkInList.isEmpty) && (list.isEmpty)) {
      if (action == 2) {
        NotificationService notificationService = NotificationService();
        notificationService.showNotification(
            12,
            'LEAVE/OUTDOOR REQUEST Completed',
            'Leave/OUTDOOR Approval request has been successfully completed.',
            'Leave/OUTDOOR Approval request has been successfully completed.');
      }
      stopService(mService);
    } else {
      if (checkInList.isNotEmpty) {
        apicall(checkInList);
      } else if (list.isNotEmpty) syncLeaveApproval(list[0]);
    }
  } else {
    stopService(mService);
  }
}

cancelNotification() async {
  NotificationService notificationService = NotificationService();
  notificationService.cancelNotification(888);
}

stopService(ServiceInstance mService) {
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    mService.stopSelf();
    cancelNotification();
  });
}

syncLeaveApproval(ApproveLeaveRequestManager model) {
  ApproveLeaveRequestManager request = ApproveLeaveRequestManager(
    xml: model.xml,
    userId: model.userId.toString(),
    index: model.index,
    actionType: model.actionType,
  );
  if (request.xml.contains('[]')) {
    if (model.index != null) {
      DBHelper helper = DBHelper();
      //debugPrint('DELTE ID ${model.index!.toString()}');
      helper.delete(LocalConstant.TABLE_DATA_SYNC, model.index!.toString());
    }
    checkPendingLeaveApprovals(2);
  } else if (model.actionType.isNotEmpty &&
      model.actionType == 'ATTENDANCE_MAN') {
    //debugPrint('ATTENDANCE_MAN request');
    APIService apiService = APIService();
    apiService.approveAttendance(request).then((value) {
      //debugPrint('approveAttendance response ${value}');
      if (value != null) {
        if (value == null || value.responseData == null) {
          //debugPrint('Serviceclosed NULL....................');
          mService.stopSelf();
        } else if (value is ApproveAttendanceResponse) {
          ApproveAttendanceResponse response = value;
          if (response.statusCode == 200) {
            if (model.index != null) {
              DBHelper helper = DBHelper();
              //debugPrint('DELTE ID ${model.index!.toString()}');
              helper.delete(
                  LocalConstant.TABLE_DATA_SYNC, model.index!.toString());
            }
          } else {
            if (model.index != null) {
              DBHelper helper = DBHelper();
              //debugPrint('DELTE ID ${model.index!.toString()}');
              helper.delete(
                  LocalConstant.TABLE_DATA_SYNC, model.index!.toString());
            }
          }
          checkPendingLeaveApprovals(2);
        } else if (value.toString().contains('Failed host lookup')) {
          //debugPrint('Serviceclosed....................');
          mService.stopSelf();
        } else {
          //debugPrint('Serviceclosed NULL.ELSE...................');
          mService.stopSelf();
        }
      }
    });
  } else {
    //debugPrint('approveLeaveManager request');
    APIService apiService = APIService();
    apiService.approveLeaveManager(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          mService.stopSelf();
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          //debugPrint(response.responseMessage);
          //debugPrint('Serviceclosed NULL....523...........');
          debugPrint(response.responseMessage);
          if (model.index != null) {
            DBHelper helper = DBHelper();
            //debugPrint('DELTE ID ${model.index!.toString()}');
            helper.delete(
                LocalConstant.TABLE_DATA_SYNC, model.index!.toString());
          }
          checkPendingLeaveApprovals(2);
        }
      }
    });
  }
}

apicall(List<CheckInModel> list) async {
  //debugPrint('api calling...');

  //debugPrint('Offline Data found ${list.length}');
  if (list.isNotEmpty) {
    debugPrint('Offline Data found ${list.length}');
    debugPrint(list[0].body);
    UpdateCVFStatusRequest request = UpdateCVFStatusRequest.fromJson(
      json.decode(list[0].body),
    );
    //debugPrint('json decode ');
    //debugPrint(request.toString());
    APIService apiService = APIService();
    apiService.updateCVFStatus(request).then((value) {
      //debugPrint('response received...');
      //debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          //onResponse.onError('Unable to update the status');
        } else if (value is UpdateCVFStatusResponse) {
          UpdateCVFStatusResponse response = value;
          //debugPrint(response.toString());
          //onResponse.onSuccess(response);
          DBHelper helper = DBHelper();
          helper.updateCheckInStatus(list[0].id, 1);
          checkPendingLeaveApprovals(3);
        } else {
          //onResponse.onError('Unable to update the status ');
        }
      } else {
        //onResponse.onError('Unable to update the status');
      }
    });
  }
}

Future<void> setup() async {
  // #1
  const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSetting = DarwinInitializationSettings();

  // #2
  const initSettings =
      InitializationSettings(android: androidSetting, iOS: iosSetting);

  // #3
  await flutterLocalNotificationsPlugin?.initialize(initSettings).then((_) {
    debugPrint('setupPlugin: setup success');
  }).catchError((Object error) {
    debugPrint('Error: $error');
  });
}

Future _showNotificationWithDefaultSound(
    RemoteMessage message, String title, String messageData) async {
  if (Platform.isIOS) {
  } else if (false && Platform.isAndroid) {
    if (!AwesomeStringUtils.isNullOrEmpty(title,
            considerWhiteSpaceAsEmpty: true) ||
        !AwesomeStringUtils.isNullOrEmpty(messageData,
            considerWhiteSpaceAsEmpty: true)) {
      debugPrint('message also contained a notification: $message');

      String? imageUrl;
      try {
        imageUrl ??= message.notification!.android?.imageUrl;
        imageUrl ??= message.notification!.apple?.imageUrl;
      } catch (e) {}

      Map<String, dynamic> notificationAdapter = {
        NOTIFICATION_CHANNEL_KEY: 'basic_channel',
        NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
            message.messageId ??
            Random().nextInt(2147483647),
        NOTIFICATION_TITLE: message.data[NOTIFICATION_CONTENT]
                ?[NOTIFICATION_TITLE] ??
            message.notification?.title,
        NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]
                ?[NOTIFICATION_BODY] ??
            message.notification?.body,
        NOTIFICATION_LAYOUT: AwesomeStringUtils.isNullOrEmpty(imageUrl)
            ? 'Default'
            : 'BigPicture',
        NOTIFICATION_BIG_PICTURE: imageUrl
      };

      AwesomeNotifications()
          .createNotificationFromJsonData(notificationAdapter);
    } else {
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    }
  } else {
    NotificationService notificationService = NotificationService();
    notificationService.showNotification(12, title, messageData, messageData);
  }
  debugPrint('Send Notification');
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Intranet',
      themeMode: ThemeMode.light,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 360, name: 'SMALL_MOBILE'),
          const Breakpoint(start: 361, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      theme: ThemeData(
        useMaterial3: true,
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.white),
          //fillColor: MaterialStateProperty.all(Colors.white),
          fillColor: WidgetStateColor.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return kPrimaryLightColor; // the color when checkbox is selected;
              }
              return Colors.black12; //the color when checkbox is unselected;
            },
          ),
          overlayColor: WidgetStateProperty.all(Colors.black),
          side: const BorderSide(color: Color(0xff585858)),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.pink,
          labelStyle: TextStyle(color: Colors.pink), // color for text
          indicator: UnderlineTabIndicator(
              // color for indicator (underline)
              borderSide: BorderSide(color: LightColors.kLightGray1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: kPrimaryLightColor,
          textStyle: const TextStyle(
            color: Colors.white,
          ),
        )),
        fontFamily: 'Roboto',
        /*colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryLightColor,
          background: LightColors.kLightGray1,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        primaryColorDark: kPrimaryLightColor,
        primaryColor: kPrimaryLightColor,*/
        appBarTheme: const AppBarTheme(
          // <-- SEE HERE
          color: kPrimaryLightColor,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle:
              TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: kPrimaryLightColor,
          onPrimary: Colors.black,
          secondary: Colors.green,
          onSecondary: Colors.black45,
          primaryContainer: Colors.white,
          error: Colors.black,
          onError: Colors.red,
          surface: Colors.white,
          onSurface: Colors.black87,
          outline: LightColors.kLightGrayM,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black54),
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            errorStyle: LightColors.textsubtitle,
            helperStyle: LightColors.textsubtitle,
            hintStyle: LightColors.textsubtitle,
            focusedErrorBorder: LightColors.kRed.getOutlineBorder,
            errorBorder: LightColors.kRed.getOutlineBorder,
            focusedBorder: Colors.black45.getOutlineBorder,
            iconColor: Colors.black38,
            prefixIconColor: Colors.black38,
            enabledBorder: Colors.black12.getOutlineBorder,
            disabledBorder: Colors.black12.getOutlineBorder,
            errorMaxLines: 1,
            suffixIconColor: kPrimaryLightColor,
            floatingLabelStyle: const TextStyle(
              color: Colors.black38,
              backgroundColor: Colors.white,
            )),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black),
        primaryTextTheme: Typography().black,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kPrimaryLightColor,
          selectionColor: kPrimaryLightColor,
          selectionHandleColor: kPrimaryLightColor,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: kPrimaryLightColor,
          textTheme: ButtonTextTheme.primary,
        ),
        /*colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          background: LightColors.kLightGray1,
          primaryContainer: Colors.white,
          secondary: Colors.white,
          secondaryContainer: Colors.white,
          primary: Colors.white,
          brightness: Brightness.light,
          onSurface: Colors.black87, // text color
          surface: Colors.white

        ),*/
      ),
      home: const Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NotificationController {
  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    print('onActionReceivedImplementationMethod 1192');
    Navigator.push(MyApp.navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => const UserNotification()));
  }

  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: LocalConstant.NOTIFICATION_CHANNEL,
              channelName: LocalConstant.NOTIFICATION_CHANNEL,
              channelDescription: "important notification for Intranet",
              playSound: true,
              onlyAlertOnce: true,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              channelShowBadge: true,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('Received action is - ${receivedAction.actionType}');
    debugPrint('Received payload - ${receivedAction.payload}');
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      // await executeLongTaskInBackground();
    } else if (receivedAction.payload != null &&
        receivedAction.payload!['type'] != null &&
        receivedAction.payload!['type'] == 'td') {
      print(
          'SAATHI Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      print('SAATHI payload - ${receivedAction.payload}');
      openSaathiNotification(receivedAction);
    } else if (receivedAction.payload != null &&
        receivedAction.payload!['Video_path'] != null) {
      Navigator.push(
          MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(
              builder: (context) => VideoPlayer(
                    Title: receivedAction.payload!['Video_path']!,
                    path: receivedAction.payload!['Video_path']!,
                  )));
    } else if (receivedAction.payload != null &&
        receivedAction.payload!['url'] != null &&
        receivedAction.payload!['url']!.isNotEmpty) {
      Navigator.push(MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const UserNotification()));
    } else {
      Navigator.push(MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const UserNotification()));
    }
  }

  static openSaathiNotification(ReceivedAction receivedAction) async {
    try {
      var hiveBox = await Utility.openBox();
      await Hive.openBox(LocalConstant.KidzeeDB);
      String mUserName = hiveBox.get(LocalConstant.KEY_USER_NAME) as String;
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(
            builder: (context) => ZllTicketDetails(
              ticketId: receivedAction.payload!['id'].toString(),
              bid: '0',
              businessUserId: '',
              userId: mUserName,
              mColor: kPrimaryLightColor,
            ),
          ),
          (route) => false);
    } catch (e) {
      print('SAATHI exception $e');
      print(e);
    }
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    /*await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });*/
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  static Future<void> executeLongTaskInBackground() async {}

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Huston! The eagle has landed!',
            body:
                "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> scheduleNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: "Huston! The eagle has landed!",
            body:
                "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {
              'notificationId': '1234567890'
            }),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ],
        schedule: NotificationCalendar.fromDate(
            date: DateTime.now().add(const Duration(seconds: 10))));
  }
}
