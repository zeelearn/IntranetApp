import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class PJPReportRequest {
  final String employeeCode;
  final String? fromDate;
  final String? toDate;
  final String businessId;

  PJPReportRequest(
      {required this.employeeCode,
      this.fromDate,
      this.toDate,
      required this.businessId});

  getJson() {
    String appType = 'unknown';
    if (kIsWeb) {
      appType = 'Web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appType = 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      appType = 'IOS';
    }

    print(
      'Encoded data is - ${employeeCode} - ${businessId} - ${fromDate} - ${toDate} - ${appType}  ',
    );
    return jsonEncode({
      'EmployeeCode': employeeCode,
      'BusinessId': businessId,
      'FromDate': /* null */ fromDate,
      'ToDate': /*  null */ toDate,
      'AppType': appType
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'EmployeeCode': "$employeeCode",
      'FromDate': fromDate,
      'ToDate': toDate,
      'BusinessId': businessId
    };
    return map;
  }
}
