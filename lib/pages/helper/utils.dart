import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum TaskPageStatus {
  all,
  completed,
  active,
  details,
}

class Utility{


  static Future<bool> isInternet() async{
    bool isConnected = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      isConnected = false;
    }
    return isConnected;
  }

  // static Future<String> getDeviceIdentifier() async {
  //   String? deviceIdentifier = "unknown";
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print("Android device Info");
  //     if(androidInfo==null){
  //       print("----NULL");
  //     }
  //     print("Android device Info ${androidInfo.androidId}");
  //     deviceIdentifier = androidInfo.androidId;
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     deviceIdentifier = iosInfo.identifierForVendor;
  //   } else if (kIsWeb) {
  //     // The web doesnt have a device UID, so use a combination fingerprint as an example
  //     WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
  //     String? userAgent = webInfo.userAgent;
  //     deviceIdentifier = "${webInfo.vendor} ${userAgent as String}";
  //   } else if (Platform.isLinux) {
  //     LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
  //     deviceIdentifier = linuxInfo.machineId;
  //   }
  //   return deviceIdentifier as String;
  // }


  static Container emptyDataSet(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 100,),
          Image.asset(
            'assets/images/ic_empty_box.png',
            height: 200.0,
          ),
          const Text("No Data Found", style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600
          ),),
        ],
      ),
    );
  }

  static String getPercentage(int value1, int total){

    int percentage =  ((value1/total)*100).round();
    print('value ${value1} and ${total} ${percentage}');
    if(percentage==0){
      return '';
    }
    else{
      return 'in ${percentage}';
    }
  }

  static void showMessage(BuildContext context,String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
  static void showMessages(BuildContext context,String? message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message!),
    ));
  }

  static void displaySnackbar(BuildContext context,
      {String msg = "Feature is under development",
        required GlobalKey<ScaffoldState> key}) {
    final snackBar = SnackBar(content: Text(msg));
    if (key != null && key.currentState != null) {
      key.currentState?.hideCurrentSnackBar();
      key.currentState?.showSnackBar(snackBar);
    } else {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }


  static showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

// static launchOnWeb(String url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   }
// }

  static getShortDate(String value){
    return shortDate(convertDate(value));
  }

  static DateTime convertDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-ddTmm:hh:ss').parse(value);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }
  static DateTime convertTime(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('HH:mm:ss').parse(value);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }



  static String convertShortDate(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('yyyy-MM-dd').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }


  static String parseDate(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('yyyy-MM-ddTmm:hh:ss').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }
  static String shortDate(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('dd-MMM').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortTime(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('hh:mm').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }
  static String shortTimeFormat(DateTime date) {
    String value='';
    try {
      value = new DateFormat('hh-mm a').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }
  static String shortTimeAMPM(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('a').format(date);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static int getDateDifference(DateTime start,DateTime end){
    int difference = 1;
    int days = start.difference(end).inDays;
    if(days>1){
      difference = days;
    }
    if(difference>100){
      difference = 1;
    }
    return difference;
  }

}