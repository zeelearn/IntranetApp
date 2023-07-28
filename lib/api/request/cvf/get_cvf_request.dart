import 'dart:convert';
import 'dart:io';

class GetAllCVF {
  int Employee_id;
  int Business_id;

  GetAllCVF(
      {
        required this.Employee_id,
        required this.Business_id,
      });

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
      'Business_id': Business_id,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_id': Employee_id,
      'Business_id': Business_id,
    };
    return map;
  }
}