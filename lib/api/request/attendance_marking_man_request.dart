import 'dart:convert';

class AttendanceMarkingManRequest {
  String Role;
  String Status;
  String Employee_Id;
  String ToDate;
  String FromDate;
  String Type;


  AttendanceMarkingManRequest(
      {required this.Role,
        required this.Status,
        required this.Employee_Id,
        required this.ToDate,
        required this.FromDate,
        required this.Type,

      });

  getJson(){
    return jsonEncode( {
      'Role': Role,
      'Status': Status.trim(),
      'Employee_Id': Employee_Id.trim(),
      'ToDate': ToDate.trim(),
      'FromDate': FromDate.trim(),
      'Type': Type.trim(),
    });
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Role': Role,
      'Status': Status.trim(),
      'Employee_Id': Employee_Id.trim(),
      'ToDate': ToDate.trim(),
      'FromDate': FromDate.trim(),
      'Type': Type.trim(),

    };

    return map;
  }
}