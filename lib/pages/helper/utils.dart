import 'dart:io';

import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/pjp/models/PjpModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_nominatim/flutter_nominatim.dart';

import '../intro/intro.dart';
import '../utils/theme/colors/light_colors.dart';
import 'LightColor.dart';
import 'LocalConstant.dart';
import 'window_close.dart';

enum TaskPageStatus {
  all,
  completed,
  active,
  details,
}

class Utility {
  static int ACTION_OK = 100012;
  static int ACTION_CONFIRM = 100018;
  static int ACTION_ALERT_OK = 100019;
  static int ACTION_REJECT = 100014;
  static int ACTION_CCNCEL = 100013;
  static int ACTION_ADDPJP = 100015;
  static int ACTION_IMAGE_UPLOAD_RESPONSE_OK = 100015;
  static int ACTION_IMAGE_UPLOAD_RESPONSE_ERROR = 100016;

  static Future<bool?> openPermisisonSettings(BuildContext context) async {
    AlertDialog alertBox = AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
          'Please give the required Location permission for Intranet App'),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
          style: ElevatedButton.styleFrom(
              elevation: 10.0,
              textStyle: const TextStyle(color: LightColors.kDarkBlue)),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            bool isAllowed = await Utility.openSetting();

            Navigator.of(context).pop(isAllowed);
          },
          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
          style: ElevatedButton.styleFrom(
              elevation: 10.0,
              textStyle: const TextStyle(color: LightColors.kDarkBlue)),
          child: const Text('Open Settings'),
        ),
      ],
    );
    showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alertBox;
      },
    );
  }

  static void showMessageCallback(BuildContext context, String title,
      String message, onClickListener listener) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  static showLoader() {
    return Center(
      child: Lottie.asset('assets/json/loading.json', height: 200),
    );
  }

  static String formatDate() {
    String date = '';
    DateTime dt = DateTime.now();
    try {
      date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static getShortMonth(DateTime dt) {
    String date = '';
    try {
      date = DateFormat('MMM').format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String getServerDate() {
    String date = '';
    DateTime dt = DateTime.now();
    try {
      date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static getConfirmationDialogPJP(BuildContext context, onResponse response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static getConfirmationDialog(BuildContext context, String title,
      String description, onClickListener response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_OK, 'SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static String parseShortTime(String value) {
    String date = value;
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
      date = DateFormat("hh:mm a").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static getConfirmation(BuildContext context, String title, String description,
      onClickListener response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_OK, 'SUCCESS');
            });
          },
          text: 'Cancel',
          iconData: Icons.cancel,
          color: LightColors.kRed,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CONFIRM, 'SUCCESS');
            });
          },
          text: 'Confirm',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static Future<bool> openSetting() async {
    return await openAppSettings();
  }

  static Future<bool> isOfflineEligble(String value) async {
    final prefs = await SharedPreferences.getInstance();
    int currentSelection = prefs.containsKey(LocalConstant.KEY_SYNC_INTERVAL)
        ? prefs.getInt(LocalConstant.KEY_SYNC_INTERVAL) as int
        : 4;
    bool isOfflineEligble = false;
    if (currentSelection == 0) {
      return false;
    }
    if (value.isEmpty) {
      return false;
    }
    try {
      DateTime from = parseStringDate(value);
      //from = DateTime(from.year, from.month, from.day);
      int numberOfHour = (DateTime.now().difference(from).inHours).round();
      int numberOfMinutes = (DateTime.now().difference(from).inMinutes).round();
      if (numberOfHour <= currentSelection) {
        isOfflineEligble = true;
      }
    } catch (_) {}
    return isOfflineEligble;
  }

  static DateTime parseStringDate(String value) {
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  static String parseShortDate(String value) {
    String date = value;
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.sss\'Z\'').parse(value);
      date = DateFormat("dd MMM yy").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String parsePJPDateTime(String value) {
    String date = value;
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
      date = DateFormat("dd MMM yy, hh:mm a").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static DateTime parseDateTime(String value) {
    DateTime date = DateTime.now();
    try {
      date = DateFormat('yyyy-MM-dd').parse(value);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String parseDateOnly(String value) {
    String date = value;
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('mm-dd-yy').parse(value);
      date = DateFormat("dd MMM yy").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static String parseCVFDateOnly(String value) {
    String date = value;
    DateTime dt = DateTime.now();
    try {
      dt = DateFormat('yyyy-MM-dd').parse(value);
      date = DateFormat("dd MMM yy").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  static downloadXFile(BuildContext context, String url, String name) async {
    Directory? tempDir = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();
    await FlutterDownloader.enqueue(
      url: url,
      fileName: name, //================File Name
      savedDir: tempDir!.path,
      showNotification: true,
      timeout: 90000,

      requiresStorageNotLow: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(LocalConstant.FILE_DOWNLOAD_REQUEST)),
    );
  }

  static shareFile(String filename) async {
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/$filename';
    //Share.shareXFiles([XFile(path)], text: model.ContentDescription);
    Share.shareXFiles([XFile(path)], text: filename);
  }

  static isFileExists(String fileName) async {
    bool isFileExists = false;
    String dir = (await getTemporaryDirectory()).path;
    String path = '$dir/$fileName';
    if (await File(path).exists()) {
      isFileExists = true;
    } else {
      isFileExists = false;
    }
    return isFileExists;
  }

  static Future<dynamic> downloadFile(String url, String filename) async {
    var httpClient = HttpClient();
    String dir = (await getTemporaryDirectory()).path;
    File file = File('$dir/$filename');
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {}
  }

  static Future<dynamic> downloadContent(String url, String filename) async {
    //String dir = (await getTemporaryDirectory()).path;
    var httpClient = HttpClient();
    File file = File(filename);
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {}
  }

  static Future<bool> isInternet() async {
    bool isConnected = true;
    if (kIsWeb) {
      return true;
    } else {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        }
      } on SocketException catch (_) {
        isConnected = false;
      }
    }
    return isConnected;
  }

  static Widget noInternetDataSet(BuildContext context) {
    return SizedBox(
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

  static isInternetConnected() async {
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

  static Widget emptyDataSet(BuildContext context, String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.4;
        final animationHeight = (maxH * 0.55).clamp(100.0, 200.0);
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: animationHeight,
                child: Lottie.asset(
                  'assets/json/not_found.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    color: LightColor.black,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static footer(String appVersion) {
    return SafeArea(
      child: Container(
        height: 30,
        decoration: const BoxDecoration(
          color: LightColors.kLightGray,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Center(
          child: Text('Intranet_$appVersion'),
        ),
      ),
    );
  }

  static String getPercentage(int value1, int total) {
    int percentage = ((value1 / total) * 100).round();
    if (percentage == 0) {
      return '';
    } else {
      return 'in $percentage';
    }
  }

  static void showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
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


  void showBusinessNotMappedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Access Denied'),
          content: const Text(
            'Business is not mapped for your account.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // closeAppWindow();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showMessageSingleButton(
      BuildContext context, String message, onClickListener listener,
      {dynamic object}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void showMessageMultiButton(
    BuildContext context,
    String actionOk,
    String actionCancel,
    String title,
    String message,
    dynamic object,
    onClickListener listener,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
              child: Text(actionOk),
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
              child: Text(actionCancel),
            ),
          ],
        );
      },
    );
  }

  static void showMessages(BuildContext context, String? message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message!),
    ));
  }

  static void displaySnackbar(BuildContext context,
      {String msg = "Feature is under development",
      required GlobalKey<ScaffoldState> key}) {
    final snackBar = SnackBar(content: Text(msg));
    if (key.currentState != null) {
      //key.currentState?.hideCurrentSnackBar();
      //key.currentState?.showSnackBar(snackBar);
    } else {
      //Scaffold.of(context).hideCurrentSnackBar();
      //Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  static showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

// static launchOnWeb(String url) async {
//   if (await canLaunch(url)) {
//     await launch(url);
//   }
// }

  static getShortDate(String value) {
    return shortDate(convertDate(value));
  }

  static getShortDateTime(String value) {
    return shortDateTime(convertDate(value));
  }

  static DateTime convertDate(String value) {
    try {
      // Try parsing as ISO 8601 format first (e.g., "2023-10-27T10:00:00")
      return DateTime.parse(value);
    } catch (e) {
      // Fallback to custom format if ISO parsing fails
      try {
        // Format: "dd-MM-yyyy'T'HH:mm:ss"
        return DateFormat('dd-MM-yyyy\'T\'HH:mm:ss').parse(value);
      } catch (e2) {
        // Return current time as a last resort
        return DateTime.now();
      }
    }
  }

  static DateTime convertServerDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = DateFormat('yyyy-MM-dd').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  static DateTime convertTime(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = DateFormat('HH:mm:ss').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  static String convertShortDate(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String parseDate(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortDate(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('d-MMM').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortDateTime(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('d-MMM, hh:mm a').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortTime(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('hh:mm').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortTimeFormat(DateTime date) {
    String value = '';
    try {
      value = DateFormat('hh-mm a').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static String shortTimeAMPM(DateTime date) {
    String value = '';
    //2022-07-18T00:00:00
    try {
      value = DateFormat('a').format(date);
    } catch (e) {
      e.toString();
    }
    return value;
  }

  static int getDateDifference(DateTime start, DateTime end) {
    int difference = 1;
    int days = end.difference(start).inDays;
    if (days > 1) {
      difference = days;
    }
    days = days + 1;
    if (days > 100) {
      days = 1;
    }
    return days;
  }

  static getDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  static getDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static parseSimpleDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = DateFormat('yyyy-MM-dd').parse(value);
    } catch (e) {
      e.toString();
    }
    return DateFormat('MMM-dd').format(dt);
  }

  static getAlertDialog(
      BuildContext context, String message, onClickListener response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_ADDPJP, 'addpjp');
            });
          },
          text: 'ADD PJP',
          iconData: Icons.location_pin,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_OK, 'ok');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static signOut(BuildContext context) async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    hiveBox.clear();
    hiveBox.close();
    DBHelper helper = DBHelper();
    helper.deleteAllData();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IntroPage(),
        ),
        (route) => false);
    /* if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    } else if (Platform.isIOS) {
      exit(0);
    } */
  }

  static onSuccessMessage(
      BuildContext context, String title, String message, onResponse response) {
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
            //Navigator.of(context, rootNavigator: true).pop();
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onConfirmationBox(
      BuildContext context,
      String actionOk,
      String actionCancel,
      String title,
      String message,
      dynamic action,
      onClickListener response) {
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
            response.onClick(ACTION_OK, action);
            /*Future.delayed(Duration(milliseconds: 50)).then((_) {

            });*/
          },
          text: actionOk,
          iconData: Icons.check,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_CCNCEL, action);
            });
          },
          iconData: Icons.cancel,
          text: actionCancel,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onConfirmationBoxNew(
    BuildContext context,
    String actionOk,
    String actionCancel,
    String title,
    String message,
    dynamic action,
    VoidCallback onReject,
    VoidCallback onApprove,
  ) {
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
            Navigator.pop(context);
            onApprove();
          },
          text: actionOk,
          iconData: Icons.check,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.pop(context);
              onReject();
            });
          },
          iconData: Icons.cancel,
          text: actionCancel,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onApproveConfirmationBox(BuildContext context, String title,
      String message, onClickListener response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_OK, 'onConfirmationBox');
            });
          },
          text: 'Approve',
          iconData: Icons.check,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_REJECT, 'onConfirmationBox');
            });
          },
          text: 'Reject',
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onClick(ACTION_CCNCEL, 'onConfirmationBox');
            });
          },
          text: 'Cancel',
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static onApproveConfirmation(BuildContext context, String title,
      String message, onClickListener response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context).pop();
              response.onClick(ACTION_OK, 'onConfirmationBox');
            });
          },
          text: 'Cancel',
          iconData: Icons.clear,
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context).pop();
              response.onClick(ACTION_CONFIRM, 'onConfirmationBox');
            });
          },
          text: 'Delete',
          color: kPrimaryLightColor,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static getRejectionDialog(
      BuildContext context, String title, String message, onResponse response) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              response.onSuccess('SUCCESS');
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static noInternetConnection(BuildContext context) {
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
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context).pop();
            });
          },
          text: 'OK',
          iconData: Icons.done,
          color: LightColors.kRed,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static Future<Box> openBox() async {
    if (!kIsWeb && !Hive.isBoxOpen(LocalConstant.KidzeeDB)) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
    }
    return await Hive.openBox(LocalConstant.KidzeeDB);
  }

  static showWarning(BuildContext context, String title, String description,
      String filename, String oklabel, onClickListener response) {
    Dialogs.materialDialog(
      color: Colors.white,
      msg: description,
      title: title,
      titleStyle: const TextStyle(color: Colors.black54),
      msgStyle: const TextStyle(color: Colors.black54),
      lottieBuilder: Lottie.asset('assets/json/$filename.json',
          fit: BoxFit.contain, width: 20),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CONFIRM, 'Alert');
            });
          },
          text: oklabel,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.red,
        ),
        IconsButton(
          onPressed: () {
            Future.delayed(const Duration(milliseconds: 50)).then((_) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              response.onClick(ACTION_CCNCEL, 'Cancel');
            });
          },
          text: 'Cancel',
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }

  static Future<String?> getAddress(double latitude, double longitude) async {
    // if (kIsWeb) {
    final nominatim = Nominatim.instance;

    // Get address from coordinates
    Place address = await nominatim.getAddressFromLatLng(latitude, longitude);
    return address.displayName;
    // } else {
    //   List<Placemark> placemarks =
    //       await placemarkFromCoordinates(latitude, longitude);
    //   if (placemarks.isEmpty) {
    //     return 'Unknown address';
    //   }

    //   Placemark placemark = placemarks.first;
    //   String address = '';
    //   if (placemark.street != null) {
    //     address += '${placemark.street ?? ''}  , ';
    //   } else if (placemark.thoroughfare != null) {
    //     address += '${placemark.thoroughfare ?? ''}, ';
    //   }

    //   if (placemark.subLocality != null) {
    //     address += '${placemark.subLocality ?? ''}, ';
    //   }
    //   if (placemark.locality != null) {
    //     address += '${placemark.locality ?? ''}, ';
    //   }
    //   if (placemark.administrativeArea != null) {
    //     address += '${placemark.administrativeArea ?? ''}, ';
    //   }
    //   if (placemark.country != null) {
    //     address += '${placemark.country ?? ''}';
    //   }
    //   if (placemark.postalCode != null) {
    //     address += ', ${placemark.postalCode ?? ''}';
    //   }
    //   return address;
    // }
  }


  Future<void> showPJPStatusDialog({
    required BuildContext pageContext,
    required PJPModel pjp,
    required onClickListener listener,
    required bool isSuccess,
    String? message,
  }) {

    return showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 340,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    color: Color(0x1A000000),
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isSuccess
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.1),
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 42,
                      color: isSuccess
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Title
                  Text(
                    isSuccess
                        ? "PJP Created Successfully"
                        : "Failed to Create PJP",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Subtitle
                  Text(
                    isSuccess
                        ? "Your PJP has been created successfully."
                        : "We couldn't create your PJP. Please try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _infoCard(
                    Icons.calendar_today_outlined,
                    "From Date",
                    DateFormat('MMM dd').format(pjp.fromDate)  ?? "-",
                    isSuccess,
                  ),

                  const SizedBox(height: 12),

                  _infoCard(
                    Icons.calendar_today_outlined,
                    "To Date",
                    DateFormat('MMM dd').format(pjp.toDate)  ?? "-",
                    isSuccess,
                  ),

                  const SizedBox(height: 12),

                  _infoCard(
                    Icons.description_outlined,
                    "Description",
                    pjp.remark ?? "-",
                    isSuccess,
                  ),

                  if (!isSuccess) ...[
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              message ??
                                  "Something went wrong. Please try again.",
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);

                        if (isSuccess) {
                          Navigator.pop(pageContext);
                        }
                        //listener.onClick(Utility.ACTION_OK, pjp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess
                            ? Colors.green
                            : Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSuccess ? "Done" : "OK",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
    bool isSuccess,
  ) {
    final color =
        isSuccess ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Create a Dialog on Fri 19th Jun 2026, to show the confirmation message to Managers before approving or rejecting the PJP. This dialog will display the PJP details and provide options for approval or rejection.
   * 
   */
  String generatePJPApprovalMessage(List<PJPInfo> pjps,isApprove) {
    StringBuffer DocXML = new StringBuffer("<root>");
    for (int index = 0; index < pjps.length; index++) {
        DocXML.write("<subroot><PJP_id>${pjps[index].PJP_Id}</PJP_id><Is_Approved>${isApprove}</Is_Approved></subroot>");
    }
    DocXML.write("</root>");
    return DocXML.toString();
  }

  Future<String?> showPJPApprovalDialog(
    BuildContext context,
    List<PJPInfo> pjps,
  ) {
    //final remarkController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                  maxHeight: 700,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFF3F8F4),
                      child: Icon(
                        Icons.assignment_turned_in,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Approve or Reject PJP(s)?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You are about to approve or reject ${pjps.length} selected PJP(s).',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${pjps.length} PJP(s) Selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Selected PJP(s)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.separated(
                        itemCount: pjps.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final pjp = pjps[index];

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pjp.displayName ?? '-',
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pjp.fromDate} - ${pjp.toDate}',
                                ),
                                if ((pjp.remarks ?? '')
                                    .isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 4,
                                    ),
                                    child: Text(
                                      pjp.remarks!,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // const SizedBox(height: 16),

                    // TextField(
                    //   controller: remarkController,
                    //   maxLines: 3,
                    //   decoration: InputDecoration(
                    //     labelText: 'Comments (Optional)',
                    //     hintText:
                    //         'Enter comments here...',
                    //     border: OutlineInputBorder(
                    //       borderRadius:
                    //           BorderRadius.circular(12),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            onPressed: () {
                              String requestXML = generatePJPApprovalMessage(pjps,false);
                              Navigator.pop(
                                context,
                                requestXML,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Approve',
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green,
                              foregroundColor:
                                  Colors.white,
                            ),
                            onPressed: () {
                              String requestXML = generatePJPApprovalMessage(pjps,true);
                              Navigator.pop(
                                context,
                                requestXML,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
