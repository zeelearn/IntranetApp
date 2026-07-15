import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.statusLabel,
    required this.statusColor,
    required this.onDetails,
    required this.onNotes,
    required this.onEdit,
    this.index = 0,
    this.showMissedDeadline = false,
  });

  final ProjectItem project;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onDetails;
  final VoidCallback onNotes;
  final VoidCallback onEdit;
  final int index;
  final bool showMissedDeadline;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 186;
  late final AnimationController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    if (_swipeController.isCompleted) {
      _swipeController.reverse();
    } else {
      _swipeController.forward();
    }
  }

  void _closeActions() {
    if (_swipeController.value > 0) {
      _swipeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final chip = widget.statusLabel.length > 3
        ? widget.statusLabel.substring(0, 1).toUpperCase()
        : widget.statusLabel;
    final approved = ProjectDateUtils.formatReadable(p.approvedDate);
    final deadline = ProjectDateUtils.formatReadable(p.deadline);
    final missed = widget.showMissedDeadline &&
        ProjectDateUtils.isMissed(p.deadline);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (widget.index * 40).clamp(0, 400)),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _swipeController,
            builder: (context, _) {
              final offset = -_actionWidth * _swipeController.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      children: [
                        const Spacer(),
                        _SwipeAction(
                          color: DashboardColors.primary,
                          icon: Icons.folder_open_rounded,
                          label: 'Details',
                          onTap: () {
                            _closeActions();
                            widget.onDetails();
                          },
                        ),
                        _SwipeAction(
                          color: DashboardColors.success,
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Notes',
                          onTap: () {
                            _closeActions();
                            widget.onNotes();
                          },
                        ),
                        _SwipeAction(
                          color: DashboardColors.purple,
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          onTap: () {
                            _closeActions();
                            widget.onEdit();
                          },
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0x14000000),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (_swipeController.value > 0) {
                            _closeActions();
                          } else {
                            widget.onDetails();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.crmId.isEmpty ? '—' : p.crmId,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: DashboardColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  StatusBadge(
                                    label: chip,
                                    color: widget.statusColor,
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    tooltip: 'More actions',
                                    onPressed: _toggleActions,
                                    icon: Icon(
                                      _swipeController.value > 0.5
                                          ? Icons.close_rounded
                                          : Icons.more_vert_rounded,
                                      color: DashboardColors.textMuted,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                p.franchiseeName.isNotEmpty
                                    ? p.franchiseeName
                                    : (p.title.isNotEmpty ? p.title : '—'),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF37474F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: p.catchmentArea.isNotEmpty
                                    ? p.catchmentArea
                                    : '—',
                              ),
                              const SizedBox(height: 3),
                              _InfoRow(
                                icon: Icons.person_outline_rounded,
                                text: p.createdBy.isNotEmpty
                                    ? p.createdBy
                                    : (p.responsiblePerson.isNotEmpty
                                        ? p.responsiblePerson
                                        : '—'),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetaChip(
                                      icon: Icons.layers_outlined,
                                      label: p.tierName.isNotEmpty
                                          ? p.tierName
                                          : 'Tier —',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _MetaChip(
                                      icon: Icons.payments_outlined,
                                      label: p.feeType.isNotEmpty
                                          ? p.feeType
                                          : 'Fee —',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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
                              const SizedBox(height: 6),
                              TaskSummaryWidget(summary: p.taskSummary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
