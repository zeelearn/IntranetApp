import 'dart:convert';

class PJPListRequest {
  final int Employee_id;
  final int PJP_id;


  PJPListRequest(
      {required this.Employee_id,this.PJP_id=0});

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
      'PJP_id':PJP_id
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