import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class PJPListRequest {
  final int Employee_id;
  final int Business_id;
  final int PJP_id;


  PJPListRequest(
      {
        required this.Employee_id,
        required this.Business_id,
        this.PJP_id=0});

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
      'Business_id': Business_id,
      'PJP_id':PJP_id,
      'AppType' : kIsWeb ? 'web' :  Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_id': Employee_id,
      'Business_id': Business_id,
      'PJP_id': PJP_id
    };
    return map;
  }
}