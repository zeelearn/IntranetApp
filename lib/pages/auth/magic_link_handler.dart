import 'dart:convert';
import 'package:Intranet/api/request/login_request.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../api/APIService.dart';
import '../../api/response/login_response.dart';
import '../firebase/anylatics.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';
import '../home/IntranetHomePage.dart';

class MagicLinkHandler {
  static String? _lastHandledToken;

  static Future<void> handle(Uri uri, BuildContext context) async {
    final token = uri.queryParameters['t'];
    final source = uri.queryParameters['s'];

    if (token == null || token.isEmpty) {
      return; // Not a magic link
    }

    if (token == _lastHandledToken) {
      return; // Prevent duplicate execution
    }
    _lastHandledToken = token;

    Utility.showLoaderDialog(context);

    try {
     
      final value = await APIService()
          .login(LoginRequestModel(token: token, source: source));
      // final value = await APIService().magicLogin(token);

      if (value != null &&
          value is! LoginResponseInvalid &&
          value.responseData != null) {
        List<EmployeeDetails> infoList = value.responseData.employeeDetails;
        if (infoList.isEmpty) {
          Navigator.pop(context);
          Utility.showMessage(context, 'Invalid Magic Link');
        } else {
          EmployeeDetails info = value.responseData.employeeDetails[0];
          await Hive.openBox(LocalConstant.KidzeeDB);
          var hive = Hive.box(LocalConstant.KidzeeDB);

          hive.put(LocalConstant.KEY_EMPLOYEE_ID,
              info.employeeId.toInt().toString());
          hive.put(LocalConstant.KEY_EMPLOYEE_CODE, info.employeeCode);
          hive.put(LocalConstant.KEY_FIRST_NAME, info.employeeFirstName);
          hive.put(LocalConstant.KEY_LAST_NAME, info.employeeLastName);
          hive.put(LocalConstant.KEY_DOJ, info.employeeDateOfJoining);
          hive.put(LocalConstant.KEY_EMP_SUPERIOR_ID,
              info.employeeSuperiorId.toInt().toString());
          hive.put(LocalConstant.KEY_DEPARTMENT, info.employeeDepartmentName);
          hive.put(LocalConstant.KEY_DESIGNATION, info.employeeDesignation);
          hive.put(LocalConstant.KEY_EMAIL, info.employeeEmailId);
          hive.put(LocalConstant.KEY_CONTACT, info.employeeContactNumber);
          hive.put(LocalConstant.KEY_IS_ACTIVE, info.isActive);
          hive.put(LocalConstant.KEY_ISCEO, info.isCEO);
          hive.put(LocalConstant.KEY_IS_BUSINESS_HEAD, info.isBusinessHead);
          hive.put(LocalConstant.KEY_USER_NAME, info.userName);
          hive.put(LocalConstant.KEY_USER_PASSWORD, info.userPassword);
          hive.put(LocalConstant.KEY_DOB, info.employeeDateOfBirth);
          hive.put(LocalConstant.KEY_GRADE, info.employeeGrade);
          hive.put(
              LocalConstant.KEY_DATE_OF_MARRAGE, info.employeeDateOfMarriage);
          hive.put(LocalConstant.KEY_LOCATION, info.employeeLocation);
          hive.put(LocalConstant.KEY_GENDER, info.gender);

          FirebaseAnalyticsUtils.sendEvent(info.userName);
          hive.put(LocalConstant.KEY_LOGIN_RESPONSE, jsonEncode(value));

          Navigator.pop(context); // close loader
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => IntranetHomePage(
                    userId: info.employeeId.toInt().toString())),
          );
        }
      } else {
        Navigator.pop(context);
        Utility.showMessage(context, "Invalid or expired Magic Link");
      }
    } catch (e) {
      Navigator.pop(context);
      Utility.showMessage(context, "Error verifying magic link");
    }
  }

  String encode(String username, String password) {
    return base64Encode(utf8.encode('$username:$password'));
  }

  static String decode(String token) {
    return utf8.decode(base64Decode(token));
  }
}
