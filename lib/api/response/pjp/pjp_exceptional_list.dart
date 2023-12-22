class PjpExceptionalResponse {
  late String responseMessage;
  late int statusCode;
  late List<PjpExceptionalModel> responseData;

  PjpExceptionalResponse(
      {required this.responseMessage, required this.statusCode,required this.responseData});

  PjpExceptionalResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <PjpExceptionalModel>[];
      json['responseData'].forEach((v) {
        responseData!.add(new PjpExceptionalModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

enum PJPCVFStatus { UNKNOWN, APPROVE, REJECTED }


class PjpExceptionalModel {
  late final int employeeId;
  late final String employeeCode;
  late final String displayName;
  late final int pjPId;
  late final int pjpcvFId;
  late final String visitDate;
  late final String dateTimeIn;
  late final String dateTimeOut;
  late final String isExpectionallyApproved;

  PjpExceptionalModel(
      {required this.employeeId,
        required this.employeeCode,
        required this.displayName,
        required this.pjPId,
        required this.pjpcvFId,
        required this.visitDate,
        required this.dateTimeIn,
        required this.dateTimeOut});

  PjpExceptionalModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_Id'].round();
    employeeCode = json['employee_Code'] ?? '';
    displayName = json['displayName'] ?? '';
    pjPId = json['pjP_Id'].round();
    pjpcvFId = json['pjpcvF_Id'].round();
    visitDate = json['visit_Date'] ?? '';
    dateTimeIn = json['dateTimeIn'] ?? '';
    dateTimeOut = json['dateTimeOut'] ?? '';
    isExpectionallyApproved =  json['isExpectionallyApproved'] == null ? 'null' : json['isExpectionallyApproved'] == true ? 'true' : 'false';
  }

  getStatus(){
    return   isExpectionallyApproved == 'null' ? PJPCVFStatus.UNKNOWN : isExpectionallyApproved =='true' ? PJPCVFStatus.APPROVE : PJPCVFStatus.REJECTED;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_Id'] = this.employeeId;
    data['employee_Code'] = this.employeeCode;
    data['displayName'] = this.displayName;
    data['pjP_Id'] = this.pjPId;
    data['pjpcvF_Id'] = this.pjpcvFId;
    data['visit_Date'] = this.visitDate;
    data['dateTimeIn'] = this.dateTimeIn;
    data['dateTimeOut'] = this.dateTimeOut;
    data['isExpectionallyApproved'] = this.isExpectionallyApproved;
    return data;
  }
}
