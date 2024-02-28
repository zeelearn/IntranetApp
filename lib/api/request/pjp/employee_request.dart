import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class EmployeeListRequest {
  int SuperiorId;


  EmployeeListRequest(
      {required this.SuperiorId});

  getJson(){
    return jsonEncode( {
      'SuperiorId': SuperiorId,
      'AppType' : kIsWeb ? 'web' : Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'SuperiorId': SuperiorId
    };
    return map;
  }
}