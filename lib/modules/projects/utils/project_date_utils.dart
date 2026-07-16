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

  /// Formats as `07 Sep 2023, 02:47 PM` when time is present.
  static String formatReadableDateTime(String? raw, {String? timeHint}) {
    final dt = tryParse(raw);
    if (dt == null) {
      final trimmed = raw?.trim() ?? '';
      if (trimmed.isEmpty) return '—';
      if (timeHint != null && timeHint.trim().isNotEmpty) {
        return '$trimmed, ${timeHint.trim()}';
      }
      return trimmed;
    }
    final day = dt.day.toString().padLeft(2, '0');
    final datePart = '$day ${_months[dt.month - 1]} ${dt.year}';
    final hint = timeHint?.trim() ?? '';
    if (hint.isNotEmpty) return '$datePart, $hint';
    if (dt.hour == 0 && dt.minute == 0 && dt.second == 0) return datePart;
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    final h = hour12.toString().padLeft(2, '0');
    return '$datePart, $h:$min $ampm';
  }

  /// Formats currency-like amounts with Indian grouping when possible.
  static String formatAmount(num value) {
    final n = value.toDouble();
    if (n == 0) return '₹0';
    final isNeg = n < 0;
    final abs = n.abs();
    final whole = abs.floor();
    final frac = ((abs - whole) * 100).round();
    final s = whole.toString();
    final buf = StringBuffer();
    if (s.length <= 3) {
      buf.write(s);
    } else {
      final last3 = s.substring(s.length - 3);
      var rest = s.substring(0, s.length - 3);
      final parts = <String>[];
      while (rest.length > 2) {
        parts.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.insert(0, rest);
      buf.write(parts.join(','));
      buf.write(',');
      buf.write(last3);
    }
    final out = frac == 0 ? buf.toString() : '${buf.toString()}.${frac.toString().padLeft(2, '0')}';
    return isNeg ? '₹-$out' : '₹$out';
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
