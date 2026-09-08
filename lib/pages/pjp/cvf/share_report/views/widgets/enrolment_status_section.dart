import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/enrolment_status_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_table.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Enrolment Status table:
/// Enrolment Status | Total No of Children | Teacher Name |
/// Date of Joining | Tutelage Trained (Y/N) | PTO Score
///
/// First column = full API `batch` (e.g. `SENIOR KG - Batch 2`).
/// Rows are dynamic from `enr_status_array`. Nulls render as empty.
class EnrolmentStatusSection extends StatelessWidget {
  const EnrolmentStatusSection({super.key});

  static const _minTableWidth = 700.0;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();

    return Obx(() {
      final rows = c.enrolmentStatus;
      final tick = c.previewTick.value;
      assert(tick >= 0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF37474F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(
              'Enrolment Status',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (rows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ShareReportTheme.surface,
                border: Border.all(color: ShareReportTheme.border),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Text(
                'No enrolment status data available.',
                style: ShareReportTheme.label,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final needsScroll = maxW < _minTableWidth;
                final tableWidth = needsScroll ? _minTableWidth : maxW;

                final table = SizedBox(
                  width: tableWidth,
                  child: Table(
                    defaultVerticalAlignment:
                        TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: ShareReportTheme.border),
                    columnWidths: const {
                      0: FlexColumnWidth(2.0),
                      1: FlexColumnWidth(1.3),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.4),
                      4: FlexColumnWidth(1.4),
                      5: FlexColumnWidth(1.0),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                        ),
                        children: [
                          _headerCell('Enrolment Status'),
                          _headerCell('Total No of Children'),
                          _headerCell('Teacher Name'),
                          _headerCell('Date of Joining'),
                          _headerCell('Tutelage Trained (Y/N)'),
                          _headerCell('PTO Score'),
                        ],
                      ),
                      for (var i = 0; i < rows.length; i++)
                        TableRow(
                          decoration: BoxDecoration(
                            color: i.isEven
                                ? Colors.white
                                : const Color(0xFFFAFBFC),
                          ),
                          children: [
                            _labelCell(rows[i].batch),
                            _numField(
                              key: 'es_tot_$i',
                              value: rows[i].totalChildren,
                              hint: '',
                              onChanged: (v) {
                                rows[i].totalChildren = v;
                                c.onRowEdited();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: TextFormField(
                                key: ValueKey('es_tn_$i'),
                                initialValue: rows[i].teacherName,
                                maxLength: 100,
                                style: shareReportCellTextStyle(),
                                decoration: shareReportCellDecoration(
                                  hint: '',
                                ).copyWith(counterText: ''),
                                onChanged: (v) {
                                  rows[i].teacherName = v;
                                  c.onRowEdited();
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: _DateField(
                                key: ValueKey(
                                  'es_doj_${i}_${rows[i].dateOfJoining}',
                                ),
                                value: rows[i].dateOfJoining,
                                onPicked: (v) {
                                  rows[i].dateOfJoining = v;
                                  c.onRowEdited();
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: DropdownButtonFormField<String>(
                                key: ValueKey(
                                  'es_tt_${i}_${rows[i].dropdownTutelage ?? 'none'}',
                                ),
                                initialValue: rows[i].dropdownTutelage,
                                isExpanded: true,
                                decoration:
                                    shareReportCellDecoration(hint: ''),
                                items: [
                                  for (final o
                                      in EnrolmentStatusRow.tutelageOptions)
                                    DropdownMenuItem(
                                      value: o,
                                      child: Text(o),
                                    ),
                                ],
                                onChanged: (v) {
                                  rows[i].tutelageTrained =
                                      EnrolmentStatusRow.normalizeTutelage(v);
                                  c.onRowEdited();
                                },
                              ),
                            ),
                            _numField(
                              key: 'es_pto_$i',
                              value: rows[i].ptoScore,
                              hint: '',
                              decimal: true,
                              onChanged: (v) {
                                rows[i].ptoScore = v;
                                c.onRowEdited();
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                );

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ShareReportTheme.surface,
                    border: Border.all(color: ShareReportTheme.border),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: needsScroll
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: table,
                        )
                      : table,
                );
              },
            ),
          const SizedBox(height: 6),
          Text(
            'Rows load from enr_status_array. Tutelage = Y/N. PTO Score = 0–100.',
            style: ShareReportTheme.label,
          ),
        ],
      );
    });
  }

  static Widget _numField({
    required String key,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    bool decimal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: TextFormField(
        key: ValueKey(key),
        initialValue: value,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: [
          if (decimal)
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        style: shareReportCellTextStyle(),
        decoration: shareReportCellDecoration(hint: hint),
        onChanged: onChanged,
      ),
    );
  }

  static Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: ShareReportTheme.textPrimary,
        ),
      ),
    );
  }

  static Widget _labelCell(String text) {
    final label = EnrolmentStatusRow.displayText(text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        label.isEmpty ? '' : label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ShareReportTheme.textPrimary,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.value,
    required this.onPicked,
  });

  final String value;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final display = EnrolmentStatusRow.displayText(value);
    return InkWell(
      onTap: () async {
        DateTime initial = DateTime.now();
        if (display.isNotEmpty) {
          for (final pattern in const [
            'dd-MM-yyyy',
            'dd-MMM-yyyy',
            'yyyy-MM-dd',
          ]) {
            try {
              initial = DateFormat(pattern).parse(display);
              break;
            } catch (_) {}
          }
        }
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1990),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked == null) return;
        onPicked(DateFormat('dd-MM-yyyy').format(picked));
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: shareReportCellDecoration(hint: ''),
        child: Text(
          display,
          style: shareReportCellTextStyle().copyWith(
            color: display.isEmpty
                ? ShareReportTheme.textSecondary.withValues(alpha: 0.7)
                : ShareReportTheme.textPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
