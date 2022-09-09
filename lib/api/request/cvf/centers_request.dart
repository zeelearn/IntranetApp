import 'dart:convert';

class CentersRequestModel {
  int EmployeeId;
  int Brand;

  CentersRequestModel(
      {required this.EmployeeId,
        required this.Brand,
      });

  getJson(){
    return jsonEncode( {
      'EmployeeId': EmployeeId,
      'Brand': Brand
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userName': EmployeeId,
      'password': Brand,
    };

    return map;
  }
}