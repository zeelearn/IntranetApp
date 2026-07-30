import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_summary.dart';

enum DashboardCardKind { project, task }

class DashboardCardModel extends Equatable {
  const DashboardCardModel({
    required this.title,
    required this.count,
    required this.percent,
    required this.statusId,
    required this.statusName,
    required this.chipLabel,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.kind,
  });

  final String title;
  final int count;
  final double percent;
  final int statusId;
  final String statusName;
  final String chipLabel;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final DashboardCardKind kind;

  String get percentLabel {
    final value = percent.isNaN || percent.isInfinite ? 0.0 : percent;
    final formatted =
        value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$formatted% of total';
  }

  DashboardCardModel copyWith({
    String? title,
    int? count,
    double? percent,
    int? statusId,
    String? statusName,
    String? chipLabel,
    Color? color,
    Color? backgroundColor,
    IconData? icon,
    DashboardCardKind? kind,
  }) {
    return DashboardCardModel(
      title: title ?? this.title,
      count: count ?? this.count,
      percent: percent ?? this.percent,
      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,
      chipLabel: chipLabel ?? this.chipLabel,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
      kind: kind ?? this.kind,
    );
  }

  @override
  List<Object?> get props => [
        title,
        count,
        percent,
        statusId,
        statusName,
        chipLabel,
        color,
        backgroundColor,
        icon,
        kind,
      ];

  static double _percent(int count, int total) {
    if (total <= 0) return 0;
    return (count / total) * 100;
  }

  /// Builds dashboard cards from a parsed [DashboardSummary].
  /// [All Projects] is always first.
  static List<DashboardCardModel> fromSummary(DashboardSummary summary) {
    final totalProjects = summary.totalProject;
    final totalTasks = summary.totalTasks;

    final allCount = summary.allProjectCount;
    final pendingCount = summary.countFor(summary.pendingProject);
    final confirmedCount = summary.countFor(summary.completedProject);
    final refundCount = summary.countFor(summary.refundedProject);
    final rejectedCount = summary.countFor(summary.rejectedProject);
    final notInterestedCount = summary.countFor(summary.notInterestedProject);

    return [
      DashboardCardModel(
        title: 'All Projects',
        count: allCount,
        percent: _percent(allCount, totalProjects > 0 ? totalProjects : allCount),
        statusId: summary.statusIdFor(
          summary.allProject,
          DashboardStatusIds.allProject,
        ),
        statusName: 'All Projects',
        chipLabel: 'ALL',
        color: DashboardColors.textDark,
        backgroundColor: const Color(0xFFE8EAF6),
        icon: Icons.apps_rounded,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Pending Projects',
        count: pendingCount,
        percent: _percent(pendingCount, totalProjects),
        statusId: summary.statusIdFor(
          summary.pendingProject,
          DashboardStatusIds.pendingProject,
        ),
        statusName: 'Pending Projects',
        chipLabel: 'P',
        color: DashboardColors.primary,
        backgroundColor: DashboardColors.primaryLight,
        icon: Icons.work_outline_rounded,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Confirmed Projects',
        count: confirmedCount,
        percent: _percent(confirmedCount, totalProjects),
        statusId: summary.statusIdFor(
          summary.completedProject,
          DashboardStatusIds.confirmedProject,
        ),
        statusName: 'Confirmed Projects',
        chipLabel: 'C',
        color: DashboardColors.success,
        backgroundColor: DashboardColors.successLight,
        icon: Icons.check_circle_outline_rounded,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Refund Projects',
        count: refundCount,
        percent: _percent(refundCount, totalProjects),
        statusId: summary.statusIdFor(
          summary.refundedProject,
          DashboardStatusIds.refundProject,
        ),
        statusName: 'Refund Projects',
        chipLabel: 'RF',
        color: DashboardColors.teal,
        backgroundColor: DashboardColors.tealLight,
        icon: Icons.autorenew_rounded,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Reject Projects',
        count: rejectedCount,
        percent: _percent(rejectedCount, totalProjects),
        statusId: summary.statusIdFor(
          summary.rejectedProject,
          DashboardStatusIds.rejectedProject,
        ),
        statusName: 'Rejected Projects',
        chipLabel: 'R',
        color: DashboardColors.error,
        backgroundColor: DashboardColors.errorLight,
        icon: Icons.cancel_outlined,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Not Interested Projects',
        count: notInterestedCount,
        percent: _percent(notInterestedCount, totalProjects),
        statusId: summary.statusIdFor(
          summary.notInterestedProject,
          DashboardStatusIds.notInterestedProject,
        ),
        statusName: 'Not Interested Projects',
        chipLabel: 'NI',
        color: DashboardColors.purple,
        backgroundColor: DashboardColors.purpleLight,
        icon: Icons.help_outline_rounded,
        kind: DashboardCardKind.project,
      ),
      DashboardCardModel(
        title: 'Pending Tasks',
        count: summary.pendingTask,
        percent: _percent(summary.pendingTask, totalTasks),
        statusId: DashboardStatusIds.pendingTask,
        statusName: 'Pending Tasks',
        chipLabel: 'P',
        color: DashboardColors.primary,
        backgroundColor: DashboardColors.primaryLight,
        icon: Icons.checklist_rounded,
        kind: DashboardCardKind.task,
      ),
      DashboardCardModel(
        title: 'In Progress Tasks',
        count: summary.inProgressTask,
        percent: _percent(summary.inProgressTask, totalTasks),
        statusId: DashboardStatusIds.inProgressTask,
        statusName: 'In Progress Tasks',
        chipLabel: 'IP',
        color: DashboardColors.warning,
        backgroundColor: DashboardColors.warningLight,
        icon: Icons.schedule_rounded,
        kind: DashboardCardKind.task,
      ),
      DashboardCardModel(
        title: 'Completed Tasks',
        count: summary.completedTask,
        percent: _percent(summary.completedTask, totalTasks),
        statusId: DashboardStatusIds.completedTask,
        statusName: 'Completed Tasks',
        chipLabel: 'C',
        color: DashboardColors.success,
        backgroundColor: DashboardColors.successLight,
        icon: Icons.task_alt_rounded,
        kind: DashboardCardKind.task,
      ),
    ];
  }
}
