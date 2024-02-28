import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class OutdoorRequest {
  String Employee_Id;
  String LeaveType;
  String device;
  String Role;
  String FromDate;
  String ToDate;


  OutdoorRequest(
      {required this.Employee_Id,
        required this.LeaveType,
        required this.device,
        required this.Role,
        required this.FromDate,
        required this.ToDate,
      });

  getJson(){
    return jsonEncode( {
      'Employee_Id': Employee_Id.trim(),
      'LeaveType': LeaveType.trim(),
      'device': device.trim(),
      'Role': Role.trim(),
      'FromDate': FromDate.trim(),
      'ToDate': ToDate.trim(),
      'AppType' :kIsWeb ?'web' : Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_Id': Employee_Id.trim(),
      'LeaveType': LeaveType.trim(),
      'device': device.trim(),
      'Role': Role.trim(),
      'FromDate': FromDate.trim(),
      'ToDate': ToDate.trim(),
    };

    return map;
  }
}