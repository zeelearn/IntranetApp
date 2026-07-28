import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/dashboard_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_summary.dart';

void main() {
  group('DashboardResponse.parseInnerSummary', () {
    test('parses nested JSON string list', () {
      const inner = r'''
[
  {
    "TotalProject": 1155,
    "pendingtask": 395,
    "completedTask": 1430,
    "InprogressTask": 4,
    "CancelledTask": 0,
    "CompletedProject":[{"status_id":1,"c":767}],
    "NotInterestedProject":[{"status_id":2,"c":24}],
    "RefundedProject":[{"status_id":4,"c":4}],
    "RejectedProject":[{"status_id":3,"c":6}],
    "PendingProject":[{"status_id":6,"c":354}],
    "NotStartedProject":[{"status_id":5,"c":95}]
  }
]
''';

      final response = DashboardResponse.fromJson({
        'success': 200,
        'data': [
          {'data': inner},
        ],
      });

      final summary = response.parseInnerSummary();
      expect(summary.totalProject, 1155);
      expect(summary.pendingTask, 395);
      expect(summary.countFor(summary.pendingProject), 354);
      expect(summary.countFor(summary.completedProject), 767);
    });

    test('throws invalidJson on malformed inner string', () {
      final response = DashboardResponse.fromJson({
        'success': 200,
        'data': [
          {'data': '{not-json'},
        ],
      });

      expect(
        () => response.parseInnerSummary(),
        throwsA(
          isA<DashboardFailure>().having(
            (e) => e.type,
            'type',
            DashboardFailureType.invalidJson,
          ),
        ),
      );
    });

    test('throws empty when data list is empty', () {
      final response = DashboardResponse.fromJson({
        'success': 200,
        'data': <dynamic>[],
      });

      expect(
        () => response.parseInnerSummary(),
        throwsA(
          isA<DashboardFailure>().having(
            (e) => e.type,
            'type',
            DashboardFailureType.empty,
          ),
        ),
      );
    });
  });

  group('DashboardCardModel.fromSummary', () {
    test('calculates percentages with zero-safe totals', () {
      final cards = DashboardCardModel.fromSummary(DashboardSummary.empty());
      expect(cards.length, 8);
      expect(cards.every((c) => c.percent == 0), isTrue);
    });

    test('maps pending and confirmed counts', () {
      final parsed = DashboardSummary.fromJson({
        'TotalProject': 1000,
        'pendingtask': 100,
        'completedTask': 300,
        'InprogressTask': 100,
        'CancelledTask': 0,
        'CompletedProject': [
          {'status_id': 1, 'c': 400}
        ],
        'NotInterestedProject': [
          {'status_id': 2, 'c': 20}
        ],
        'RefundedProject': [
          {'status_id': 4, 'c': 5}
        ],
        'RejectedProject': [
          {'status_id': 3, 'c': 10}
        ],
        'PendingProject': [
          {'status_id': 6, 'c': 250}
        ],
        'NotStartedProject': [
          {'status_id': 5, 'c': 50}
        ],
      });

      final cards = DashboardCardModel.fromSummary(parsed);
      final pending = cards.firstWhere((c) => c.title == 'Pending Projects');
      final confirmed =
          cards.firstWhere((c) => c.title == 'Confirmed Projects');
      final pendingTasks =
          cards.firstWhere((c) => c.title == 'Pending Tasks');

      expect(pending.count, 250);
      expect(pending.percent, 25);
      expect(confirmed.count, 400);
      expect(confirmed.percent, 40);
      expect(pendingTasks.statusId, 101);
      expect(pendingTasks.percent, 20);
    });
  });
}
