/// Parses API date strings into a human-readable form and deadline helpers.
class ProjectDateUtils {
  ProjectDateUtils._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formats common API date shapes into `dd MMM yyyy` (e.g. `07 Jul 2023`).
  static String formatReadable(String? raw) {
    final dt = tryParse(raw);
    if (dt == null) {
      final trimmed = raw?.trim() ?? '';
      return trimmed.isEmpty ? '—' : trimmed;
    }
    final day = dt.day.toString().padLeft(2, '0');
    return '$day ${_months[dt.month - 1]} ${dt.year}';
  }

  static DateTime? tryParse(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty || value == '-' || value.toLowerCase() == 'null') {
      return null;
    }

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    // dd-MM-yyyy / dd/MM/yyyy / dd.MM.yyyy
    final dmy = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$');
    final m1 = dmy.firstMatch(value);
    if (m1 != null) {
      final day = int.tryParse(m1.group(1)!);
      final month = int.tryParse(m1.group(2)!);
      var year = int.tryParse(m1.group(3)!);
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          return DateTime(year, month, day);
        }
      }
    }

    // yyyy-MM-dd already covered by DateTime.tryParse; also yyyy/MM/dd
    final ymd = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})');
    final m2 = ymd.firstMatch(value);
    if (m2 != null) {
      final year = int.tryParse(m2.group(1)!);
      final month = int.tryParse(m2.group(2)!);
      final day = int.tryParse(m2.group(3)!);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  /// True when deadline is before today (date-only comparison).
  static bool isMissed(String? raw) {
    final dt = tryParse(raw);
    if (dt == null) return false;
    final today = DateTime.now();
    final deadlineDay = DateTime(dt.year, dt.month, dt.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return deadlineDay.isBefore(todayDay);
  }

  /// API payload date: `yyyy-MM-dd`.
  static String formatApi(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  /// Display in form fields: `dd-MM-yyyy`.
  static String formatForm(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d-$m-${date.year}';
  }
}
