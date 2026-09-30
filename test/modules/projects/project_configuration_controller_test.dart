import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';
import 'fake_project_reassignment_repository.dart';

void main() {
  ProjectConfigurationController controller([
    ProjectReassignmentRepository? repo,
  ]) {
    return ProjectConfigurationController(
      repository: repo ?? FakeProjectReassignmentRepository(),
    );
  }

  test('blocks queue when source equals target', () async {
    final c = controller();
    await c.load();
    final a = c.employees.first;
    c.selectSource(a);
    c.selectTarget(a);
    expect(
      c.sameEmployeeError,
      ProjectConfigurationController.sameEmployeeMessage,
    );
    expect(c.canQueueCurrentPair, isFalse);
  });

  test('target list excludes inactive employees', () async {
    final c = controller();
    await c.load();
    expect(c.employees.any((e) => !c.isActiveEmployee(e)), isTrue);
    expect(
      c.filterTargetEmployees('').every(c.isActiveEmployee),
      isTrue,
    );
    expect(
      c.filterTargetEmployees('').map((e) => e.employeeCode),
      isNot(contains('EMP003')),
    );
  });

  test('blocks selecting inactive target', () async {
    final c = controller();
    await c.load();
    final inactive =
        c.employees.firstWhere((e) => e.employeeCode == 'EMP003');
    c.selectTarget(inactive);
    expect(c.targetEmployee.value, isNull);
    expect(
      c.actionError.value,
      ProjectConfigurationController.inactiveTargetMessage,
    );
  });

  test('toggleProject adds and removes a project id', () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees.first);
    await c.loadProjectsForSource();
    final id = c.sourceProjects.first.id;

    c.toggleProject(id);
    expect(c.selectedProjectIds, contains(id));
    c.toggleProject(id);
    expect(c.selectedProjectIds, isNot(contains(id)));
  });

  test('toggleSelectAllProjects selects then deselects', () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees.first);
    await c.loadProjectsForSource();
    expect(c.sourceProjects, isNotEmpty);

    c.toggleSelectAllProjects();
    expect(c.selectedProjectIds, hasLength(c.sourceProjects.length));
    expect(c.isAllSourceProjectsSelected, isTrue);

    c.toggleSelectAllProjects();
    expect(c.selectedProjectIds, isEmpty);
    expect(c.isAllSourceProjectsSelected, isFalse);
  });

  test('clearSource and clearTarget deselect employees', () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);

    c.clearTarget();
    expect(c.targetEmployee.value, isNull);
    expect(c.sourceEmployee.value, isNotNull);
    expect(c.selectedProjectIds, isNotEmpty);

    c.clearSource();
    expect(c.sourceEmployee.value, isNull);
    expect(c.sourceProjects, isEmpty);
    expect(c.selectedProjectIds, isEmpty);
  });

  test('queues pair and enables submit with reassignAll when all selected',
      () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    expect(c.canQueueCurrentPair, isTrue);
    c.queueCurrentPair();
    expect(c.queuedPairs.length, 1);
    expect(c.queuedPairs.first.reassignAll, isTrue);
    expect(c.canSubmit, isTrue);
  });

  test('partial selection sets reassignAll false', () async {
    final repo = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.toggleProject(c.sourceProjects.first.id);
    c.selectTarget(c.employees[1]);
    expect(await c.submit(), isTrue);
    expect(repo.lastSubmitted, hasLength(1));
    expect(repo.lastSubmitted!.single.reassignAll, isFalse);
  });

  test('submit sends queued pairs then clears', () async {
    final repo = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    c.queueCurrentPair();

    expect(await c.submit(), isTrue);
    expect(repo.lastSubmitted, hasLength(1));
    expect(c.queuedPairs, isEmpty);
    expect(c.canSubmit, isFalse);
  });

  test('submit sends current pair when queue is empty but valid', () async {
    final repo = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    expect(await c.submit(), isTrue);
    expect(repo.lastSubmitted, hasLength(1));
    expect(c.sourceEmployee.value, isNull);
  });

  test('submit includes current pair when queue is non-empty', () async {
    final repo = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    c.queueCurrentPair();

    c.selectSource(c.employees[1]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    // employees[2] is inactive — use only active targets.
    // After queue, employees[0] and [1] are both active; target must differ.
    // Source is employees[1], target employees[0].
    c.selectTarget(c.employees[0]);
    expect(await c.submit(), isTrue);
    expect(repo.lastSubmitted, hasLength(2));
    expect(c.queuedPairs, isEmpty);
  });

  test('submit returns false when there is nothing to send', () async {
    final repo = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(repo);
    await c.load();
    expect(await c.submit(), isFalse);
    expect(repo.lastSubmitted, isNull);
  });

  test('submit returns false when repository throws', () async {
    final repo = _RecordingRepository(
      FakeProjectReassignmentRepository(),
      submitError: Exception('network'),
    );
    final c = controller(repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    c.queueCurrentPair();

    expect(await c.submit(), isFalse);
    expect(c.queuedPairs, hasLength(1));
    expect(c.isSubmitting.value, isFalse);
  });

  test('sourceQuery and targetQuery filter employees', () async {
    final c = controller();
    await c.load();
    c.sourceQuery.value = 'Amit';
    c.targetQuery.value = 'Neha';
    expect(c.filteredSourceEmployees, hasLength(1));
    expect(c.filteredSourceEmployees.single.employeeCode, 'EMP001');
    expect(c.filteredTargetEmployees.single.employeeCode, 'EMP002');
  });

  test('validates source, projects, target, and same-employee rules', () async {
    final c = controller();
    await c.load();
    expect(
      c.queueValidationError,
      ProjectConfigurationController.selectSourceMessage,
    );

    c.selectSource(c.employees.first);
    await c.loadProjectsForSource();
    expect(
      c.queueValidationError,
      ProjectConfigurationController.selectProjectsMessage,
    );

    c.selectAllProjects();
    expect(
      c.queueValidationError,
      ProjectConfigurationController.selectTargetMessage,
    );

    c.selectTarget(c.employees.first);
    expect(
      c.queueValidationError,
      ProjectConfigurationController.sameEmployeeMessage,
    );
    expect(c.canQueueCurrentPair, isFalse);
    expect(c.queueCurrentPair(), isFalse);
  });

  test('blocks queue when project is already queued', () async {
    final c = controller();
    await c.load();
    final source = c.employees[0];
    final targetA = c.employees[1];

    c.selectSource(source);
    await c.loadProjectsForSource();
    final projectId = c.sourceProjects.first.id;
    c.toggleProject(projectId);
    c.selectTarget(targetA);
    expect(c.queueCurrentPair(), isTrue);

    c.selectSource(source);
    await c.loadProjectsForSource();
    c.toggleProject(projectId);
    expect(
      c.actionError.value,
      ProjectConfigurationController.duplicateQueuedMessage,
    );
  });

  test('project search filters mapped list', () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees.first);
    await c.loadProjectsForSource();
    c.projectQuery.value = 'KYC';
    expect(c.filteredSourceProjects, isNotEmpty);
    expect(
      c.filteredSourceProjects.every(
        (p) => p.name.toLowerCase().contains('kyc'),
      ),
      isTrue,
    );
  });

  test('removeQueuedPair restores ability to select project', () async {
    final c = controller();
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    final projectId = c.sourceProjects.first.id;
    c.toggleProject(projectId);
    c.selectTarget(c.employees[1]);
    expect(c.queueCurrentPair(), isTrue);
    expect(c.queuedProjectIds, contains(projectId));

    c.removeQueuedPair(0);
    expect(c.queuedPairs, isEmpty);
    expect(c.queuedProjectIds, isEmpty);
  });

  test('loads projects using Business_UserID key', () async {
    final c = controller();
    await c.load();
    final source = c.employees.firstWhere((e) => e.employeeId == '1001');
    c.selectSource(source);
    await c.loadProjectsForSource();
    expect(c.sourceProjects, isNotEmpty);
    expect(c.sourceProjects.every((p) => p.ownerId == '1001'), isTrue);
  });

  test('submit includes task_status from task status dropdown', () async {
    final recording = _RecordingRepository(FakeProjectReassignmentRepository());
    final c = controller(recording);
    await c.load();
    final source = c.employees.first;
    final target = c.employees[1];
    c.selectSource(source);
    await c.loadProjectsForSource();
    c.toggleProject(c.sourceProjects.first.id);
    c.selectTarget(target);
    c.setTaskStatusFilter(TaskStatusFilter.pending);

    expect(await c.submit(), isTrue);
    expect(recording.lastSubmitted, isNotNull);
    expect(recording.lastSubmitted!.single.taskStatus, 1);
  });
}

class _RecordingRepository implements ProjectReassignmentRepository {
  _RecordingRepository(this._inner, {this.submitError});

  final ProjectReassignmentRepository _inner;
  final Object? submitError;
  List<ReassignmentPair>? lastSubmitted;

  @override
  Future<List<EmployeeInfo>> listEmployees() => _inner.listEmployees();

  @override
  Future<List<ReassignableProject>> listProjectsForEmployee(
    String employeeKey,
  ) {
    return _inner.listProjectsForEmployee(employeeKey);
  }

  @override
  Future<void> submitMassReassignment(List<ReassignmentPair> pairs) async {
    lastSubmitted = List<ReassignmentPair>.from(pairs);
    if (submitError != null) {
      throw submitError!;
    }
    await _inner.submitMassReassignment(pairs);
  }
}
