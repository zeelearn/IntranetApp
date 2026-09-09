import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';
import 'package:Intranet/modules/projects/services/project_reassignment_remote_service.dart';

/// Live BPMS implementation for mass project reassignment.
class ApiProjectReassignmentRepository
    implements ProjectReassignmentRepository {
  ApiProjectReassignmentRepository({
    required this.managerCode,
    required this.actingUserId,
    ProjectReassignmentRemoteService? remote,
  }) : _remote = remote ?? ProjectReassignmentRemoteService();

  /// Logged-in manager employee code (`ManagerCode` for team API).
  final String managerCode;

  /// Logged-in BPMS business user id (`user_id` for UpdateTaskUser).
  final int actingUserId;

  final ProjectReassignmentRemoteService _remote;

  @override
  Future<List<EmployeeInfo>> listEmployees() async {
    final members = await _remote.fetchTeam(managerCode: managerCode);
    if (members.isEmpty) return const [];

    final mapped = members.map(_mapMember).toList(growable: false);
    mapped.sort((a, b) {
      final aActive = _isActive(a);
      final bActive = _isActive(b);
      if (aActive != bActive) return aActive ? -1 : 1;
      return a.employeeFullName
          .toLowerCase()
          .compareTo(b.employeeFullName.toLowerCase());
    });
    return mapped;
  }

  @override
  Future<List<ReassignableProject>> listProjectsForEmployee(
    String employeeKey,
  ) async {
    final userId = int.tryParse(employeeKey.trim()) ?? 0;
    if (userId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Unable to load projects for this employee.',
      );
    }

    final projects = await _remote.fetchProjectsForUser(userId: userId);
    return [
      for (final project in projects) _mapProject(project, ownerId: employeeKey),
    ];
  }

  @override
  Future<void> submitMassReassignment(List<ReassignmentPair> pairs) async {
    if (pairs.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Nothing selected to move.',
      );
    }

    final input = <UpdateTaskUserItemDto>[];
    for (final pair in pairs) {
      input.addAll(_itemsForPair(pair));
    }
    if (input.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Nothing selected to move.',
      );
    }

    await _remote.updateTaskUser(
      actingUserId: actingUserId,
      inputData: input,
    );
  }

  List<UpdateTaskUserItemDto> _itemsForPair(ReassignmentPair pair) {
    final oldUserId = _businessUserId(pair.source);
    final newUserId = _businessUserId(pair.target);
    if (oldUserId.isEmpty || newUserId.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Current or new employee details are incomplete.',
      );
    }
    if (oldUserId == newUserId) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Current and new employee cannot be the same.',
      );
    }

    final taskStatus = pair.taskStatus;

    if (pair.reassignAll) {
      return [
        UpdateTaskUserItemDto(
          projectId: '0',
          taskId: 0,
          oldUserId: oldUserId,
          newUserId: newUserId,
          taskStatus: taskStatus,
        ),
      ];
    }

    if (pair.projects.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Select at least one project to move.',
      );
    }

    return [
      for (final project in pair.projects)
        UpdateTaskUserItemDto(
          projectId: project.projectId.isNotEmpty
              ? project.projectId
              : project.id,
          // GetMyTask is project-level; send task_id 0 unless a task id exists.
          taskId: project.taskId,
          oldUserId: oldUserId,
          newUserId: newUserId,
          taskStatus: taskStatus,
        ),
    ];
  }

  EmployeeInfo _mapMember(TeamMemberDto member) {
    final name = member.displayName.trim().isNotEmpty
        ? member.displayName.trim()
        : member.employeeCode.trim();
    return EmployeeInfo(
      employeeFullName: name,
      employeeContactNumber: '',
      employeeEmailId: '',
      employeeCode: member.employeeCode.trim(),
      employeeDesignation: '',
      empAppStatus: member.isActive ? 'Active' : 'Inactive',
      display: name,
      employeeDepartmentName: '',
      employeeRoleName: '',
      employeeId: member.businessUserId.toString(),
    );
  }

  ReassignableProject _mapProject(
    AssignedProjectDto project, {
    required String ownerId,
  }) {
    final franchiseeCode = project.franchiseeCode.trim();
    final franchiseeName = project.franchiseeName.trim();
    final displayName = franchiseeName.isNotEmpty
        ? franchiseeName
        : (franchiseeCode.isNotEmpty ? franchiseeCode : project.projectId);
    final labels = <String>[
      if (franchiseeCode.isNotEmpty) franchiseeCode,
      if (franchiseeName.isNotEmpty && franchiseeName != franchiseeCode)
        franchiseeName,
    ];

    return ReassignableProject(
      id: project.projectId,
      name: displayName,
      status: '',
      teamLabels: labels,
      ownerId: ownerId,
      ownerName: '',
      // Code in franchisee column; name is already the row title.
      franchiseeCode: franchiseeCode.isNotEmpty ? franchiseeCode : displayName,
      catchmentArea: '',
      taskCount: '',
      projectId: project.projectId,
      taskId: 0,
    );
  }

  String _businessUserId(EmployeeInfo employee) {
    final id = employee.employeeId.trim();
    if (id.isNotEmpty) return id;
    return employee.employeeCode.trim();
  }

  bool _isActive(EmployeeInfo employee) {
    final status = employee.empAppStatus.trim().toLowerCase();
    return status == 'active' || status == 'true' || status == '1';
  }
}
