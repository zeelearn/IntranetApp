import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';

void main() {
  group('ProjectCommunicationItem email parsing', () {
    ProjectCommunicationItem item({required String body}) {
      return ProjectCommunicationItem(
        rowId: 1,
        id: 1,
        msgType: 'EMAIL',
        toAddress: 'a@b.com',
        ccAddress: '',
        emailSubject: 'Subject',
        emailBody: body,
        emailStatus: 'SENT',
        createdDate: '2026-01-02T12:00:00.000',
        createdTime: '12:00 PM',
        response: '',
      );
    }

    test('detects HTML body', () {
      final mail = item(body: '<p>Hello <b>World</b></p>');
      expect(mail.isHtmlBody, isTrue);
      expect(mail.plainTextBody, contains('Hello'));
      expect(mail.plainTextBody, isNot(contains('<p>')));
    });

    test('unescapes entity-encoded HTML', () {
      final mail = item(body: '&lt;p&gt;Hi&lt;/p&gt;');
      expect(mail.decodedEmailBody, contains('<p>'));
      expect(mail.isHtmlBody, isTrue);
      expect(mail.plainTextBody.trim(), 'Hi');
    });

    test('bodyPreview truncates long plain text', () {
      final long = List.filled(200, 'x').join();
      final mail = item(body: long);
      expect(mail.bodyPreview.length, lessThanOrEqualTo(161));
      expect(mail.bodyPreview.endsWith('…'), isTrue);
    });

    test('plain text body is not treated as HTML', () {
      final mail = item(body: 'Just a plain note');
      expect(mail.isHtmlBody, isFalse);
      expect(mail.plainTextBody, 'Just a plain note');
    });
  });

  group('ProjectDateUtils extended', () {
    test('formatApi uses yyyy-MM-dd', () {
      expect(ProjectDateUtils.formatApi(DateTime(2026, 7, 20)), '2026-07-20');
    });

    test('formatAmount uses Indian grouping', () {
      expect(ProjectDateUtils.formatAmount(0), '₹0');
      expect(ProjectDateUtils.formatAmount(1000), contains('1,000'));
      expect(ProjectDateUtils.formatAmount(100000), contains('1,00,000'));
    });

    test('tryParse supports ISO and dd-MM-yyyy', () {
      expect(ProjectDateUtils.tryParse('2026-07-20'), isNotNull);
      expect(ProjectDateUtils.tryParse('20-07-2026'), isNotNull);
      expect(ProjectDateUtils.tryParse(''), isNull);
      expect(ProjectDateUtils.tryParse('null'), isNull);
    });

    test('formatReadableDateTime appends time hint', () {
      final text = ProjectDateUtils.formatReadableDateTime(
        '2026-01-02T00:00:00.000',
        timeHint: '12:03 PM',
      );
      expect(text, contains('2026'));
      expect(text, contains('12:03 PM'));
    });
  });

  group('TaskAttachmentList helpers', () {
    test('fileName extracts last path segment', () {
      expect(
        TaskAttachmentList.fileName(
          'https://cdn.example.com/folder/a%20file.pdf',
        ),
        'a%20file.pdf',
      );
      expect(TaskAttachmentList.fileName(''), 'File');
    });

    test('extensionOf is lowercase without dot', () {
      expect(TaskAttachmentList.extensionOf('a.PDF'), 'pdf');
      expect(TaskAttachmentList.extensionOf('noext'), '');
    });
  });
}
