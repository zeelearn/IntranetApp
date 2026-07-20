import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';

class ProjectDetailLocalService {
  ProjectDetailLocalService({this.boxName = 'projects_detail_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey({
    required int franchiseeId,
    required String crmId,
  }) =>
      'detail_${franchiseeId}_${crmId.trim()}';

  Future<void> saveDetail({
    required int franchiseeId,
    required String crmId,
    required ProjectDetailData detail,
  }) async {
    final box = await _ensureBox();
    await box.put(
      cacheKey(franchiseeId: franchiseeId, crmId: crmId),
      jsonEncode(detail.toJson()),
    );
  }

  Future<ProjectDetailData?> loadDetail({
    required int franchiseeId,
    required String crmId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(franchiseeId: franchiseeId, crmId: crmId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ProjectDetailData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
