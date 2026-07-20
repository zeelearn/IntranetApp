import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

/// Opens a mail-client style viewer for a communication email.
Future<void> showProjectEmailViewer(
  BuildContext context,
  ProjectCommunicationItem item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProjectEmailViewerSheet(item: item),
  );
}

class ProjectEmailViewerSheet extends StatelessWidget {
  const ProjectEmailViewerSheet({super.key, required this.item});

  final ProjectCommunicationItem item;

  @override
  Widget build(BuildContext context) {
    final when = ProjectDateUtils.formatReadableDateTime(
      item.createdDate,
      timeHint: item.createdTime,
    );
    final subject =
        item.emailSubject.trim().isEmpty ? '(No subject)' : item.emailSubject;
    final status = item.emailStatus.trim().isEmpty ? '' : item.emailStatus;
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      margin: EdgeInsets.only(top: top + 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.45,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                    ),
                    Expanded(
                      child: Text(
                        'Email',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.textDark,
                        ),
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.toUpperCase() == 'SENT'
                                  ? Icons.done_all_rounded
                                  : Icons.mail_outline_rounded,
                              size: 14,
                              color: _statusColor(status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(status),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  children: [
                    // Subject + meta card (mail header)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: DashboardColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.mail_rounded,
                                  color: DashboardColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  subject,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: DashboardColors.textDark,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _MailMetaRow(
                            label: 'To',
                            value: item.toAddress.isEmpty
                                ? '—'
                                : item.toAddress,
                          ),
                          if (item.ccAddress.trim().isNotEmpty)
                            _MailMetaRow(
                              label: 'Cc',
                              value: item.ccAddress,
                            ),
                          if (item.msgType.trim().isNotEmpty)
                            _MailMetaRow(
                              label: 'Type',
                              value: item.msgType,
                            ),
                          _MailMetaRow(
                            label: 'Date',
                            value: when.isEmpty ? '—' : when,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Body paper
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: _MailBody(item: item),
                    ),
                    if (item.response.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFE0A3)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Response',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8A6A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.response,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.4,
                                color: DashboardColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
      case 'DELIVERED':
        return DashboardColors.success;
      case 'FAILED':
      case 'BOUNCE':
        return DashboardColors.error;
      default:
        return DashboardColors.primary;
    }
  }
}

class _MailMetaRow extends StatelessWidget {
  const _MailMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: DashboardColors.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MailBody extends StatelessWidget {
  const _MailBody({required this.item});

  final ProjectCommunicationItem item;

  @override
  Widget build(BuildContext context) {
    final body = item.decodedEmailBody;
    if (body.trim().isEmpty) {
      return Text(
        'No message body',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: DashboardColors.textMuted,
        ),
      );
    }

    if (item.isHtmlBody) {
      return HtmlWidget(
        body,
        textStyle: GoogleFonts.poppins(
          fontSize: 13,
          height: 1.45,
          color: DashboardColors.textDark,
        ),
      );
    }

    return SelectableText(
      item.plainTextBody,
      style: GoogleFonts.poppins(
        fontSize: 13,
        height: 1.5,
        color: DashboardColors.textDark,
      ),
    );
  }
}
