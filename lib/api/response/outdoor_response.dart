class OutdoorResponse {
  late String responseMessage;
  int statusCode=200;
  List<OutdoorModel> responseData=[];

  OutdoorResponse({required this.responseMessage,required  this.statusCode,required  this.responseData});

  OutdoorResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData =[];
      json['responseData'].forEach((v) {
        responseData.add(new OutdoorModel.fromJson(v));
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

class OutdoorModel {
  late double requisitionId;
  late double employeeId;
  late String employeeName;
  late String superiorName;
  late String leaveType;
  late String date;
  late String fromTime;
  late String toTime;
  late double noOfDays;
  late String reason;
  late String status;
  late String requisitionTypeCode;
  late String workflowTypeCode;
  late String workPlannerStatus;
  bool workPlannerActiveStatus=false;

  OutdoorModel(
      {required this.requisitionId,
        required this.employeeId,
        required this.employeeName,
        required this.superiorName,
        required this.leaveType,
        required this.date,
        required this.fromTime,
        required this.toTime,
        required this.noOfDays,
        required this.reason,
        required this.status,
        required this.requisitionTypeCode,
        required this.workflowTypeCode,
        required this.workPlannerStatus,
        required this.workPlannerActiveStatus});

  OutdoorModel.fromJson(Map<String, dynamic> json) {
    requisitionId = json['requisition_Id'] ?? 0.0;
    employeeId = json['employee_Id'] ?? 0;
    employeeName = json['employee_Name'] ?? 'NA';
    superiorName = json['superior_Name'] ?? 'NA';
    leaveType = json['leaveType'] ?? 'NA';
    date = json['date'] ?? 'NA';
    fromTime = json['fromTime'] ?? 'NA';
    toTime = json['toTime'] ?? 'NA';
    noOfDays = json['noOfDays'] ?? 0.0;
    reason = json['reason']  ?? 'NA';
    status = json['status'] ?? 'NA';
    requisitionTypeCode = json['requisitionTypeCode'] ?? 'NA';
    workflowTypeCode = json['workflowTypeCode'] ?? 'NA';
    workPlannerStatus = json['workPlannerStatus'] ?? 'NA';
    workPlannerActiveStatus = json['workPlannerActiveStatus'] ?? 'NA';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requisition_Id'] = this.requisitionId;
    data['employee_Id'] = this.employeeId;
    data['employee_Name'] = this.employeeName;
    data['superior_Name'] = this.superiorName;
    data['leaveType'] = this.leaveType;
    data['date'] = this.date;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    data['noOfDays'] = this.noOfDays;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['requisitionTypeCode'] = this.requisitionTypeCode;
    data['workflowTypeCode'] = this.workflowTypeCode;
    data['workPlannerStatus'] = this.workPlannerStatus;
    data['workPlannerActiveStatus'] = this.workPlannerActiveStatus;
    return data;
  }
}
