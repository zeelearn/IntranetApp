import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';

void main() {
  test('maskEmail hides local and domain parts', () {
    expect(ShareReportTheme.maskEmail('john.doe@example.com'), contains('@'));
    expect(ShareReportTheme.maskEmail('john.doe@example.com'), startsWith('j'));
    expect(ShareReportTheme.maskEmail('john.doe@example.com'), isNot(contains('john.doe')));
    expect(ShareReportTheme.maskEmail(''), '—');
  });
}
