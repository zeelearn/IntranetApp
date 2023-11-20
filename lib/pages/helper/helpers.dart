import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../iface/onClick.dart';
import '../utils/theme/colors/light_colors.dart';

class Helpers{
  void nextScreen(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }
}

Widget buildTextAreaField(
    GlobalKey<FormState> key,
    TextEditingController controller,
    String hintText,
    IconData icon,
    size,
    double width,
    bool isDarkMode,

    ) {
  return Padding(
    padding: EdgeInsets.only(top: size.height * 0.025,bottom: 15),
    child: Container(
      width: width,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xffF7F8F8),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Form(
        key: key,
        child: TextFormField(
          maxLines: 4,
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.deny(
                RegExp(r'\s')),
          ],
          style: LightColors.textHeaderStyle13,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            fillColor: const Color(0xffF7F8F8),
            errorStyle: const TextStyle(height: 0),
            hintStyle: const TextStyle(
              color: Color(0xffADA4A5),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(
              top: 10,
            ),
            hintText: hintText,
            prefixIcon: SizedBox(width: 14,height: 14,
                child: Icon(
                  icon,
                  color: const Color(0xff7B6F72),
                )),
          ),
        ),
      ),
    ),
  );
}


Widget getTextAreaField(GlobalKey<FormState> key,TextEditingController controller,String hint,IconData icon,Size size,double width){
  return Form(
    child: buildTextAreaField(
      key,
      controller,
      hint,
      icon,
      size,
      width,
      false,
    ),
  );
}

Widget getDropdownField(GlobalKey<FormState> key,String title,String hint,List<String> options,onClickListener listener,Size size,double width, int action){
  return Form(
    child: buildDropdownField(
        key,
        title,
        hint,
        options,
        listener,
        size,
        width,
        false,action
    ),
  );
}

Widget buildDropdownField(
    GlobalKey<FormState> key,
    String title,
    String label,
    List<String> options,
    onClickListener listener,
    Size size,
    double width,
    bool isDark,int action
    ) {
  return Padding(
    padding: EdgeInsets.only(top: size.height * 0.025),
    child: Container(
      width: width,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : const Color(0xffF9F9F9),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Form(
        key: key,
        child: getDropdownButton(title,label, options, action, listener),
      ),
    ),
  );
}

Widget getDropdownButton(String title, String _chosenValue,
    List<String> options, int action, onClickListener listener) {
  return Padding(padding: EdgeInsets.only(left: 5,right: 5),
    child: DropdownButton<String>(
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down),
      focusColor: Colors.white,
      value: _chosenValue,
      underline: Container(),
      style: TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: LightColors.textHeaderStyle13,
          ),
        );
      }).toList(),
      hint: Text(
        title,
        style: TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onChanged: (value) {
        _chosenValue = value!;
        listener.onClick(action, value);
      },
    ),);
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
 /* ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 1),
      ),
    );*/
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