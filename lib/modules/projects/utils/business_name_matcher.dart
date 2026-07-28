import 'package:Intranet/modules/projects/models/project_business.dart';

/// Normalizes business display names so intranet ↔ GetBusiness can match
/// even when ids differ (e.g. `eKidzee` vs `Kidzee`).
String normalizeBusinessName(String name) {
  var s = name.trim().toLowerCase();
  s = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
  if (s.length > 1 && s.startsWith('e')) {
    s = s.substring(1);
  }
  return s;
}

/// Finds the GetBusiness row whose normalized name matches [intranetName].
///
/// Returns `null` when [intranetName] is empty or no row matches.
ProjectBusiness? matchProjectBusinessByName({
  required String intranetName,
  required List<ProjectBusiness> projectsBusinesses,
}) {
  final needle = normalizeBusinessName(intranetName);
  if (needle.isEmpty) return null;
  for (final item in projectsBusinesses) {
    if (normalizeBusinessName(item.businessName) == needle) {
      return item;
    }
  }
  return null;
}
