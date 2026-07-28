import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';

void main() {
  group('UserTaskItem', () {
    test('fromJson maps GettaskbyUser fields', () {
      final item = UserTaskItem.fromJson({
        'id': '120972',
        'project_id': '259262000101590371',
        'title': 'Follow up',
        'latest_comment': 'Please call',
        'priority': 'High',
        'Start_date': '2026-07-15T00:00:00.000Z',
        'End_date': '2026-07-16T00:00:00.000Z',
        'p_start_date': '2026-07-14T00:00:00.000Z',
        'due_date': '2026-07-20T00:00:00.000Z',
        'Responsible_person': 'Manish Sharma',
        'status': 1,
        'statusname': 'Pending',
        'parent_task_id': '0',
        'taskcount': 'P-1',
        'mtask_id': '0',
        'Franchisee_Name': 'Kidzee',
        'Franchisee_Code': 'S-1',
        'files': 'a.pdf,b.png',
      });

      expect(item.id, '120972');
      expect(item.title, 'Follow up');
      expect(item.note, 'Please call');
      expect(item.statusName, 'Pending');
      expect(item.parentTaskId, '0');
      expect(item.files, 'a.pdf,b.png');
    });

    test('toProjectItem uses franchisee / project ids', () {
      final item = UserTaskItem.fromJson({
        'id': '1',
        'project_id': 'crm-9',
        'title': 'Task',
        'Franchisee_Name': 'Center A',
        'Franchisee_Code': 'C-A',
        'status': 1,
        'statusname': 'Pending',
        'parent_task_id': '0',
        'taskcount': '',
        'mtask_id': '0',
      });
      final project = item.toProjectItem();
      expect(project.crmId, 'crm-9');
      expect(project.franchiseeName, 'Center A');
      expect(project.franchiseeCode, 'C-A');
    });

    test('toJson round-trips core keys', () {
      final item = UserTaskItem.fromJson({
        'id': '7',
        'project_id': 'p1',
        'title': 'T',
        'status': 2,
        'statusname': 'In Progress',
        'parent_task_id': '3',
        'taskcount': 'IP-1',
        'mtask_id': '0',
      });
      final json = item.toJson();
      expect(json['id'], '7');
      expect(json['status'], 2);
      expect(json['parent_task_id'], '3');
    });
  });
}
