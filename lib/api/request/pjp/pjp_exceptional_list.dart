import 'dart:convert';
import 'dart:io';

class PJPExceptionalRequest {
  int Manager_Emp_id;

  PJPExceptionalRequest(
      {required this.Manager_Emp_id,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Manager_Emp_id': Manager_Emp_id,
    };

    return map;
  }


  getJson(){
    return jsonEncode( {
      'Manager_Emp_id': Manager_Emp_id,
    });
  }
}