import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/center_kit_item.dart';

class CenterKitLocalService {
  CenterKitLocalService({this.boxName = 'center_kit_report_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey({required int? businessId}) =>
      'center_kit_${businessId ?? 'all'}';

  Future<void> saveReport({
    required int? businessId,
    required List<CenterKitItem> items,
  }) async {
    final box = await _ensureBox();
    final payload = jsonEncode({
      'data': items.map((e) => e.toJson()).toList(growable: false),
    });
    await box.put(cacheKey(businessId: businessId), payload);
  }

  Future<List<CenterKitItem>?> loadReport({required int? businessId}) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(businessId: businessId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => CenterKitItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }
}
