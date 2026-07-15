import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';
import 'package:Intranet/modules/projects/services/task_local_service.dart';
import 'package:Intranet/modules/projects/services/task_remote_service.dart';

class TaskRepository {
  TaskRepository({
    required TaskRemoteService remoteService,
    required TaskLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final TaskRemoteService _remote;
  final TaskLocalService _local;

  /// Builds parent → children map once (O(n)).
  static Map<String, List<HierarchyTask>> buildChildrenMap(
    List<HierarchyTask> tasks,
  ) {
    final map = <String, List<HierarchyTask>>{};
    for (final task in tasks) {
      final key = task.isRoot ? '0' : task.parentTaskId;
      map.putIfAbsent(key, () => <HierarchyTask>[]).add(task);
    }
    return map;
  }

  static List<HierarchyTask> roots(Map<String, List<HierarchyTask>> map) =>
      List<HierarchyTask>.from(map['0'] ?? const []);

  static List<HierarchyTask> childrenOf(
    Map<String, List<HierarchyTask>> map,
    String parentId,
  ) =>
      List<HierarchyTask>.from(map[parentId] ?? const []);

  Future<List<HierarchyTask>?> loadOffline({
    required int userId,
    required String projectId,
  }) {
    return _local.loadTasks(userId: userId, projectId: projectId);
  }

  Future<List<HierarchyTask>> sync({
    required int userId,
    required String projectId,
  }) async {
    final list = await _remote.fetchTasks(
      projectId: projectId,
      userId: userId,
    );
    await _local.saveTasks(
      userId: userId,
      projectId: projectId,
      tasks: list,
    );
    return list;
  }

  Future<List<HierarchyTask>> refresh({
    required int userId,
    required String projectId,
  }) async {
    try {
      return await sync(userId: userId, projectId: projectId);
    } on DashboardFailure catch (failure) {
      final cached =
          await loadOffline(userId: userId, projectId: projectId);
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }

  /// Online → create API. Offline / unreachable → pending queue.
  Future<AddTaskResult> addTask(AddTaskRequest request) async {
    _validateCreateRequest(request);
    try {
      final result = await _remote.addTask(request);
      if (result.task != null) {
        await upsertCachedTask(
          userId: request.userId,
          projectId: request.projectId,
          task: result.task!,
        );
      }
      return result;
    } on DashboardFailure catch (failure) {
      if (failure.type == DashboardFailureType.noInternet ||
          failure.type == DashboardFailureType.timeout) {
        await _local.enqueueAddTask(request);
        return const AddTaskResult(
          success: true,
          savedOffline: true,
          message: 'Task saved offline. It will sync when you are online.',
        );
      }
      rethrow;
    }
  }

  /// Update via UpdateTaskStatus and upsert response task into cache.
  Future<AddTaskResult> updateTaskStatus({
    required UpdateTaskStatusRequest request,
    required String projectId,
  }) async {
    _validateUpdateRequest(request);
    final result = await _remote.updateTaskStatus(request);
    if (result.task != null) {
      await upsertCachedTask(
        userId: request.userId,
        projectId: projectId,
        task: result.task!,
      );
    }
    return result;
  }

  /// Delete task and remove from local cache.
  Future<DeleteTaskResult> deleteTask({
    required String taskId,
    required int userId,
    required String projectId,
  }) async {
    final result = await _remote.deleteTask(taskId: taskId);
    await removeCachedTask(
      userId: userId,
      projectId: projectId,
      taskId: taskId,
    );
    return result;
  }

  /// Inserts or replaces a task in the project cache.
  Future<void> upsertCachedTask({
    required int userId,
    required String projectId,
    required HierarchyTask task,
  }) async {
    final cached =
        await loadOffline(userId: userId, projectId: projectId) ??
            <HierarchyTask>[];
    final next = <HierarchyTask>[];
    var found = false;
    for (final t in cached) {
      if (t.id == task.id) {
        next.add(task);
        found = true;
      } else {
        next.add(t);
      }
    }
    if (!found) next.add(task);
    await _local.saveTasks(
      userId: userId,
      projectId: projectId,
      tasks: next,
    );
  }

  Future<void> removeCachedTask({
    required int userId,
    required String projectId,
    required String taskId,
  }) async {
    final cached = await loadOffline(userId: userId, projectId: projectId);
    if (cached == null) return;
    final next =
        cached.where((t) => t.id != taskId).toList(growable: false);
    await _local.saveTasks(
      userId: userId,
      projectId: projectId,
      tasks: next,
    );
  }

  void _validateCreateRequest(AddTaskRequest request) {
    if (request.projectId.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Project id is required.',
      );
    }
    if (request.title.trim().length < 3) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Title must be at least 3 characters.',
      );
    }
    if (request.note.trim().length < 5) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Description must be at least 5 characters.',
      );
    }
    if (request.startDate.trim().isEmpty || request.endDate.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Actual start and end dates are required.',
      );
    }
    if (request.planStartDate.trim().isEmpty ||
        request.planEndDate.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Plan start and end dates are required.',
      );
    }
    if (request.userId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid user id.',
      );
    }
  }

  void _validateUpdateRequest(UpdateTaskStatusRequest request) {
    if (request.taskId.trim().isEmpty || request.taskId == '0') {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid task id.',
      );
    }
    if (request.status.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Status is required.',
      );
    }
    if (request.remark.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Remark is required.',
      );
    }
    if (request.startDate.trim().isEmpty || request.endDate.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Start and end dates are required.',
      );
    }
    if (request.userId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid user id.',
      );
    }
  }

  Future<List<UserTaskItem>?> loadUserTasksOffline({
    required int userId,
    required int apiStatus,
  }) {
    return _local.loadUserTasks(userId: userId, apiStatus: apiStatus);
  }

  Future<List<UserTaskItem>> syncUserTasks({
    required int userId,
    required int apiStatus,
  }) async {
    final list = await _remote.fetchTasksByUser(
      userId: userId,
      apiStatus: apiStatus,
    );
    await _local.saveUserTasks(
      userId: userId,
      apiStatus: apiStatus,
      tasks: list,
    );
    return list;
  }

  Future<List<UserTaskItem>> refreshUserTasks({
    required int userId,
    required int apiStatus,
  }) async {
    try {
      return await syncUserTasks(userId: userId, apiStatus: apiStatus);
    } on DashboardFailure catch (failure) {
      final cached =
          await loadUserTasksOffline(userId: userId, apiStatus: apiStatus);
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }

  /// Attempts to flush the offline add-task queue.
  Future<int> syncPendingAddTasks() async {
    final pending = await _local.loadPendingAddTasks();
    if (pending.isEmpty) return 0;
    final remaining = <AddTaskRequest>[];
    var synced = 0;
    for (final request in pending) {
      try {
        await _remote.addTask(request);
        synced++;
      } on DashboardFailure {
        remaining.add(request);
      } catch (_) {
        remaining.add(request);
      }
    }
    await _local.savePendingAddTasks(remaining);
    return synced;
  }

  List<HierarchyTask> search({
    required List<HierarchyTask> source,
    required String query,
    String? statusFilter,
    String? priorityFilter,
    String? assigneeFilter,
  }) {
    var result = source;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.responsiblePerson.toLowerCase().contains(q) ||
                t.statusName.toLowerCase().contains(q) ||
                t.priority.toLowerCase().contains(q),
          )
          .toList(growable: false);
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      result = result
          .where(
            (t) =>
                t.statusName.toLowerCase() == statusFilter.toLowerCase() ||
                t.statusChip == statusFilter.toUpperCase(),
          )
          .toList(growable: false);
    }
    if (priorityFilter != null && priorityFilter.isNotEmpty) {
      result = result
          .where(
            (t) => t.priority.toLowerCase() == priorityFilter.toLowerCase(),
          )
          .toList(growable: false);
    }
    if (assigneeFilter != null && assigneeFilter.isNotEmpty) {
      result = result
          .where(
            (t) => t.responsiblePerson.toLowerCase() ==
                assigneeFilter.toLowerCase(),
          )
          .toList(growable: false);
    }
    return result;
  }
}
