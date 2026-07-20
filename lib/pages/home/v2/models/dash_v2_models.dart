import 'package:flutter/material.dart';

class DashKpiStat {
  const DashKpiStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress = 0,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;
}

class DashActivityItem {
  const DashActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final IconData icon;
  final Color color;
}

class DashReminderItem {
  const DashReminderItem({
    required this.month,
    required this.day,
    required this.title,
    required this.when,
  });

  final String month;
  final String day;
  final String title;
  final String when;
}

class DashChartSegment {
  const DashChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class DashNavItem {
  const DashNavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.section,
  });

  final String key;
  final String label;
  final IconData icon;
  final String? section;
}

class DashQuickAccessItem {
  const DashQuickAccessItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.requiresBusiness,
    this.bpmsOnly = false,
    this.hideWhenBpms = false,
    this.notiflowOnly = false,
  });

  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool requiresBusiness;
  final bool bpmsOnly;
  final bool hideWhenBpms;
  final bool notiflowOnly;
}
