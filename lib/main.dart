import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intranet/pages/firebase/firebase_options.dart';
import 'package:intranet/pages/firebase/notification_service.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LightColor.dart';
import 'package:intranet/pages/intro/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:intranet/pages/model/NotificationDataModel.dart';
import 'package:upgrader/upgrader.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
  DBHelper helper=new DBHelper();
  if(message.data != null) {
    print(message.data.toString());
    String type ="";
    String title ="";
    String imageUrl ="";
    String body="";
    try{
      String mData = message.data.toString();
      mData = mData.replaceAll("{", "{\"");
      mData = mData.replaceAll("}", "\"}");
      mData = mData.replaceAll(":", "\":\"");
      mData = mData.replaceAll(", ", "\",\"");
      if(!message.data.containsKey("URL")){
        NotificationActionModel model = NotificationActionModel.fromJson(
          json.decode(mData),
        );
        type = model.type;
        title = model.title;
        imageUrl = '';
        body = model.message;
      }else {
        print('in else data ${mData}');
        NotificationDataModel model = NotificationDataModel.fromJson(
          json.decode(mData),
        );
        type = model.type;
        title = model.title;
        imageUrl = model.image;
        body = model.message;
      }
      _showNotificationWithDefaultSound(message,title, body);
    }catch(e){
      print(e);
    }
    helper.insertNotification(message.messageId as String,
        message.data.toString(),
        type,
        '',
        message.data.toString(),
        0,
        imageUrl);

  }
  print('Data insetted');
  if(message.notification!=null) {
    print(message.notification.toString());
    helper.insertNotification(message.messageId as String,
        message.notification!.title as String,
        'simple',
        message.notification!.body as String,
        '',
        0,
        '');
    _showNotificationWithDefaultSound(message,message.notification!.title as String, message.notification!.body as String);
  }
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);

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
    DBHelper helper=new DBHelper();
    if(message.data != null) {
      print(message.data.toString());
      String type ="";
      String title ="";
      String imageUrl ="";
      String body ="";
      try{
        String mData = message.data.toString();
        mData = mData.replaceAll("{", "{\"");
        mData = mData.replaceAll("}", "\"}");
        mData = mData.replaceAll(":", "\":\"");
        mData = mData.replaceAll(", ", "\",\"");
        print('-========================');
        print(mData);
        if(!message.data.containsKey("URL")){
          NotificationActionModel model = NotificationActionModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = '';
          body = model.message;
        }else {
          print(mData);
          NotificationDataModel model = NotificationDataModel.fromJson(
            json.decode(mData),
          );
          type = model.type;
          title = model.title;
          imageUrl = model.image;
          body = model.message;
        }
        _showNotificationWithDefaultSound(message,title, body);
      }catch(e){
        print(e);
      }
      helper.insertNotification(message.messageId as String,
          message.data.toString(),
          type,
          '',
          message.data.toString(),
          0,
          imageUrl);

    }
    print('Data insetted');
    if(message.notification!=null) {
      print(message.notification.toString());
      helper.insertNotification(message.messageId as String,
          message.notification!.title as String,
          'simple',
          message.notification!.body as String,
          '',
          0,
          '');
      _showNotificationWithDefaultSound(message,message.notification!.title as String, message.notification!.body as String);
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



  runApp(const MyApp());
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


Future _showNotificationWithDefaultSound(RemoteMessage message, String title,String messageData) async {

  if (false && Platform.isAndroid) {
    if(
    !AwesomeStringUtils.isNullOrEmpty(title, considerWhiteSpaceAsEmpty: true) ||
        !AwesomeStringUtils.isNullOrEmpty(messageData, considerWhiteSpaceAsEmpty: true)
    ){
      print('message also contained a notification: ${message}');

      String? imageUrl;
      imageUrl ??= message.notification!.android?.imageUrl;
      imageUrl ??= message.notification!.apple?.imageUrl;

      Map<String, dynamic> notificationAdapter = {
        NOTIFICATION_CHANNEL_KEY: 'basic_channel',
        NOTIFICATION_ID:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
            message.messageId ??
            Random().nextInt(2147483647),
        NOTIFICATION_TITLE:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_TITLE] ??
            message.notification?.title,
        NOTIFICATION_BODY:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_BODY] ??
            message.notification?.body ,
        NOTIFICATION_LAYOUT:
        AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
        NOTIFICATION_BIG_PICTURE: imageUrl
      };

      AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
    }
    else {
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    }
  }else {
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
      home: const Scaffold(
          body:SplashScreen(),
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
