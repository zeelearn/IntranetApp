import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';

class ProjectLocalService {
  ProjectLocalService({this.boxName = 'projects_list_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) =>
      'projects_${userId}_${projectTeamStatus}_${businessId ?? 'all'}';

  Future<void> saveProjects({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
    required List<ProjectItem> projects,
  }) async {
    final box = await _ensureBox();
    final payload = jsonEncode({
      'data': projects.map((e) => e.toJson()).toList(growable: false),
    });
    await box.put(
      cacheKey(
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: businessId,
      ),
      payload,
    );
  }

  Future<List<ProjectItem>?> loadProjects({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(
      cacheKey(
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: businessId,
      ),
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => ProjectItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }
}
