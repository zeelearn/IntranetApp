import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';

class TaskLocalService {
  TaskLocalService({this.boxName = 'projects_tasks_box'});

  final String boxName;
  Box<String>? _box;

  static const _pendingQueueKey = 'pending_add_task_queue';

  Future<Box<String>> _ensureBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  String cacheKey(int userId, String projectId) =>
      'tasks_${userId}_$projectId';

  String userTaskListKey(int userId, int apiStatus) =>
      'user_tasks_${userId}_$apiStatus';

  Future<void> saveTasks({
    required int userId,
    required String projectId,
    required List<HierarchyTask> tasks,
  }) async {
    final box = await _ensureBox();
    await box.put(
      cacheKey(userId, projectId),
      jsonEncode({
        'data': tasks.map((e) => e.toJson()).toList(growable: false),
      }),
    );
  }

  Future<List<HierarchyTask>?> loadTasks({
    required int userId,
    required String projectId,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(cacheKey(userId, projectId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => HierarchyTask.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserTasks({
    required int userId,
    required int apiStatus,
    required List<UserTaskItem> tasks,
  }) async {
    final box = await _ensureBox();
    await box.put(
      userTaskListKey(userId, apiStatus),
      jsonEncode({
        'data': tasks.map((e) => e.toJson()).toList(growable: false),
      }),
    );
  }

  Future<List<UserTaskItem>?> loadUserTasks({
    required int userId,
    required int apiStatus,
  }) async {
    final box = await _ensureBox();
    final raw = box.get(userTaskListKey(userId, apiStatus));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final list = decoded['data'];
      if (list is! List) return null;
      return list
          .whereType<Map>()
          .map((e) => UserTaskItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  /// Queues an add/update when offline for later sync.
  Future<void> enqueueAddTask(AddTaskRequest request) async {
    final box = await _ensureBox();
    final existing = await loadPendingAddTasks();
    existing.add(request);
    await box.put(
      _pendingQueueKey,
      jsonEncode(existing.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<List<AddTaskRequest>> loadPendingAddTasks() async {
    final box = await _ensureBox();
    final raw = box.get(_pendingQueueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => AddTaskRequest.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePendingAddTasks(List<AddTaskRequest> requests) async {
    final box = await _ensureBox();
    await box.put(
      _pendingQueueKey,
      jsonEncode(requests.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<void> clearPendingAddTasks() async {
    final box = await _ensureBox();
    await box.delete(_pendingQueueKey);
  }
}
