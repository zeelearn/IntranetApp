import 'dart:convert';
import 'dart:io';

class AttendanceMarkingRequest {
  String Employee_Name;
  String Worklocation;
  String Employee_Id;
  String Reason;
  String FromDT;
  String ToDT;


  AttendanceMarkingRequest(
      {required this.Employee_Name,
        required this.Worklocation,
        required this.Employee_Id,
        required this.Reason,
        required this.FromDT,
        required this.ToDT,

      });

  getJson(){
    return jsonEncode( {
      'Employee_Name': Employee_Name,
      'Worklocation': Worklocation.trim(),
      'Employee_Id': Employee_Id.trim(),
      'Reason': Reason.trim(),
      'FromDT': FromDT.trim(),
      'ToDT': ToDT.trim(),
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_Name': Employee_Name,
      'Worklocation': Worklocation.trim(),
      'Employee_Id': Employee_Id.trim(),
      'Reason': Reason.trim(),
      'FromDT': FromDT.trim(),
      'ToDT': ToDT.trim(),

    };

    return map;
  }
}