import 'dart:convert';
import 'dart:io';

class PJPListRequest {
  final int Employee_id;
  final int PJP_id;


  PJPListRequest(
      {required this.Employee_id,this.PJP_id=0});

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
      'PJP_id':PJP_id,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_id': Employee_id,
      'PJP_id': PJP_id
    };
    return map;
  }
}