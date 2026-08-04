import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/visual_chart_item.dart';

class VisualChartsLocalService {
  VisualChartsLocalService({this.boxName = 'visual_charts_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey({required String userType, required int userId}) =>
      'visual_charts_${userType}_$userId';

  Future<void> saveCharts({
    required String userType,
    required int userId,
    required List<VisualChartItem> charts,
  }) async {
    final box = await _ensureBox();
    final payload = jsonEncode({
      'data': charts.map((e) => e.toJson()).toList(growable: false),
    });
    await box.put(
      cacheKey(userType: userType, userId: userId),
      payload,
    );
  }

  Future<List<VisualChartItem>?> loadCharts({
    required String userType,
    required int userId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(userType: userType, userId: userId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => VisualChartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }
}
