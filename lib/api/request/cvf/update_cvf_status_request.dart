import 'dart:convert';

class UpdateCVFStatusRequest {
  late String PJPCVF_id;
  late String DateTime;
  late String Status;
  late int Employee_id;
  late double Latitude;
  late double Longitude;

  UpdateCVFStatusRequest(
      {required this.PJPCVF_id,required this.DateTime,required this.Status,required this.Employee_id,required this.Latitude,required this.Longitude
      });

  getJson(){
    return jsonEncode( {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
      'Latitude': Latitude,
      'Longitude': Longitude,
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJPCVF_id': PJPCVF_id,
      'DateTime': DateTime,
      'Status': Status,
      'Employee_id': Employee_id,
      'Latitude': Latitude,
      'Longitude': Longitude,
    };
    return map;
  }
}