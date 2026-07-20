import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';

void main() {
  group('TaskRepository.buildChildrenMap', () {
    test('maps roots and children', () {
      final tasks = [
        HierarchyTask.fromJson({
          'id': '1',
          'title': 'Root',
          'parent_task_id': '0',
        }),
        HierarchyTask.fromJson({
          'id': '2',
          'title': 'Child',
          'parent_task_id': '1',
        }),
        HierarchyTask.fromJson({
          'id': '3',
          'title': 'Grand',
          'parent_task_id': '2',
        }),
      ];
      final map = TaskRepository.buildChildrenMap(tasks);
      expect(TaskRepository.roots(map).single.id, '1');
      expect(TaskRepository.childrenOf(map, '1').single.id, '2');
      expect(TaskRepository.childrenOf(map, '2').single.id, '3');
    });

    test('only exact parent_task_id 0 is root; children stay nested', () {
      final tasks = [
        HierarchyTask.fromJson({
          'id': '1',
          'title': 'Root A',
          'parent_task_id': 0,
        }),
        HierarchyTask.fromJson({
          'id': '2',
          'title': '',
          'parent_task_id': '1',
        }),
        HierarchyTask.fromJson({
          'id': '3',
          'title': 'Untitled child',
          'parent_task_id': '999',
        }),
        HierarchyTask.fromJson({
          'id': '4',
          'title': 'Missing parent field',
          'parent_task_id': null,
        }),
        HierarchyTask.fromJson({
          'id': '5',
          'title': 'Empty parent',
          'parent_task_id': '',
        }),
      ];
      final roots = TaskRepository.rootTasks(tasks);
      expect(roots.map((t) => t.id).toList(), ['1']);
      expect(roots.single.isRoot, isTrue);
      expect(tasks[1].isRoot, isFalse);
      expect(tasks[2].isRoot, isFalse);
      expect(tasks[3].isRoot, isFalse);
      expect(tasks[4].isRoot, isFalse);

      final map = TaskRepository.buildChildrenMap(tasks);
      expect(TaskRepository.roots(map).single.id, '1');
      expect(TaskRepository.childrenOf(map, '1').single.id, '2');
      // Orphans (parent 999 / empty) are not promoted to root.
      expect(TaskRepository.roots(map).any((t) => t.id == '3'), isFalse);
    });
  });

  group('HierarchyTaskResponse', () {
    test('flattens nested data lists', () {
      final response = HierarchyTaskResponse.fromJson({
        'success': 200,
        'data': [
          [
            {'id': 'a', 'title': 'A', 'parent_task_id': '0'},
            {'id': 'b', 'title': 'B', 'parent_task_id': 'a'},
          ]
        ],
      });
      expect(response.tasks.length, 2);
    });
  });

  group('HierarchyTask parent dates', () {
    test('parses parant_date and parant_plandate pairs', () {
      final task = HierarchyTask.fromJson({
        'id': '1',
        'title': 'Root',
        'parent_task_id': '0',
        'parant_date': '22-08-2023,23-09-2023',
        'parant_plandate': '22-08-2023,15-09-2023',
      });
      expect(task.isRoot, isTrue);
      expect(task.displayActualStart, '22-08-2023');
      expect(task.displayActualEnd, '23-09-2023');
      expect(task.displayPlanStart, '22-08-2023');
      expect(task.displayPlanEnd, '15-09-2023');
    });
  });

  group('Create/Update API response parsing', () {
    test('maps AddNewTask data item into HierarchyTask', () {
      final task = HierarchyTask.fromJson({
        'project_id': 'xxxxxxxxxx00000002',
        'title': 'Test ',
        'id': '120972',
        'note': 'Please Ignore, this is created for Testing purpose',
        'img': 'assets/images/user/user1.jpg',
        'priority': 'High',
        'Start_date': '2026-07-15T00:00:00.000Z',
        'End_date': '2026-07-15T00:00:00.000Z',
        'p_start_date': '2026-07-15T00:00:00.000Z',
        'due_date': '2026-07-15T00:00:00.000Z',
        'Responsible_person': 'Manish Sharma',
        'taskcount': 'P-1',
        'status': 1,
        'statusname': 'Pending',
        'parent_task_id': '9566',
        'mtask_id': '0',
        'latest_comment': 'Please Ignore, this is created for Testing purpose',
        'files': null,
        'manager': '9566',
        'taskcreateduser': '12345',
      });
      expect(task.id, '120972');
      expect(task.parentTaskId, '9566');
      expect(task.statusName, 'Pending');
      expect(task.isRoot, isFalse);
      expect(task.taskCreatedUser, '12345');
    });
  });
}
