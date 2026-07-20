import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';

void main() {
  group('DashboardStatusIds', () {
    test('maps task card ids to GettaskbyUser Status', () {
      expect(DashboardStatusIds.apiStatusForTaskCard(101), 1);
      expect(DashboardStatusIds.apiStatusForTaskCard(102), 2);
      expect(DashboardStatusIds.apiStatusForTaskCard(103), 4);
    });

    test('showsMissedDeadline only for pending project/task', () {
      expect(DashboardStatusIds.showsMissedDeadline(6), isTrue);
      expect(DashboardStatusIds.showsMissedDeadline(101), isTrue);
      expect(DashboardStatusIds.showsMissedDeadline(103), isFalse);
      expect(DashboardStatusIds.showsMissedDeadline(1), isFalse);
    });

    test('isTaskCard detects task status ids', () {
      expect(DashboardStatusIds.isTaskCard(101), isTrue);
      expect(DashboardStatusIds.isTaskCard(102), isTrue);
      expect(DashboardStatusIds.isTaskCard(103), isTrue);
      expect(DashboardStatusIds.isTaskCard(6), isFalse);
    });
  });

  group('DashboardFailure', () {
    test('toString includes type and message', () {
      const failure = DashboardFailure(
        type: DashboardFailureType.noInternet,
        message: 'No internet connection.',
      );
      expect(failure.toString(), contains('noInternet'));
      expect(failure.toString(), contains('No internet connection.'));
    });
  });
}
