import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/services/mock_project_reassignment_service.dart';

void main() {
  test('mock lists employees and projects for a source', () async {
    final repo = MockProjectReassignmentRepository();
    final employees = await repo.listEmployees();
    expect(employees.length, greaterThanOrEqualTo(2));
    final projects = await repo.listProjectsForEmployee(employees.first.employeeCode);
    expect(projects, isNotEmpty);
    await repo.submitMassReassignment([]);
  });
}
