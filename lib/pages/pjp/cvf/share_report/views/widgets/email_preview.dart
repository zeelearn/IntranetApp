import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/services/share_report_email_service.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gmail / Outlook style compose preview — masked To/CC, rich table body.
class EmailComposePanel extends StatelessWidget {
  const EmailComposePanel({
    super.key,
    this.showSendInPanel = true,
  });

  final bool showSendInPanel;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();
    const emailSvc = ShareReportEmailService();

    return Obx(() {
      final previewVersion = c.previewTick.value;
      assert(previewVersion >= 0);
      final sending = c.isSending.value;
      final pdfOk = c.pdfAvailable.value;

      final ww = emailSvc.filledWorkingWell(c.workingWell.toList());
      final ua = emailSvc.filledUrgent(c.urgentAttention.toList());
      final teachers = emailSvc.filledTeachers(c.teacherObservation.toList());
      final training = emailSvc.filledTraining(c.trainingSupport.toList());

      return Material(
        color: ShareReportTheme.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ShareReportTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ShareReportTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ComposeToolbar(
                sending: sending,
                showSend: showSendInPanel,
                onSend: c.sendReport,
                onDiscard: c.confirmDiscard,
              ),
              const Divider(height: 1, color: ShareReportTheme.border),
              _MetaRow(
                label: 'To',
                child: _EmailChip(
                  text: ShareReportTheme.maskEmail(c.toEmail),
                  icon: Icons.lock_outline_rounded,
                ),
              ),
              const Divider(height: 1, color: ShareReportTheme.border),
              _MetaRow(
                label: 'Cc',
                child: c.ccEmails.isEmpty
                    ? Text(
                        '—',
                        style: ShareReportTheme.emailMeta.copyWith(
                          color: ShareReportTheme.textSecondary,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: c.ccEmails
                            .map(
                              (e) => _EmailChip(
                                text: ShareReportTheme.maskEmail(e),
                                icon: Icons.lock_outline_rounded,
                              ),
                            )
                            .toList(),
                      ),
              ),
              const Divider(height: 1, color: ShareReportTheme.border),
              _MetaRow(
                label: 'Subject',
                child: Text(
                  c.subject.value,
                  style: ShareReportTheme.subject,
                ),
              ),
              const Divider(height: 1, color: ShareReportTheme.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 18,
                      color: pdfOk
                          ? ShareReportTheme.primary
                          : Colors.red.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.pdfFileName,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: pdfOk
                              ? ShareReportTheme.primary
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    Text(
                      pdfOk ? 'Attached' : 'Unavailable',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pdfOk ? Colors.green.shade700 : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: ShareReportTheme.border),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dear ${c.bpName.isEmpty ? 'Business Partner' : c.bpName},',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 10),
                      Text('Namaste!', style: _boldBody),
                      const SizedBox(height: 10),
                      Text(
                        'Thank you for your time, support, and warm hospitality '
                        'extended during the recent Centre Visit conducted at '
                        'your centre on ${c.visitDateDisplay}.',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'It was a pleasure interacting with you and your team '
                        'and gaining insights into the operational and academic '
                        'practices at the centre.',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please find below a snapshot of the visit, including '
                        'key observations, strengths, and recommended action '
                        'points for your review and implementation.',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 18),
                      _PreviewSection(
                        title: "WHAT'S WORKING WELL",
                        child: ww.isEmpty
                            ? const _NoDataBox()
                            : _PreviewTable(
                                headers: const ['No.', 'Observation'],
                                rows: [
                                  for (var i = 0; i < ww.length; i++)
                                    ['${i + 1}', ww[i].observation.trim()],
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),
                      _PreviewSection(
                        title: 'URGENT ATTENTION',
                        child: ua.isEmpty
                            ? const _NoDataBox()
                            : _PreviewTable(
                                headers: const [
                                  'No.',
                                  'Area of Concern',
                                  'Timeline',
                                ],
                                rows: [
                                  for (var i = 0; i < ua.length; i++)
                                    [
                                      '${i + 1}',
                                      ua[i].areaOfConcern.trim(),
                                      ua[i].timeline.trim(),
                                    ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),
                      _PreviewSection(
                        title: 'TEACHER OBSERVATION',
                        child: teachers.isEmpty
                            ? const _NoDataBox()
                            : _PreviewTable(
                                headers: const [
                                  'No.',
                                  'Teacher Name',
                                  'Class',
                                  'App Status',
                                ],
                                rows: [
                                  for (var i = 0; i < teachers.length; i++)
                                    [
                                      '${i + 1}',
                                      teachers[i].teacherName.trim(),
                                      teachers[i].className.trim(),
                                      teachers[i].appStatus.trim(),
                                    ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 14),
                      _PreviewSection(
                        title: 'TRAINING & SUPPORT PROVIDED',
                        child: training.isEmpty
                            ? const _NoDataBox()
                            : _PreviewTable(
                                headers: const ['No.', 'Details'],
                                rows: [
                                  for (var i = 0; i < training.length; i++)
                                    ['${i + 1}', training[i].details.trim()],
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The detailed Centre Visit Form (CVF) report is '
                        'attached for your reference.',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sincerely appreciate your continued support, '
                        'collaboration, and commitment.',
                        style: ShareReportTheme.emailBody,
                      ),
                      const SizedBox(height: 16),
                      Text('Warm Regards,', style: ShareReportTheme.emailBody),
                      const SizedBox(height: 4),
                      Text(
                        c.facilitatorName.isEmpty
                            ? 'Facilitator'
                            : c.facilitatorName,
                        style: _boldBody,
                      ),
                    ],
                  ),
                ),
              ),
              if (showSendInPanel) ...[
                const Divider(height: 1, color: ShareReportTheme.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: sending ? null : c.sendReport,
                        style: FilledButton.styleFrom(
                          backgroundColor: ShareReportTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: sending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          sending ? 'Sending…' : 'Send',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: sending ? null : c.confirmDiscard,
                        child: Text(
                          'Discard',
                          style: GoogleFonts.poppins(
                            color: ShareReportTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  TextStyle get _boldBody => GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: ShareReportTheme.textPrimary,
        height: 1.55,
      );
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: ShareReportTheme.chipBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ShareReportTheme.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _NoDataBox extends StatelessWidget {
  const _NoDataBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShareReportTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16, color: ShareReportTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            ShareReportEmailService.noDataMessage,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: ShareReportTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: ShareReportTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: ShareReportTheme.border),
          verticalInside:
              BorderSide(color: ShareReportTheme.border.withValues(alpha: 0.8)),
        ),
        columnWidths: {
          0: const FixedColumnWidth(40),
          for (var i = 1; i < headers.length; i++) i: const FlexColumnWidth(),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: ShareReportTheme.composeHeader),
            children: [
              for (final h in headers)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    h,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ShareReportTheme.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          for (var r = 0; r < rows.length; r++)
            TableRow(
              decoration: BoxDecoration(
                color: r.isEven ? Colors.white : const Color(0xFFFAFBFC),
              ),
              children: [
                for (final cell in rows[r])
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      cell,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: ShareReportTheme.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ComposeToolbar extends StatelessWidget {
  const _ComposeToolbar({
    required this.sending,
    required this.showSend,
    required this.onSend,
    required this.onDiscard,
  });

  final bool sending;
  final bool showSend;
  final VoidCallback onSend;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: const BoxDecoration(
        color: ShareReportTheme.composeHeader,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline_rounded,
              size: 20, color: ShareReportTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'New message',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ShareReportTheme.textPrimary,
              ),
            ),
          ),
          if (showSend)
            IconButton(
              tooltip: 'Send',
              onPressed: sending ? null : onSend,
              icon: Icon(
                Icons.send_rounded,
                color: sending
                    ? ShareReportTheme.textSecondary
                    : ShareReportTheme.primary,
              ),
            ),
          IconButton(
            tooltip: 'Discard',
            onPressed: sending ? null : onDiscard,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ShareReportTheme.textSecondary,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ShareReportTheme.chipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShareReportTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: ShareReportTheme.textSecondary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: ShareReportTheme.emailMeta,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
