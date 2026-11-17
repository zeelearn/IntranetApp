import 'dart:convert';

import 'package:flutter/cupertino.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

double _asDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  final str = value.toString().trim().toLowerCase();
  if (str == 'true' || str == '1') return true;
  if (str == 'false' || str == '0') return false;
  return fallback;
}

String _asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

class LoginResponseModel {
  LoginResponseModel({
    required this.responseMessage,
    required this.statusCode,
    required this.responseData,
  });
  late final String responseMessage;
  late final int statusCode;
  late final ResponseData responseData;

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
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
    required this.businessApplications,
    this.myMobileApplications = const [],
  });
  late final List<EmployeeDetails> employeeDetails;
  late final List<EmployeeRoles> employeeRoles;
  late final List<BusinessApplications> businessApplications;
  late final List<MyMobileApplication> myMobileApplications;

  ResponseData.fromJson(Map<String, dynamic> json) {
    try {
      employeeDetails = List.from(json['employeeDetails'] ?? const [])
          .map((e) => EmployeeDetails.fromJson(e))
          .toList();
      employeeRoles = List.from(json['employeeRoles'] ?? const [])
          .map((e) => EmployeeRoles.fromJson(e))
          .toList();
    } catch (e, stack) {
      debugPrint('Error parsing employeeDetails or employeeRoles: $e\n$stack');
      employeeDetails = [];
      employeeRoles = [];
    }
    businessApplications = [];
    if (json['businessApplications'] is List) {
      json['businessApplications'].forEach((v) {
        try {
          businessApplications.add(BusinessApplications.fromJson(v));
        } catch (_) {}
      });
    } else if (json['businessApplications'] is Map) {
      try {
        businessApplications
            .add(BusinessApplications.fromJson(json['businessApplications']));
      } catch (_) {}
    }

    myMobileApplications = [];
    final mobileRaw = json['myMobileApplications'];
    if (mobileRaw is List) {
      for (final v in mobileRaw) {
        try {
          if (v is Map) {
            myMobileApplications
                .add(MyMobileApplication.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['employeeDetails'] = employeeDetails.map((e) => e.toJson()).toList();
    _data['employeeRoles'] = employeeRoles.map((e) => e.toJson()).toList();
    _data['businessApplications'] =
        businessApplications.map((e) => e.toJson()).toList();
    _data['myMobileApplications'] =
        myMobileApplications.map((e) => e.toJson()).toList();
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
  late final String managerName;
  late final int passwordExpired;
  late final String token;

  EmployeeDetails.fromJson(Map<String, dynamic> json) {
    employeeId = _asDouble(json['employee_Id']);
    employeeCode = _asString(json['employee_Code']);
    employeeFirstName = _asString(json['employee_FirstName']);
    employeeLastName = _asString(json['employee_LastName']);
    employeeDateOfJoining = _asString(json['employee_DateOfJoining']);
    employeeSuperiorId = _asDouble(json['employee_SuperiorId']);
    employeeRoleId = _asDouble(json['employee_RoleId']);
    employeeRoleName = _asString(json['employeeRole_Name']);
    employeeDepartmentID = _asInt(json['employee_DepartmentID']);
    employeeDepartmentName = _asString(json['employee_DepartmentName']);
    employeeDesignation = _asString(json['employee_Designation']);
    employeeEmailId = _asString(json['employee_EmailId']);
    employeeContactNumber = _asString(json['employee_ContactNumber']);
    isActive = _asBool(json['isActive']);
    createdBy = _asString(json['created_By']);
    createdDate = _asString(json['created_Date']);
    modifiedBy = _asString(json['modified_By']);
    modifiedDate = _asString(json['modified_Date']);
    isBusinessHead = _asBool(json['isBusinessHead']);
    isCEO = _asBool(json['isCEO']);
    userName = _asString(json['user_Name']);
    userPassword = _asString(json['user_Password']);
    isLoggedIn = _asBool(json['is_LoggedIn']);
    isExternal = _asBool(json['is_External']);
    employeeDateOfBirth = _asString(json['employee_DateOfBirth']);
    employeeGrade = _asString(json['employee_Grade']);
    zone = _asString(json['zone']);
    employeeDepartmentID1 = _asInt(json['employee_DepartmentID1']);
    companyId = _asDouble(json['companyId']);
    employeeDateOfMarriage = _asString(json['employee_DateOfMarriage']);
    gender = _asString(json['gender']);
    employeeMiddleName = _asString(json['employeeMiddleName']);
    employeeDateOfBirthActual = _asString(json['employeeDateOfBirthActual']);
    employeeWorkRoleId = _asDouble(json['employee_WorkRoleId']);
    employeeLocation = _asString(json['employee_Location']);
    employeeQualification = _asString(json['employeeQualification']);
    employeeMaritalStatus = _asString(json['employee_MaritalStatus']);
    landingPage = _asString(json['landingPage']);
    companyName = _asString(json['companyName']);
    managerName = _asString(json['managerName']);
    passwordExpired = _asInt(json['isPasswordExpired']);
    token = _asString(json['token']);
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
    _data['managerName'] = managerName;
    _data['isPasswordExpired'] = passwordExpired;
    _data['token'] = token;
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

  EmployeeRoles.fromJson(Map<String, dynamic> json) {
    splRole = _asString(json['splRole']);
    value = _asInt(json['value']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['splRole'] = splRole;
    _data['value'] = value;
    return _data;
  }
}

class BusinessApplications {
  BusinessApplications({
    required this.businessID,
    required this.business_UserID,
    required this.employeeId,
    required this.businessName,
    required this.logoPath,
    required this.headerPath,
    required this.footerPath,
    required this.path,
  });
  late final int businessID;
  late final int business_UserID;
  late final String employeeId;
  late final String businessName;
  late final String? logoPath;
  late final String? headerPath;
  late final String? footerPath;
  late final String path;

  BusinessApplications.fromJson(Map<String, dynamic> json) {
    businessID = _asInt(json['business_ID']);
    business_UserID = _asInt(json['business_UserID']);
    employeeId = _asString(json['employee_Id']);
    businessName = _asString(json['business_Name']);
    logoPath = json['logo_Path'] != null ? _asString(json['logo_Path']) : null;
    headerPath =
        json['header_Path'] != null ? _asString(json['header_Path']) : null;
    footerPath =
        json['footer_Path'] != null ? _asString(json['footer_Path']) : null;
    path = _asString(json['path']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['business_ID'] = businessID;
    _data['business_UserID'] = business_UserID;
    _data['employee_Id'] = employeeId;
    _data['business_Name'] = businessName;
    _data['logo_Path'] = logoPath;
    _data['header_Path'] = headerPath;
    _data['footer_Path'] = footerPath;
    _data['path'] = path;
    return _data;
  }
}

/// Apps from login `myMobileApplications` — used for dashboard deep-links.
class MyMobileApplication {
  MyMobileApplication({
    required this.businessId,
    required this.employeeId,
    required this.businessName,
    required this.imageUrl,
    required this.path,
    this.headerPath,
    this.footerPath,
  });

  final int businessId;
  final String employeeId;
  final String businessName;
  final String imageUrl;
  final String? headerPath;
  final String? footerPath;
  final String path;

  /// Normalized display name for matching.
  String get normalizedName => businessName.trim();

  /// Trimmed launch URL from API `path`.
  String get launchUrl => path.trim();

  bool get hasValidLaunchUrl {
    final url = launchUrl;
    if (url.isEmpty || url.toLowerCase() == 'null') return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  factory MyMobileApplication.fromJson(Map<String, dynamic> json) {
    return MyMobileApplication(
      businessId: _asInt(json['business_ID'] ?? json['business_Id']),
      employeeId: (json['employee_Id'] ?? json['employeeId'] ?? '').toString(),
      businessName:
          (json['business_Name'] ?? json['businessName'] ?? '').toString().trim(),
      imageUrl: (json['imageURL'] ??
              json['imageUrl'] ??
              json['logo_Path'] ??
              '')
          .toString()
          .trim(),
      headerPath: json['header_Path']?.toString(),
      footerPath: json['footer_Path']?.toString(),
      path: (json['path'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'business_ID': businessId,
      'employee_Id': employeeId,
      'business_Name': businessName,
      'imageURL': imageUrl,
      'header_Path': headerPath,
      'footer_Path': footerPath,
      'path': path,
    };
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }
}

class LoginResponseInvalid {
  late String responseMessage;
  late int statusCode;
  late String responseData;

  LoginResponseInvalid(
      {required this.responseMessage,
      required this.statusCode,
      required this.responseData});

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
