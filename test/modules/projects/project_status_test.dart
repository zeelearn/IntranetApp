import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_status.dart';

void main() {
  group('ProjectStatus', () {
    test('fromJson maps status_id and c', () {
      final status = ProjectStatus.fromJson({'status_id': 6, 'c': 354});
      expect(status.statusId, 6);
      expect(status.count, 354);
    });

    test('fromJson coerces string numbers', () {
      final status = ProjectStatus.fromJson({'status_id': '1', 'c': '10'});
      expect(status.statusId, 1);
      expect(status.count, 10);
    });

    test('toJson / copyWith', () {
      const status = ProjectStatus(statusId: 2, count: 5);
      expect(status.toJson(), {'status_id': 2, 'c': 5});
      expect(status.copyWith(count: 9).count, 9);
      expect(status.copyWith(count: 9).statusId, 2);
    });
  });
}
