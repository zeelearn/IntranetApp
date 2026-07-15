import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

/// Compact task meta lines — only renders non-empty fields.
class TaskMetaInfo extends StatelessWidget {
  const TaskMetaInfo({
    super.key,
    this.responsiblePerson = '',
    this.planStart = '',
    this.planEnd = '',
    this.actualStart = '',
    this.actualEnd = '',
    this.highlightMissedPlanEnd = false,
  });

  final String responsiblePerson;
  final String planStart;
  final String planEnd;
  final String actualStart;
  final String actualEnd;
  final bool highlightMissedPlanEnd;

  @override
  Widget build(BuildContext context) {
    final lines = <Widget>[];

    if (_has(responsiblePerson)) {
      lines.add(_line('Responsible', responsiblePerson.trim()));
    }
    if (_has(planStart)) {
      lines.add(
        _line('Plan Start', ProjectDateUtils.formatReadable(planStart)),
      );
    }
    if (_has(planEnd)) {
      final missed =
          highlightMissedPlanEnd && ProjectDateUtils.isMissed(planEnd);
      lines.add(
        _line(
          'Plan End',
          ProjectDateUtils.formatReadable(planEnd),
          emphasize: missed,
          emphasizeColor: DashboardColors.error,
        ),
      );
    }
    if (_has(actualStart)) {
      lines.add(
        _line('Actual Start', ProjectDateUtils.formatReadable(actualStart)),
      );
    }
    if (_has(actualEnd)) {
      lines.add(
        _line('Actual End', ProjectDateUtils.formatReadable(actualEnd)),
      );
    }

    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            lines[i],
          ],
        ],
      ),
    );
  }

  bool _has(String? value) {
    final v = value?.trim() ?? '';
    return v.isNotEmpty &&
        v != '-' &&
        v.toLowerCase() != 'null' &&
        v.toLowerCase() != 'n/a';
  }

  Widget _line(
    String label,
    String value, {
    bool emphasize = false,
    Color? emphasizeColor,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DashboardColors.textMuted,
            ),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
              color: emphasize
                  ? (emphasizeColor ?? DashboardColors.textDark)
                  : DashboardColors.textMuted,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
