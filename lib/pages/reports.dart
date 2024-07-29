// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';

// class MyReportScreen extends StatefulWidget {
//   String title;
//   String url;

//   MyReportScreen({Key? key, required this.title,required this.url})
//       : super(key: key);

//   @override
//   WebViewExampleState createState() => WebViewExampleState();
// }

// class WebViewExampleState extends State<MyReportScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition.
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: widget.title,
//       home: Scaffold(
//         appBar:  AppBar(
//           title: Text('My Reports'),// You can add title here
//           leading: new IconButton(
//             icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           backgroundColor: Colors.blue.withOpacity(0.7), //You can make this transparent
//           elevation: 0.0, //No shadow
//         ),
//         body: WebView(
//           initialUrl: widget.url,
//           javascriptMode: JavascriptMode.unrestricted,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget buildBK(BuildContext context) {
//     return const WebView(
//       initialUrl: 'https://www.kidzee.com/Home/PrivacyPolicy',
//     );
//   }
// }