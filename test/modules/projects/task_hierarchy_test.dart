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
}
