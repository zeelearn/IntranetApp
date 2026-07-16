import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/dashboard_summary.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';
import 'package:Intranet/modules/projects/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController({
    required this.userId,
    required this.userName,
    required List<BusinessApplications> businesses,
    required DashboardRepository repository,
    int? businessId,
    this.businessName = '',
    this.onCardTap,
    this.onQuickAction,
    Connectivity? connectivity,
  })  : businesses = List<BusinessApplications>.unmodifiable(businesses),
        _repository = repository,
        _connectivity = connectivity ?? Connectivity() {
    selectedBusinessId.value = businessId;
  }

  final int userId;
  final String userName;
  final String businessName;
  final List<BusinessApplications> businesses;
  final DashboardRepository _repository;
  final Connectivity _connectivity;

  /// Backward-compatible alias used by list/task openers.
  String get displayName => userName;

  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;

  final RxnInt selectedBusinessId = RxnInt();
  final RxString selectedBusinessLabel = 'All Business'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<DashboardFailureType> failureType = Rxn<DashboardFailureType>();

  final Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  final RxList<DashboardCardModel> cards = <DashboardCardModel>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void onInit() {
    super.onInit();
    _updateBusinessLabel();
    observeConnectivity();
    loadDashboard();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  Future<void> observeConnectivity() async {
    await _updateConnectivityFlag();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) async {
      final offline = results.every((r) => r == ConnectivityResult.none);
      final previouslyOffline = isOffline.value;
      isOffline.value = offline;
      if (previouslyOffline && !offline) {
        await sync();
      }
    });
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    failureType.value = null;
    // Keep shimmer until server responds — do not paint cache first.
    summary.value = null;
    cards.clear();
    servingFromCache.value = false;

    try {
      await _updateConnectivityFlag();
      await sync();

      // Fallback to cache only when server did not deliver data.
      if (summary.value == null) {
        await loadOffline();
      }
    } finally {
      // Always clear shimmer, even if sync throws unexpectedly.
      isLoading.value = false;
    }
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      userId: userId,
      businessId: selectedBusinessId.value,
    );
    if (cached != null) {
      _applySummary(cached, fromCache: true);
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = summary.value != null;
      if (summary.value == null) {
        errorMessage.value = 'No internet connection.';
        failureType.value = DashboardFailureType.noInternet;
      }
      return;
    }

    try {
      servingFromCache.value = false;
      final remote = await _repository.sync(
        userId: userId,
        businessId: selectedBusinessId.value,
      );
      _applySummary(remote, fromCache: false);
      errorMessage.value = null;
      failureType.value = null;
    } on DashboardFailure catch (failure) {
      await _handleFailure(failure);
    } catch (e) {
      errorMessage.value = e.toString();
      failureType.value = DashboardFailureType.unknown;
    }
  }

  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      await _updateConnectivityFlag();
      if (isOffline.value) {
        await loadOffline();
        if (summary.value == null) {
          errorMessage.value = 'No internet connection.';
          failureType.value = DashboardFailureType.noInternet;
        } else {
          servingFromCache.value = true;
        }
      } else {
        final result = await _repository.refresh(
          userId: userId,
          businessId: selectedBusinessId.value,
        );
        _applySummary(result, fromCache: false);
        errorMessage.value = null;
        failureType.value = null;
        servingFromCache.value = false;
      }
    } on DashboardFailure catch (failure) {
      await _handleFailure(failure);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> selectBusiness(int? businessId) async {
    if (selectedBusinessId.value == businessId) return;
    selectedBusinessId.value = businessId;
    _updateBusinessLabel();
    isLoading.value = true;
    errorMessage.value = null;
    failureType.value = null;
    cards.clear();
    summary.value = null;
    servingFromCache.value = false;

    try {
      await _updateConnectivityFlag();
      await sync();
      if (summary.value == null) {
        await loadOffline();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void handleCardTap(DashboardCardModel card) {
    onCardTap?.call(card.statusId, card.statusName);
  }

  void handleQuickAction(QuickActionType action) {
    onQuickAction?.call(action);
  }

  void calculateDashboard(DashboardSummary value) {
    cards.assignAll(DashboardCardModel.fromSummary(value));
  }

  void calculatePercentages() {
    final current = summary.value;
    if (current == null) return;
    calculateDashboard(current);
  }

  void _applySummary(DashboardSummary value, {required bool fromCache}) {
    summary.value = value;
    servingFromCache.value = fromCache;
    calculateDashboard(value);
  }

  Future<void> _handleFailure(DashboardFailure failure) async {
    failureType.value = failure.type;
    errorMessage.value = failure.message;

    if (failure.type == DashboardFailureType.noInternet ||
        failure.type == DashboardFailureType.timeout ||
        failure.type == DashboardFailureType.server) {
      isOffline.value =
          failure.type == DashboardFailureType.noInternet || isOffline.value;
      final cached = await _repository.loadOffline(
        userId: userId,
        businessId: selectedBusinessId.value,
      );
      if (cached != null) {
        _applySummary(cached, fromCache: true);
      }
    }
  }

  void _updateBusinessLabel() {
    final id = selectedBusinessId.value;
    if (id == null) {
      selectedBusinessLabel.value = 'All Business';
      return;
    }
    final match = businesses.where((b) => b.businessID == id);
    if (match.isNotEmpty) {
      selectedBusinessLabel.value = match.first.businessName;
      return;
    }
    selectedBusinessLabel.value =
        businessName.trim().isEmpty ? 'Business $id' : businessName.trim();
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    final offline = results.every((r) => r == ConnectivityResult.none);
    isOffline.value = offline;
  }
}
