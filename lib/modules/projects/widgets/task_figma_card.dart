import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/task_summary.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';

/// Figma-aligned task / subtask card used by Tree and List views.
class TaskFigmaCard extends StatelessWidget {
  const TaskFigmaCard({
    super.key,
    required this.task,
    required this.isFolder,
    required this.onTap,
    this.canMutate = false,
    this.expanded = false,
    this.showRootTag = false,
    this.onAction,
    this.trailingChevron = false,
  });

  final HierarchyTask task;
  final bool isFolder;
  final bool canMutate;
  final bool expanded;
  final bool showRootTag;
  final bool trailingChevron;
  final VoidCallback onTap;
  final void Function(TaskActionType action)? onAction;

  static const statusPending = Color(0xFFF9A825);
  static const statusInProgress = Color(0xFF673AB7);
  static const statusCompleted = Color(0xFF43A047);
  static const statusBpCompleted = Color(0xFF1976D2);
  static const priorityHigh = Color(0xFFE53935);
  static const priorityMedium = Color(0xFFFB8C00);
  static const priorityLow = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    final statusColor = statusColorFor(task.statusChip);
    final cardColor = task.isRoot ? task.pastelBackground : Colors.white;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: const Color(0x1A000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            task.isRoot ? 12 : 12,
            8,
            task.isRoot ? 12 : 12,
          ),
          child: task.isRoot
              ? _RootTaskBody(
                  task: task,
                  statusColor: statusColor,
                  canMutate: canMutate,
                  onAction: onAction,
                )
              : _SubTaskBody(
                  task: task,
                  isFolder: isFolder,
                  expanded: expanded,
                  canMutate: canMutate,
                  trailingChevron: trailingChevron,
                  statusColor: statusColor,
                  onAction: onAction,
                ),
        ),
      ),
    );
  }

  static bool hasDateValue(String raw) {
    final v = raw.trim();
    if (v.isEmpty || v == '-' || v.toLowerCase() == 'null') return false;
    return true;
  }

  static bool hasAnyDate(String start, String end) =>
      hasDateValue(start) || hasDateValue(end);

  static String fmtDate(String raw) {
    if (!hasDateValue(raw)) return '—';
    return ProjectDateUtils.formatReadable(raw);
  }

  static Color statusColorFor(String chip) {
    switch (chip.toUpperCase()) {
      case 'IP':
        return statusInProgress;
      case 'C':
        return statusCompleted;
      case 'BPC':
        return statusBpCompleted;
      default:
        return statusPending;
    }
  }

  static Color priorityColorFor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('high')) return priorityHigh;
    if (p.contains('medium')) return priorityMedium;
    if (p.contains('low')) return priorityLow;
    return DashboardColors.textMuted;
  }

  static String subTasksLabel(TaskSummary summary, int total) {
    if (total <= 0) return '0';
    if (summary.completed > 0 &&
        summary.pending == 0 &&
        summary.inProgress == 0) {
      return '${summary.completed} Completed';
    }
    if (summary.pending > 0 &&
        summary.completed == 0 &&
        summary.inProgress == 0) {
      return '${summary.pending} Pending';
    }
    return '$total Total';
  }

  static int? durationDays({
    required String preferStart,
    required String preferEnd,
    required String fallbackStart,
    required String fallbackEnd,
  }) {
    var start = ProjectDateUtils.tryParse(preferStart);
    var end = ProjectDateUtils.tryParse(preferEnd);
    if (start == null || end == null) {
      start = ProjectDateUtils.tryParse(fallbackStart);
      end = ProjectDateUtils.tryParse(fallbackEnd);
    }
    if (start == null || end == null) return null;
    final days = end.difference(start).inDays.abs() + 1;
    return days < 1 ? 1 : days;
  }
}

/// Root / main task card — Figma: count | title+chips | status+menu, then date grid.
class _RootTaskBody extends StatelessWidget {
  const _RootTaskBody({
    required this.task,
    required this.statusColor,
    required this.canMutate,
    this.onAction,
  });

  final HierarchyTask task;
  final Color statusColor;
  final bool canMutate;
  final void Function(TaskActionType action)? onAction;

  @override
  Widget build(BuildContext context) {
    final summary = task.summary;
    final attachments = task.attachmentList;
    final planStart = task.displayPlanStart;
    final planEnd = task.displayPlanEnd;
    final actualStart = task.displayActualStart;
    final actualEnd = task.displayActualEnd;
    final hasAnyDate = TaskFigmaCard.hasDateValue(planStart) ||
        TaskFigmaCard.hasDateValue(planEnd) ||
        TaskFigmaCard.hasDateValue(actualStart) ||
        TaskFigmaCard.hasDateValue(actualEnd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _TaskCountBadge(count: task.totalTaskCount),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title.isEmpty ? 'Untitled' : task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _RootStatusChips(summary: summary),
                ],
              ),
            ),
            const SizedBox(width: 4),
            _CircularStatusBadge(
              label: task.statusChip,
              color: statusColor,
              size: 30,
            ),
            if (onAction != null)
              _TaskOverflowMenu(
                canMutate: canMutate,
                onAction: onAction!,
              ),
          ],
        ),
        if (hasAnyDate) ...[
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RootDateCell(
                  label: 'Plan Start',
                  value: TaskFigmaCard.fmtDate(planStart),
                ),
              ),
              Expanded(
                child: _RootDateCell(
                  label: 'Plan End',
                  value: TaskFigmaCard.fmtDate(planEnd),
                ),
              ),
              Expanded(
                child: _RootDateCell(
                  label: 'Actual Start',
                  value: TaskFigmaCard.fmtDate(actualStart),
                ),
              ),
              Expanded(
                child: _RootDateCell(
                  label: 'Actual End',
                  value: TaskFigmaCard.fmtDate(actualEnd),
                ),
              ),
            ],
          ),
        ],
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 8),
          TaskAttachmentList(files: attachments, compact: true),
        ],
      ],
    );
  }
}

