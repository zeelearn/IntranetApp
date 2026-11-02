import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';
import 'package:intl/intl.dart';

/// Builds the share-report email body (HTML) from current form values.
class ShareReportEmailService {
  const ShareReportEmailService();

  static const noDataMessage = 'No data available';

  String formatVisitDate(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '—';
    try {
      final dt = DateTime.parse(text);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return text;
    }
  }

  String defaultSubject({
    required String centreName,
    required String visitDateRaw,
  }) {
    return 'Centre Visit Report – $centreName – ${formatVisitDate(visitDateRaw)}';
  }

  List<WorkingWellItem> filledWorkingWell(List<WorkingWellItem> items) =>
      items.where((e) => e.observation.trim().isNotEmpty).toList();

  List<UrgentAttentionItem> filledUrgent(List<UrgentAttentionItem> items) =>
      items
          .where((e) =>
              e.areaOfConcern.trim().isNotEmpty || e.timeline.trim().isNotEmpty)
          .toList();

  List<TeacherObservationItem> filledTeachers(
    List<TeacherObservationItem> items,
  ) =>
      items
          .where((e) =>
              e.teacherName.trim().isNotEmpty ||
              e.className.trim().isNotEmpty ||
              e.appStatus.trim().isNotEmpty)
          .toList();

  List<TrainingSupportItem> filledTraining(List<TrainingSupportItem> items) =>
      items.where((e) => e.details.trim().isNotEmpty).toList();

