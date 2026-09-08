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
    expect(c.sameEmployeeError, isNotNull);
    expect(c.canQueueCurrentPair, isFalse);
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

    await c.submit();

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

    await c.submit();

    expect(repo.lastSubmitted, hasLength(1));
    expect(c.sourceEmployee.value, isNull);
    expect(c.selectedProjectIds, isEmpty);
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
  _RecordingRepository(this._inner);

  final ProjectReassignmentRepository _inner;
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
    await _inner.submitMassReassignment(pairs);
  }
}
