import 'dart:convert';

class UpdateCVFStatusRequest {
  late String PJPCVF_id;
  late String DateTime;
  late String Status;
  late int Employee_id;

  UpdateCVFStatusRequest(
      {required this.PJPCVF_id,required this.DateTime,required this.Status,required this.Employee_id
      });

  getJson(){
    return jsonEncode( {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
    };
    return map;
  }
}