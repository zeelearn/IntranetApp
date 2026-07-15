import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

void main() {
  group('AddTaskRequest', () {
    test('serializes API payload keys', () {
      const request = AddTaskRequest(
        taskId: 0,
        mtaskId: 0,
        projectId: '259262000101590371',
        title: 'Test',
        note: 'test note',
        startDate: '2026-07-14',
        endDate: '2026-07-14',
        planStartDate: '2026-07-14',
        planEndDate: '2026-07-14',
        status: 1,
        parentTaskId: '94213',
        dependentTaskId: 0,
        contributionId: 3,
        userId: 34254,
      );
      final json = request.toJson();
      expect(json['taskid'], 0);
      expect(json['project_id'], '259262000101590371');
      expect(json['parent_task_id'], '94213');
      expect(json['User_id'], 34254);
      expect(json['contribution_id'], 3);
      expect(json['status'], 1);
    });
  });

  group('ProjectDateUtils.formatApi', () {
    test('formats yyyy-MM-dd', () {
      expect(
        ProjectDateUtils.formatApi(DateTime(2026, 7, 14)),
        '2026-07-14',
      );
    });
  });
}
