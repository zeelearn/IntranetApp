import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/cvf_internal_data.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_table.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Branding (read-only from Requested_PenteMind) + enrolment matrix.
///
/// Headers = Class_Name from [head_cnt].
/// Rows (fixed order):
/// 1. Enrolment for {stud_count_array[0].academicyear_id}
/// 2. ACK for {kit_count_array[0].academicyear_id}
/// 3. Enrolment for {stud_count_array[1].academicyear_id} (if present)
/// 4. Head Count on date of visit (editable from head_cnt)
/// 5. Register Count on the day of visit (editable from reg_cnt)
class BrandingEnrolmentSection extends StatelessWidget {
  const BrandingEnrolmentSection({super.key});

  static const _minTableWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();

    return Obx(() {
      final tick = c.enrolmentMatrixTick.value;
      assert(tick >= 0);
      final data = c.internalData.value;
      final branding = c.brandingLabel;

      // Column headers come from head_cnt Class_Name (fallback class_list).
      final classes = _headerClasses(data);
      if (data == null || classes.isEmpty) {
        return _emptyState();
      }

      final stud0 =
          data.studCountArray.isNotEmpty ? data.studCountArray[0] : null;
      final stud1 =
          data.studCountArray.length > 1 ? data.studCountArray[1] : null;
      final kit0 = data.kitCountArray.isNotEmpty ? data.kitCountArray[0] : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EAF8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFAED6F1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Centre is upgraded with Branding:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ShareReportTheme.textPrimary,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0.85,
                    child: _YesNoToggle(
                      value: c.brandingUpgraded,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  branding,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ShareReportTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final needsScroll = maxW < _minTableWidth;
              final tableWidth =
                  needsScroll ? (_minTableWidth + classes.length * 24.0) : maxW;

              final table = SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(color: ShareReportTheme.border),
                  columnWidths: {
                    0: const FlexColumnWidth(2.6),
                    for (var i = 0; i < classes.length; i++)
                      i + 1: const FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
                      children: [
                        _cornerCell(),
                        for (final cls in classes) _headerCell(cls.className),
                      ],
                    ),
                    if (stud0 != null)
                      _readonlyCountRow(
                        label: 'Enrolment For ${stud0.academicYearId}',
                        classes: classes,
                        valueFor: (classId) =>
                            _studNumber(stud0.studList, classId),
                      ),
                    if (kit0 != null)
                      _readonlyCountRow(
                        label: 'ACK For ${kit0.academicYearId}',
                        classes: classes,
                        valueFor: (classId) =>
                            _kitNumber(kit0.kitList, classId),
                      ),
                    if (stud1 != null)
                      _readonlyCountRow(
                        label: 'Enrolment For ${stud1.academicYearId}',
                        classes: classes,
                        valueFor: (classId) =>
                            _studNumber(stud1.studList, classId),
                      ),
                    _editableCountRow(
                      label: 'Head Count on date of visit',
                      classes: classes,
                      keyPrefix: 'hc',
                      valueFor: (id) {
                        final v = data.headCountOrNull(id);
                        return v == null ? '' : '$v';
                      },
                      onChanged: c.onHeadCountChanged,
                    ),
                    _editableCountRow(
                      label: 'Register Count on the day of visit',
                      classes: classes,
                      keyPrefix: 'rc',
                      valueFor: (id) {
                        final v = data.regCountOrNull(id);
                        return v == null ? '' : '$v';
                      },
                      onChanged: c.onRegCountChanged,
                    ),
                  ],
                ),
              );

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ShareReportTheme.surface,
                  border: Border.all(color: ShareReportTheme.border),
                  borderRadius: BorderRadius.circular(10),
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
            'Enrolment / ACK values come from the API. '
            'Enter Head Count and Register Count for every class.',
            style: ShareReportTheme.label,
          ),
        ],
      );
    });
  }

  static List<CvfClassInfo> _headerClasses(CvfInternalData? data) {
    if (data == null) return const [];
    if (data.headCnt.isNotEmpty) {
      return [
        for (final h in data.headCnt)
          CvfClassInfo(classId: h.classId, className: h.className),
      ];
    }
    return data.classList;
  }

  static String? _studNumber(List<CvfStudListItem> list, int classId) {
    for (final s in list) {
      if (s.classId == classId) {
        return s.studNumber == null ? '' : '${s.studNumber}';
      }
    }
    return null;
  }

  static String? _kitNumber(List<CvfKitListItem> list, int classId) {
    for (final k in list) {
      if (k.classId == classId) {
        return k.kitNumber == null ? '' : '${k.kitNumber}';
      }
    }
    return null;
  }

  static Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShareReportTheme.composeHeader,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ShareReportTheme.border),
      ),
      child: Text(
        'Enrolment matrix will appear once centre internal data is loaded.',
        style: ShareReportTheme.label,
      ),
    );
  }

  static TableRow _readonlyCountRow({
    required String label,
    required List<CvfClassInfo> classes,
    required String? Function(int classId) valueFor,
  }) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF7F9FB)),
      children: [
        _labelCell(label),
        for (final cls in classes) _readonlyCell(valueFor(cls.classId) ?? ''),
      ],
    );
  }

  static TableRow _editableCountRow({
    required String label,
    required List<CvfClassInfo> classes,
    required String keyPrefix,
    required String Function(int classId) valueFor,
    required void Function(int classId, String value) onChanged,
  }) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _labelCell(label),
        for (final cls in classes)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // Stable key (no value) so typing does not recreate the field.
            child: TextFormField(
              key: ValueKey('${keyPrefix}_${cls.classId}'),
              initialValue: valueFor(cls.classId),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: shareReportCellTextStyle(),
              decoration: shareReportCellDecoration(hint: ''),
              onChanged: (v) => onChanged(cls.classId, v),
            ),
          ),
      ],
    );
  }

  static Widget _cornerCell() => const SizedBox(height: 36);

  static Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: ShareReportTheme.textPrimary,
        ),
      ),
    );
  }

  static Widget _labelCell(String text) {
    return Container(
      color: const Color(0xFFF0F2F5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ShareReportTheme.textPrimary,
        ),
      ),
    );
  }

  static Widget _readonlyCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ShareReportTheme.textPrimary,
        ),
      ),
    );
  }
}

class _YesNoToggle extends StatelessWidget {
  const _YesNoToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(value: true, label: Text('Yes')),
        ButtonSegment<bool>(value: false, label: Text('No')),
      ],
      selected: {value},
      onSelectionChanged: (set) {
        if (set.isEmpty) return;
        onChanged(set.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
