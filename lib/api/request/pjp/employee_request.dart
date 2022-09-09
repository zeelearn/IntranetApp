import 'dart:convert';

class EmployeeListRequest {
  int SuperiorId;


  EmployeeListRequest(
      {required this.SuperiorId});

  getJson(){
    return jsonEncode( {
      'SuperiorId': SuperiorId
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'SuperiorId': SuperiorId
    };
    return map;
  }
}