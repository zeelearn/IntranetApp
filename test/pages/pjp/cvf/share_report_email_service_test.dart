import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/services/share_report_email_service.dart';

void main() {
  const service = ShareReportEmailService();

  test('formats visit date and builds subject', () {
    expect(service.formatVisitDate('2026-08-01'), '01 Aug 2026');
    expect(
      service.defaultSubject(
        centreName: 'Kidzee Pune',
        visitDateRaw: '2026-08-01',
      ),
      'Centre Visit Report – Kidzee Pune – 01 Aug 2026',
    );
  });

  test('generateEmailBody returns HTML tables and escapes content', () {
    final withData = service.generateEmailBody(
      bpName: 'Sudhir <Patil>',
      centreName: 'Kidzee Pune',
      visitDateRaw: '2026-08-01',
      facilitatorName: 'Anurag Dixit',
      workingWell: [
        WorkingWellItem(observation: 'Good classroom environment'),
      ],
      urgentAttention: [
        UrgentAttentionItem(areaOfConcern: 'Infrastructure', timeline: '7 Days'),
      ],
      teacherObservation: [
        TeacherObservationItem(
          teacherName: 'John',
          className: 'LKG',
          appStatus: 'Active',
        ),
      ],
      trainingSupport: [
        TrainingSupportItem(details: 'Classroom management training'),
      ],
    );

    expect(withData, startsWith('<!DOCTYPE html>'));
    expect(withData, contains('<table'));
    expect(withData, contains("WHAT'S WORKING WELL"));
    expect(withData, contains('Good classroom environment'));
    expect(withData, contains('Infrastructure'));
    expect(withData, contains('Sudhir &lt;Patil&gt;'));
    expect(withData, contains('Dear <strong>Sudhir &lt;Patil&gt;</strong>,'));
    expect(withData, contains('<strong>Namaste!</strong>'));
    expect(withData, contains('Warm regards,'));
    expect(withData, contains('<strong>Zee Learn Ltd</strong>'));
    expect(withData, isNot(contains('Anurag Dixit')));

    final empty = service.generateEmailBody(
      bpName: 'Sudhir Patil',
      centreName: 'Kidzee Pune',
      visitDateRaw: '2026-08-01',
      facilitatorName: 'Anurag Dixit',
      workingWell: [WorkingWellItem()],
      urgentAttention: [UrgentAttentionItem()],
      teacherObservation: [TeacherObservationItem()],
      trainingSupport: [TrainingSupportItem()],
    );
    expect(empty, contains(ShareReportEmailService.noDataMessage));
  });
}
