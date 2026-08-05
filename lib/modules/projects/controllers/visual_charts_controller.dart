import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/visual_chart_item.dart';
import 'package:Intranet/modules/projects/repositories/visual_charts_repository.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';

class VisualChartsController extends GetxController {
  VisualChartsController({
    required this.userId,
    required this.userType,
    required VisualChartsRepository repository,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  final int userId;
  final String userType;
  final VisualChartsRepository _repository;
  final Connectivity _connectivity;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString searchQuery = ''.obs;

  final RxList<VisualChartItem> allCharts = <VisualChartItem>[].obs;
  final RxList<VisualChartItem> visibleCharts = <VisualChartItem>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    observeConnectivity();
    loadCharts();
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
        await sync();
      }
    });
  }

  Future<void> loadCharts() async {
    isLoading.value = true;
    errorMessage.value = null;

    if (userId <= 0 || userType.trim().isEmpty) {
      errorMessage.value =
          'Unable to load charts. User type or user id is missing.';
      isLoading.value = false;
      return;
    }

    await loadOffline();
    await sync();
    isLoading.value = false;
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      userType: userType,
      userId: userId,
    );
    if (cached != null) {
      allCharts.assignAll(cached);
      servingFromCache.value = true;
      _recomputeVisible();
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = allCharts.isNotEmpty;
      if (allCharts.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(
        userType: userType,
        userId: userId,
      );
      allCharts.assignAll(remote);
      servingFromCache.value = false;
      errorMessage.value = null;
      _recomputeVisible();
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshCharts() async {
    isRefreshing.value = true;
    try {
      await sync();
    } finally {
      isRefreshing.value = false;
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = value;
      _recomputeVisible();
    });
  }

  Future<void> openChart(VisualChartItem chart) async {
    if (!chart.hasValidUrl) {
      Get.snackbar(
        'Visual Charts',
        'Chart URL is missing or invalid.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return;
    }

    final url = chart.url.trim();
    final title = chart.name.isNotEmpty ? chart.name : 'Visual Chart';

    if (kIsWeb) {
      final launched = await launchUrl(
        Uri.parse(url),
        webOnlyWindowName: '_blank',
      );
      if (!launched) {
        Get.snackbar(
          'Visual Charts',
          'Unable to open chart in a new tab.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
          colorText: DashboardColors.textDark,
        );
      }
      return;
    }

    Get.to(() => MyWebsiteView(title: title, url: url));
  }

  void _recomputeVisible() {
    visibleCharts.assignAll(
      _repository.applySearch(
        source: allCharts.toList(growable: false),
        search: searchQuery.value,
      ),
    );
  }

  Future<void> _handleFailure(DashboardFailure failure) async {
    errorMessage.value = failure.message;
    if (failure.type == DashboardFailureType.noInternet ||
        failure.type == DashboardFailureType.timeout ||
        failure.type == DashboardFailureType.server) {
      if (failure.type == DashboardFailureType.noInternet) {
        isOffline.value = true;
      }
      final cached = await _repository.loadOffline(
        userType: userType,
        userId: userId,
      );
      if (cached != null) {
        allCharts.assignAll(cached);
        servingFromCache.value = true;
        _recomputeVisible();
      }
    }
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }
}
