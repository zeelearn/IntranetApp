import 'dart:async';
import 'dart:io';

import 'package:Intranet/pages/helper/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:lottie/lottie.dart';

import '../helper/utils.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  String url;
  PrivacyPolicyScreen({Key? key, required this.url}) : super(key: key);

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<PrivacyPolicyScreen> {
  // late final WebViewController _webviewController;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
        bool isUrlLoadingCompleted = true;
  double progress = 0;

  @override
  void dispose() async {
    super.dispose();
    //  debugPrint('Clear cache in dispose $_webviewController');
    // WebViewController webViewController = await _controller.future;
    // await webViewController.clearCache();
  }

showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Lottie.asset('assets/json/loader.json'),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
 

  @override
  Widget build(BuildContext context) {
    print('-----------------URL ${widget.url}');
    return PopScope(
      onPopInvoked: (didPop) async {
        print('didpop ${didPop}');
            if(didPop) {
              return;
            }
            WebViewController webViewController = await _controller.future;
            if ( await webViewController.canGoBack()) {
              print('didpopcan goback');
              webViewController.goBack();
            } else {
              print('didpop vacn goback back');
              Navigator.pop(context);
            }
          },
          canPop: false,
      child: MaterialApp(
        title: "ZLLSaathi",
        theme: ThemeData(
          primaryColor: kPrimaryLightColor,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'ZLLSaathi',
              style: TextStyle(color: Colors.white),
            ), // You can add title here
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: () async {
                WebViewController webViewController = await _controller.future;
                if (await webViewController.canGoBack()) {
                  webViewController.goBack();
                } else {
                  Navigator.pop(context);
                }
                // Navigator.of(context).pop()
              },
            ),
            backgroundColor:
                kPrimaryLightColor, //You can make this transparent
            elevation: 0.0, //No shadow
          ),
          body: WebView(
            javascriptChannels: Set.from([
                JavascriptChannel(
                    name: 'Print',
                    onMessageReceived: (JavascriptMessage message) {
                      //This is where you receive message from 
                      //javascript code and handle in Flutter/Dart
                      //like here, the message is just being printed
                      //in Run/LogCat window of android studio
                      print('FROM FLUTTER --- ${message.message}');
                    })
              ]),
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (String url) {
                isUrlLoadingCompleted = false;
                print('FLWEB- show dialog');
                //showLoaderDialog(context);
                print('FLWEB-Page started loading: $url');
              },
              onProgress: (int progress) {
                print('FLWEB- WebView is loading (onProgress : $progress%)');
                if (progress >= 100 && !isUrlLoadingCompleted) {
                  isUrlLoadingCompleted = true;
                  print('FLWEB- hide dialog');
                  Navigator.of(context, rootNavigator: true).pop('dialog');

                  //Navigator.pop(context);
                }else if(progress<100 && isUrlLoadingCompleted){
                  print('FLWEB- show--a dialog');
                  isUrlLoadingCompleted = false;
                  showLoaderDialog(context);
                }
              },
              onWebViewCreated: (c) {
                // _webviewController = c;
                _controller.complete(c);
                print('FLWEB- onWebViewCreated');
                c.clearCache();
              },
              onPageFinished: (String page) async {
                print('FLWEB- onPageFinished');
                setState(() {
                  //_isPageLoaded = true;
                });
              },
              initialUrl: widget.url),
        ),
      ),
    );
  }

  @override
  Widget buildBK(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      //initialUrl: 'https://kidzee.com/PrivacyPolicy',
    );
  }
}
