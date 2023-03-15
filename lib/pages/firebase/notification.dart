import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:intranet/api/APIService.dart';

import '../../api/request/fcm_request.dart';
import '../helper/LocalConstant.dart';
import 'firebase_options.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications(String employeeId,String deviceId,String userAgent) {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
          (message) async {
            print(message.toString());
        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
      },
    );
    // With this token you can test it easily on your phone
    final token = _firebaseMessaging.getToken().then((value) => sendFcm(value!,employeeId,deviceId,userAgent) );


  }
  sendFcm(String token,String employeeId,deviceId,userAgent) async {
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    var oldoken = hiveBox.get(LocalConstant.KEY_FCM_ID);
    print(token);
    if(oldoken==null || oldoken != token) {
      hiveBox.put(LocalConstant.KEY_FCM_ID, token);
      APIService service = APIService();

      FcmRequestModel model = FcmRequestModel(FCM_Reg_ID: token,
          Employee_ID: employeeId,
          Device_ID: deviceId,
          User_Agent: userAgent);
      service.updateFCM(model);
    }else{
      print('in else notification id not change');
    }
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}