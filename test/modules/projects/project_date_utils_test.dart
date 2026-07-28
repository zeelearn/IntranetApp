import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

void main() {
  group('ProjectDateUtils', () {
    test('formats dd-MM-yyyy', () {
      expect(ProjectDateUtils.formatReadable('07-07-2023'), '07 Jul 2023');
    });

    test('detects missed deadline', () {
      expect(ProjectDateUtils.isMissed('01-01-2020'), isTrue);
      expect(ProjectDateUtils.isMissed('01-01-2099'), isFalse);
    });
  });
}
