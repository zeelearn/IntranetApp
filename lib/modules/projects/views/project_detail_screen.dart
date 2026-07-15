import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';

/// Lightweight project detail placeholder (tasks hierarchy later).
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.statusName,
    required this.statusColor,
    this.showMissedDeadline = false,
  });

  final ProjectItem project;
  final String statusName;
  final Color statusColor;
  final bool showMissedDeadline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      appBar: AppBar(
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Project Detail',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.crmId,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DashboardColors.textDark,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: statusName.length > 12
                            ? statusName.split(' ').first
                            : statusName,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.franchiseeName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24),
                  _row('Franchise Code', project.franchiseeCode),
                  _row('Franchise ID', '${project.franchiseeId}'),
                  _row('Catchment', project.catchmentArea),
                  _row('Tier', project.tierName),
                  _row('Fee Type', project.feeType),
                  _row('Created By', project.createdBy),
                  _row('Approved', ProjectDateUtils.formatReadable(project.approvedDate)),
                  _row('Deadline', ProjectDateUtils.formatReadable(project.deadline)),
                  if (showMissedDeadline &&
                      ProjectDateUtils.isMissed(project.deadline))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Deadline missed',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.error,
                        ),
                      ),
                    ),
                  _row('Total Tasks', '${project.totalNoOfTask}'),
                  const SizedBox(height: 12),
                  Text(
                    'Task Summary',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TaskSummaryWidget(
                    summary: project.taskSummary,
                    compact: false,
                  ),
                  if (project.docUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.description_outlined,
                        color: DashboardColors.primary,
                      ),
                      title: Text(
                        'Project Document',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      subtitle: Text(
                        project.docUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Task hierarchy will appear here in a future update.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: DashboardColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: DashboardColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