  /// Escapes text for safe HTML insertion.
  String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// HTML email body used for API send and preview serialization.
  ///
  /// Greeting uses [bpName] (BusinessPartnerName). Sign-off is always Zee Learn Ltd.
  String generateEmailBody({
    required String bpName,
    required String centreName,
    required String visitDateRaw,
    @Deprecated('Sign-off is fixed to Zee Learn Ltd') String facilitatorName = '',
    required List<WorkingWellItem> workingWell,
    required List<UrgentAttentionItem> urgentAttention,
    required List<TeacherObservationItem> teacherObservation,
    required List<TrainingSupportItem> trainingSupport,
  }) {
    final visitDate = formatVisitDate(visitDateRaw);
    final partner = escapeHtml(
      bpName.trim().isEmpty ? 'Business Partner' : bpName.trim(),
    );
    final centre =
        escapeHtml(centreName.trim().isEmpty ? 'Centre' : centreName.trim());
    final visit = escapeHtml(visitDate);

    final ww = filledWorkingWell(workingWell);
    final ua = filledUrgent(urgentAttention);
    final to = filledTeachers(teacherObservation);
    final ts = filledTraining(trainingSupport);

    final workingTable = ww.isEmpty
        ? _noDataHtml()
        : _tableHtml(
            headers: const ['No.', 'Observation'],
            rows: [
              for (var i = 0; i < ww.length; i++)
                ['${i + 1}', escapeHtml(ww[i].observation.trim())],
            ],
          );

    final urgentTable = ua.isEmpty
        ? _noDataHtml()
        : _tableHtml(
            headers: const ['No.', 'Area of Concern', 'Timeline'],
            rows: [
              for (var i = 0; i < ua.length; i++)
                [
                  '${i + 1}',
                  escapeHtml(ua[i].areaOfConcern.trim()),
                  escapeHtml(ua[i].timeline.trim()),
                ],
            ],
          );

    final teacherTable = to.isEmpty
        ? _noDataHtml()
        : _tableHtml(
            headers: const ['No.', 'Teacher Name', 'Class', 'App Status'],
            rows: [
              for (var i = 0; i < to.length; i++)
                [
                  '${i + 1}',
                  escapeHtml(to[i].teacherName.trim()),
                  escapeHtml(to[i].className.trim()),
                  escapeHtml(to[i].appStatus.trim()),
                ],
            ],
          );

    final trainingTable = ts.isEmpty
        ? _noDataHtml()
        : _tableHtml(
            headers: const ['No.', 'Details'],
            rows: [
              for (var i = 0; i < ts.length; i++)
                ['${i + 1}', escapeHtml(ts[i].details.trim())],
            ],
          );

    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Centre Visit Report</title>
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;color:#222;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:24px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:680px;background:#ffffff;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
          <tr>
            <td style="background:#1565c0;padding:18px 22px;">
              <div style="font-size:18px;font-weight:700;color:#ffffff;">Centre Visit Report</div>
              <div style="font-size:13px;color:#e3f2fd;margin-top:4px;">$centre &nbsp;|&nbsp; $visit</div>
            </td>
          </tr>
          <tr>
            <td style="padding:22px;">
              <p style="margin:0 0 12px;font-size:14px;line-height:1.55;">Dear <strong>$partner</strong>,</p>
              <p style="margin:0 0 12px;font-size:14px;line-height:1.55;"><strong>Namaste!</strong></p>
              <p style="margin:0 0 12px;font-size:14px;line-height:1.55;">
                Thank you for your time, support, and warm hospitality extended during the recent
                Centre Visit conducted at your centre on <strong>$visit</strong>.
              </p>
              <p style="margin:0 0 12px;font-size:14px;line-height:1.55;">
                It was a pleasure interacting with you and your team and gaining insights into the
                operational and academic practices at the centre.
              </p>
              <p style="margin:0 0 20px;font-size:14px;line-height:1.55;">
                Please find below a snapshot of the visit, including key observations, strengths,
                and recommended action points for your review and implementation.
              </p>

              ${_sectionHtml("WHAT'S WORKING WELL", workingTable)}
              ${_sectionHtml('URGENT ATTENTION', urgentTable)}
              ${_sectionHtml('TEACHER OBSERVATION', teacherTable)}
              ${_sectionHtml('TRAINING &amp; SUPPORT PROVIDED', trainingTable)}

              <p style="margin:8px 0 12px;font-size:14px;line-height:1.55;">
                The detailed Centre Visit Form (CVF) report is attached for your reference.
              </p>
              <p style="margin:0 0 18px;font-size:14px;line-height:1.55;">
                We sincerely appreciate your continued support, collaboration, and commitment.
              </p>
              <p style="margin:0;font-size:14px;line-height:1.55;">
                Warm regards,<br>
                <strong>Zee Learn Ltd</strong>
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
'''
        .trim();
  }

  String _sectionHtml(String title, String content) {
    return '''
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0 0 18px;">
                <tr>
                  <td style="background:#e3f2fd;border-radius:6px;padding:10px 12px;">
                    <div style="font-size:13px;font-weight:700;color:#0d47a1;letter-spacing:0.3px;">$title</div>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top:10px;">
                    $content
                  </td>
                </tr>
              </table>
''';
  }

  String _noDataHtml() {
    return '''
                    <div style="padding:12px 14px;background:#f7f8fa;border:1px solid #e5e7eb;border-radius:6px;font-size:13px;font-style:italic;color:#6b7280;">
                      $noDataMessage
                    </div>
''';
  }

  String _tableHtml({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final headerCells = headers
        .map(
          (h) =>
              '<th style="padding:8px 10px;text-align:left;font-size:12px;font-weight:700;color:#0d47a1;background:#f0f7ff;border:1px solid #dbe3ee;">${escapeHtml(h)}</th>',
        )
        .join();

    final bodyRows = StringBuffer();
    for (var r = 0; r < rows.length; r++) {
      final bg = r.isEven ? '#ffffff' : '#fafbfc';
      final cells = rows[r]
          .map(
            (c) =>
                '<td style="padding:8px 10px;font-size:13px;color:#222;border:1px solid #e5e7eb;vertical-align:top;">$c</td>',
          )
          .join();
      bodyRows.writeln(
        '<tr style="background:$bg;">$cells</tr>',
      );
    }

    return '''
                    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
                      <thead>
                        <tr>$headerCells</tr>
                      </thead>
                      <tbody>
                        ${bodyRows.toString()}
                      </tbody>
                    </table>
''';
  }
}
