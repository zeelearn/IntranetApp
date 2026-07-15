import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

/// Activity chart section. v1 shows empty state only (no fabricated series).
///
/// Place inside [Expanded]/[Flexible] to fill remaining height (mobile),
/// or leave unbounded and it uses a fixed chart body height (tablet/web).
class DashboardChart extends StatelessWidget {
  const DashboardChart({
    super.key,
    this.onViewAll,
    this.fillsHeight = false,
  });

  final VoidCallback? onViewAll;

  /// When true, chart expands to fill parent height (for mobile Expanded slot).
  final bool fillsHeight;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Project Activity Overview',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardColors.primary,
            ),
          ),
        ),
      ],
    );

    final body = _EmptyChartBody();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: fillsHeight
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 8),
                Expanded(child: body),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 8),
                SizedBox(height: 160, child: body),
              ],
            ),
    );
  }
}

class _EmptyChartBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 42,
                color: DashboardColors.primary.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 8),
              Text(
                'No activity data yet',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Activity trends will appear here when available',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: DashboardColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
