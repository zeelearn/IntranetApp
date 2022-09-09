import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class Helpers{
  void nextScreen(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;



  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}

class AppColors {
  static const red = Color(0xFFDB3022);
  static const black = Color(0xFF222222);
  static const lightGray = Color(0xFF9B9B9B);
  static const darkGray = Color(0xFF979797);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFFFBA49);
  static const background = Color(0xFFE5E5E5);
  static const backgroundLight = Color(0xFFF9F9F9);
  static const transparent = Color(0x00000000);
  static const success = Color(0xFF2AA952);
  static const green = Color(0xFF2AA952);

  static const Color dark = Colors.black;
  static const Color darkGrey = Color(0x50000000);
  static const Color primary = Color(0xFFEC407A);
  static const Color primaryLight = Color(0xFFf48fb1);
  static const Color primarySoft = Color(0xFFF6E1EC);
  static const Color primaryAccent = Color(0xFFAD1457);
  static const Color secondary = Color(0xFF241B50);
  static const Color disabled = Color(0xFFEBEBE4);
  static const Color lightGrey = Color(0xFFf5f5f5);
  static const Color greenAccent = Color(0xFF4CAF50);
}

/// This dialog will basically show up right on top of the webview.
///
/// AlertDialog is a widget, so it needs to be wrapped in `WebViewAware`, in order
/// to be able to interact (on web) with it.
///
/// Read the `Readme.md` for more info.
/*void showAlertDialog(String content, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => WebViewAware(
      child: AlertDialog(
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}


Future<String> getUniqueDeviceId() async {
  String uniqueDeviceId = '';

  var deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    uniqueDeviceId = '${iosDeviceInfo.identifierForVendor}'; // unique ID on iOS
  } else if(Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    uniqueDeviceId = '${androidDeviceInfo.androidId}' ; // unique ID on Android
  }
  return uniqueDeviceId;
}*/


void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 1),
      ),
    );
}

Widget createButton({
  VoidCallback? onTap,
  required String text,
}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    ),
    child: Text(text),
  );
}