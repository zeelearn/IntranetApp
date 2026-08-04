import 'dart:async';

import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../api/request/fcm_request.dart';
import '../helper/LocalConstant.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
      name: "Intranet", options: DefaultFirebaseOptions.currentPlatform);

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
  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications(String employeeId, String deviceId, String userAgent) {
    Future.delayed(
      Duration(seconds: 5),
      () async {
        await _getAndRegisterToken(employeeId, deviceId, userAgent);
        
        if (kIsWeb) {
          // Set up a periodic check to fetch and register token if it failed initially
          Timer.periodic(const Duration(seconds: 15), (timer) async {
            try {
              var hiveBox = Hive.box(LocalConstant.KidzeeDB);
              var oldToken = hiveBox.get(LocalConstant.KEY_FCM_ID);
              if (oldToken != null && oldToken.toString().isNotEmpty) {
                timer.cancel();
              } else {
                debugPrint('FCM Web: Retrying token generation...');
                await _getAndRegisterToken(employeeId, deviceId, userAgent);
              }
            } catch (e) {
              debugPrint('FCM Web: Error in periodic retry check: $e');
            }
          });
        }
      },
    );
  }

  Future<void> _getAndRegisterToken(String employeeId, String deviceId, String userAgent) async {
    try {
      if (kIsWeb) {
        debugPrint('FCM Web: Requesting notification permission...');
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      String? token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BG5w1AwwXhI1M3Y18az4mr5yISPo2isT_xDisMq89OL05-hZY1WO5FEvmiE0UkOdGDvFK9gCHtufo7YIVE4kpn0');
      
      if (token != null) {
        debugPrint('FCM: Token successfully retrieved: $token');
        if (!kIsWeb) {
          await FirebaseMessaging.instance.subscribeToTopic("intranet");
          await Future.delayed(Duration(seconds: 1));
          await FirebaseMessaging.instance.subscribeToTopic("saathi");
        } else if (kIsWeb) {
          await APIService().subscribeToTopicForWeb(token, 'intranet');
          await APIService().subscribeToTopicForWeb(token, 'saathi');
        }
        await sendFcm(token, employeeId, deviceId, userAgent);
      } else {
        debugPrint('FCM: Retrieved token is null');
      }
    } catch (e) {
      debugPrint('FCM: Exception during token retrieval/subscription: $e');
    }
  }

  sendFcm(String token, String employeeId, deviceId, userAgent) async {
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    var oldoken = hiveBox.get(LocalConstant.KEY_FCM_ID);
    if (oldoken == null || oldoken != token) {
      /* Moved this to APIService to store after successful api call. */
      // hiveBox.put(LocalConstant.KEY_FCM_ID, token);
      APIService service = APIService();

      FcmRequestModel model = FcmRequestModel(
          FCM_Reg_ID: token,
          Employee_ID: employeeId,
          Device_ID: deviceId,
          User_Agent: userAgent);
      service.updateFCM(model);
    } else {}
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}
