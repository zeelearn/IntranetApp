import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/project_business.dart';

/// Offline cache for Projects `GetBusiness` list.
class ProjectBusinessLocalService {
  ProjectBusinessLocalService({
    this.boxName = 'projects_business_box',
  });

  final String boxName;
  static const String cacheKey = 'get_business_list';

  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  Future<void> saveBusinesses(List<ProjectBusiness> businesses) async {
    final box = await _ensureBox();
    final payload = {
      'data': businesses.map((b) => b.toJson()).toList(),
    };
    await box.put(cacheKey, jsonEncode(payload));
  }

  Future<List<ProjectBusiness>> loadBusinesses() async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const [];
      final data = decoded['data'];
      if (data is! List) return const [];
      final list = <ProjectBusiness>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          list.add(ProjectBusiness.fromJson(item));
        } else if (item is Map) {
          list.add(ProjectBusiness.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return list;
    } catch (_) {
      return const [];
    }
  }
}
