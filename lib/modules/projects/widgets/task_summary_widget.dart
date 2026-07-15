import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/task_summary.dart';

class TaskSummaryWidget extends StatelessWidget {
  const TaskSummaryWidget({
    super.key,
    required this.summary,
    this.compact = true,
  });

  final TaskSummary summary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = <_ChipData>[
      _ChipData('P', summary.pending, DashboardColors.warning),
      _ChipData('IP', summary.inProgress, DashboardColors.purple),
      _ChipData('C', summary.completed, DashboardColors.success),
      if (summary.bpCompleted > 0)
        _ChipData('BPC', summary.bpCompleted, DashboardColors.primary),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: chips
          .map(
            (c) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 6 : 8,
                vertical: compact ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.color.withValues(alpha: 0.35)),
              ),
              child: Text(
                '${c.label}-${c.count}',
                style: GoogleFonts.poppins(
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: c.color,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StatusLegendBar extends StatelessWidget {
  const StatusLegendBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Legend',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: const [
              _LegendItem(label: 'P Pending', color: DashboardColors.warning),
              _LegendItem(
                label: 'IP In Progress',
                color: DashboardColors.purple,
              ),
              _LegendItem(label: 'C Completed', color: DashboardColors.success),
              _LegendItem(
                label: 'BPC BP Completed',
                color: DashboardColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  const _ChipData(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: DashboardColors.textMuted,
          ),
        ),
      ],
    );
  }
}
