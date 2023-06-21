import 'dart:convert';
import 'dart:io';

class CheckPhpRequest {
  late String Employee_id;
  late String OnDate;

  CheckPhpRequest({required this.Employee_id,required this.OnDate});

  CheckPhpRequest.fromJson(Map<String, dynamic> json) {
    Employee_id = json['Employee_id'];
    OnDate = json['OnDate'];
  }

  toJson() {
    return jsonEncode( {
      'Employee_id': this.Employee_id,
      'OnDate': this.OnDate,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });

  }
}
