import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/task_comments_payload.dart';

class TaskCommentsLocalService {
  TaskCommentsLocalService({this.boxName = 'projects_task_comments_box'});

  final String boxName;
  Box<String>? _box;

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey(String taskId) => 'task_comments_${taskId.trim()}';

  Future<void> save({
    required String taskId,
    required TaskCommentsPayload payload,
  }) async {
    final box = await _ensureBox();
    await box.put(cacheKey(taskId), jsonEncode(payload.toJson()));
  }

  Future<TaskCommentsPayload?> load({required String taskId}) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(taskId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return TaskCommentsPayload.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
