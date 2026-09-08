import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';

class MockProjectReassignmentRepository implements ProjectReassignmentRepository {
  MockProjectReassignmentRepository({
    List<EmployeeInfo>? employees,
    List<ReassignableProject>? projects,
    Duration submitDelay = const Duration(milliseconds: 100),
  })  : _employees = employees ?? _seedEmployees,
        _projects = projects ?? _seedProjects,
        _submitDelay = submitDelay;

  final List<EmployeeInfo> _employees;
  final List<ReassignableProject> _projects;
  final Duration _submitDelay;

  static final List<EmployeeInfo> _seedEmployees = [
    EmployeeInfo(
      employeeFullName: 'Amit Verma',
      employeeContactNumber: '9876543210',
      employeeEmailId: 'amit.verma@example.com',
      employeeCode: 'EMP001',
      employeeDesignation: 'Business Head',
      empAppStatus: 'Active',
      display: 'Amit Verma (EMP001)',
      employeeDepartmentName: 'Projects',
      employeeRoleName: 'BH',
    ),
    EmployeeInfo(
      employeeFullName: 'Neha Kapoor',
      employeeContactNumber: '9876543211',
      employeeEmailId: 'neha.kapoor@example.com',
      employeeCode: 'EMP002',
      employeeDesignation: 'Zone Manager',
      empAppStatus: 'Active',
      display: 'Neha Kapoor (EMP002)',
      employeeDepartmentName: 'Projects',
      employeeRoleName: 'ZM',
    ),
    EmployeeInfo(
      employeeFullName: 'Rohit Sharma',
      employeeContactNumber: '9876543212',
      employeeEmailId: 'rohit.sharma@example.com',
      employeeCode: 'EMP003',
      employeeDesignation: 'Project Manager',
      empAppStatus: 'Active',
      display: 'Rohit Sharma (EMP003)',
      employeeDepartmentName: 'Projects',
      employeeRoleName: 'MAN',
    ),
  ];

  static final List<ReassignableProject> _seedProjects = [
    ReassignableProject(
      id: 'PRJ001',
      name: 'Sunrise Academy',
      status: 'Active',
      teamLabels: ['North', 'Primary'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ002',
      name: 'Green Valley School',
      status: 'In Progress',
      teamLabels: ['West'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ003',
      name: 'Blue Ridge Public School',
      status: 'Pending',
      teamLabels: ['East', 'Secondary'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ004',
      name: 'Heritage International',
      status: 'Active',
      teamLabels: ['South'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ005',
      name: 'Maple Leaf Academy',
      status: 'In Progress',
      teamLabels: ['North', 'Senior'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ006',
      name: 'Silver Oak School',
      status: 'Active',
      teamLabels: ['Central'],
      ownerId: 'EMP001',
      ownerName: 'Amit Verma',
    ),
    ReassignableProject(
      id: 'PRJ007',
      name: 'Crystal Heights School',
      status: 'Pending',
      teamLabels: ['West', 'Primary'],
      ownerId: 'EMP002',
      ownerName: 'Neha Kapoor',
    ),
    ReassignableProject(
      id: 'PRJ008',
      name: 'Golden Gate Academy',
      status: 'Active',
      teamLabels: ['East'],
      ownerId: 'EMP003',
      ownerName: 'Rohit Sharma',
    ),
  ];

  @override
  Future<List<EmployeeInfo>> listEmployees() async {
    return List<EmployeeInfo>.from(_employees);
  }

  @override
  Future<List<ReassignableProject>> listProjectsForEmployee(
    String employeeKey,
  ) async {
    return _projects
        .where((project) => project.ownerId == employeeKey)
        .toList(growable: false);
  }

  @override
  Future<void> submitMassReassignment(List<ReassignmentPair> pairs) async {
    await Future<void>.delayed(_submitDelay);
  }
}
