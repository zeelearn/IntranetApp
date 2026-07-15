import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/widgets/task_figma_card.dart';

/// Home › Project › Folder… breadcrumbs for drill-down mode.
class TaskBreadcrumbBar extends StatelessWidget {
  const TaskBreadcrumbBar({
    super.key,
    required this.controller,
  });

  final TaskHierarchyController controller;

  @override
  Widget build(BuildContext context) {
    final stack = controller.navStack.toList(growable: false);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _crumb(
              icon: Icons.home_rounded,
              label: null,
              active: stack.isEmpty,
              onTap: () => controller.popDrill(stackIndex: -1),
            ),
            _sep(),
            _crumb(
              label: controller.projectTitle,
              active: stack.isEmpty,
              onTap: () => controller.popDrill(stackIndex: -1),
            ),
            for (var i = 0; i < stack.length; i++) ...[
              _sep(),
              _crumb(
                label: stack[i].title.isEmpty ? 'Task' : stack[i].title,
                active: i == stack.length - 1,
                onTap: () => controller.popDrill(stackIndex: i),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sep() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
      );

  Widget _crumb({
    required bool active,
    VoidCallback? onTap,
    String? label,
    IconData? icon,
  }) {
    final color = active ? DashboardColors.primary : DashboardColors.textMuted;
    return InkWell(
      onTap: active && label != null && icon == null ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 18, color: color)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  label ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Figma folder card (parent with children) for List / drill-down view.
class TaskFolderTile extends StatelessWidget {
  const TaskFolderTile({
    super.key,
    required this.task,
    required this.onTap,
    this.canMutate = false,
    this.onAction,
  });

  final HierarchyTask task;
  final VoidCallback onTap;
  final bool canMutate;
  final void Function(TaskActionType action)? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TaskFigmaCard(
        task: task,
        isFolder: true,
        canMutate: canMutate,
        trailingChevron: onAction == null,
        onTap: onTap,
        onAction: onAction,
      ),
    );
  }
}

/// Figma leaf card with hierarchy rail for List / drill-down view.
class TaskTimelineTile extends StatelessWidget {
  const TaskTimelineTile({
    super.key,
    required this.task,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.canMutate = false,
    this.onAction,
  });

  final HierarchyTask task;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final bool canMutate;
  final void Function(TaskActionType action)? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TaskHierarchyRail(
        depth: isFirst && isLast ? 0 : 1,
        isLast: isLast,
        child: TaskFigmaCard(
          task: task,
          isFolder: false,
          canMutate: canMutate,
          trailingChevron: onAction == null,
          onTap: onTap,
          onAction: onAction,
        ),
      ),
    );
  }
}
