// import 'dart:io';

// import 'package:Intranet/pages/helper/constants.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';

// class PrivacyPolicyScreen extends StatefulWidget {
//   String url;
//   PrivacyPolicyScreen({
//     Key? key,
//     required this.url
//   }) : super(key: key);
  
//   @override
//   WebViewExampleState createState() => WebViewExampleState();
// }

// class WebViewExampleState extends State<PrivacyPolicyScreen> {
//   late final WebViewController _webviewController;

//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition.
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {

//     print('-----------------URL ${widget.url}');
//     return MaterialApp(
//       title: "ZllSaathi",
//       theme: ThemeData(
//         primaryColor: kPrimaryLightColor,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'ZllSaathi',
//             style: TextStyle(color: Colors.black54),
//           ), // You can add title here
//           leading: new IconButton(
//             icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           backgroundColor:
//               Colors.blue.withOpacity(0.3), //You can make this transparent
//           elevation: 0.0, //No shadow
//         ),
//         body: WebView(
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (c) {
//             _webviewController = c;
//             print("cleaning the cache");
//             _webviewController.clearCache();
//           },
//           onPageFinished: (String page) async {
//             setState(() {
//               //_isPageLoaded = true;
//             });
//           },
//           initialUrl: widget.url
//         ),
//       ),
//     );
//   }

//   @override
//   Widget buildBK(BuildContext context) {
//     return WebView(
//       initialUrl: widget.url,
//       //initialUrl: 'https://kidzee.com/PrivacyPolicy',
//     );
//   }
// }
