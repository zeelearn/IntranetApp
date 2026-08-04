import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

/// Left navigation matching the Projects admin menu design.
///
/// Menu visibility is controlled by the dashboard controller (user type).
class ProjectsSidebar extends StatelessWidget {
  const ProjectsSidebar({
    super.key,
    required this.projectCards,
    required this.onProjectTap,
    required this.onAllIndentsTap,
    required this.onCenterKitReportTap,
    required this.onVisualChartsTap,
    this.showProjects = true,
    this.showAllIndents = true,
    this.showCenterKitReport = true,
    this.showVisualCharts = false,
    this.width = 280,
  });

  final List<DashboardCardModel> projectCards;
  final ValueChanged<DashboardCardModel> onProjectTap;
  final VoidCallback onAllIndentsTap;
  final VoidCallback onCenterKitReportTap;
  final VoidCallback onVisualChartsTap;
  final bool showProjects;
  final bool showAllIndents;
  final bool showCenterKitReport;
  final bool showVisualCharts;
  final double width;

  static const _sectionBg = Color(0xFFE8EEF5);

  @override
  Widget build(BuildContext context) {
    final projects = projectCards
        .where((c) => c.kind == DashboardCardKind.project)
        .toList(growable: false);
    final tasks = projectCards
        .where((c) => c.kind == DashboardCardKind.task)
        .toList(growable: false);

    final showIndentsSection = showAllIndents;
    final showReportSection = showCenterKitReport;
    final showAnalyticsSection = showVisualCharts;

    return Material(
      color: Colors.white,
      elevation: 1,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              if (showProjects) ...[
                _SectionHeader(
                  icon: Icons.menu_book_outlined,
                  title: 'Projects',
                ),
                ...projects.map(
                  (card) => _SubMenuItem(
                    label: card.title,
                    count: card.count,
                    onTap: () => onProjectTap(card),
                  ),
                ),
                if (tasks.isNotEmpty) ...[
                  ...tasks.map(
                    (card) => _SubMenuItem(
                      label: card.title,
                      count: card.count,
                      onTap: () => onProjectTap(card),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
              if (showIndentsSection) ...[
                _SectionHeader(
                  icon: Icons.menu_book_outlined,
                  title: 'Indents',
                ),
                if (showAllIndents)
                  _SubMenuItem(
                    label: 'All Indents',
                    onTap: onAllIndentsTap,
                  ),
                const SizedBox(height: 8),
              ],
              if (showReportSection) ...[
                _SectionHeader(
                  icon: Icons.menu_book_outlined,
                  title: 'Report',
                ),
                if (showCenterKitReport)
                  _SubMenuItem(
                    label: 'Center Kit Report',
                    onTap: onCenterKitReportTap,
                  ),
                const SizedBox(height: 8),
              ],
              if (showAnalyticsSection) ...[
                _SectionHeader(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Analytics',
                ),
                if (showVisualCharts)
                  _SubMenuItem(
                    label: 'Visual Charts',
                    onTap: onVisualChartsTap,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ProjectsSidebar._sectionBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF37474F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  const _SubMenuItem({
    required this.label,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final countText = count == null ? '' : ' $count';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(44, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$label -',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    if (countText.isNotEmpty)
                      TextSpan(
                        text: countText,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: DashboardColors.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
