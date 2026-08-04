import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';

class IndentLocalService {
  IndentLocalService({this.boxName = 'indents_list_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey({required int userId, required String businessId}) =>
      'indents_${userId}_$businessId';

  Future<void> saveIndents({
    required int userId,
    required String businessId,
    required List<IndentItem> indents,
  }) async {
    final box = await _ensureBox();
    final payload = jsonEncode({
      'data': indents.map((e) => e.toJson()).toList(growable: false),
    });
    await box.put(cacheKey(userId: userId, businessId: businessId), payload);
  }

  Future<List<IndentItem>?> loadIndents({
    required int userId,
    required String businessId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(userId: userId, businessId: businessId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => IndentItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }
}
