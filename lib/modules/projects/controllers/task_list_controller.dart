import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/views/task_hierarchy_screen.dart';

class TaskListController extends GetxController {
  TaskListController({
    required this.userId,
    required this.dashboardStatusId,
    required this.statusName,
    required this.statusColor,
    required this.currentUserName,
    required this.apiStatus,
    required TaskRepository repository,
    this.contributionId = 0,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  final int userId;
  final int dashboardStatusId;
  final String statusName;
  final Color statusColor;
  final String currentUserName;
  final int apiStatus;
  final int contributionId;
  final TaskRepository _repository;
  final Connectivity _connectivity;

  final RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString searchQuery = ''.obs;
  final RxList<UserTaskItem> allTasks = <UserTaskItem>[].obs;
  final RxList<UserTaskItem> visibleTasks = <UserTaskItem>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _observeConnectivity();
    loadTasks();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _connectivitySub?.cancel();
    super.onClose();
  }

  Future<void> _observeConnectivity() async {
    await _updateConnectivity();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((results) async {
      final offline = results.every((r) => r == ConnectivityResult.none);
      final wasOffline = isOffline.value;
      isOffline.value = offline;
      if (wasOffline && !offline) {
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
    final cached = await _repository.loadUserTasksOffline(
      userId: userId,
      apiStatus: apiStatus,
    );
    if (cached != null) {
      _apply(cached, fromCache: true);
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
      final remote = await _repository.syncUserTasks(
        userId: userId,
        apiStatus: apiStatus,
      );
      _apply(remote, fromCache: false);
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
      await _updateConnectivity();
      if (isOffline.value) {
        await loadOffline();
      } else {
        final list = await _repository.refreshUserTasks(
          userId: userId,
          apiStatus: apiStatus,
        );
        _apply(list, fromCache: false);
      }
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = value;
      _recomputeVisible();
    });
  }

  void openTask(UserTaskItem task) {
    TaskHierarchyScreen.open(
      project: task.toProjectItem(),
      userId: userId,
      currentUserName: currentUserName,
      contributionId: contributionId,
    );
  }

  void _apply(List<UserTaskItem> list, {required bool fromCache}) {
    allTasks.assignAll(list);
    servingFromCache.value = fromCache;
    _recomputeVisible();
  }

  void _recomputeVisible() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      visibleTasks.assignAll(allTasks);
      return;
    }
    visibleTasks.assignAll(
      allTasks.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.franchiseeName.toLowerCase().contains(q) ||
            t.responsiblePerson.toLowerCase().contains(q) ||
            t.projectId.toLowerCase().contains(q) ||
            t.statusName.toLowerCase().contains(q);
      }),
    );
  }

  Future<void> _handleFailure(DashboardFailure failure) async {
    errorMessage.value = failure.message;
    if (failure.type == DashboardFailureType.noInternet) {
      isOffline.value = true;
    }
    final cached = await _repository.loadUserTasksOffline(
      userId: userId,
      apiStatus: apiStatus,
    );
    if (cached != null) {
      _apply(cached, fromCache: true);
    }
  }

  Future<void> _updateConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }
}
