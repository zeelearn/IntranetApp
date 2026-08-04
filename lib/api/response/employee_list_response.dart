class EmployeeListResponse {
  late String responseMessage;
  late int statusCode;
  late List<EmployeeInfo> responseData;

  EmployeeListResponse({
    required this.responseMessage,
    required this.statusCode,
    required this.responseData,
  });

  EmployeeListResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = (json['responseMessage'] ?? '').toString();
    statusCode = _asInt(json['statusCode']) ?? 0;
    responseData = [];
    final raw = json['responseData'];
    if (raw is List) {
      for (final v in raw) {
        if (v is Map<String, dynamic>) {
          responseData.add(EmployeeInfo.fromJson(v));
        } else if (v is Map) {
          responseData.add(
            EmployeeInfo.fromJson(Map<String, dynamic>.from(v)),
          );
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'responseMessage': responseMessage,
      'statusCode': statusCode,
      'responseData': responseData.map((e) => e.toJson()).toList(),
    };
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

  /// Optional fields — present when API returns them.
  String employeeDepartmentName;
  String employeeRoleName;
  String employeeGrade;
  String employeeLocation;
  String zone;
  String managerName;
  String employeeDateOfBirth;
  String employeeId;

  EmployeeInfo({
    required this.employeeFullName,
    required this.employeeContactNumber,
    required this.employeeEmailId,
    required this.employeeCode,
    required this.employeeDesignation,
    required this.empAppStatus,
    required this.display,
    this.employeeDepartmentName = '',
    this.employeeRoleName = '',
    this.employeeGrade = '',
    this.employeeLocation = '',
    this.zone = '',
    this.managerName = '',
    this.employeeDateOfBirth = '',
    this.employeeId = '',
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      employeeFullName: _str(json, const [
        'employee_Full_Name',
        'employeeFullName',
        'Employee_Full_Name',
      ]),
      employeeContactNumber: _str(json, const [
        'employee_ContactNumber',
        'employeeContactNumber',
        'employee_Contact_Number',
      ]),
      employeeEmailId: _str(json, const [
        'employee_EmailId',
        'employeeEmailId',
        'employee_Email_Id',
      ]),
      employeeCode: _str(json, const [
        'employee_Code',
        'employeeCode',
        'Employee_Code',
      ]),
      employeeDesignation: _str(json, const [
        'employee_Designation',
        'employeeDesignation',
        'Employee_Designation',
      ]),
      empAppStatus: _str(json, const ['empAppStatus', 'EmpAppStatus']),
      display: _str(json, const ['display', 'Display']),
      employeeDepartmentName: _str(json, const [
        'employee_DepartmentName',
        'employeeDepartmentName',
        'Department',
        'department',
      ]),
      employeeRoleName: _str(json, const [
        'employeeRole_Name',
        'employee_RoleName',
        'employeeRoleName',
        'Role',
        'role',
      ]),
      employeeGrade: _str(json, const [
        'employee_Grade',
        'employeeGrade',
        'Grade',
      ]),
      employeeLocation: _str(json, const [
        'employee_Location',
        'employeeLocation',
        'Location',
      ]),
      zone: _str(json, const ['zone', 'Zone', 'ZONE']),
      managerName: _str(json, const [
        'managerName',
        'ManagerName',
        'manager_Name',
        'superiorName',
        'SuperiorName',
        'employee_SuperiorName',
        'ReportingManager',
      ]),
      employeeDateOfBirth: _str(json, const [
        'employee_DateOfBirth',
        'employeeDateOfBirth',
        'employeeDateOfBirthActual',
        'DateOfBirth',
        'DOB',
      ]),
      employeeId: _str(json, const [
        'employee_Id',
        'employeeId',
        'EmployeeId',
        'Employee_Id',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_Full_Name': employeeFullName,
      'employee_ContactNumber': employeeContactNumber,
      'employee_EmailId': employeeEmailId,
      'employee_Code': employeeCode,
      'employee_Designation': employeeDesignation,
      'empAppStatus': empAppStatus,
      'display': display,
      'employee_DepartmentName': employeeDepartmentName,
      'employeeRole_Name': employeeRoleName,
      'employee_Grade': employeeGrade,
      'employee_Location': employeeLocation,
      'zone': zone,
      'managerName': managerName,
      'employee_DateOfBirth': employeeDateOfBirth,
      'employee_Id': employeeId,
    };
  }

  static String _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
