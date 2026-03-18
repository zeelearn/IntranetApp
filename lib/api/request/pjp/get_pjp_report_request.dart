import 'dart:convert';
import 'package:flutter/foundation.dart';

class PJPReportRequest {
  final String employeeCode;
  final String fromDate;
  final String toDate;

  PJPReportRequest(
      {required this.employeeCode,
      required this.fromDate,
      required this.toDate});

  getJson() {
    String appType = 'unknown';
    if (kIsWeb) {
      appType = 'Web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appType = 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      appType = 'IOS';
    }

    return jsonEncode({
      'EmployeeCode': employeeCode,
      'FromDate': null /* fromDate */,
      'ToDate': null /* toDate */,
      'AppType': appType
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'EmployeeCode': "$employeeCode",
      'FromDate': fromDate,
      'ToDate': toDate
    };
    return map;
  }
}
