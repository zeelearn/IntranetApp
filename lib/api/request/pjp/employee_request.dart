import 'dart:convert';
import 'dart:io';

class EmployeeListRequest {
  int SuperiorId;


  EmployeeListRequest(
      {required this.SuperiorId});

  getJson(){
    return jsonEncode( {
      'SuperiorId': SuperiorId,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'SuperiorId': SuperiorId
    };
    return map;
  }
}