import 'package:Intranet/pages/helper/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:location_geocoder/geocoder.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/theme/colors/light_colors.dart';
import 'LightColor.dart';
import 'LocalConstant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum TaskPageStatus {
  all,
  completed,
  active,
  details,
}

class Utility{

  static int ACTION_OK=100012;
  static int ACTION_CONFIRM=100018;
  static int ACTION_ALERT_OK=100019;
  static int ACTION_REJECT=100014;
  static int ACTION_CCNCEL=100013;
  static int ACTION_ADDPJP=100015;
  static int ACTION_IMAGE_UPLOAD_RESPONSE_OK=100015;
  static int ACTION_IMAGE_UPLOAD_RESPONSE_ERROR=100016;

  static void openPermisisonSettings(BuildContext context){
    AlertDialog alertBox = AlertDialog(
      title: new Text('Permission Required'),
      content: new Text(
          'Please give the required Location permission for Intranet App'),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
          style: ElevatedButton.styleFrom(
              elevation: 10.0,
              textStyle: const TextStyle(color: LightColors.kDarkBlue)),
          child: const Text('Cancel'),
        ),ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await Utility.openSetting();
          },
          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
          style: ElevatedButton.styleFrom(
              elevation: 10.0,
              textStyle: const TextStyle(color: LightColors.kDarkBlue)),
          child: const Text('Open Settings'),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertBox;
      },
    );
  }
  static void showMessageCallback(BuildContext context,String title,String message,onClickListener listener) {
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
                listener.onClick(ACTION_OK, '');
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 10.0,
                  textStyle: const TextStyle(color: LightColors.kDarkBlue)),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static showLoader(){
    return Center(child: Lottie.asset('assets/json/loading.json',height: 200),);
  }

  static String formatDate() {
    String date='';
    DateTime dt = DateTime.now();
    try {
      date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String getServerDate() {
    String date ='';
    DateTime dt = DateTime.now();
    try {
      date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static getConfirmationDialogPJP(BuildContext context,onResponse response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: 'Thank you for Approve the PJP',
      title: 'Approved',
      titleStyle: LightColors.textHeaderStyle13,
      msgStyle: LightColors.textHeaderStyle13,
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

  static getConfirmationDialog(BuildContext context,String title,String description,onClickListener response){
    Dialogs.materialDialog(
      titleStyle: LightColors.textHeaderStyle13,
      msgStyle: LightColors.textHeaderStyle13,
      color: Colors.white,
      msg: description,
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
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_OK,'SUCCESS');
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


  static String parseShortTime(String value) {
    String date =value;
    DateTime dt = DateTime.now();
    //print('value ${value}');
    try {

      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
      //print('dt ${dt.day}');
      date = DateFormat("hh:mm a").format(dt);
      //print('date ${date}');
    } catch (e) {
      e.toString();
    }
    return date;
  }


  static getConfirmation(BuildContext context,String title,String description,onClickListener response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: description,
      title: title,
      titleStyle: GoogleFonts.roboto(
        fontSize: 16.0,
        height: 1,
      ),
      lottieBuilder: Lottie.asset(
        'assets/json/alert.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_OK,'SUCCESS');
            });
          },
          text: 'Cancel',
          iconData: Icons.cancel,
          color: LightColors.kRed,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CONFIRM,'SUCCESS');
            });
          },
          text: 'Confirm',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }
  static openSetting() async{
    print('open setting');
    await  openAppSettings();
  }

  static Future<bool> isOfflineEligble(String value) async {
    final prefs = await SharedPreferences.getInstance();
    int _currentSelection=prefs.containsKey(LocalConstant.KEY_SYNC_INTERVAL) ? prefs.getInt(LocalConstant.KEY_SYNC_INTERVAL) as int : 4;
    print('Current Selection is ${_currentSelection}');
    bool isOfflineEligble = false;
    if(_currentSelection==0){
      return false;
    }
    if(value.isEmpty)
      return false;
    try {
      DateTime from = parseStringDate(value);
      //from = DateTime(from.year, from.month, from.day);
      int numberOfHour =  (DateTime.now().difference(from).inHours).round();
      int numberOfMinutes =  (DateTime.now().difference(from).inMinutes).round();
      if(numberOfHour<=_currentSelection){
        isOfflineEligble = true;
      }
      print('is Offline ${isOfflineEligble}');
    }catch(e){}
    return isOfflineEligble;
  }

  static DateTime parseStringDate(String value) {
    DateTime dt = DateTime.now();
    print('value ${value}');
    try {

      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  static String parseShortDate(String value) {
    String date =value;
    DateTime dt = DateTime.now();
    //print('value ${value}');
    try {
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
      //print('dt ${dt.day}');
      date = DateFormat("dd MMM yy").format(dt);
      //print('date ${date}');
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String parseDateOnly(String value) {
    String date =value;
    DateTime dt = DateTime.now();
    //print('value ${value}');
    try {
      dt = new DateFormat('mm-dd-yy').parse(value);
      //print('dt ${dt.day}');
      date = DateFormat("dd MMM yy").format(dt);
      //print('date ${date}');
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static shareFile(String filename) async{
    debugPrint('shareFile ${filename}');
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
      debugPrint('exists');
      isFileExists=true;
    }else{
      debugPrint('NOT exists');
      isFileExists=false;
    }
    return isFileExists;
  }

  static Future<dynamic> downloadFile(String url, String filename) async {
    debugPrint('download url  59 ${url}');
    var httpClient = new HttpClient();
    String dir = (await getTemporaryDirectory()).path;
    debugPrint(dir.toString());
    File file = new File('$dir/$filename');
    debugPrint(file.path.toString());
    try {
      debugPrint('in Download file ${Uri.parse(url)} ${filename}');
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      debugPrint('in Download file completed...');
      return file;
    }catch(e){
      debugPrint(e.toString());
    }
    debugPrint('in Download file completed...');
  }

  static Future<dynamic> downloadContent(String url, String filename) async {
    //String dir = (await getTemporaryDirectory()).path;
    var httpClient = new HttpClient();
    File file = new File(filename);
    debugPrint(filename);
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return file;
    }catch(e){
      debugPrint('error ');
      debugPrint(e.toString());
    }
    debugPrint('in Download file completed...');
  }

  static Future<bool> isInternet() async{
    bool isConnected = true;
    if(kIsWeb){
      return true;
    }else {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          debugPrint('connected');
        }
      } on SocketException catch (_) {
        debugPrint('not connected');
        isConnected = false;
      }
    }
    return isConnected;
  }


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
    debugPrint('value ${value1} and ${total} ${percentage}');
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

  static getShortDateTime(String value){
    return shortDateTime(convertDate(value));
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
  static String shortDateTime(DateTime date) {
    String value='';
    //2022-07-18T00:00:00
    try {
      value = new DateFormat('d-MMM, hh:mm a').format(date);
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
    //debugPrint('${Utility.shortDate(start)} to ${Utility.shortDate(end)} : days ${days}');
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
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }


  static getAlertDialog(BuildContext context,String message,onClickListener response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: message,
      title: 'Alert',
      lottieBuilder: Lottie.asset(
        'assets/json/error.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_ADDPJP, 'addpjp');
            });
          },
          text: 'ADD PJP',
          iconData: Icons.location_pin,
          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_OK, 'ok');
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
            debugPrint('click functions listener......');
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

  static onApproveConfirmation(BuildContext context,String title,String message,onClickListener response){
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
              Navigator.of(context).pop();
              response.onClick(ACTION_OK, 'onConfirmationBox');
            });
          },
          text: 'Cancel',
          iconData: Icons.clear,
          color: Colors.red,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context).pop();
              response.onClick(ACTION_CONFIRM, 'onConfirmationBox');
            });
          },
          text: 'Delete',
          color: kPrimaryLightColor,
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

  static showWarning(BuildContext context,String title,String description,String filename,String oklabel,onClickListener response){
    Dialogs.materialDialog(
      color: Colors.white,
      msg: '${description}',
      title: '${title}',
      titleStyle: TextStyle(color: Colors.black54),
      msgStyle: TextStyle(color: Colors.black54),
      lottieBuilder: Lottie.asset(
        'assets/json/${filename}.json',
        fit: BoxFit.contain,
        width: 20
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CONFIRM,'Alert');
            });
          },
          text: oklabel,

          color: Colors.blue,
          textStyle: TextStyle(color: Colors.white),
          iconColor: Colors.red,
        ),IconsButton(
          onPressed: () {
            Future.delayed(Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CCNCEL,'Cancel');
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

  static getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      return 'Unknown address';
    }

    Placemark placemark = placemarks.first;
    String address = '';
    print(placemark.toString());
    if (placemark.street != null) {
      address += '${placemark.street}  , ';
    }else if (placemark.thoroughfare !=null){
      address += '${placemark.thoroughfare}, ';
    }

    if (placemark.subLocality != null) {
      address += '${placemark.subLocality}, ';
    }
    if (placemark.locality != null) {
      address += '${placemark.locality}, ';
    }
    if (placemark.administrativeArea != null) {
      address += '${placemark.administrativeArea}, ';
    }
    if (placemark.country != null) {
      address += '${placemark.country}';
    }
    if (placemark.postalCode != null) {
      address += ', ${placemark.postalCode}';
    }
    return address;
  }

  static getAddress1(double latitude,double longitude) async
  {
    final LocatitonGeocoder geocoder = LocatitonGeocoder(LocalStrings.kGoogleApiKey);
    final address = await geocoder.findAddressesFromCoordinates(Coordinates(latitude, longitude));
    return address.first.addressLine;
  }



}