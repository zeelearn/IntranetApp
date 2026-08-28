import 'package:Intranet/pages/pjp/cvf/share_report/models/cvf_internal_data.dart';

/// One editable Enrolment Status row — maps 1:1 to `enr_status_array` items.
class EnrolmentStatusRow {
  EnrolmentStatusRow({
    this.batch = '',
    this.totalChildren = '',
    this.teacherName = '',
    this.dateOfJoining = '',
    this.tutelageTrained = '',
    this.ptoScore = '',
  });

  /// Full API `batch` label shown in first column (e.g. `SENIOR KG - Batch 2`).
  String batch;

  String totalChildren;
  String teacherName;
  String dateOfJoining;
  String tutelageTrained;
  String ptoScore;

  static const tutelageOptions = ['Y', 'N'];

  /// Canonical Y/N for dropdown; empty if null/unknown (avoids DropdownButton crash).
  static String normalizeTutelage(String? raw) {
    final text = (raw ?? '').trim().toUpperCase();
    if (text.isEmpty || text == 'NULL') return '';
    if (text == 'Y' || text == 'YES' || text == 'TRUE' || text == '1') {
      return 'Y';
    }
    if (text == 'N' || text == 'NO' || text == 'FALSE' || text == '0') {
      return 'N';
    }
    return tutelageOptions.contains(text) ? text : '';
  }

  /// Null / "null" / blank → empty display string.
  static String displayText(String? raw) {
    if (raw == null) return '';
    final text = raw.trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  /// Null / non-numeric → empty; otherwise digit string (no forced `0`).
  static String displayNumber(num? value) {
    if (value == null) return '';
    if (value is int) return '$value';
    if (value == value.roundToDouble()) return '${value.toInt()}';
    return value.toString();
  }

  String? get dropdownTutelage {
    final n = normalizeTutelage(tutelageTrained);
    return n.isEmpty ? null : n;
  }

  bool get hasAnyValue =>
      totalChildren.trim().isNotEmpty ||
      teacherName.trim().isNotEmpty ||
      dateOfJoining.trim().isNotEmpty ||
      tutelageTrained.trim().isNotEmpty ||
      ptoScore.trim().isNotEmpty;

  factory EnrolmentStatusRow.fromEnrItem(CvfEnrStatusItem item) {
    return EnrolmentStatusRow(
      batch: displayText(item.batch),
      totalChildren: displayNumber(item.totalChild),
      teacherName: displayText(item.teacherName),
      dateOfJoining: displayText(item.doj),
      tutelageTrained: normalizeTutelage(item.tutelage),
      ptoScore: displayNumber(item.pto),
    );
  }

  /// One UI row per API `enr_status_array` entry (dynamic).
  static List<EnrolmentStatusRow> fromEnrStatusArray(
    List<CvfEnrStatusItem> items,
  ) {
    if (items.isEmpty) return const [];
    return items.map(EnrolmentStatusRow.fromEnrItem).toList();
  }

  /// Maps UI rows back to API `enr_status_array` (null-safe empties → defaults).
  static List<CvfEnrStatusItem> toEnrStatusArray(List<EnrolmentStatusRow> rows) {
    return [
      for (final row in rows)
        CvfEnrStatusItem(
          batch: displayText(row.batch),
          totalChild: int.tryParse(row.totalChildren.trim()),
          teacherName: displayText(row.teacherName),
          doj: displayText(row.dateOfJoining),
          tutelage: normalizeTutelage(row.tutelageTrained),
          pto: int.tryParse(row.ptoScore.trim()) ??
              double.tryParse(row.ptoScore.trim())?.round(),
        ),
    ];
  }
}
