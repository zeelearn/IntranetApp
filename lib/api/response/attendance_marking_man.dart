class AttendanceMarkingManResponse {
  late String responseMessage;
  late int statusCode;
  late List<AttendanceReqManModel> responseData;

  AttendanceMarkingManResponse(
      {required this.responseMessage, required this.statusCode, required this.responseData});

  AttendanceMarkingManResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = [];
      json['responseData'].forEach((v) {
        responseData.add(new AttendanceReqManModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttendanceReqManModel {
  late double requisitionId;
  late double employeeId;
  late String employeeName;
  late String superiorName;
  late String date;
  late String inTime;
  late String outTime;
  late String worklocation;
  late String reason;
  late String status;
  late String requisitionTypeCode;
  late String workflowTypeCode;

  AttendanceReqManModel(
      {required this.requisitionId,
        required this.employeeId,
        required this.employeeName,
        required this.superiorName,
        required this.date,
        required this.inTime,
        required this.outTime,
        required this.worklocation,
        required this.reason,
        required this.status,
        required this.requisitionTypeCode,
        required this.workflowTypeCode});

  AttendanceReqManModel.fromJson(Map<String, dynamic> json) {
    requisitionId = json['requisition_Id'];
    employeeId = json['employee_Id'];
    employeeName = json['employee_Name'];
    superiorName = json['superior_Name'];
    date = json['date'];
    inTime = json['in_Time'];
    outTime = json['out_Time'];
    worklocation = json['worklocation'];
    reason = json['reason'];
    status = json['status'];
    requisitionTypeCode = json['requisitionTypeCode'];
    workflowTypeCode = json['workflowTypeCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requisition_Id'] = this.requisitionId;
    data['employee_Id'] = this.employeeId;
    data['employee_Name'] = this.employeeName;
    data['superior_Name'] = this.superiorName;
    data['date'] = this.date;
    data['in_Time'] = this.inTime;
    data['out_Time'] = this.outTime;
    data['worklocation'] = this.worklocation;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['requisitionTypeCode'] = this.requisitionTypeCode;
    data['workflowTypeCode'] = this.workflowTypeCode;
    return data;
  }
}
