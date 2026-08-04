import 'package:Intranet/api/response/employee_list_response.dart';

/// Client-side filter helpers for employee directory search.
class EmployeeSearchUtils {
  EmployeeSearchUtils._();

  static bool matchesQuery(EmployeeInfo employee, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    bool hit(String? value) =>
        (value ?? '').toLowerCase().contains(q);

    return hit(employee.employeeFullName) ||
        hit(employee.employeeCode) ||
        hit(employee.employeeEmailId) ||
        hit(employee.employeeDesignation) ||
        hit(employee.employeeContactNumber) ||
        hit(employee.employeeDepartmentName) ||
        hit(employee.employeeRoleName) ||
        hit(employee.employeeLocation) ||
        hit(employee.zone) ||
        hit(employee.managerName);
  }

  static List<EmployeeInfo> filter(
    List<EmployeeInfo> source,
    String query, {
    int? limit,
  }) {
    final filtered =
        source.where((e) => matchesQuery(e, query)).toList(growable: false);
    if (limit == null || filtered.length <= limit) return filtered;
    return filtered.take(limit).toList(growable: false);
  }

  static String displayOrDash(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '—' : text;
  }
}
