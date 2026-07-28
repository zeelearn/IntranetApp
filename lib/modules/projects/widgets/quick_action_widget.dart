import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';

class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({
    super.key,
    required this.onAction,
  });

  final ValueChanged<QuickActionType> onAction;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionItem>[
      _QuickActionItem(
        type: QuickActionType.projectList,
        label: 'Project List',
        icon: Icons.folder_open_rounded,
        color: DashboardColors.primary,
        background: DashboardColors.primaryLight,
      ),
      _QuickActionItem(
        type: QuickActionType.myTasks,
        label: 'My Tasks',
        icon: Icons.assignment_outlined,
        color: DashboardColors.warning,
        background: DashboardColors.warningLight,
      ),
      _QuickActionItem(
        type: QuickActionType.createProject,
        label: 'Create Project',
        icon: Icons.add_rounded,
        color: DashboardColors.success,
        background: DashboardColors.successLight,
      ),
      _QuickActionItem(
        type: QuickActionType.reports,
        label: 'Reports',
        icon: Icons.bar_chart_rounded,
        color: DashboardColors.purple,
        background: DashboardColors.purpleLight,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            if (isCompact) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions
                    .map(
                      (item) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: _ActionTile(
                          item: item,
                          onTap: () => onAction(item.type),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            }
            return Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _ActionTile(
                          item: item,
                          onTap: () => onAction(item.type),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final QuickActionType type;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.item,
    required this.onTap,
  });

  final _QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
