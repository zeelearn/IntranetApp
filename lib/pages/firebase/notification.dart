import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intranet/api/APIService.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        // Or do other work.
        //titleCtlr.sink.add(message.notification!.title!);
        //bodyCtlr.sink.add(message.notification!.body!);
      },
    );
    // With this token you can test it easily on your phone
    final token = _firebaseMessaging.getToken().then((value) => sendFcm(value!,employeeId,deviceId,userAgent) );


  }
  sendFcm(String token,String employeeId,deviceId,userAgent) async {
    final prefs = await SharedPreferences.getInstance();
    var oldoken = prefs.getString(LocalConstant.KEY_FCM_ID);
    if(oldoken==null || oldoken != token) {
      prefs.setString(LocalConstant.KEY_FCM_ID, token);
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