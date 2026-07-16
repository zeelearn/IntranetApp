import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/views/add_task_screen.dart';
import 'package:Intranet/modules/projects/views/task_comments_screen.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';

enum TaskActionType {
  view,
  edit,
  updateStatus,
  uploadFile,
  comments,
  assignUser,
  activity,
  timeline,
  createChild,
  delete,
}

/// List presentation on the Task Hierarchy screen.
enum TaskListViewMode {
  /// In-place expand / collapse tree (current default).
  tree,

  /// Figma drill-down: folder cards → timeline subtasks + breadcrumbs.
  drillDown,
}

/// Reactive state for Task Hierarchy.
///
/// Tree expand/collapse uses a plain [Set] + [treeRevision] so a single parent
/// `Obx` can rebuild reliably (GetX `RxSet` + nested `Obx` is error-prone).
class TaskHierarchyController extends GetxController {
  TaskHierarchyController({
    required this.project,
    required this.userId,
    required this.currentUserName,
    required TaskRepository repository,
    this.contributionId = 0,
    Connectivity? connectivity,
    this.onTaskAction,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  final ProjectItem project;
  final int userId;
  final String currentUserName;
  final int contributionId;
  final TaskRepository _repository;
  final Connectivity _connectivity;
  final void Function(TaskActionType action, HierarchyTask task)? onTaskAction;

  final RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();

  final RxString searchQuery = ''.obs;
  final RxnString statusFilter = RxnString();
  final RxnString priorityFilter = RxnString();
  final RxnString assigneeFilter = RxnString();

  /// When true, list shows only tasks assigned to [myTasksUserName].
  final RxBool showMyTasksOnly = false.obs;

  /// Temporary identity for "My Tasks" until preference / Hive is wired.
  /// Replace this with the logged-in display name from prefs/Hive later.
  static const String myTasksUserName = '';

  final RxList<HierarchyTask> allTasks = <HierarchyTask>[].obs;
  final RxInt treeRevision = 0.obs;
  final Rx<TaskListViewMode> viewMode = TaskListViewMode.tree.obs;
  final RxList<HierarchyTask> navStack = <HierarchyTask>[].obs;

  final RxInt totalCount = 0.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt inProgressCount = 0.obs;
  final RxInt completedCount = 0.obs;

  Map<String, List<HierarchyTask>> _childrenMap = const {};
  final Set<String> _expandedIds = <String>{};

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;

  String get projectId =>
      project.crmId.isNotEmpty ? project.crmId : project.id;

  Set<String> get expandedIds => Set<String>.unmodifiable(_expandedIds);

  @override
  void onInit() {
    super.onInit();
    observeConnectivity();
    loadTasks();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _connectivitySub?.cancel();
    super.onClose();
  }

  Future<void> observeConnectivity() async {
    await _updateConnectivityFlag();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((results) async {
      final offline = results.every((r) => r == ConnectivityResult.none);
      final wasOffline = isOffline.value;
      isOffline.value = offline;
      if (wasOffline && !offline) {
        await _repository.syncPendingAddTasks();
        await sync();
      }
    });
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadOffline();
    await sync();
    isLoading.value = false;
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      userId: userId,
      projectId: projectId,
    );
    if (cached != null) {
      _applyTasks(cached, fromCache: true);
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = allTasks.isNotEmpty;
      if (allTasks.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(
        userId: userId,
        projectId: projectId,
      );
      _applyTasks(remote, fromCache: false);
      errorMessage.value = null;
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshTasks() async {
    errorMessage.value = null;
    try {
      await _updateConnectivityFlag();
      if (isOffline.value) {
        await loadOffline();
      } else {
        final list = await _repository.refresh(
          userId: userId,
          projectId: projectId,
        );
        _applyTasks(list, fromCache: false);
      }
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    }
  }

  void setViewMode(TaskListViewMode mode) {
    if (viewMode.value == mode) return;
    viewMode.value = mode;
    navStack.clear();
    treeRevision.value++;
  }

  void toggleExpand(String taskId) {
    if (_expandedIds.contains(taskId)) {
      _expandedIds.remove(taskId);
    } else {
      _expandedIds.add(taskId);
    }
    treeRevision.value++;
  }

  bool isExpanded(String taskId) => _expandedIds.contains(taskId);

  bool hasChildren(String taskId) =>
      (_childrenMap[taskId]?.isNotEmpty ?? false);

  bool isFolder(HierarchyTask task) => hasChildren(task.id);

  bool get canPopDrill => navStack.isNotEmpty;

  String get projectTitle {
    if (project.franchiseeName.isNotEmpty) return project.franchiseeName;
    if (project.title.isNotEmpty) return project.title;
    return project.crmId;
  }

  /// Header title for the active view mode.
  String get screenTitle {
    if (viewMode.value == TaskListViewMode.drillDown) {
      if (navStack.isEmpty) return 'All Tasks';
      final title = navStack.last.title.trim();
      return title.isEmpty ? 'Tasks' : title;
    }
    return projectTitle;
  }

  /// Push into a folder (drill-down mode only).
  void drillInto(HierarchyTask task) {
    if (!isFolder(task)) return;
    navStack.add(task);
  }

  /// Pop one level, or jump to [stackIndex] (-1 = project root).
  void popDrill({int stackIndex = -2}) {
    if (stackIndex == -1) {
      navStack.clear();
      return;
    }
    if (stackIndex >= 0) {
      if (stackIndex + 1 < navStack.length) {
        navStack.removeRange(stackIndex + 1, navStack.length);
      }
      return;
    }
    if (navStack.isNotEmpty) {
      navStack.removeLast();
    }
  }

  /// Display name used for "My Tasks" filter (prefs/Hive later).
  String get effectiveMyTaskUserName => myTasksUserName;

  /// Items for the current drill-down level (filtered).
  List<HierarchyTask> drillDownItems() {
    final base = navStack.isEmpty
        ? TaskRepository.rootTasks(allTasks.toList(growable: false))
        : childrenOf(navStack.last.id);
    return _applyMyTasksFilter(
      _repository.search(
        source: base,
        query: searchQuery.value,
        statusFilter: statusFilter.value,
        priorityFilter: priorityFilter.value,
        assigneeFilter: assigneeFilter.value,
      ),
    );
  }

  /// Edit / Delete (and related) when current [userId] created the task.
  bool canMutate(HierarchyTask task) => isCreatedByCurrentUser(task);

  bool isCreatedByCurrentUser(HierarchyTask task) {
    final created = task.taskCreatedUser.trim();
    if (created.isEmpty) return false;
    return created == userId.toString();
  }

  /// Immediate + nested subtask count under [taskId].
  int subtaskCountOf(String taskId) {
    var count = 0;
    for (final child in childrenOf(taskId)) {
      count += 1 + subtaskCountOf(child.id);
    }
    return count;
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = value;
    });
  }

  void applyFilters({
    String? status,
    String? priority,
    String? assignee,
    bool? myTasksOnly,
  }) {
    statusFilter.value = status;
    priorityFilter.value = priority;
    assigneeFilter.value = assignee;
    if (myTasksOnly != null) {
      showMyTasksOnly.value = myTasksOnly;
    }
  }

  void setShowMyTasksOnly(bool value) {
    showMyTasksOnly.value = value;
  }

  void clearFilters() {
    statusFilter.value = null;
    priorityFilter.value = null;
    assigneeFilter.value = null;
    showMyTasksOnly.value = false;
    searchQuery.value = '';
  }

  bool get _hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      (statusFilter.value?.isNotEmpty ?? false) ||
      (priorityFilter.value?.isNotEmpty ?? false) ||
      (assigneeFilter.value?.isNotEmpty ?? false) ||
      showMyTasksOnly.value;

  List<HierarchyTask> _applyMyTasksFilter(List<HierarchyTask> source) {
    if (!showMyTasksOnly.value) return source;
    final me = effectiveMyTaskUserName.toLowerCase().trim();
    if (me.isEmpty) return source;
    return source
        .where((t) => t.responsiblePerson.toLowerCase().trim() == me)
        .toList(growable: false);
  }

  /// Top-level list: **only** `parent_task_id == "0"` (legacy BPMS HOME).
  /// Children appear only after expand — never promoted to root.
  List<HierarchyTask> visibleRoots() {
    // Strict filter on the flat list (do not use empty/null as root).
    final roots = TaskRepository.rootTasks(allTasks.toList(growable: false));

    if (!_hasActiveFilters) {
      return roots;
    }

    final filtered = _applyMyTasksFilter(
      _repository.search(
        source: allTasks.toList(growable: false),
        query: searchQuery.value,
        statusFilter: statusFilter.value,
        priorityFilter: priorityFilter.value,
        assigneeFilter: assigneeFilter.value,
      ),
    );
    final matchedIds = filtered.map((t) => t.id).toSet();

    return roots.where((root) {
      if (matchedIds.contains(root.id)) return true;
      return _subtreeContainsAny(root.id, matchedIds);
    }).toList(growable: false);
  }

  bool _subtreeContainsAny(String parentId, Set<String> ids) {
    for (final child in childrenOf(parentId)) {
      if (ids.contains(child.id)) return true;
      if (_subtreeContainsAny(child.id, ids)) return true;
    }
    return false;
  }

  List<HierarchyTask> childrenOf(String parentId) =>
      TaskRepository.childrenOf(_childrenMap, parentId);

  List<String> get assigneeOptions {
    final set = <String>{};
    for (final t in allTasks) {
      if (t.responsiblePerson.trim().isNotEmpty) {
        set.add(t.responsiblePerson.trim());
      }
    }
    return set.toList()..sort();
  }

  void handleAction(TaskActionType action, HierarchyTask task) {
    onTaskAction?.call(action, task);
  }

  /// Opens Add/Edit Task form. Upserts returned task into local list.
  Future<bool> openAddTask({HierarchyTask? parent}) async {
    final effectiveParent = parent ??
        (navStack.isNotEmpty ? navStack.last : null);
    final result = await AddTaskScreen.open(
      AddTaskArgs(
        projectId: projectId,
        userId: userId,
        projectName: projectTitle,
        parentTaskId: effectiveParent?.id ?? '0',
        parentTaskName: effectiveParent?.title ?? '',
        contributionId: contributionId,
        parentOptions: allTasks.toList(growable: false),
        assigneeOptions: assigneeOptions,
        defaultAssignee: currentUserName,
      ),
    );
    return _applySaveResult(result);
  }

  /// Opens Edit Task form prefilled from [task].
  Future<bool> openEditTask(HierarchyTask task) async {
    final parsedId = int.tryParse(task.id) ?? 0;
    final parsedMTask = int.tryParse(task.mtaskId) ?? 0;
    String parentName = '';
    if (!task.isRoot) {
      for (final t in allTasks) {
        if (t.id == task.parentTaskId) {
          parentName = t.title;
          break;
        }
      }
    }
    final result = await AddTaskScreen.open(
      AddTaskArgs(
        projectId: projectId,
        userId: userId,
        projectName: projectTitle,
        parentTaskId: task.isRoot ? '0' : task.parentTaskId,
        parentTaskName: parentName,
        contributionId: contributionId,
        taskId: parsedId,
        mtaskId: parsedMTask,
        seedTask: task,
        parentOptions: allTasks.toList(growable: false),
        assigneeOptions: assigneeOptions,
        defaultAssignee: currentUserName,
      ),
    );
    return _applySaveResult(result);
  }

  /// Quick status update via UpdateTaskStatus API.
  Future<bool> updateTaskStatus({
    required HierarchyTask task,
    required String statusLabel,
    String remark = '',
  }) async {
    try {
      final startRaw = task.startDate.isNotEmpty
          ? task.startDate
          : task.displayActualStart;
      final endRaw =
          task.endDate.isNotEmpty ? task.endDate : task.displayActualEnd;
      final start = ProjectDateUtils.tryParse(startRaw) ?? DateTime.now();
      final end = ProjectDateUtils.tryParse(endRaw) ?? start;
      final result = await _repository.updateTaskStatus(
        request: UpdateTaskStatusRequest(
          taskId: task.id,
          status: statusLabel,
          remark: remark.trim().isEmpty
              ? (task.note.trim().isEmpty ? statusLabel : task.note.trim())
              : remark.trim(),
          startDate: ProjectDateUtils.formatApi(start),
          endDate: ProjectDateUtils.formatApi(end),
          userId: userId,
        ),
        projectId: projectId,
      );
      if (result.task != null) {
        upsertLocalTask(result.task!);
      } else {
        await refreshTasks();
      }
      Get.snackbar(
        'Success',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on DashboardFailure catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// Deletes own task and removes it (and descendants) from local list.
  Future<bool> deleteTask(HierarchyTask task) async {
    if (!isCreatedByCurrentUser(task)) {
      Get.snackbar(
        'Not allowed',
        'You can only delete tasks you created.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    final subCount = subtaskCountOf(task.id);
    final title = task.title.isEmpty ? 'this task' : task.title;
    final message = subCount > 0
        ? 'You have $subCount subtask${subCount == 1 ? '' : 's'} under '
            '"$title". Do you want to delete this task and all its subtasks? '
            'This cannot be undone.'
        : 'Delete "$title"? This cannot be undone.';
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete task?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: DashboardColors.primaryFilledButton(),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    try {
      final result = await _repository.deleteTask(
        taskId: task.id,
        userId: userId,
        projectId: projectId,
      );
      removeLocalTask(task.id);
      Get.snackbar(
        'Deleted',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on DashboardFailure catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> _applySaveResult(AddTaskResult? result) async {
    if (result == null || !result.success) return false;

    // Optimistic local upsert when API returns the task payload.
    if (result.task != null) {
      upsertLocalTask(result.task!);
    }

    // Reload listing from server so parent counts / tree stay in sync.
    if (!result.savedOffline) {
      await refreshTasks();
    }

    Get.snackbar(
      result.savedOffline ? 'Saved Offline' : 'Success',
      result.message.isEmpty
          ? (result.savedOffline
              ? 'Task saved offline. It will sync when you are online.'
              : 'Task saved successfully.')
          : result.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: result.savedOffline
          ? const Color(0xFFFFF3E0)
          : const Color(0xFFE8F5E9),
      colorText: const Color(0xFF1A237E),
      margin: const EdgeInsets.all(12),
    );
    return true;
  }

  void upsertLocalTask(HierarchyTask task) {
    final list = allTasks.toList(growable: true);
    final index = list.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      list[index] = task;
    } else {
      list.add(task);
    }
    _applyTasks(list, fromCache: false);
  }

  void removeLocalTask(String taskId) {
    final toRemove = <String>{taskId};
    // Also drop descendants that reference this parent chain.
    var growing = true;
    while (growing) {
      growing = false;
      for (final t in allTasks) {
        if (toRemove.contains(t.parentTaskId) && !toRemove.contains(t.id)) {
          toRemove.add(t.id);
          growing = true;
        }
      }
    }
    final list =
        allTasks.where((t) => !toRemove.contains(t.id)).toList(growable: false);
    _applyTasks(list, fromCache: false);
  }

  /// Opens Task Comments / Communication (static data until API).
  Future<void> openComments(HierarchyTask task) {
    String parentTitle = '';
    if (!task.isRoot) {
      for (final t in allTasks) {
        if (t.id == task.parentTaskId) {
          parentTitle = t.title;
          break;
        }
      }
    }
    return TaskCommentsScreen.open(
      TaskCommentsArgs(
        task: task,
        userId: userId,
        projectName: projectTitle,
        parentTaskTitle: parentTitle,
        currentUserName: effectiveMyTaskUserName,
      ),
    );
  }

  void _applyTasks(List<HierarchyTask> list, {required bool fromCache}) {
    allTasks.assignAll(list);
    _childrenMap = TaskRepository.buildChildrenMap(list);
    final ids = list.map((t) => t.id).toSet();
    // Always start collapsed so only parent_task_id == "0" is visible.
    _expandedIds
      ..clear()
      ..removeWhere((id) => !ids.contains(id));
    navStack.removeWhere((t) => !ids.contains(t.id));
    servingFromCache.value = fromCache;
    _recomputeSummary();
    treeRevision.value++;
  }

  void _recomputeSummary() {
    totalCount.value = allTasks.length;
    var p = 0, ip = 0, c = 0;
    for (final t in allTasks) {
      final s = t.statusName.toLowerCase();
      if (s.contains('complete')) {
        c++;
      } else if (s.contains('progress')) {
        ip++;
      } else {
        p++;
      }
    }
    pendingCount.value = p;
    inProgressCount.value = ip;
    completedCount.value = c;
  }

  Future<void> _handleFailure(DashboardFailure failure) async {
    errorMessage.value = failure.message;
    if (failure.type == DashboardFailureType.noInternet) {
      isOffline.value = true;
    }
    final cached = await _repository.loadOffline(
      userId: userId,
      projectId: projectId,
    );
    if (cached != null) {
      _applyTasks(cached, fromCache: true);
    }
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }
}
