import 'dart:convert';
import 'dart:io';

class FcmRequestModel {
  String FCM_Reg_ID;
  String Employee_ID;
  String Device_ID;
  String User_Agent;

  FcmRequestModel(
      {required this.FCM_Reg_ID,
        required this.Employee_ID,
        required this.Device_ID,
        required this.User_Agent,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'FCM_Reg_ID': FCM_Reg_ID.trim(),
      'Employee_ID': Employee_ID.trim(),
      'Device_ID': Device_ID.trim(),
      'User_Agent': User_Agent.trim(),
    };

    return map;
  }


  getJson(){
    return jsonEncode( {
      'FCM_Reg_ID': FCM_Reg_ID,
      'Employee_ID': Employee_ID,
      'Device_ID': Device_ID,
      'User_Agent': User_Agent,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }
}