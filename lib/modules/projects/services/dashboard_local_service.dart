import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/dashboard_summary.dart';

class DashboardLocalService {
  DashboardLocalService({
    this.boxName = 'projects_dashboard_box',
  });

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey(int userId, int? businessId) =>
      'dashboard_${userId}_${businessId ?? 'all'}';

  Future<void> saveSummary({
    required int userId,
    int? businessId,
    required DashboardSummary summary,
  }) async {
    final box = await _ensureBox();
    await box.put(
      cacheKey(userId, businessId),
      jsonEncode(summary.toJson()),
    );
  }

  Future<DashboardSummary?> loadSummary({
    required int userId,
    int? businessId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(userId, businessId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return DashboardSummary.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear({
    required int userId,
    int? businessId,
  }) async {
    final box = await _ensureBox();
    await box.delete(cacheKey(userId, businessId));
  }
}
