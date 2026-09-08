import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';
import 'package:Intranet/modules/projects/services/mock_project_reassignment_service.dart';

void main() {
  test('blocks queue when source equals target', () async {
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
    await c.load();
    final a = c.employees.first;
    c.selectSource(a);
    c.selectTarget(a);
    expect(
      c.sameEmployeeError,
      'Source and target employee cannot be the same.',
    );
    expect(
      c.sameEmployeeError,
      ProjectConfigurationController.sameEmployeeMessage,
    );
    expect(c.canQueueCurrentPair, isFalse);
  });

  test('toggleProject adds and removes a project id', () async {
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
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
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
    await c.load();
    c.selectSource(c.employees.first);
    await c.loadProjectsForSource();
    expect(c.sourceProjects, isNotEmpty);
    expect(c.selectedProjectIds, isEmpty);

    c.toggleSelectAllProjects();
    expect(c.selectedProjectIds, hasLength(c.sourceProjects.length));
    expect(
      c.selectedProjectIds.toSet(),
      c.sourceProjects.map((project) => project.id).toSet(),
    );

    c.toggleSelectAllProjects();
    expect(c.selectedProjectIds, isEmpty);
  });

  test('clearSource and clearTarget deselect employees', () async {
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
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

  test('queues pair and enables submit', () async {
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
    await c.load();
    final source = c.employees[0];
    final target = c.employees[1];
    c.selectSource(source);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(target);
    expect(c.canQueueCurrentPair, isTrue);
    c.queueCurrentPair();
    expect(c.queuedPairs.length, 1);
    expect(c.canSubmit, isTrue);
  });

  test('submit sends queued pairs then clears', () async {
    final repo = _RecordingRepository(MockProjectReassignmentRepository());
    final c = ProjectConfigurationController(repository: repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    c.queueCurrentPair();

    expect(await c.submit(), isTrue);

    expect(repo.lastSubmitted, isNotNull);
    expect(repo.lastSubmitted, hasLength(1));
    expect(c.queuedPairs, isEmpty);
    expect(c.canSubmit, isFalse);
  });

  test('submit sends current pair when queue is empty but valid', () async {
    final repo = _RecordingRepository(MockProjectReassignmentRepository());
    final c = ProjectConfigurationController(repository: repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    expect(c.queuedPairs, isEmpty);
    expect(c.canSubmit, isTrue);

    expect(await c.submit(), isTrue);

    expect(repo.lastSubmitted, hasLength(1));
    expect(c.sourceEmployee.value, isNull);
    expect(c.selectedProjectIds, isEmpty);
  });

  test('submit includes current pair when queue is non-empty', () async {
    final repo = _RecordingRepository(MockProjectReassignmentRepository());
    final c = ProjectConfigurationController(repository: repo);
    await c.load();
    c.selectSource(c.employees[0]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[1]);
    c.queueCurrentPair();
    expect(c.queuedPairs, hasLength(1));

    c.selectSource(c.employees[1]);
    await c.loadProjectsForSource();
    c.selectAllProjects();
    c.selectTarget(c.employees[2]);
    expect(c.canQueueCurrentPair, isTrue);
    expect(c.queuedPairs, hasLength(1));

    expect(await c.submit(), isTrue);

    expect(repo.lastSubmitted, hasLength(2));
    expect(
      repo.lastSubmitted!.first.source.employeeCode,
      c.employees[0].employeeCode,
    );
    expect(
      repo.lastSubmitted!.last.source.employeeCode,
      c.employees[1].employeeCode,
    );
    expect(c.queuedPairs, isEmpty);
    expect(c.sourceEmployee.value, isNull);
  });

  test('submit returns false when there is nothing to send', () async {
    final repo = _RecordingRepository(MockProjectReassignmentRepository());
    final c = ProjectConfigurationController(repository: repo);
    await c.load();

    expect(await c.submit(), isFalse);
    expect(repo.lastSubmitted, isNull);
  });

  test('submit returns false when repository throws', () async {
    final repo = _RecordingRepository(
      MockProjectReassignmentRepository(),
      submitError: Exception('network'),
    );
    final c = ProjectConfigurationController(repository: repo);
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
    final c = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
    await c.load();
    c.sourceQuery.value = 'Neha';
    c.targetQuery.value = 'EMP003';
    expect(c.filteredSourceEmployees, hasLength(1));
    expect(c.filteredSourceEmployees.single.employeeCode, 'EMP002');
    expect(c.filteredTargetEmployees.single.employeeCode, 'EMP003');
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
      String employeeKey) {
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
