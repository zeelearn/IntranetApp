import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intranet/pages/iface/onClick.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

import '../utils/theme/colors/light_colors.dart';
import 'LightColor.dart';
import 'LocalConstant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum TaskPageStatus {
  all,
  completed,
  active,
  details,
}

class Utility{

  static int ACTION_OK=100012;
  static int ACTION_REJECT=100014;
  static int ACTION_CCNCEL=100013;

  static showLoader(){
    return Lottie.asset('assets/json/loading.json');
  }

  static shareFile(String filename) async{
    print('shareFile ${filename}');
    String dir = (await getTemporaryDirectory()).path;
    String path = '${dir}/${filename}';
    //Share.shareXFiles([XFile(path)], text: model.ContentDescription);
    Share.shareFiles([path], text: filename);
  }

  static isFileExists(String fileName) async{
    bool isFileExists=false;
    String dir = (await getTemporaryDirectory()).path;
    String path = '${dir}/${fileName}';
    if(await File(path).exists()){
      print('exists');
      isFileExists=true;
    }else{
      print('NOT exists');
      isFileExists=false;
    }
    return isFileExists;
  }

  static Future<dynamic> downloadFile(String url, String filename) async {
    print('download url  59 ${url}');
    var httpClient = new HttpClient();
    String dir = (await getTemporaryDirectory()).path;
    print(dir.toString());
    File file = new File('$dir/$filename');
    print(file.path.toString());
    try {
      print('in Download file ${Uri.parse(url)} ${filename}');
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      print('in Download file completed...');
      return file;
    }catch(e){
      print(e.toString());
    }
    print('in Download file completed...');
  }

  static Future<dynamic> downloadContent(String url, String filename) async {
    //String dir = (await getTemporaryDirectory()).path;
    var httpClient = new HttpClient();
    File file = new File(filename);
    print(filename);
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return file;
    }catch(e){
      print('error ');
      print(e.toString());
    }
    print('in Download file completed...');
  }

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

  static Container noInternetDataSet(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /*Image.asset(
            'assets/images/ic_empty_box.png',
            height: 200.0,
          ),*/
          Lottie.asset('assets/json/no_internet_connection.json'),

        ],
      ),
    );
  }

  static isInternetConnected() async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
  static Container emptyDataSet(BuildContext context,String message) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /*Image.asset(
            'assets/images/ic_empty_box.png',
            height: 200.0,
          ),*/
          Lottie.asset('assets/json/not_found.json'),
          Center(
            child: Text(message, style: GoogleFonts.inter(
              fontSize: 16.0,
              color: LightColor.black,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
                textAlign: TextAlign.center,),
          )
        ],
      ),
    );
  }

  static footer(String appVersion){
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: LightColors.kLightGray,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text('Intranet_${appVersion}'),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text(
              message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  static void showMessageSingleButton(BuildContext context,String message,onClickListener listener) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert"),
          content: new Text(
              message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                listener.onClick(ACTION_OK, '');
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showMessageMultiButton(BuildContext context,String actionOk,String actionCancel,String title,String message,dynamic object,onClickListener listener,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(
              message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                listener.onClick(ACTION_OK, object);
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child:  Text(actionOk),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                listener.onClick(ACTION_CCNCEL, object);
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child:  Text(actionCancel),
            ),
          ],
        );
      },
    );
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
      //key.currentState?.hideCurrentSnackBar();
      //key.currentState?.showSnackBar(snackBar);
    } else {
      //Scaffold.of(context).hideCurrentSnackBar();
      //Scaffold.of(context).showSnackBar(snackBar);
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
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }
  static DateTime convertServerDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd').parse(value);
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
    } catch (e) {
      e.toString();
    }
    return value;
  }


  static String parseDate(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }
  static String shortDate(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('d-MMM').format(date);
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
    } catch (e) {
      e.toString();
    }
    return value;
  }
  static String shortTimeFormat(DateTime date) {
    String value='';
    try {
      value = new DateFormat('hh-mm a').format(date);
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
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static int getDateDifference(DateTime start,DateTime end){

    int difference = 1;
    int days = end.difference(start).inDays;
    print('${Utility.shortDate(start)} to ${Utility.shortDate(end)} : days ${days}');
    if(days>1){
      difference = days;
    }
    days=days+1;
    if(days>100){
      days = 1;
    }
    return days;
  }

  static getDateTime(){
    return DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
  }

  static getConfirmationDialog(BuildContext context,onResponse response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: 'Thank you for Approve the PJP',
      title: 'Approved',
      lottieBuilder: Lottie.asset(
        'assets/json/85594-done.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onSuccessMessage(BuildContext context,String title,String message,onResponse response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: message,
      title: title,
      lottieBuilder: Lottie.asset(
        'assets/json/85594-done.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onConfirmationBox(BuildContext context,String actionOk,String actionCancel,String title,String message,dynamic action,onClickListener response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: message,
      title: title,
      lottieBuilder: Lottie.asset(
        'assets/json/75382-question.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.2 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            print('click functions listener......');
            response.onClick(ACTION_OK, action);
            /*Future.delayed(Duration(milliseconds: 50)).then((_) {

            });*/
          },
          text: actionOk,
          iconData: Icons.check,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),

        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_CCNCEL, action);
            });
          },
          iconData: Icons.cancel,
          text: actionCancel,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }
  static onApproveConfirmationBox(BuildContext context,String title,String message,onClickListener response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: message,
      title: title,
      lottieBuilder: Lottie.asset(
        'assets/json/75382-question.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.2 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_OK, 'onConfirmationBox');
            });
          },
          text: 'Approve',
          iconData: Icons.check,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_REJECT, 'onConfirmationBox');
            });
          },
          text: 'Reject',

          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_CCNCEL, 'onConfirmationBox');
            });
          },
          text: 'Cancel',
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static getRejectionDialog(BuildContext context,String title,String message,onResponse response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: message,
      title: title,
      lottieBuilder: Lottie.asset(
        'assets/json/rejected.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static noInternetConnection(BuildContext context){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: 'Internet connection not avaliable please check and try again later',
      title: 'Connectivity Error',
      lottieBuilder: Lottie.asset(
        'assets/json/90478-disconnect.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context).pop();
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: LightColors.kRed,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static Future<Box> openBox() async {
    if (!kIsWeb && !Hive.isBoxOpen(LocalConstant.KidzeeDB))
      Hive.init((await getApplicationDocumentsDirectory()).path);
    return await Hive.openBox(LocalConstant.KidzeeDB);
  }

}