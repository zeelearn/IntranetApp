/// Role-based visibility for Projects sidebar menus.
class ProjectsSidebarRoles {
  ProjectsSidebarRoles._();

  /// Visual Charts: MAN, BH, ZM only.
  static const visualChartsRoles = {'MAN', 'BH', 'ZM'};

  static String normalize(String? employeeType) =>
      (employeeType ?? '').trim().toUpperCase();

  /// Currently open to all user types.
  static bool canShowProjects(String? employeeType) => true;

  /// Currently open to all user types.
  static bool canShowAllIndents(String? employeeType) => true;

  /// Currently open to all user types.
  static bool canShowCenterKitReport(String? employeeType) => true;

  /// True when [employeeType] is MAN, BH, or ZM (case-insensitive).
  static bool canShowVisualCharts(String? employeeType) {
    return visualChartsRoles.contains(normalize(employeeType));
  }
}
