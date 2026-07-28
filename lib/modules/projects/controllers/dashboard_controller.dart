import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/dashboard_summary.dart';
import 'package:Intranet/modules/projects/models/project_business.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';
import 'package:Intranet/modules/projects/repositories/dashboard_repository.dart';
import 'package:Intranet/modules/projects/repositories/project_business_repository.dart';
import 'package:Intranet/modules/projects/utils/business_name_matcher.dart';

class DashboardController extends GetxController {
  DashboardController({
    required this.userId,
    required this.userName,
    required List<BusinessApplications> businesses,
    required DashboardRepository repository,
    required ProjectBusinessRepository businessRepository,
    int? businessId,
    this.businessName = '',
    this.onCardTap,
    this.onQuickAction,
    Connectivity? connectivity,
  })  : intranetBusinesses = List<BusinessApplications>.unmodifiable(businesses),
        _repository = repository,
        _businessRepository = businessRepository,
        _connectivity = connectivity ?? Connectivity(),
        _intranetBusinessId = businessId {
    // Do not use intranet businessId for Projects APIs until GetBusiness maps it.
    selectedBusinessId.value = null;
  }

  final int userId;
  final String userName;

  /// Intranet session business name (`KEY_BUSINESS_NAME`) used for name mapping.
  final String businessName;

  /// Login businesses (intranet ids) — fallback only if GetBusiness unavailable.
  final List<BusinessApplications> intranetBusinesses;

  final int? _intranetBusinessId;

  final DashboardRepository _repository;
  final ProjectBusinessRepository _businessRepository;
  final Connectivity _connectivity;

  /// Backward-compatible alias used by list/task openers.
  String get displayName => userName;

  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;

  /// Projects selector list (GetBusiness ids). Reactive so UI updates after load.
  final RxList<BusinessApplications> businesses = <BusinessApplications>[].obs;

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
      await _loadProjectBusinesses();
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

  /// Loads GetBusiness list (network → cache) and maps intranet name → Projects id.
  Future<void> _loadProjectBusinesses() async {
    List<ProjectBusiness> projectList = const [];
    try {
      if (isOffline.value) {
        projectList = await _businessRepository.loadOffline();
        if (projectList.isNotEmpty) {
          servingFromCache.value = true;
        }
      } else {
        projectList = await _businessRepository.sync();
        if (projectList.isEmpty) {
          projectList = await _businessRepository.loadOffline();
          if (projectList.isNotEmpty) {
            servingFromCache.value = true;
          }
        }
      }
    } catch (_) {
      projectList = await _businessRepository.loadOffline();
      if (projectList.isNotEmpty) {
        servingFromCache.value = true;
      }
    }

    if (projectList.isNotEmpty) {
      businesses.assignAll(projectList.map(_toSelectorItem));
      _applyMappedSelection(projectList);
      return;
    }

    // Last resort: keep intranet list so UI is not empty (ids may be wrong).
    if (intranetBusinesses.isNotEmpty && businesses.isEmpty) {
      businesses.assignAll(intranetBusinesses);
      selectedBusinessId.value = _intranetBusinessId;
      _updateBusinessLabel();
    } else {
      _applyMappedSelection(const []);
    }
  }

  void _applyMappedSelection(List<ProjectBusiness> projectList) {
    final match = matchProjectBusinessByName(
      intranetName: businessName,
      projectsBusinesses: projectList,
    );
    selectedBusinessId.value = match?.businessId;
    _updateBusinessLabel();
  }

  BusinessApplications _toSelectorItem(ProjectBusiness item) {
    return BusinessApplications(
      businessID: item.businessId,
      business_UserID: userId,
      employeeId: '',
      businessName: item.businessName,
      logoPath: '',
      headerPath: '',
      footerPath: '',
      path: '',
    );
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
      servingFromCache.value = summary.value != null || businesses.isNotEmpty;
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
      await _loadProjectBusinesses();
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
