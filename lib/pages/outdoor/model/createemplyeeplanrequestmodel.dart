// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:flutter/material.dart";
import "package:hive/hive.dart";

import "../../helper/LocalConstant.dart";

class CreateEmployeeRequestModel {
  var hive = Hive.box(LocalConstant.KidzeeDB);
  List<XMLRequest> xmlrequest;
  String date;
  var employeeID, businessID, businessuserID;

  CreateEmployeeRequestModel({required this.date, required this.xmlrequest}) {
    employeeID = hive.get(LocalConstant.KEY_EMPLOYEE_ID);
    businessID = hive.get(LocalConstant.KEY_BUSINESS_ID, defaultValue: 0);
    businessuserID =
        hive.get(LocalConstant.KEY_BUSINESS_USERID, defaultValue: 0);
    // var loginresponse = hive.get(LocalConstant.KEY_LOGIN_RESPONSE);

    /*  try {
      LoginResponseModel response = LoginResponseModel.fromJson(
        json.decode(loginresponse),
      );

      businessuserID =
          response.responseData.businessApplications[0].business_UserID;
    } catch (e) {
      debugPrint("error - $e");
    } */
  }

  @override
  String toString() {
    var listObjectEncoded = '''"{'root': {'subroot': $xmlrequest}}"''';
    var request =
        '''{
      "business_id": "$businessID",
      "business_user_id": "$businessuserID",
      "employee_id": "$employeeID",
      "date": "$date",
      "xml": $listObjectEncoded
    }''';
    debugPrint("request for createplan api is - $request");
    return request;
  }
}

class XMLRequest {
  int centerId;
  int id;
  String fromDate;
  String toDate;
  String eventName, url, remark;

  XMLRequest(
      {required this.id,
      required this.centerId,
      required this.fromDate,
      required this.toDate,
      required this.remark,
      required this.eventName,
      required this.url});

  @override
  String toString() {
    return '''{'id': '$id','center_id': '$centerId','remarks': '$remark','eventName': '$eventName','url': '$url'}''';
  }
}
