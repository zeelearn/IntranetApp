import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/pages/userinfo/employee_search_utils.dart';

EmployeeInfo _emp({
  String name = 'Sudhir Patil',
  String code = 'E123',
  String email = 'sudhir@example.com',
  String designation = 'Manager',
  String department = 'IT',
  String role = 'MAN',
  String location = 'Mumbai',
  String zone = 'West',
  String manager = 'Rajesh Kumar',
  String contact = '9876543210',
}) {
  return EmployeeInfo(
    employeeFullName: name,
    employeeContactNumber: contact,
    employeeEmailId: email,
    employeeCode: code,
    employeeDesignation: designation,
    empAppStatus: 'Active',
    display: name,
    employeeDepartmentName: department,
    employeeRoleName: role,
    employeeLocation: location,
    zone: zone,
    managerName: manager,
  );
}

void main() {
  group('EmployeeInfo.fromJson', () {
    test('parses core and optional fields', () {
      final info = EmployeeInfo.fromJson({
        'employee_Full_Name': 'Sudhir Patil',
        'employee_EmailId': 'sudhir@example.com',
        'employee_Code': 'E123',
        'employee_Designation': 'Manager',
        'employee_DepartmentName': 'IT',
        'employeeRole_Name': 'MAN',
        'employee_Grade': 'M2',
        'employee_Location': 'Mumbai',
        'zone': 'West',
        'managerName': 'Rajesh Kumar',
        'employee_DateOfBirth': '1990-01-15',
      });

      expect(info.employeeFullName, 'Sudhir Patil');
      expect(info.employeeDepartmentName, 'IT');
      expect(info.employeeRoleName, 'MAN');
      expect(info.employeeGrade, 'M2');
      expect(info.zone, 'West');
      expect(info.managerName, 'Rajesh Kumar');
      expect(info.employeeDateOfBirth, '1990-01-15');
    });
  });

  group('EmployeeSearchUtils', () {
    final list = [
      _emp(),
      _emp(
        name: 'Anita Sharma',
        code: 'E456',
        email: 'anita@example.com',
        designation: 'Executive',
        department: 'HR',
        role: 'EMP',
      ),
    ];

    test('matches by name, code, department, role', () {
      expect(EmployeeSearchUtils.filter(list, 'sudhir').length, 1);
      expect(EmployeeSearchUtils.filter(list, 'E456').length, 1);
      expect(EmployeeSearchUtils.filter(list, 'hr').length, 1);
      expect(EmployeeSearchUtils.filter(list, 'man').length, 1);
      expect(EmployeeSearchUtils.filter(list, '').length, 2);
      expect(EmployeeSearchUtils.filter(list, 'zzz'), isEmpty);
    });

    test('displayOrDash falls back to em dash', () {
      expect(EmployeeSearchUtils.displayOrDash(''), '—');
      expect(EmployeeSearchUtils.displayOrDash('  '), '—');
      expect(EmployeeSearchUtils.displayOrDash('IT'), 'IT');
    });
  });
}
