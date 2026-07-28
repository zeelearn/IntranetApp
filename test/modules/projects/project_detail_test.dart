import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';

void main() {
  group('ProjectDetailData', () {
    test('parses GetFranchiseeDetailInfoV1 envelope', () {
      final data = ProjectDetailData.fromApiEnvelope({
        'success': 200,
        'data': [
          {
            'franDetails': {
              'Franchisee_Code': 'S-R-S-7230',
              'Franchisee_Name': 'Kidzee Siruseri',
              'Franchisee_Id': 7230,
              'Operating_Status': 'A',
              'Attendee': 'Yuvaraj R',
              'Mobile_No': '9940026062',
              'Email_Id': 'Kidzee7230@kidzee.com',
              'Tier_Name': 'I2 TIER 8 ',
              'Fee_Type': 'ST',
              'LeadId': '259262000180154996',
            },
            'indentDetails': [
              {
                'Indent_Id': 1,
                'Indent_No': 'ACK-1',
                'Indent_Amount': 100,
                'Appr_Amount': 100,
                'Due_Amount': 20,
                'Indent_Status': 'Partial',
                'Indent_Type': 'ACK',
                'Indent_Date': '2026-03-25T16:09:55.337',
                'Academicyear_Id': 26,
                'Docket_No': '',
                'Created_By': 'X',
              }
            ],
            'documents': [
              {
                'Name': 'Sign UP PPT',
                'DocURL': 'https://example.com/a.pptx',
              }
            ],
            'communication': [
              {
                'RowID': 1,
                'ID': 2,
                'Msg_Type': 'EMAIL',
                'To_Address': 'a@b.com',
                'CC_Address': '',
                'Email_Subject': 'Hello',
                'Email_Body': '<p>Hi <strong>there</strong></p>',
                'Email_Status': 'SENT',
                'Created_Date': '2026-01-02T12:03:50.100',
                'createdtime': '12:03 PM',
                'Response': 'Sent',
              }
            ],
          }
        ],
      });

      expect(data.franDetails.franchiseeCode, 'S-R-S-7230');
      expect(data.franDetails.isActive, isTrue);
      expect(data.indentDetails, hasLength(1));
      expect(data.indentDetails.first.paidAmount, 80);
      expect(data.documents.single.name, 'Sign UP PPT');
      expect(data.communication.single.bodyPreview, contains('Hi there'));
      expect(data.totalIndents, 1);
      expect(data.isStaleForToday, isFalse);
    });

    test('isStaleForToday when synced yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final data = ProjectDetailData(
        franDetails: const FranchiseeDetails(),
        indentDetails: const [],
        documents: const [],
        communication: const [],
        syncedAt: yesterday,
      );
      expect(data.isStaleForToday, isTrue);
    });
  });
}
