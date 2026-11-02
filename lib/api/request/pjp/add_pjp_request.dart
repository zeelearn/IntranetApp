import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class AddPJPRequest {
  final int PJP_Id = 0;
  final int Business_Id;
  final String Visit_Type = '';
  String remarks = '';
  String FromDate;
  String ToDate;
  String ByEmployee_Id;
  int Is_Submit = 1;

  String? state;
  String? city;
  int? cityId;

  AddPJPRequest({
    required this.Business_Id,
    required this.FromDate,
    required this.ToDate,
    required this.ByEmployee_Id,
    required this.remarks,
    this.state,
    this.city,
    this.cityId,
  });

  getJson() {
    Map<String, dynamic> data = {
      'PJP_Id': PJP_Id,
      'Business_Id': Business_Id,
      'Visit_Type': Visit_Type,
      'remarks': base64Encode(utf8.encode(remarks.trim())),
      'FromDate': FromDate,
      'ToDate': ToDate,
      'ByEmployee_Id': ByEmployee_Id,
      'Is_Submit': Is_Submit,
      'AppType': kIsWeb
          ? 'Web'
          : Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
                  ? 'IOS'
                  : 'unknown'
    };
    if (state != null && state!.isNotEmpty) {
      data['state_name'] = state;
      // data['State_Name'] = state;
    }
    if (city != null && city!.isNotEmpty) {
      // data['City'] = city;
      data['city_name'] = city;
    }
    if (cityId != null && cityId! > 0) {
      data['city_id'] = cityId;
    }
    return jsonEncode(data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJP_Id': PJP_Id,
      'Business_Id': Business_Id,
      'Is_Submit': Is_Submit,
      'ByEmployee_Id': ByEmployee_Id,
      'Visit_Type': Visit_Type.trim(),
      'remarks': remarks.trim(),
      'FromDate': FromDate.trim(),
      'ToDate': ToDate.trim(),
    };
    if (state != null && state!.isNotEmpty) {
      map['State'] = state;
      map['State_Name'] = state;
    }
    if (city != null && city!.isNotEmpty) {
      map['City'] = city;
      map['City_Name'] = city;
    }
    if (cityId != null && cityId! > 0) {
      map['City_Id'] = cityId;
    }
    return map;
  }
}