class _RootStatusChips extends StatelessWidget {
  const _RootStatusChips({required this.summary});

  final TaskSummary summary;

  @override
  Widget build(BuildContext context) {
    final chips = <(String, int, Color)>[
      ('P', summary.pending, TaskFigmaCard.statusPending),
      ('IP', summary.inProgress, TaskFigmaCard.statusInProgress),
      ('C', summary.completed, TaskFigmaCard.statusCompleted),
      ('BPC', summary.bpCompleted, TaskFigmaCard.statusBpCompleted),
    ];
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final c in chips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: c.$3.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${c.$1} ${c.$2}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: c.$3,
              ),
            ),
          ),
      ],
    );
  }
}

class _RootDateCell extends StatelessWidget {
  const _RootDateCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: DashboardColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TaskCountBadge extends StatelessWidget {
  const _TaskCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: GoogleFonts.poppins(
          fontSize: count > 99 ? 11 : 15,
          fontWeight: FontWeight.w700,
          color: DashboardColors.primary,
        ),
      ),
    );
  }
}

/// Subtask fields: Responsible, Plan/Actual, Priority / Sub Tasks / Comments.
class _SubTaskBody extends StatelessWidget {
  const _SubTaskBody({
    required this.task,
    required this.isFolder,
    required this.expanded,
    required this.canMutate,
    required this.trailingChevron,
    required this.statusColor,
    this.onAction,
  });

  final HierarchyTask task;
  final bool isFolder;
  final bool expanded;
  final bool canMutate;
  final bool trailingChevron;
  final Color statusColor;
  final void Function(TaskActionType action)? onAction;

