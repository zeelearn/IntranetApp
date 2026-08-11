import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_table.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkingWellSection extends StatelessWidget {
  const WorkingWellSection({super.key, this.hideTitle = false});

  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideTitle) ...[
          Text("What's Working Well", style: ShareReportTheme.sectionTitle),
          const SizedBox(height: 8),
        ],
        Obx(() {
          final items = c.workingWell;
          return ShareReportTable(
            columnWidths: const {
              0: FixedColumnWidth(52),
              1: FlexColumnWidth(6),
              2: FixedColumnWidth(56),
            },
            headers: const ['No.', 'Observation', ''],
            rows: [
              for (var i = 0; i < items.length; i++)
                [
                  Text(
                    '${i + 1}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  TextFormField(
                    key: ValueKey('ww_obs_$i'),
                    initialValue: items[i].observation,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 3,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(
                      hint: 'Enter observation *',
                    ).copyWith(counterText: ''),
                    onChanged: (v) {
                      items[i].observation = v;
                      c.onRowEdited();
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => c.removeWorkingWell(i),
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
            ],
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: c.addWorkingWell,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Add Observation',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: ShareReportTheme.primary,
          ),
        ),
      ],
    );
  }
}
