class LoginResponseModel {
  LoginResponseModel({
    required this.responseMessage,
    required this.statusCode,
    required this.responseData,
  });
  late final String responseMessage;
  late final int statusCode;
  late final ResponseData responseData;

  LoginResponseModel.fromJson(Map<String, dynamic> json){
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = ResponseData.fromJson(json['responseData']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['responseMessage'] = responseMessage;
    _data['statusCode'] = statusCode;
    _data['responseData'] = responseData.toJson();
    return _data;
  }
}

class ResponseData {
  ResponseData({
    required this.employeeDetails,
    required this.employeeRoles,
  });
  late final List<EmployeeDetails> employeeDetails;
  late final List<EmployeeRoles> employeeRoles;

  ResponseData.fromJson(Map<String, dynamic> json){
    employeeDetails = List.from(json['employeeDetails']).map((e)=>EmployeeDetails.fromJson(e)).toList();
    employeeRoles = List.from(json['employeeRoles']).map((e)=>EmployeeRoles.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['employeeDetails'] = employeeDetails.map((e)=>e.toJson()).toList();
    _data['employeeRoles'] = employeeRoles.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class EmployeeDetails {
  EmployeeDetails({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeFirstName,
    required this.employeeLastName,
    required this.employeeDateOfJoining,
    required this.employeeSuperiorId,
    required this.employeeRoleId,
    required this.employeeRoleName,
    required this.employeeDepartmentID,
    required this.employeeDepartmentName,
    required this.employeeDesignation,
    required this.employeeEmailId,
    required this.employeeContactNumber,
    required this.isActive,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isBusinessHead,
    required this.isCEO,
    required this.userName,
    required this.userPassword,
    required this.isLoggedIn,
    required this.isExternal,
    required this.employeeDateOfBirth,
    required this.employeeGrade,
    required this.zone,
    required this.employeeDepartmentID1,
    required this.companyId,
    required this.employeeDateOfMarriage,
    required this.gender,
    required this.employeeMiddleName,
    required this.employeeDateOfBirthActual,
    required this.employeeWorkRoleId,
    required this.employeeLocation,
    required this.employeeQualification,
    required this.employeeMaritalStatus,
    required this.landingPage,
    required this.companyName,
  });
  late final double employeeId;
  late final String employeeCode;
  late final String employeeFirstName;
  late final String employeeLastName;
  late final String employeeDateOfJoining;
  late final double employeeSuperiorId;
  late final double employeeRoleId;
  late final String employeeRoleName;
  late final int employeeDepartmentID;
  late final String employeeDepartmentName;
  late final String employeeDesignation;
  late final String employeeEmailId;
  late final String employeeContactNumber;
  late final bool isActive;
  late final String createdBy;
  late final String createdDate;
  late final String modifiedBy;
  late final String modifiedDate;
  late final bool isBusinessHead;
  late final bool isCEO;
  late final String userName;
  late final String userPassword;
  late final bool isLoggedIn;
  late final bool isExternal;
  late final String employeeDateOfBirth;
  late final String employeeGrade;
  late final String zone;
  late final int employeeDepartmentID1;
  late final double companyId;
  late final String employeeDateOfMarriage;
  late final String gender;
  late final String employeeMiddleName;
  late final String employeeDateOfBirthActual;
  late final double employeeWorkRoleId;
  late final String employeeLocation;
  late final String employeeQualification;
  late final String employeeMaritalStatus;
  late final String landingPage;
  late final String companyName;

  EmployeeDetails.fromJson(Map<String, dynamic> json){
    employeeId = json['employee_Id'];
    employeeCode = json['employee_Code'];
    employeeFirstName = json['employee_FirstName'];
    employeeLastName = json['employee_LastName'];
    employeeDateOfJoining = json['employee_DateOfJoining'] ?? "";
    employeeSuperiorId = json['employee_SuperiorId'] ?? "";
    employeeRoleId = json['employee_RoleId'] ?? "";
    employeeRoleName = json['employeeRole_Name'] ?? "";
    employeeDepartmentID = json['employee_DepartmentID'] ?? "";
    employeeDepartmentName = json['employee_DepartmentName'] ?? "";
    employeeDesignation = json['employee_Designation'] ?? "";
    employeeEmailId = json['employee_EmailId'] ?? "";
    employeeContactNumber = json['employee_ContactNumber'] ?? "";
    isActive = json['isActive'] ?? "";
    createdBy = json['created_By'] ?? "";
    createdDate = json['created_Date'] ?? "";
    modifiedBy = json['modified_By'] ?? "";
    modifiedDate = json['modified_Date'] ?? "";
    isBusinessHead = json['isBusinessHead'] ?? "";
    isCEO = json['isCEO'] ?? "";
    userName = json['user_Name'] ?? "";
    userPassword = json['user_Password'] ?? "";
    isLoggedIn = json['is_LoggedIn'] ?? "";
    isExternal = json['is_External'] ?? "";
    employeeDateOfBirth = json['employee_DateOfBirth'] ?? "";
    employeeGrade = json['employee_Grade'] ?? "";
    zone = json['zone'] ?? "";
    employeeDepartmentID1 = json['employee_DepartmentID1'] ?? "";
    companyId = json['companyId'];
    employeeDateOfMarriage = json['employee_DateOfMarriage'] ?? "";
    gender = json['gender'] ?? "";
    employeeMiddleName = json['employeeMiddleName'] ?? "";
    employeeDateOfBirthActual = json['employeeDateOfBirthActual'] ?? "";
    employeeWorkRoleId = json['employee_WorkRoleId'] ?? "";
    employeeLocation = json['employee_Location'] ?? "";
    employeeQualification = json['employeeQualification'] ?? "";
    employeeMaritalStatus = json['employee_MaritalStatus'];
    landingPage = json['landingPage'] ?? "";
    companyName = json['companyName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['employee_Id'] = employeeId;
    _data['employee_Code'] = employeeCode;
    _data['employee_FirstName'] = employeeFirstName;
    _data['employee_LastName'] = employeeLastName;
    _data['employee_DateOfJoining'] = employeeDateOfJoining;
    _data['employee_SuperiorId'] = employeeSuperiorId;
    _data['employee_RoleId'] = employeeRoleId;
    _data['employeeRole_Name'] = employeeRoleName;
    _data['employee_DepartmentID'] = employeeDepartmentID;
    _data['employee_DepartmentName'] = employeeDepartmentName;
    _data['employee_Designation'] = employeeDesignation;
    _data['employee_EmailId'] = employeeEmailId;
    _data['employee_ContactNumber'] = employeeContactNumber;
    _data['isActive'] = isActive;
    _data['created_By'] = createdBy;
    _data['created_Date'] = createdDate;
    _data['modified_By'] = modifiedBy;
    _data['modified_Date'] = modifiedDate;
    _data['isBusinessHead'] = isBusinessHead;
    _data['isCEO'] = isCEO;
    _data['user_Name'] = userName;
    _data['user_Password'] = userPassword;
    _data['is_LoggedIn'] = isLoggedIn;
    _data['is_External'] = isExternal;
    _data['employee_DateOfBirth'] = employeeDateOfBirth;
    _data['employee_Grade'] = employeeGrade;
    _data['zone'] = zone;
    _data['employee_DepartmentID1'] = employeeDepartmentID1;
    _data['companyId'] = companyId;
    _data['employee_DateOfMarriage'] = employeeDateOfMarriage;
    _data['gender'] = gender;
    _data['employee_MiddleName'] = employeeMiddleName;
    _data['employee_DateOfBirthActual'] = employeeDateOfBirthActual;
    _data['employee_WorkRoleId'] = employeeWorkRoleId;
    _data['employee_Location'] = employeeLocation;
    _data['employee_Qualification'] = employeeQualification;
    _data['employee_MaritalStatus'] = employeeMaritalStatus;
    _data['landingPage'] = landingPage;
    _data['companyName'] = companyName;
    return _data;
  }
}

class EmployeeRoles {
  EmployeeRoles({
    required this.splRole,
    required this.value,
  });
  late final String splRole;
  late final int value;

  EmployeeRoles.fromJson(Map<String, dynamic> json){
    splRole = json['splRole'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['splRole'] = splRole;
    _data['value'] = value;
    return _data;
  }
}


class LoginResponseInvalid {
  late String responseMessage;
  late int statusCode;
  late String responseData;

  LoginResponseInvalid(
      {required this.responseMessage,required  this.statusCode,required  this.responseData});

  LoginResponseInvalid.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = json['responseData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    data['responseData'] = this.responseData;
    return data;
  }
}