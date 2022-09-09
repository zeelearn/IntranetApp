class LeaveListManagerResponse {
  late String responseMessage;
  late int statusCode;
  late List<LeaveInfoMan> responseData;

  LeaveListManagerResponse(
      {required this.responseMessage,required this.statusCode,required this.responseData});

  LeaveListManagerResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = [];
      json['responseData'].forEach((v) {
        responseData.add(new LeaveInfoMan.fromJson(v));
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

class LeaveInfoMan {
  late double requisitionId;
  late double employeeId;
  late String employeeName;
  late String managerName;
  late String employeeCode;
  late String employeeDepartmentName;
  late String leaveType;
  late String fromDay;
  late String toDay;
  late double noOfDays;
  late String reason;
  late String status;
  late String workflowTypeCode;
  late String requisitionTypeCode;
  late String requistionStatusCode;
  late int canCancel;
  late String shift;

  LeaveInfoMan(
      {required this.requisitionId,
        required this.employeeId,
        required this.employeeName,
        required this.managerName,
        required this.employeeCode,
        required this.employeeDepartmentName,
        required this.leaveType,
        required this.fromDay,
        required this.toDay,
        required this.noOfDays,
        required this.reason,
        required this.status,
        required this.workflowTypeCode,
        required this.requisitionTypeCode,
        required this.requistionStatusCode,
        required this.canCancel,
        required this.shift});

  LeaveInfoMan.fromJson(Map<String, dynamic> json) {
    requisitionId = json['requisition_Id'];
    employeeId = json['employee_Id'];
    employeeName = json['employee_Name'];
    managerName = json['manager_Name'];
    employeeCode = json['employee_Code'];
    employeeDepartmentName = json['employee_DepartmentName'];
    leaveType = json['leaveType'];
    fromDay = json['fromDay'];
    toDay = json['toDay'];
    noOfDays = json['noOfDays'];
    reason = json['reason'];
    status = json['status'];
    workflowTypeCode = json['workflowTypeCode'];
    requisitionTypeCode = json['requisitionTypeCode'];
    requistionStatusCode = json['requistion_Status_Code'];
    canCancel = json['can_Cancel'];
    shift = json['shift'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requisition_Id'] = this.requisitionId;
    data['employee_Id'] = this.employeeId;
    data['employee_Name'] = this.employeeName;
    data['manager_Name'] = this.managerName;
    data['employee_Code'] = this.employeeCode;
    data['employee_DepartmentName'] = this.employeeDepartmentName;
    data['leaveType'] = this.leaveType;
    data['fromDay'] = this.fromDay;
    data['toDay'] = this.toDay;
    data['noOfDays'] = this.noOfDays;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['workflowTypeCode'] = this.workflowTypeCode;
    data['requisitionTypeCode'] = this.requisitionTypeCode;
    data['requistion_Status_Code'] = this.requistionStatusCode;
    data['can_Cancel'] = this.canCancel;
    data['shift'] = this.shift;
    return data;
  }
}
