import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/center_kit_item.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/repositories/center_kit_repository.dart';

class CenterKitReportController extends GetxController {
  CenterKitReportController({
    required this.businessId,
    required CenterKitRepository repository,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  /// Null matches API payload `{ "business_id": null }` (all businesses).
  final int? businessId;
  final CenterKitRepository _repository;
  final Connectivity _connectivity;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();

  final RxString searchQuery = ''.obs;
  final Rx<CenterKitFilter> filter = CenterKitFilter.empty.obs;

  final RxList<CenterKitItem> allItems = <CenterKitItem>[].obs;
  final RxList<CenterKitItem> visibleItems = <CenterKitItem>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    observeConnectivity();
    loadReport();
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

  Future<void> loadReport() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadOffline();
    await sync();
    isLoading.value = false;
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(businessId: businessId);
    if (cached != null) {
      allItems.assignAll(cached);
      servingFromCache.value = true;
      _recomputeVisible();
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = allItems.isNotEmpty;
      if (allItems.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(businessId: businessId);
      allItems.assignAll(remote);
      servingFromCache.value = false;
      errorMessage.value = null;
      _recomputeVisible();
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshReport() async {
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

  void applyFilter(CenterKitFilter value) {
    filter.value = value;
    _recomputeVisible();
  }

  void clearFilters() {
    filter.value = CenterKitFilter.empty;
    searchQuery.value = '';
    _recomputeVisible();
  }

  List<String> get indentStatusOptions =>
      _uniqueValues((i) => i.indentStatus);
  List<String> get paymentStatusOptions =>
      _uniqueValues((i) => i.paymentStatus);
  List<String> get zoneOptions => _uniqueValues((i) => i.zoneCode);
  List<String> get stateOptions => _uniqueValues((i) => i.stateName);
  List<String> get projectManagerOptions =>
      _uniqueValues((i) => i.projectManager);

  List<String> _uniqueValues(String Function(CenterKitItem) picker) {
    final set = <String>{};
    for (final item in allItems) {
      final v = picker(item).trim();
      if (v.isNotEmpty) set.add(v);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _recomputeVisible() {
    final filtered = _repository.applyQuery(
      source: allItems.toList(growable: false),
      search: searchQuery.value,
      filter: filter.value,
    );
    visibleItems.assignAll(filtered);
  }

  Future<void> _handleFailure(DashboardFailure failure) async {
    errorMessage.value = failure.message;
    if (failure.type == DashboardFailureType.noInternet ||
        failure.type == DashboardFailureType.timeout ||
        failure.type == DashboardFailureType.server) {
      if (failure.type == DashboardFailureType.noInternet) {
        isOffline.value = true;
      }
      final cached = await _repository.loadOffline(businessId: businessId);
      if (cached != null) {
        allItems.assignAll(cached);
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
