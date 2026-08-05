import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/send_credentials_result.dart';
import 'package:Intranet/modules/projects/services/credentials_cooldown_store.dart';

void main() {
  group('ProjectChartUrl', () {
    test('builds chart url with crm id', () {
      expect(
        ProjectChartUrl.build('xxxxxxxxxx00000001'),
        'https://chart.zeelearn.com/chart.html?pid=xxxxxxxxxx00000001',
      );
    });

    test('trims crm id', () {
      expect(
        ProjectChartUrl.build('  abc  '),
        'https://chart.zeelearn.com/chart.html?pid=abc',
      );
    });

    test('validates empty crm id', () {
      expect(ProjectChartUrl.isValidCrmId(''), isFalse);
      expect(ProjectChartUrl.isValidCrmId('   '), isFalse);
      expect(ProjectChartUrl.isValidCrmId('crm-1'), isTrue);
    });
  });

  group('SendCredentialsResult', () {
    test('parses successful response', () {
      final result = SendCredentialsResult.fromJson({
        'success': 200,
        'data': [
          {'msg': 'Credential sent successfully!'},
        ],
      });
      expect(result.success, isTrue);
      expect(result.message, 'Credential sent successfully!');
    });

    test('parses Msg key fallback', () {
      final result = SendCredentialsResult.fromJson({
        'success': 200,
        'data': [
          {'Msg': 'Sent'},
        ],
      });
      expect(result.success, isTrue);
      expect(result.message, 'Sent');
    });

    test('marks non-200 without success message as failure', () {
      final result = SendCredentialsResult.fromJson({
        'success': 500,
        'data': [
          {'msg': 'Failed'},
        ],
      });
      expect(result.success, isFalse);
      expect(result.message, 'Failed');
    });
  });

  group('CredentialsCooldownStore helpers', () {
    test('remainingFromUntil returns null when expired', () {
      final now = DateTime(2026, 7, 29, 12, 0);
      final remaining = CredentialsCooldownStore.remainingFromUntil(
        DateTime(2026, 7, 29, 11, 59),
        now: now,
      );
      expect(remaining, isNull);
    });

    test('remainingFromUntil returns duration while active', () {
      final now = DateTime(2026, 7, 29, 12, 0);
      final remaining = CredentialsCooldownStore.remainingFromUntil(
        DateTime(2026, 7, 29, 12, 10),
        now: now,
      );
      expect(remaining, const Duration(minutes: 10));
    });

    test('formatRemaining formats minutes and seconds', () {
      expect(
        CredentialsCooldownStore.formatRemaining(const Duration(minutes: 15)),
        '15m',
      );
      expect(
        CredentialsCooldownStore.formatRemaining(
          const Duration(minutes: 2, seconds: 5),
        ),
        '2m 5s',
      );
      expect(
        CredentialsCooldownStore.formatRemaining(const Duration(seconds: 40)),
        '40s',
      );
    });
  });
}
