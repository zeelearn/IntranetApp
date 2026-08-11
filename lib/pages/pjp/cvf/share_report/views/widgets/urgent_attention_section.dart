import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_table.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UrgentAttentionSection extends StatelessWidget {
  const UrgentAttentionSection({super.key, this.hideTitle = false});

  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideTitle) ...[
          Text('Urgent Attention', style: ShareReportTheme.sectionTitle),
          const SizedBox(height: 8),
        ],
        Obx(() {
          final items = c.urgentAttention;
          return ShareReportTable(
            columnWidths: const {
              0: FixedColumnWidth(52),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(2),
              3: FixedColumnWidth(56),
            },
            headers: const ['No.', 'Area of Concern', 'Timeline', ''],
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
                    key: ValueKey('ua_area_$i'),
                    initialValue: items[i].areaOfConcern,
                    maxLength: 500,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(
                      hint: 'Area of concern *',
                    ).copyWith(counterText: ''),
                    onChanged: (v) {
                      items[i].areaOfConcern = v;
                      c.onRowEdited();
                    },
                  ),
                  TextFormField(
                    key: ValueKey('ua_time_$i'),
                    initialValue: items[i].timeline,
                    maxLength: 100,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(
                      hint: 'e.g. 7 Days *',
                    ).copyWith(counterText: ''),
                    onChanged: (v) {
                      items[i].timeline = v;
                      c.onRowEdited();
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => c.removeUrgentAttention(i),
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
            ],
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: c.addUrgentAttention,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Add Area',
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
