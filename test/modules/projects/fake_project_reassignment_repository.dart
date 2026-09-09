import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';

/// Lightweight in-memory repository for unit/widget tests (no static JSON).
class FakeProjectReassignmentRepository
    implements ProjectReassignmentRepository {
  FakeProjectReassignmentRepository({
    List<EmployeeInfo>? employees,
    List<ReassignableProject>? projects,
    this.submitDelay = Duration.zero,
  })  : _employees = List<EmployeeInfo>.from(employees ?? _defaultEmployees),
        _projects = List<ReassignableProject>.from(projects ?? _defaultProjects);

  final List<EmployeeInfo> _employees;
  final List<ReassignableProject> _projects;
  final Duration submitDelay;

  static final List<EmployeeInfo> _defaultEmployees = [
    EmployeeInfo(
      employeeFullName: 'Amit Verma',
      employeeContactNumber: '',
      employeeEmailId: '',
      employeeCode: 'EMP001',
      employeeDesignation: 'BH',
      empAppStatus: 'Active',
      display: 'Amit Verma',
      employeeId: '1001',
    ),
    EmployeeInfo(
      employeeFullName: 'Neha Kapoor',
      employeeContactNumber: '',
      employeeEmailId: '',
      employeeCode: 'EMP002',
      employeeDesignation: 'ZM',
      empAppStatus: 'Active',
      display: 'Neha Kapoor',
      employeeId: '1002',
    ),
    EmployeeInfo(
      employeeFullName: 'Inactive User',
      employeeContactNumber: '',
      employeeEmailId: '',
      employeeCode: 'EMP003',
      employeeDesignation: 'RM',
      empAppStatus: 'Inactive',
      display: 'Inactive User',
      employeeId: '1003',
    ),
  ];

  static final List<ReassignableProject> _defaultProjects = [
    const ReassignableProject(
      id: '3996',
      name: 'Customer KYC and Agreement',
      status: 'Pending',
      teamLabels: ['KDZ- Nasrin S Aga'],
      ownerId: '1001',
      ownerName: 'Amit Verma',
      franchiseeCode: 'KDZ- Nasrin S Aga',
      catchmentArea: 'Nasrin S Aga',
      projectId: '259262000014037136',
      taskId: 3996,
    ),
    const ReassignableProject(
      id: '3997',
      name: 'Center Setup Checklist',
      status: 'In Progress',
      teamLabels: ['KDZ- Green Valley'],
      ownerId: '1001',
      ownerName: 'Amit Verma',
      franchiseeCode: 'KDZ- Green Valley',
      catchmentArea: 'Green Valley',
      projectId: '259262000014037137',
      taskId: 3997,
    ),
    const ReassignableProject(
      id: '5001',
      name: 'Neha Task',
      status: 'Pending',
      teamLabels: ['West'],
      ownerId: '1002',
      ownerName: 'Neha Kapoor',
      franchiseeCode: 'WEST-1',
      projectId: 'p-5001',
      taskId: 5001,
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
    final key = employeeKey.trim();
    if (key.isEmpty) return const [];
    return _projects
        .where((project) => project.ownerId.trim() == key)
        .toList(growable: false);
  }

  @override
  Future<void> submitMassReassignment(List<ReassignmentPair> pairs) async {
    if (submitDelay > Duration.zero) {
      await Future<void>.delayed(submitDelay);
    }
    if (pairs.isEmpty) {
      throw StateError('No reassignment pairs to submit.');
    }
    for (final pair in pairs) {
      if (pair.projects.isEmpty && !pair.reassignAll) {
        throw StateError('Each reassignment pair needs at least one project.');
      }
      final targetId = pair.target.employeeId.trim().isNotEmpty
          ? pair.target.employeeId.trim()
          : pair.target.employeeCode.trim();
      final targetName = pair.target.employeeFullName.trim();
      for (final selected in pair.projects) {
        final index = _projects.indexWhere((p) => p.id == selected.id);
        if (index < 0) continue;
        _projects[index] = _projects[index].copyWith(
          ownerId: targetId,
          ownerName: targetName,
        );
      }
    }
  }
}
