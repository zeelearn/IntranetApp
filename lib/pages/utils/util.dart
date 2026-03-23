import 'package:Intranet/pages/helper/utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:saathi/zllsaathi.dart';

import '../../firebase_options.dart';
import '../../main.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';

class Util {
  static String getDisplayTitle(String status) {
    switch (status) {
      case 'All':
        return 'All';
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'draft':
        return 'Draft';
      default:
        return status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : status;
    }
  }

  static Future<FirebaseApp> getCurrentFirebaseApp() async {
    FirebaseApp app;
    try {
      if (!kIsWeb) {
        app = await Firebase.initializeApp(
            name: 'intranet', options: DefaultFirebaseOptions.currentPlatform);
      } else {
        app = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
    } catch (e) {
      if (!kIsWeb) {
        app = await Firebase.initializeApp(
            name: 'intranet', options: DefaultFirebaseOptions.currentPlatform);
      } else {
        app = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
    }
    return app;
  }

  static openSaathiNotification(ReceivedAction receivedAction) async {
    try {
      var hiveBox = await Utility.openBox();
      await Hive.openBox(LocalConstant.KidzeeDB);
      String mUserName = hiveBox.get(LocalConstant.KEY_USER_NAME) as String;
      if (receivedAction.payload?['url'] != null) {
        Uri uri = Uri.parse(receivedAction.payload!['url']!);
        debugPrint(
            'Query Parameter is - ${uri.queryParameters} ${MyApp.navigatorKey.currentContext}');

        Navigator.push(
          // ignore: use_build_context_synchronously
          MyApp.navigatorKey.currentState!.context,
          MaterialPageRoute(
            builder: (context) => ZllTicketDetails(
              ticketId: uri.queryParameters['id'] ??
                  receivedAction.payload!['id'].toString(),
              bid: uri.queryParameters['bu_id'] ?? '0',
              businessUserId: uri.queryParameters['b_id'] ?? '0',
              userId: uri.queryParameters['u_id'] ?? mUserName /* mUserName */,
              mColor: kPrimaryLightColor,
            ),
          ),
        );
      }
    } catch (e) {
      print('SAATHI exception $e');
      print(e);
    }
  }
}
