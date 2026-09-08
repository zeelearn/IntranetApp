import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/cvf_internal_data.dart';
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

    test('parses internal_data when nested arrays are JSON strings', () {
      final data = ShareReportEmailData.fromJson({
        'PJP_Id': '28585',
        'PJPCVF_Id': '13747',
        'internal_data': [
          {
            'Franchisee_code': 'COWSS-4110',
            'Franchisee_name': 'Kidze COCO  Malad (West)',
            'Requested_PenteMind': 'Yes',
            'cm':
                '[{"Teacher_Name":"Madhavi  Manohar Sawant"},{"Teacher_Name":"Diwakar B Yadav"}]',
            'class_list':
                '[{"Class_Id":3,"Class_Name":"Junior KG - Regular"},{"Class_Id":5,"Class_Name":"Nursery - Regular"}]',
            'stud_count_array':
                '[{"academicyear_id":25,"is_curr_ay":0,"stud_list":[{"Class_Id":3,"Class_Name":"Junior KG - Regular","stud_number":10,"stud_number_as_per_visit":0}]},{"academicyear_id":26,"is_curr_ay":1,"stud_list":[{"Class_Id":3,"Class_Name":"Junior KG - Regular","stud_number":12,"stud_number_as_per_visit":0}]}]',
            'kit_count_array':
                '[{"academicyear_id":26,"kit_list":[{"Class_Id":3,"Class_Name":"Junior KG - Regular","kit_number":11}]}]',
            'head_cnt':
                '[{"Class_Id":3,"Class_Name":"Junior KG - Regular","cnt":0},{"Class_Id":5,"Class_Name":"Nursery - Regular","cnt":0}]',
            'reg_cnt':
                '[{"Class_Id":3,"Class_Name":"Junior KG - Regular","cnt":0},{"Class_Id":5,"Class_Name":"Nursery - Regular","cnt":0}]',
            'enr_status_array':
                '[{"batch": "PLAY GROUP - Batch 1","totalChild": 0,"teacherName": "","doj": "","tutelage": "","pto": 0},{"batch": "NURSERY - Batch 1","totalChild": 0,"teacherName": "","doj": "","tutelage": "","pto": 0},{"batch": "JUNIOR KG - Batch 1","totalChild": 0,"teacherName": "","doj": "","tutelage": "","pto": 0},{"batch": "SENIOR KG - Batch 1","totalChild": 0,"teacherName": "","doj": "","tutelage": "","pto": 0}]',
            'is_draft': true,
            'is_submitted': false,
            'academic_year_id': 26,
          },
        ],
      });

      final internal = data.internalData;
      expect(internal, isNotNull);
      expect(internal!.classList.length, 2);
      expect(internal.studCountArray.length, 2);
      expect(internal.studCountArray.first.studList.first.studNumber, 10);
      expect(internal.kitCountArray.length, 1);
      expect(internal.headCnt.length, 2);
      expect(internal.regCnt.length, 2);
      expect(internal.enrStatusArray.length, 4);
      expect(internal.enrStatusArray.first.batch, 'PLAY GROUP - Batch 1');
      expect(internal.cm.length, 2);
      expect(data.enrolmentStatus.length, 4);
      expect(data.enrolmentStatus.first.batch, 'PLAY GROUP - Batch 1');
      expect(internal.brandingUpgraded, isTrue);
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
        {'tn': 'teacher 2', 'class': 'Senior', 'app': 'Active'},
        {'tn': 'teacher 3', 'class': 'PG', 'app': 'Active'},
      ]);
      expect(payload['tasp'], ['Training required', 'Training']);
    });
  });

  group('CvfInternalData', () {
    test('firstFrom decodes stringified nested arrays', () {
      final internal = CvfInternalData.firstFrom([
        {
          'enr_status_array':
              '[{"batch":"SENIOR KG - Batch 2","totalChild":5,"teacherName":"A","doj":"01-01-2026","tutelage":"Y","pto":90}]',
          'head_cnt':
              '[{"Class_Id":4,"Class_Name":"Senior KG - Regular","cnt":3}]',
        },
      ]);
      expect(internal, isNotNull);
      expect(internal!.enrStatusArray.length, 1);
      expect(internal.enrStatusArray.first.batch, 'SENIOR KG - Batch 2');
      expect(internal.enrStatusArray.first.totalChild, 5);
      expect(internal.headCnt.first.cnt, 3);
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
