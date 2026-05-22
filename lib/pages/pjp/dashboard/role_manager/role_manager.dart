enum UserRole { admin, manager, employee }

class RoleManager {
  static UserRole currentRole = UserRole.admin;

  static bool canExport() => currentRole == UserRole.admin;

  static bool canViewAnalytics() => currentRole != UserRole.employee;

  static bool canSeeAllEmployees() => currentRole == UserRole.admin;
}
