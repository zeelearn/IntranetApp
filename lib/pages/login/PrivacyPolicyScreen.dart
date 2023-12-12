import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<PrivacyPolicyScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Privacy Policy",
      home: Scaffold(
        appBar:  AppBar(
          title: Text(''),// You can add title here
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.blue.withOpacity(0.3), //You can make this transparent
          elevation: 0.0, //No shadow
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://kidzee.com/PrivacyPolicy',
        ),
      ),
    );
  }

  @override
  Widget buildBK(BuildContext context) {
    return WebView(
      initialUrl: 'https://kidzee.com/PrivacyPolicy',
    );
  }
}