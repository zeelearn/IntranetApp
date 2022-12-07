import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet/pages/auth/login.dart';
import 'package:intranet/pages/firebase/firebase_options.dart';
import 'package:intranet/pages/firebase/notification_service.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LightColor.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:intranet/pages/intro/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:intranet/pages/model/NotificationDataModel.dart';
import 'package:intranet/pages/pjp/cvf/CheckInModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/APIService.dart';
import 'api/ServiceHandler.dart';
import 'api/request/cvf/update_cvf_status_request.dart';
import 'api/response/cvf/update_status_response.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try{
  await Firebase.initializeApp(
      name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message');
  DBHelper helper = new DBHelper();
  if (message.data != null) {
    print(message.data.toString());
    String type = "";
    String title = "";
    String imageUrl = "";
    String body = "";
    try {
      String mData = message.data.toString();
      /*mData = mData.replaceAll("{", "{\"");
      mData = mData.replaceAll("}", "\"}");
      mData = mData.replaceAll(":", "\":\"");
      mData = mData.replaceAll(", ", "\",\"");*/
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
        helper.insertNotification(
            message.messageId as String,
            json.decode(mData),
            type,
            '',
            json.decode(mData),
            0,
            imageUrl);
      } else {
        print('in else data ${mData}');
        NotificationDataModel model = NotificationDataModel.fromJson(
          json.decode(mData),
        );
        type = model.type;
        title = model.title;
        imageUrl = model.image;
        body = model.message;
        helper.insertNotification(
            message.messageId as String,
            json.decode(mData),
            type,
            '',
            json.decode(mData),
            0,
            imageUrl);
      }
      _showNotificationWithDefaultSound(message, title, body);
    } catch (e) {
      print(e);
    }
  }
  print('Data insetted');
  if (message.notification != null) {
    print(message.notification.toString());
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
}catch(e){

  }
}

AndroidNotificationChannel? channel;

late ServiceInstance mService;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);

  messaging = FirebaseMessaging.instance;
  messaging.subscribeToTopic("intranet");

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground! main');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    DBHelper helper = new DBHelper();
    if (message.data != null) {
      print(message.data.toString());
      String type = "";
      String title = "";
      String imageUrl = "";
      String body = "";
      try {
        String mData = message.data.toString();
        /*mData = mData.replaceAll("{", "{\"");
        mData = mData.replaceAll("}", "\"}");
        mData = mData.replaceAll(":", "\":\"");
        mData = mData.replaceAll(", ", "\",\"");*/
        print('-========================');
        print(mData);
        if (!message.data.containsKey("URL")) {
          NotificationActionModel model = NotificationActionModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = '';
          body = model.message;
        } else {
          print(mData);
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
        print(e);
      }
      helper.insertNotification(
          message.messageId as String,
          message.data.toString(),
          type,
          '',
          message.data.toString(),
          0,
          imageUrl);
    }
    print('Data insetted123');
    if (message.notification != null) {
      print(message.notification.toString());
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
  });

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
        'intranet', // id
        'intranet', // title
        importance: Importance.defaultImportance,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    /*flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
  AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

    */
    NotificationService notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestIOSPermissions();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  await initializeService();
  runApp(const MyApp());
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
        iOS: IOSInitializationSettings(),
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
      initialNotificationTitle: 'AWESOME SERVICE',
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

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  mService = service;
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /*if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }*/



  service.on('stopService').listen((event) {
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
  // bring to foreground
  /*Timer.periodic(const Duration(seconds: 5), (timer) async {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'Intranet App is Running',
          '${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'Intranet FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      });*/
  /// you can see this log in logcat
  print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  apicall();
  // test using external plugin
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

  service.invoke(
    'update',
    {
      "current_date": DateTime.now().toIso8601String(),
      "device": device,
    },
  );
}

apicall() async {
  print('api calling...');
  List<CheckInModel> list = await DBHelper().getOfflineCheckInStatus();
  print('Offline Data found ${list.length}');
  if (list.length > 0) {
    print('Offline Data found ${list.length}');
    print(list[0].body);
    UpdateCVFStatusRequest request = UpdateCVFStatusRequest.fromJson(
      json.decode(list[0].body),
    );
    print('json decode ');
    print(request.toString());
    APIService apiService = APIService();
    apiService.updateCVFStatus(request).then((value) {
      print('response received...');
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          //onResponse.onError('Unable to update the status');
        } else if (value is UpdateCVFStatusResponse) {
          UpdateCVFStatusResponse response = value;
          print(response.toString());
          //onResponse.onSuccess(response);
          DBHelper helper=DBHelper();
          helper.updateCheckInStatus(list[0].id, 1);
          apicall();
        } else {
          //onResponse.onError('Unable to update the status ');
        }
      } else {
        //onResponse.onError('Unable to update the status');
      }
    });
  } else {
    print('Offline Data not found service stopping');
    if(mService!=null)
      mService.stopSelf();
  }
}

Future<void> setup() async {
  // #1
  const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSetting = IOSInitializationSettings();

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
  if (false && Platform.isAndroid) {
    if (!AwesomeStringUtils.isNullOrEmpty(title,
            considerWhiteSpaceAsEmpty: true) ||
        !AwesomeStringUtils.isNullOrEmpty(messageData,
            considerWhiteSpaceAsEmpty: true)) {
      print('message also contained a notification: ${message}');

      String? imageUrl;
      try{
        imageUrl ??= message.notification!.android?.imageUrl;
        imageUrl ??= message.notification!.apple?.imageUrl;
      }catch(e){

      }


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
  print('Send Notification');
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Intranet',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColorDark: LightColor.primarydark_color,
        primaryColor: LightColor.primary_color,
      ),
      home:   Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
              style: Theme.of(context).textTheme.headline4,
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
