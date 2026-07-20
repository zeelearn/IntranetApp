import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';

void main() {
  group('AddTaskArgs', () {
    test('isEditMode false for create', () {
      const args = AddTaskArgs(
        projectId: 'p1',
        userId: 1,
        projectName: 'Project',
      );
      expect(args.isEditMode, isFalse);
    });

    test('isEditMode true when taskId > 0', () {
      const args = AddTaskArgs(
        projectId: 'p1',
        userId: 1,
        projectName: 'Project',
        taskId: 120973,
      );
      expect(args.isEditMode, isTrue);
    });

    test('isEditMode true when seedTask present', () {
      final seed = HierarchyTask.fromJson({
        'id': '9',
        'title': 'Seed',
        'parent_task_id': '0',
      });
      final args = AddTaskArgs(
        projectId: 'p1',
        userId: 1,
        projectName: 'Project',
        seedTask: seed,
      );
      expect(args.isEditMode, isTrue);
    });
  });

  group('TaskFormStatusOption', () {
    test('labelForId covers known statuses', () {
      expect(TaskFormStatusOption.labelForId(1), 'Pending');
      expect(TaskFormStatusOption.labelForId(2), 'In Progress');
      expect(TaskFormStatusOption.labelForId(4), isNotEmpty);
    });
  });

  group('TaskFormPriority', () {
    test('exposes standard priorities', () {
      expect(TaskFormPriority.high, isNotEmpty);
      expect(TaskFormPriority.medium, isNotEmpty);
      expect(TaskFormPriority.low, isNotEmpty);
    });
  });
}
