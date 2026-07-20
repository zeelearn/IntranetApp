import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/repositories/project_detail_repository.dart';

class ProjectDetailController extends GetxController {
  ProjectDetailController({
    required this.project,
    required this.userId,
    required this.currentUserName,
    required this.statusName,
    required this.statusColor,
    required ProjectDetailRepository repository,
    this.initialTab = ProjectDetailTab.communication,
    this.contributionId = 0,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  final ProjectItem project;
  final int userId;
  String currentUserName;
  final String statusName;
  final Color statusColor;
  final ProjectDetailTab initialTab;
  final int contributionId;
  final ProjectDetailRepository _repository;
  final Connectivity _connectivity;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool franchiseeExpanded = false.obs;

  final Rx<ProjectDetailTab> selectedTab = ProjectDetailTab.communication.obs;
  final Rxn<ProjectDetailData> detail = Rxn<ProjectDetailData>();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get crmId =>
      project.crmId.isNotEmpty ? project.crmId : project.id;

  int get franchiseeId => project.franchiseeId;

  String get projectTitleLine {
    final code = detail.value?.franDetails.franchiseeCode.trim().isNotEmpty ==
            true
        ? detail.value!.franDetails.franchiseeCode.trim()
        : project.franchiseeCode.trim();
    final name = detail.value?.franDetails.franchiseeName.trim().isNotEmpty ==
            true
        ? detail.value!.franDetails.franchiseeName.trim()
        : project.franchiseeName.trim();
    if (code.isEmpty && name.isEmpty) return crmId;
    if (code.isEmpty) return name;
    if (name.isEmpty) return code;
    return '$code - $name';
  }

  String get operatingStatusLabel {
    final fran = detail.value?.franDetails;
    if (fran != null && fran.operatingStatus.trim().isNotEmpty) {
      return fran.statusLabel;
    }
    return statusName.isEmpty ? '—' : statusName;
  }

  Color get operatingStatusColor {
    final fran = detail.value?.franDetails;
    if (fran != null && fran.operatingStatus.trim().isNotEmpty) {
      return fran.isActive ? DashboardColors.success : DashboardColors.error;
    }
    return statusColor;
  }

  @override
  void onInit() {
    super.onInit();
    selectedTab.value = initialTab;
    observeConnectivity();
    loadDetail();
  }

  @override
  void onClose() {
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
        await sync();
      }
    });
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadOffline();
    final cached = detail.value;
    final needsDayRefresh = cached == null || cached.isStaleForToday;
    if (!isOffline.value && needsDayRefresh) {
      await sync();
    } else if (!isOffline.value && cached != null) {
      // Soft background sync when same-day cache exists.
      unawaited(sync(silent: true));
    } else if (isOffline.value && cached == null) {
      errorMessage.value = 'No internet connection.';
    }
    isLoading.value = false;
    currentUserName = project.crmId.isNotEmpty ? project.crmId : 'NA';
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      franchiseeId: franchiseeId,
      crmId: crmId,
    );
    if (cached != null) {
      detail.value = cached;
      servingFromCache.value = true;
    }
  }

  Future<void> sync({bool silent = false}) async {
    if (isOffline.value) {
      servingFromCache.value = detail.value != null;
      if (detail.value == null) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(
        franchiseeId: franchiseeId,
        crmId: crmId,
      );
      detail.value = remote;
      servingFromCache.value = false;
      errorMessage.value = null;
    } on DashboardFailure catch (e) {
      if (!silent) await _handleFailure(e);
    } catch (e) {
      if (!silent) errorMessage.value = e.toString();
    }
  }

  Future<void> refreshDetail() async {
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      await _updateConnectivityFlag();
      if (isOffline.value) {
        await loadOffline();
        Get.snackbar(
          'Offline',
          'Showing cached project details.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final remote = await _repository.refresh(
          franchiseeId: franchiseeId,
          crmId: crmId,
        );
        detail.value = remote;
        servingFromCache.value = false;
      }
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } finally {
      isRefreshing.value = false;
    }
  }

  void selectTab(ProjectDetailTab tab) {
    selectedTab.value = tab;
  }

  void toggleFranchiseeExpanded() {
    franchiseeExpanded.value = !franchiseeExpanded.value;
  }

  Future<void> _handleFailure(DashboardFailure e) async {
    if (detail.value != null) {
      servingFromCache.value = true;
      Get.snackbar(
        'Using cached data',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      errorMessage.value = e.message;
    }
  }
}
