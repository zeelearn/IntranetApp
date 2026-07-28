import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/task_summary.dart';

void main() {
  group('TaskSummary.parse', () {
    test('parses C-IP-P format', () {
      final summary = TaskSummary.parse('C-28,IP-0,P-9');
      expect(summary.completed, 28);
      expect(summary.inProgress, 0);
      expect(summary.pending, 9);
      expect(summary.bpCompleted, 0);
    });

    test('parses BPC', () {
      final summary = TaskSummary.parse('C-1,IP-2,P-3,BPC-4');
      expect(summary.bpCompleted, 4);
    });

    test('handles empty and invalid', () {
      expect(TaskSummary.parse(null), const TaskSummary());
      expect(TaskSummary.parse(''), const TaskSummary());
      expect(TaskSummary.parse('bad'), const TaskSummary());
    });
  });
}
