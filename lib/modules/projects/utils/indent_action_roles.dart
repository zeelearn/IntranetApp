/// Role checks for indent finance actions (Payment Link / Branding Add Order).
class IndentActionRoles {
  IndentActionRoles._();

  static const allowedRoles = {'MAN', 'BH'};

  /// True when [employeeType] is MAN or BH (case-insensitive).
  static bool canAccessFinanceActions(String? employeeType) {
    final role = (employeeType ?? '').trim().toUpperCase();
    return allowedRoles.contains(role);
  }
}