  @override
  Widget build(BuildContext context) {
    final summary = task.summary;
    final subTotal = summary.completed +
        summary.inProgress +
        summary.pending +
        summary.bpCompleted;
    final commentCount = task.latestComment.trim().isEmpty ? 0 : 1;
    final hasPlanDates =
        TaskFigmaCard.hasAnyDate(task.planStartDate, task.dueDate);
    final hasActualDates =
        TaskFigmaCard.hasAnyDate(task.startDate, task.endDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeadingIcon(isFolder: isFolder, expanded: expanded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.title.isEmpty ? 'Untitled' : task.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A237E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            _CircularStatusBadge(
              label: task.statusChip,
              color: statusColor,
            ),
            _HeaderActions(
              canMutate: canMutate,
              trailingChevron: trailingChevron,
              isFolder: isFolder,
              expanded: expanded,
              onAction: onAction,
            ),
          ],
        ),
        if (task.responsiblePerson.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Responsible: ${task.responsiblePerson.trim()}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: DashboardColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (hasPlanDates || hasActualDates) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPlanDates)
                Expanded(
                  child: _DateColumn(
                    title: 'Plan Dates',
                    start: task.planStartDate,
                    end: task.dueDate,
                  ),
                ),
              if (hasPlanDates && hasActualDates) const SizedBox(width: 8),
              if (hasActualDates)
                Expanded(
                  child: _DateColumn(
                    title: 'Actual Dates',
                    start: task.startDate,
                    end: task.endDate,
                  ),
                ),
              const SizedBox(width: 4),
              _DurationChip(
                days: TaskFigmaCard.durationDays(
                  preferStart: task.planStartDate,
                  preferEnd: task.dueDate,
                  fallbackStart: task.startDate,
                  fallbackEnd: task.endDate,
                ),
              ),
            ],
          ),
        ],
        if (task.attachmentList.isNotEmpty) ...[
          const SizedBox(height: 8),
          TaskAttachmentList(files: task.attachmentList, compact: true),
        ],
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FooterStat(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: task.priority.trim().isEmpty
                    ? '—'
                    : task.priority.trim(),
                valueColor: TaskFigmaCard.priorityColorFor(task.priority),
              ),
            ),
            Expanded(
              child: _FooterStat(
                icon: Icons.list_alt_rounded,
                label: 'Sub Tasks',
                value: TaskFigmaCard.subTasksLabel(summary, subTotal),
                valueColor: summary.completed > 0
                    ? TaskFigmaCard.statusCompleted
                    : DashboardColors.primary,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onAction == null
                    ? null
                    : () => onAction!(TaskActionType.comments),
                borderRadius: BorderRadius.circular(8),
                child: _FooterStat(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Comments',
                  value: '$commentCount',
                  valueColor: DashboardColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.canMutate,
    required this.trailingChevron,
    required this.isFolder,
    required this.expanded,
    this.onAction,
  });

  final bool canMutate;
  final bool trailingChevron;
  final bool isFolder;
  final bool expanded;
  final void Function(TaskActionType action)? onAction;

  @override
  Widget build(BuildContext context) {
    if (onAction != null) {
      return _TaskOverflowMenu(
        canMutate: canMutate,
        onAction: onAction!,
      );
    }
    if (trailingChevron) {
      return const Padding(
        padding: EdgeInsets.only(top: 2),
        child: Icon(
          Icons.chevron_right_rounded,
          color: DashboardColors.textMuted,
        ),
      );
    }
    if (isFolder) {
      return Icon(
        expanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: DashboardColors.textMuted,
      );
    }
    return const SizedBox.shrink();
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.isFolder, required this.expanded});

  final bool isFolder;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    if (isFolder) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          expanded ? Icons.folder_open_rounded : Icons.folder_rounded,
          color: const Color(0xFFF9A825),
          size: 22,
        ),
      );
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: DashboardColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CircularStatusBadge extends StatelessWidget {
  const _CircularStatusBadge({
    required this.label,
    required this.color,
    this.size = 34,
  });

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: label.length > 2 ? 8 : (size < 32 ? 9 : 10),
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({
    required this.title,
    required this.start,
    required this.end,
  });

  final String title;
  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          TaskFigmaCard.fmtDate(start),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DashboardColors.textDark,
          ),
        ),
        Icon(Icons.arrow_downward_rounded,
            size: 12, color: Colors.grey.shade400),
        Text(
          TaskFigmaCard.fmtDate(end),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DashboardColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    if (days == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 14, color: Colors.grey.shade600),
          const SizedBox(height: 2),
          Text(
            days == 1 ? '1 Day' : '$days Days',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: DashboardColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TaskOverflowMenu extends StatelessWidget {
  const _TaskOverflowMenu({
    required this.canMutate,
    required this.onAction,
  });

  final bool canMutate;
  final void Function(TaskActionType action) onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskActionType>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: onAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: TaskActionType.view,
          child: _MenuRow(Icons.visibility_outlined, 'View'),
        ),
        const PopupMenuItem(
          value: TaskActionType.comments,
          child: _MenuRow(Icons.chat_bubble_outline, 'Comments'),
        ),
        if (canMutate) ...[
          const PopupMenuItem(
            value: TaskActionType.edit,
            child: _MenuRow(Icons.edit_outlined, 'Edit'),
          ),
          const PopupMenuItem(
            value: TaskActionType.updateStatus,
            child: _MenuRow(Icons.event_available_outlined, 'Update Status'),
          ),
          const PopupMenuItem(
            value: TaskActionType.uploadFile,
            child: _MenuRow(Icons.attach_file_rounded, 'Attach'),
          ),
          const PopupMenuItem(
            value: TaskActionType.assignUser,
            child: _MenuRow(Icons.person_add_alt_1_outlined, 'Assign'),
          ),
        ],
        const PopupMenuItem(
          value: TaskActionType.activity,
          child: _MenuRow(Icons.history_rounded, 'Activity'),
        ),
        const PopupMenuItem(
          value: TaskActionType.createChild,
          child: _MenuRow(Icons.add_circle_outline, 'Add Sub Task'),
        ),
        const PopupMenuItem(
          value: TaskActionType.timeline,
          child: _MenuRow(Icons.timeline_rounded, 'Timeline'),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DashboardColors.textMuted),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

/// Left hierarchy rail (solid / dashed) for tree nesting.
class TaskHierarchyRail extends StatelessWidget {
  const TaskHierarchyRail({
    super.key,
    required this.depth,
    required this.isLast,
    required this.child,
  });

  final int depth;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (depth <= 0) return child;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18.0 * depth,
            child: CustomPaint(
              painter: _RailPainter(depth: depth, isLast: isLast),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({required this.depth, required this.isLast});

  final int depth;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dashed = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < depth; i++) {
      final x = 9.0 + (i * 18.0);
      final isDeepest = i == depth - 1;
      final paint = isDeepest ? dashed : solid;
      if (isDeepest) {
        _drawDashedLine(
            canvas, Offset(x, 0), Offset(x, size.height * 0.55), paint);
        canvas.drawLine(
          Offset(x, size.height * 0.55),
          Offset(x + 10, size.height * 0.55),
          paint,
        );
        if (!isLast) {
          _drawDashedLine(
            canvas,
            Offset(x, size.height * 0.55),
            Offset(x, size.height),
            paint,
          );
        }
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 3.0;
    final total = (b - a).distance;
    if (total <= 0) return;
    final direction = (b - a) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final start = a + direction * drawn;
      final end = a + direction * (drawn + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RailPainter oldDelegate) =>
      oldDelegate.depth != depth || oldDelegate.isLast != isLast;
}
