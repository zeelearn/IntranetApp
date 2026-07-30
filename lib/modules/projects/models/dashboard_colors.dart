import 'package:flutter/material.dart';

/// Figma design tokens for the Projects Dashboard.
class DashboardColors {
  DashboardColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFE3F2FD);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF3E0);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color purple = Color(0xFF5E35B1);
  static const Color purpleLight = Color(0xFFECE7F6);

  static const Color teal = Color(0xFF00897B);
  static const Color tealLight = Color(0xFFE0F2F1);

  static const Color scaffold = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF1A237E);
  static const Color textMuted = Color(0xFF607D8B);
  static const Color cardShadow = Color(0x1A000000);

  /// Primary blue filled buttons always use white label/icon color.
  static ButtonStyle primaryFilledButton({
    Size? minimumSize,
    OutlinedBorder? shape,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white70,
      minimumSize: minimumSize,
      shape: shape,
    );
  }
}

/// Synthetic status ids for task cards (not API project statuses).
class DashboardStatusIds {
  DashboardStatusIds._();

  static const int allProject = 0;
  static const int confirmedProject = 1;
  static const int notInterestedProject = 2;
  static const int rejectedProject = 3;
  static const int refundProject = 4;
  static const int notStartedProject = 5;
  static const int pendingProject = 6;

  static const int pendingTask = 101;
  static const int inProgressTask = 102;
  static const int completedTask = 103;

  /// Missed-deadline highlight applies only to pending project/task lists.
  static bool showsMissedDeadline(int statusId) =>
      statusId == pendingProject || statusId == pendingTask;

  /// Maps dashboard task-card ids → `GettaskbyUser` `Status` values
  /// (legacy: Pending=1, In Progress=2, Completed=4).
  static int apiStatusForTaskCard(int dashboardTaskStatusId) {
    switch (dashboardTaskStatusId) {
      case inProgressTask:
        return 2;
      case completedTask:
        return 4;
      case pendingTask:
      default:
        return 1;
    }
  }

  static bool isTaskCard(int statusId) =>
      statusId == pendingTask ||
      statusId == inProgressTask ||
      statusId == completedTask;
}
