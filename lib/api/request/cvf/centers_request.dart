import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class CentersRequestModel {
  int EmployeeId;
  int Brand;

  CentersRequestModel({
    required this.EmployeeId,
    required this.Brand,
  });

  getJson() {
    return jsonEncode({
      'EmployeeId': EmployeeId,
      'Brand': Brand,
      'AppType': kIsWeb
          ? 'Web'
          : Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
                  ? 'IOS'
                  : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userName': EmployeeId,
      'password': Brand,
    };

    return map;
  }
}
