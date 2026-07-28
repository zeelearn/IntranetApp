import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:saathi/zllsaathi.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../firebase_options.dart';
import '../../main.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';

class Util {
  static Future<void> openGoogleMaps(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,BuildContext context
  ) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$fromLat,$fromLng'
      '&destination=$toLat,$toLng'
      '&travelmode=driving',
    );

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           InAppWebView(initialUrlRequest: URLRequest(url: WebUri.uri(uri))),
    //     ));

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Container openReportPage(GetDetailedPJP cvf,BuildContext context) {
    return Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            color: kPrimaryLightColor.withOpacity(0.4),
                            child: InkWell(
                              onTap: () {
                                if (kIsWeb) {
                                  launchUrl(
                                    Uri.parse(
                                        'https://intranet.zeelearn.com/cvfreport.html?cid=${cvf.PJPCVF_Id}'),
                                    mode: LaunchMode.platformDefault,
                                  );
                                } else {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MyWebsiteView(
                                                title:
                                                    'CVF Report - ${cvf.PJPCVF_Id}',
                                                url:
                                                    'https://intranet.zeelearn.com/cvfreport.html?cid=${cvf.PJPCVF_Id}',
                                              )));
                                }
                              },
                              child: Text(
                                'View Report',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          );
  }

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
    } catch (_) {}
  }
}
