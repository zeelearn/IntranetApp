import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_table.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherObservationSection extends StatelessWidget {
  const TeacherObservationSection({super.key, this.hideTitle = false});

  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideTitle) ...[
          Text('Teacher Observation', style: ShareReportTheme.sectionTitle),
          const SizedBox(height: 8),
        ],
        Obx(() {
          final items = c.teacherObservation;
          return ShareReportTable(
            columnWidths: const {
              0: FixedColumnWidth(52),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2.2),
              4: FixedColumnWidth(56),
            },
            headers: const ['No.', 'Teacher Name', 'Class', 'App Status', ''],
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
                    key: ValueKey('to_name_$i'),
                    initialValue: items[i].teacherName,
                    maxLength: 150,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(
                      hint: 'Teacher name *',
                    ).copyWith(counterText: ''),
                    onChanged: (v) {
                      items[i].teacherName = v;
                      c.onRowEdited();
                    },
                  ),
                  TextFormField(
                    key: ValueKey('to_class_$i'),
                    initialValue: items[i].className,
                    maxLength: 100,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(
                      hint: 'Class *',
                    ).copyWith(counterText: ''),
                    onChanged: (v) {
                      items[i].className = v;
                      c.onRowEdited();
                    },
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'to_status_$i-${items[i].dropdownAppStatus ?? 'none'}',
                    ),
                    // Always use a value that exists in [items] (or null).
                    // API may return "active" / mixed casing — normalized in model.
                    initialValue: items[i].dropdownAppStatus,
                    isExpanded: true,
                    style: shareReportCellTextStyle(),
                    decoration: shareReportCellDecoration(hint: 'Status *'),
                    items: TeacherObservationItem.appStatusOptions
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      items[i].appStatus =
                          TeacherObservationItem.normalizeAppStatus(v);
                      c.onRowEdited();
                    },
                    validator: (_) {
                      if (!items[i].hasValidAppStatus) {
                        return 'Select status';
                      }
                      return null;
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => c.removeTeacherObservation(i),
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
            ],
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: c.addTeacherObservation,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            'Add Teacher',
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
