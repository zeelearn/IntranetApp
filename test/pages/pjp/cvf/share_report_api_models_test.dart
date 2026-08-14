import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_email_data.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_response.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';

void main() {
  group('ShareReportEmailData', () {
    test('parses GetPJPCVFEmail with object ua/to arrays', () {
      final data = ShareReportEmailData.fromJson({
        'PJP_Id': '28585',
        'PJPCVF_Id': '13747',
        'To': ['ki*********@******.com'],
        'CC': ['sudhir.patil@zeelearn.com'],
        'Subject': 'Centre Visit Report',
        'Body': '',
        'www': ['applicaiton is working', 'All students are login'],
        'ua': [
          {'aoc': 'test area of concern 1', 'tl': '31st august 2026'},
          {'aoc': 'test area of concern 2', 'tl': '31st oct 2026'},
        ],
        'to': [
          {'tn': 'teacher 1', 'class': 'Nursery', 'app': 'Inactive'},
          {'tn': 'teacher 2', 'class': 'Senior', 'app': 'active'},
        ],
        'tasp': ['Training required', 'Training'],
      });

      expect(data.to, ['ki*********@******.com']);
      expect(data.workingWell.length, 2);
      expect(data.urgentAttention.first.areaOfConcern, 'test area of concern 1');
      expect(data.urgentAttention.first.timeline, '31st august 2026');
      expect(data.teacherObservation.first.teacherName, 'teacher 1');
      expect(data.teacherObservation.first.className, 'Nursery');
      expect(data.teacherObservation.first.appStatus, 'Inactive');
      expect(data.trainingSupport.length, 2);
    });

    test('toApiPayload matches required SendPJPCVFEmail shape', () {
      final data = ShareReportEmailData(
        pjpId: '28585',
        cvfId: '13747',
        to: const ['ki*********@******.com'],
        cc: const ['sudhir.patil@zeelearn.com'],
        subject: 'Centre Visit Report – Kidze COCO  Malad (West) – 03 Aug 2026',
        body: '<p>preview only</p>',
        attachmentUrl: 'https://intranet.zeelearn.com/cvfreport.html?cid=13747',
        workingWell: [
          WorkingWellItem(observation: 'applicaiton is working'),
          WorkingWellItem(observation: 'All students are login'),
        ],
        urgentAttention: [
          UrgentAttentionItem(
            areaOfConcern: 'test area of concern 1',
            timeline: '31st august 2026',
          ),
          UrgentAttentionItem(
            areaOfConcern: 'test area of concern 2',
            timeline: '31st oct 2026',
          ),
        ],
        teacherObservation: [
          TeacherObservationItem(
            teacherName: 'teacher 1',
            className: 'Nursery',
            appStatus: 'Inactive',
          ),
          TeacherObservationItem(
            teacherName: 'teacher 2',
            className: 'Senior',
            appStatus: 'active',
          ),
          TeacherObservationItem(
            teacherName: 'teacher 3',
            className: 'PG',
            appStatus: 'Active',
          ),
        ],
        trainingSupport: [
          TrainingSupportItem(details: 'Training required'),
          TrainingSupportItem(details: 'Training'),
        ],
      );

      final payload = data.toApiPayload();
      expect(payload['Body'], '');
      expect(payload['www'], ['applicaiton is working', 'All students are login']);
      expect(payload['ua'], [
        {'aoc': 'test area of concern 1', 'tl': '31st august 2026'},
        {'aoc': 'test area of concern 2', 'tl': '31st oct 2026'},
      ]);
      expect(payload['to'], [
        {'tn': 'teacher 1', 'class': 'Nursery', 'app': 'Inactive'},
        {'tn': 'teacher 2', 'class': 'Senior', 'app': 'active'},
        {'tn': 'teacher 3', 'class': 'PG', 'app': 'Active'},
      ]);
      expect(payload['tasp'], ['Training required', 'Training']);
    });
  });

  group('ShareReportResponse', () {
    test('parses SendPJPCVFEmail success envelope', () {
      final response = ShareReportResponse.fromJson({
        'responseMessage': 'Success',
        'statusCode': 200,
        'responseData': [
          {'msg': 'Email Sent Successfully!', 'data': 1},
        ],
      });
      expect(response.success, isTrue);
      expect(response.message, 'Email Sent Successfully!');
    });
  });
}
