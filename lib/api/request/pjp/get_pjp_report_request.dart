import 'dart:convert';
import 'dart:io';

class PJPReportRequest {
  final String employeeCode;
  final String fromDate;
  final String toDate;


  PJPReportRequest(
      {required this.employeeCode,required this.fromDate,required this.toDate});

  getJson(){
    return jsonEncode( {
      'EmployeeCode': employeeCode,
      'FromDate':fromDate,
      'ToDate':toDate,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'EmployeeCode': employeeCode,
      'FromDate': fromDate,
      'ToDate': toDate
    };
    return map;
  }
}