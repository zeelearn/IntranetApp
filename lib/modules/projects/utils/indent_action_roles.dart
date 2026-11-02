/// Finance / Branding Kit access from Pentemind_Illume_Status `CanIndentBK`.
class IndentActionRoles {
  IndentActionRoles._();

  /// True when API flag [canIndentBk] is exactly `1`.
  static bool canAccessFinanceActions(int? canIndentBk) => canIndentBk == 1;
}
