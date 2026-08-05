import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';
import 'package:Intranet/pages/home/v2/dashboard_screenv2.dart';
import 'intro.dart';
import '../helper/web_helper.dart';
import '../auth/magic_link_handler.dart';
import 'package:Intranet/main.dart' show NotificationController;

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.receivedAction, Key? key}) : super(key: key);
  final ReceivedAction? receivedAction;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() async {
    var box = await Utility.openBox();

    if (kIsWeb) {
      final uriStr = getBrowserUrl();
      final uri = Uri.parse(uriStr);
      if (uri.queryParameters.containsKey('token')) {
        MagicLinkHandler.handle(uri, context);
        return; // skip normal session check
      }
    }

    String displayName = '';
    String userName = '';
    String mobileNumber = '';
    String currentBusinessName = '';
    if (box.get(LocalConstant.KEY_FIRST_NAME) != null) {
      displayName = box.get(LocalConstant.KEY_FIRST_NAME) as String;
      userName = box.get(LocalConstant.KEY_FIRST_NAME) as String;
      mobileNumber = box.get(LocalConstant.KEY_CONTACT) as String;
    }
    if (box.get(LocalConstant.KEY_BUSINESS_NAME) != null) {
      currentBusinessName = box.get(LocalConstant.KEY_BUSINESS_NAME).toString();
    }
    final launchAction = widget.receivedAction ?? NotificationController.coldStartAction;
    if (displayName != '') {
      Timer(
          Duration(seconds: launchAction != null ? 0 : 4),
          () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        /*currentBusinessName==null || currentBusinessName.isEmpty ? LoginPage(isAutoLogin: true,) : */ DashboardScreenV2(
                          userId: '',
                          receivedAction: launchAction,
                        )),
              ));
    } else {
      if (false && kIsWeb) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(
                  isAutoLogin: false,
                )));
      } else {
        //IntroPage
        Timer(
            Duration(seconds: 4),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => IntroPage())));
      }
    }
  }

  void navigationPage() {
    //Navigator.of(context).pushReplacementNamed('/pages/intro/IntroPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: Image.asset('assets/images/app_logo.png'),
                    ),
                    Container(
                      child: Text(
                        "",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                  // children: const [
                  //   CircleAvatar(
                  //     backgroundColor: Colors.white,
                  //     radius: 50.0,
                  //     child: ImageIcon(
                  //       AssetImage("assets/icons/app_logo.png"),
                  //
                  //     ),
                  //   ),
                  //   Padding(padding: EdgeInsets.only(top: 10.0)),
                  //   Text(
                  //     "Kidzee",
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 24.0,
                  //         color: Colors.black),
                  //   )
                  // ],
                ),
              ),
              // Expanded(
              //   flex: 1,
              // child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     CircularProgressIndicator.adaptive(value: 3.0,),
              //     Padding(padding: const EdgeInsets.only(top: 20.0))
              //   ],
              // ),)
            ],
          ),

          // Container(
          //   margin: EdgeInsets.only(bottom: 30),
          //   child: TextButton(
          //     style: TextButton.styleFrom(
          //       backgroundColor: Colors.red,
          //       primary: Colors.white, // foreground
          //     ),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => LoginScreen()),
          //       );
          //     },
          //     child: Text('Start Now'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
