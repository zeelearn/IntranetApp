import 'dart:convert';

class GetAllCVF {
  int Employee_id;

  GetAllCVF(
      {required this.Employee_id
      });

  getJson(){
    return jsonEncode( {
      'Employee_id': Employee_id,
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_id': Employee_id,

    };
    return map;
  }
}