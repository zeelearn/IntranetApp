import 'dart:convert';
import 'dart:io';

class GetAllCVF {
  int Employee_id;

  GetAllCVF(
      {required this.Employee_id
      });

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_id': Employee_id,

    };
    return map;
  }
}