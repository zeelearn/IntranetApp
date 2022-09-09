class EmployeeListResponse {
  late String responseMessage;
  late int statusCode;
  late List<EmployeeInfo> responseData;

  EmployeeListResponse(
      {required this.responseMessage,required  this.statusCode,required  this.responseData});

  EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = [];
      json['responseData'].forEach((v) {
        responseData.add(new EmployeeInfo.fromJson(v));
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

class EmployeeInfo {
  late String employeeFullName;
  late String employeeContactNumber;
  late String employeeEmailId;
  late String employeeCode;
  late String employeeDesignation;
  late String empAppStatus;
  late String display;

  EmployeeInfo(
      {required this.employeeFullName,
        required this.employeeContactNumber,
        required this.employeeEmailId,
        required this.employeeCode,
        required this.employeeDesignation,
        required this.empAppStatus,
        required this.display});

  EmployeeInfo.fromJson(Map<String, dynamic> json) {
    employeeFullName = json['employee_Full_Name'] != null ? json['employee_Full_Name'] :'';
    employeeContactNumber = json['employee_ContactNumber'] != null ? json['employee_ContactNumber'] :'';
    employeeEmailId = json['employee_EmailId'] != null ? json['employee_EmailId'] :'';
    employeeCode =  json['employee_Code'] != null ? json['employee_Code'] :'';
    employeeDesignation = json['employee_Designation'] != null ? json['employee_Designation'] :'';
    empAppStatus = json['empAppStatus'] != null ? json['empAppStatus'] :'';
    display = json['display'] != null ? json['display'] :'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_Full_Name'] = this.employeeFullName;
    data['employee_ContactNumber'] = this.employeeContactNumber;
    data['employee_EmailId'] = this.employeeEmailId;
    data['employee_Code'] = this.employeeCode;
    data['employee_Designation'] = this.employeeDesignation;
    data['empAppStatus'] = this.empAppStatus;
    data['display'] = this.display;
    return data;
  }
}
