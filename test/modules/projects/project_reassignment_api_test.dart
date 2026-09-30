import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/services/api_project_reassignment_repository.dart';
import 'package:Intranet/modules/projects/services/project_reassignment_remote_service.dart';

void main() {
  EmployeeInfo _employee({
    required String id,
    required String code,
    required String name,
    String status = 'Active',
  }) {
    return EmployeeInfo(
      employeeFullName: name,
      employeeContactNumber: '',
      employeeEmailId: '',
      employeeCode: code,
      employeeDesignation: '',
      empAppStatus: status,
      display: name,
      employeeId: id,
    );
  }

  test('maps team members and filters inactive for display status', () async {
    final client = MockClient((request) async {
      expect(request.url.path, contains('GetMyTeamForProjects'));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['ManagerCode'], '14002030');
      return http.Response(
        jsonEncode({
          'success': 200,
          'data': [
            {
              'Business_UserID': 34246,
              'DisplayName': 'Trilok G.',
              'Employee_Code': '14001908',
              'IsActive': false,
            },
            {
              'Business_UserID': 34937,
              'DisplayName': 'Active Member',
              'Employee_Code': '14001909',
              'IsActive': true,
            },
          ],
        }),
        200,
      );
    });

    final repo = ApiProjectReassignmentRepository(
      managerCode: '14002030',
      actingUserId: 37201,
      remote: ProjectReassignmentRemoteService(client: client),
    );

    final employees = await repo.listEmployees();
    expect(employees, hasLength(2));
    expect(employees.first.empAppStatus, 'Active');
    expect(employees.last.empAppStatus, 'Inactive');
    expect(employees.first.employeeId, '34937');
  });

  test('loads projects for Business_UserID from GetMyTask', () async {
    final client = MockClient((request) async {
      expect(request.url.path, contains('GetMyTask'));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['user_id'], 34937);
      return http.Response(
        jsonEncode({
          'success': 200,
          'data': [
            {
              'project_id': '259262000302365026',
              'Franchisee_Code': 'KDZ- Patel toral',
              'Franchisee_Name': 'Patel toral',
            },
          ],
        }),
        200,
      );
    });

    final repo = ApiProjectReassignmentRepository(
      managerCode: '14002030',
      actingUserId: 37201,
      remote: ProjectReassignmentRemoteService(client: client),
    );

    final projects = await repo.listProjectsForEmployee('34937');
    expect(projects, hasLength(1));
    expect(projects.first.id, '259262000302365026');
    expect(projects.first.projectId, '259262000302365026');
    expect(projects.first.taskId, 0);
    expect(projects.first.name, 'Patel toral');
    expect(projects.first.franchiseeCode, 'KDZ- Patel toral');
    expect(projects.first.catchmentArea, '');
    expect(projects.first.teamLabels, contains('KDZ- Patel toral'));
  });

  test('select-all sends wildcard UpdateTaskUser row', () async {
    Map<String, dynamic>? captured;
    final client = MockClient((request) async {
      expect(request.url.path, contains('UpdateTaskUser'));
      captured = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'success': 200, 'message': 'ok'}),
        200,
      );
    });

    final repo = ApiProjectReassignmentRepository(
      managerCode: '14002030',
      actingUserId: 37201,
      remote: ProjectReassignmentRemoteService(client: client),
    );

    await repo.submitMassReassignment([
      ReassignmentPair(
        source: _employee(id: '36884', code: 'S1', name: 'Source'),
        target: _employee(id: '35959', code: 'T1', name: 'Target'),
        projects: const [
          ReassignableProject(
            id: 'p1',
            name: 'A',
            status: '',
            teamLabels: [],
            ownerId: '36884',
            ownerName: 'Source',
            projectId: 'p1',
            taskId: 0,
          ),
          ReassignableProject(
            id: 'p2',
            name: 'B',
            status: '',
            teamLabels: [],
            ownerId: '36884',
            ownerName: 'Source',
            projectId: 'p2',
            taskId: 0,
          ),
        ],
        reassignAll: true,
        taskStatus: 1,
      ),
    ]);

    expect(captured!['user_id'], 37201);
    final input = captured!['input_data'] as List<dynamic>;
    expect(input, hasLength(1));
    expect(input.first['project_id'], '0');
    expect(input.first['task_id'], 0);
    expect(input.first['old_user_id'], '36884');
    expect(input.first['new_user_id'], '35959');
    expect(input.first['task_status'], 1);
  });

  test('partial selection sends one UpdateTaskUser row per project', () async {
    Map<String, dynamic>? captured;
    final client = MockClient((request) async {
      captured = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'success': 200, 'message': 'ok'}),
        200,
      );
    });

    final repo = ApiProjectReassignmentRepository(
      managerCode: '14002030',
      actingUserId: 37201,
      remote: ProjectReassignmentRemoteService(client: client),
    );

    await repo.submitMassReassignment([
      ReassignmentPair(
        source: _employee(id: '36884', code: 'S1', name: 'Source'),
        target: _employee(id: '35959', code: 'T1', name: 'Target'),
        projects: const [
          ReassignableProject(
            id: '259262000302365026',
            name: 'Patel toral',
            status: '',
            teamLabels: [],
            ownerId: '36884',
            ownerName: 'Source',
            projectId: '259262000302365026',
            taskId: 0,
          ),
        ],
        taskStatus: 2,
      ),
    ]);

    final input = captured!['input_data'] as List<dynamic>;
    expect(input, hasLength(1));
    expect(input.first['project_id'], '259262000302365026');
    expect(input.first['task_id'], 0);
    expect(input.first['task_status'], 2);
  });
}
