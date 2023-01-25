import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory, Platform;
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intranet/pages/firebase/firebase_options.dart';
import 'package:intranet/pages/firebase/notification_service.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LightColor.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:intranet/pages/intro/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:intranet/pages/model/NotificationDataModel.dart';

import 'package:path_provider/path_provider.dart';

import 'package:hive/hive.dart';

part 'main.g.dart';

@HiveType(typeId: 1)
class Person {
  Person({required this.name, required this.age, required this.friends});

  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  List<String> friends;

  @override
  String toString() {
    return '$name: $age';
  }
}

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

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;


@HiveType(typeId: 1)
class UserInfo {
  UserInfo({required this.displayName,
    required this.firstName, required this.employeeId,
  required this.employeeCode,
  required this.lastName,
  required this.doj,
  required this.subid,
  required this.roleId,
  required this.roleName,
  required this.departname,
  required this.emailid,
  required this.mobileno,
  required this.gender,
  required this.workLocation,
  required this.marritialStatus,
  required this.dob,
  });

  @HiveField(0)
  String displayName;

  @HiveField(1)
  double employeeId;

  @HiveField(2)
  String employeeCode;

  @HiveField(3)
  String firstName;

  @HiveField(4)
  String lastName;

  @HiveField(5)
  String doj;

  @HiveField(6)
  double subid;

  @HiveField(7)
  double roleId;

  @HiveField(8)
  String roleName;

  @HiveField(9)
  String departname;

  @HiveField(10)
  String emailid;

  @HiveField(11)
  String mobileno;

  @HiveField(12)
  String gender;

  @HiveField(13)
  String workLocation;

  @HiveField(14)
  String marritialStatus;

  @HiveField(15)
  String dob;

  @override
  String toString() {
    return '$employeeId: $firstName';
  }
}
/*
class PersonAdapter extends TypeAdapter<UserInfo> {
  @override
  final int typeId = 1;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfo(
      displayName: fields[0] as String,
      employeeId: fields[1] as double,
      employeeCode: fields[2] as String,
      firstName: fields[3] as String,
      lastName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.friends);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PersonAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}*/
Future<Box> _openBox() async {
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  return await Hive.box('myBox');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);

  messaging = FirebaseMessaging.instance;
  messaging.subscribeToTopic("intranet");
  Directory root = await getTemporaryDirectory();
  var path = root.path + '/hive';;
  Hive
    ..init(path)
    ..registerAdapter(PersonAdapter());

  var box = await Hive.openBox('kidzeepref');

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
    //NotificationService.initNotification();

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
  if(Platform.isIOS){

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
