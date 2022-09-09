class EmployeeListPJPResponse {
  late String responseMessage;
  late int statusCode;
  late List<EmployeeInfoModel> responseData;

  EmployeeListPJPResponse(
      {required this.responseMessage,required this.statusCode,required this.responseData});

  EmployeeListPJPResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <EmployeeInfoModel>[];
      json['responseData'].forEach((v) {
        responseData.add(new EmployeeInfoModel.fromJson(v));
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

class EmployeeInfoModel {
  late double employeeId;
  late String ename;
  late String employeeDepartmentName;
  late String employeeDesignation;

  EmployeeInfoModel(
      {required this.employeeId,
        required this.ename,
        required this.employeeDepartmentName,
        required this.employeeDesignation});

  EmployeeInfoModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_Id'];
    ename = json['ename'];
    employeeDepartmentName = json['employee_DepartmentName'];
    employeeDesignation = json['employee_Designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_Id'] = this.employeeId;
    data['ename'] = this.ename;
    data['employee_DepartmentName'] = this.employeeDepartmentName;
    data['employee_Designation'] = this.employeeDesignation;
    return data;
  }
}
