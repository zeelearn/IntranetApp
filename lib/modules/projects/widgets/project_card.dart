import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.statusLabel,
    required this.statusColor,
    required this.onCommunication,
    required this.onIndentDetails,
    required this.onDocuments,
    this.index = 0,
    this.showMissedDeadline = false,
  });

  final ProjectItem project;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onCommunication;
  final VoidCallback onIndentDetails;
  final VoidCallback onDocuments;
  final int index;
  final bool showMissedDeadline;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final chip = statusLabel.length > 3
        ? statusLabel.substring(0, 1).toUpperCase()
        : statusLabel;
    final approved = ProjectDateUtils.formatReadable(p.approvedDate);
    final deadline = ProjectDateUtils.formatReadable(p.deadline);
    final missed =
        showMissedDeadline && ProjectDateUtils.isMissed(p.deadline);
    final displayName = p.franchiseeName.isNotEmpty
        ? p.franchiseeName
        : (p.title.isNotEmpty ? p.title : '—');
    final responsible = p.createdBy.isNotEmpty
        ? p.createdBy
        : (p.responsiblePerson.isNotEmpty ? p.responsiblePerson : '—');
    final showTier = p.tierName.trim().isNotEmpty;
    final showFee = p.feeType.trim().isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index * 40).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 10),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0x14000000),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.crmId.isEmpty ? '—' : p.crmId,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(label: chip, color: statusColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF263238),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: p.catchmentArea.isNotEmpty ? p.catchmentArea : '—',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  text: responsible,
                ),
                if (showTier || showFee) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (showTier)
                        Expanded(
                          child: _MetaChip(
                            icon: Icons.diamond_outlined,
                            label: 'Tier ${p.tierName.trim()}',
                          ),
                        ),
                      if (showTier && showFee) const SizedBox(width: 8),
                      if (showFee)
                        Expanded(
                          child: _MetaChip(
                            icon: Icons.payments_outlined,
                            label: 'Fee ${p.feeType.trim()}',
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: approved,
                      ),
                    ),
                    Expanded(
                      child: _InfoRow(
                        icon: Icons.event_outlined,
                        text: deadline,
                        emphasized: missed,
                        emphasizeColor: DashboardColors.error,
                      ),
                    ),
                  ],
                ),
                if (missed) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Deadline missed',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TaskSummaryWidget(summary: p.taskSummary),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FooterActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Communication',
                        color: DashboardColors.primary,
                        onTap: onCommunication,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _FooterActionButton(
                        icon: Icons.badge_outlined,
                        label: 'Indent Details',
                        color: DashboardColors.purple,
                        onTap: onIndentDetails,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _FooterActionButton(
                        icon: Icons.description_outlined,
                        label: 'Documents',
                        color: DashboardColors.success,
                        onTap: onDocuments,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterActionButton extends StatelessWidget {
  const _FooterActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              height: 1.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: DashboardColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: DashboardColors.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.emphasized = false,
    this.emphasizeColor,
  });

  final IconData icon;
  final String text;
  final bool emphasized;
  final Color? emphasizeColor;

  @override
  Widget build(BuildContext context) {
    final color = emphasized
        ? (emphasizeColor ?? DashboardColors.error)
        : DashboardColors.textMuted;
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
