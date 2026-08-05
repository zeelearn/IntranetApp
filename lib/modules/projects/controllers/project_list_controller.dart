import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/models/project_list_filter.dart';
import 'package:Intranet/modules/projects/models/send_credentials_result.dart';
import 'package:Intranet/modules/projects/repositories/project_repository.dart';
import 'package:Intranet/modules/projects/services/credentials_cooldown_store.dart';
import 'package:Intranet/modules/projects/views/project_detail_screen.dart';
import 'package:Intranet/modules/projects/views/task_hierarchy_screen.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectListController extends GetxController {
  ProjectListController({
    required this.userId,
    required this.projectTeamStatus,
    required this.statusName,
    required this.statusColor,
    required List<BusinessApplications> businesses,
    required ProjectRepository repository,
    int? businessId,
    this.currentUserName = '',
    Connectivity? connectivity,
  })  : businesses = List<BusinessApplications>.unmodifiable(businesses),
        _repository = repository,
        _connectivity = connectivity ?? Connectivity() {
    selectedBusinessId.value = businessId;
  }

  final int userId;
  final int projectTeamStatus;
  final String statusName;
  final Color statusColor;
  final String currentUserName;
  final List<BusinessApplications> businesses;
  final ProjectRepository _repository;
  final Connectivity _connectivity;

  final RxnInt selectedBusinessId = RxnInt();
  final RxString selectedBusinessLabel = 'All Business'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxBool showSearchBar = true.obs;
  final RxBool isSendingCredentials = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString sendingCredentialsCrmId = RxnString();

  final RxString searchQuery = ''.obs;
  final Rx<ProjectListFilter> filter = ProjectListFilter.empty.obs;

  final RxList<ProjectItem> allProjects = <ProjectItem>[].obs;
  final RxList<ProjectItem> visibleProjects = <ProjectItem>[].obs;

  /// crmId -> cooldown end time
  final RxMap<String, DateTime> credentialsCooldownUntil =
      <String, DateTime>{}.obs;

  final RxInt page = 1.obs;
  final RxInt pageSize = ProjectRepository.defaultPageSize.obs;
  final RxBool hasMore = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;
  Timer? _cooldownTicker;

  @override
  void onInit() {
    super.onInit();
    _updateBusinessLabel();
    observeConnectivity();
    loadProjects();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      _pruneExpiredCooldowns();
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _connectivitySub?.cancel();
    _cooldownTicker?.cancel();
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

  Future<void> loadProjects() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadOffline();
    await sync();
    await _hydrateCooldowns();
    isLoading.value = false;
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      userId: userId,
      projectTeamStatus: projectTeamStatus,
      businessId: selectedBusinessId.value,
    );
    if (cached != null) {
      allProjects.assignAll(cached);
      servingFromCache.value = true;
      _recomputeVisible();
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = allProjects.isNotEmpty;
      if (allProjects.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: selectedBusinessId.value,
      );
      allProjects.assignAll(remote);
      servingFromCache.value = false;
      errorMessage.value = null;
      page.value = 1;
      _recomputeVisible();
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshProjects() async {
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      await _updateConnectivityFlag();
      if (isOffline.value) {
        await loadOffline();
        if (allProjects.isEmpty) {
          errorMessage.value = 'No internet connection.';
        }
      } else {
        final list = await _repository.refresh(
          userId: userId,
          projectTeamStatus: projectTeamStatus,
          businessId: selectedBusinessId.value,
        );
        allProjects.assignAll(list);
        servingFromCache.value = false;
        page.value = 1;
        _recomputeVisible();
      }
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } finally {
      isRefreshing.value = false;
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = value;
      page.value = 1;
      _recomputeVisible();
    });
  }

  void applyFilter(ProjectListFilter value) {
    filter.value = value;
    page.value = 1;
    _recomputeVisible();
  }

  void clearFilters() {
    filter.value = ProjectListFilter.empty;
    searchQuery.value = '';
    page.value = 1;
    _recomputeVisible();
  }

  void loadMore() {
    if (!hasMore.value) return;
    page.value = page.value + 1;
    _recomputeVisible(append: true);
  }

  Future<void> selectBusiness(int? businessId) async {
    if (selectedBusinessId.value == businessId) return;
    selectedBusinessId.value = businessId;
    _updateBusinessLabel();
    isLoading.value = true;
    allProjects.clear();
    visibleProjects.clear();
    await loadOffline();
    await sync();
    isLoading.value = false;
  }

  void toggleSearchBar() {
    showSearchBar.value = !showSearchBar.value;
  }

  void openProjectDetail(ProjectItem project) {
    TaskHierarchyScreen.open(
      project: project,
      userId: userId,
      currentUserName: currentUserName,
      contributionId: selectedBusinessId.value ?? 0,
    );
  }

  void openTaskScreen(ProjectItem project, int taskId) {
    TaskHierarchyScreen.open(
      project: project,
      userId: userId,
      currentUserName: 'project.crmId,',
      contributionId: selectedBusinessId.value ?? 0,
    );
  }

  void openProjectDetailsPage(
    ProjectItem project, {
    required ProjectDetailTab initialTab,
  }) {
    ProjectDetailScreen.open(
      project: project,
      userId: userId,
      currentUserName: currentUserName,
      statusName: statusName,
      statusColor: statusColor,
      initialTab: initialTab,
      contributionId: selectedBusinessId.value ?? 0,
    );
  }

  void onCommunication(ProjectItem project) {
    openProjectDetailsPage(
      project,
      initialTab: ProjectDetailTab.communication,
    );
  }

  void onIndentDetails(ProjectItem project) {
    openProjectDetailsPage(
      project,
      initialTab: ProjectDetailTab.indent,
    );
  }

  void onDocuments(ProjectItem project) {
    openProjectDetailsPage(
      project,
      initialTab: ProjectDetailTab.documents,
    );
  }

  void onNotes(ProjectItem project) {
    onCommunication(project);
  }

  void onEdit(ProjectItem project) {
    Get.snackbar(
      'Edit',
      'Edit for ${project.crmId} — coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DashboardColors.primaryLight,
      colorText: DashboardColors.textDark,
    );
  }

  Future<void> viewReport(ProjectItem project) async {
    final crmId = project.crmId.trim();
    if (!ProjectChartUrl.isValidCrmId(crmId)) {
      Get.snackbar(
        'View Report',
        'CRM ID is missing for this project.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return;
    }

    final url = ProjectChartUrl.build(crmId);

    // Chart host sets X-Frame-Options: sameorigin — cannot embed in WebView/iframe.
    if (kIsWeb) {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );
      if (!launched) {
        Get.snackbar(
          'View Report',
          'Unable to open report in a new window.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
          colorText: DashboardColors.textDark,
        );
      }
      return;
    }

    final title = project.franchiseeName.isNotEmpty
        ? project.franchiseeName
        : (project.title.isNotEmpty ? project.title : 'Project Report');

    Get.to(
      () => MyWebsiteView(
        title: title,
        url: url,
      ),
    );
  }

  bool canSendCredentials(String crmId) {
    final remaining = cooldownRemaining(crmId);
    return remaining == null;
  }

  Duration? cooldownRemaining(String crmId) {
    final id = crmId.trim();
    if (id.isEmpty) return null;
    return CredentialsCooldownStore.remainingFromUntil(
      credentialsCooldownUntil[id],
    );
  }

  String? sendCredentialsCooldownHint(String crmId) {
    final remaining = cooldownRemaining(crmId);
    if (remaining == null) return null;
    return 'Wait ${CredentialsCooldownStore.formatRemaining(remaining)}';
  }

  Future<void> confirmAndSendCredentials(
    BuildContext context,
    ProjectItem project,
  ) async {
    final crmId = project.crmId.trim();
    if (!ProjectChartUrl.isValidCrmId(crmId)) {
      _showMessage(context, 'CRM ID is missing for this project.');
      return;
    }

    final remaining = cooldownRemaining(crmId);
    if (remaining != null) {
      _showMessage(
        context,
        'Credentials already sent. Please wait '
        '${CredentialsCooldownStore.formatRemaining(remaining)} before sending again.',
      );
      return;
    }

    if (isOffline.value) {
      _showMessage(context, 'No internet connection.');
      return;
    }

    final name = project.franchiseeName.isNotEmpty
        ? project.franchiseeName
        : crmId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Credentials?'),
        content: Text(
          'Send temporary login credentials for "$name"?\n\nCRM ID: $crmId',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: DashboardColors.primary,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _sendCredentials(context, project);
  }

  Future<void> _sendCredentials(
    BuildContext context,
    ProjectItem project,
  ) async {
    final crmId = project.crmId.trim();
    if (isSendingCredentials.value) return;

    isSendingCredentials.value = true;
    sendingCredentialsCrmId.value = crmId;

    try {
      final result = await _repository.sendTempCredentials(crmId: crmId);
      credentialsCooldownUntil[crmId] =
          DateTime.now().add(const Duration(minutes: 15));
      credentialsCooldownUntil.refresh();
      if (!context.mounted) return;
      _showMessage(context, result.message);
    } on DashboardFailure catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.message);
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Unable to send credentials. Please try again.');
    } finally {
      isSendingCredentials.value = false;
      sendingCredentialsCrmId.value = null;
    }
  }

  Future<void> _hydrateCooldowns() async {
    final map = <String, DateTime>{};
    for (final project in allProjects) {
      final id = project.crmId.trim();
      if (id.isEmpty) continue;
      final until = await _repository.credentialsCooldown.cooldownUntil(id);
      if (until != null) map[id] = until;
    }
    credentialsCooldownUntil
      ..clear()
      ..addAll(map);
    credentialsCooldownUntil.refresh();
  }

  void _pruneExpiredCooldowns() {
    final now = DateTime.now();
    final expired = credentialsCooldownUntil.entries
        .where((e) => !now.isBefore(e.value))
        .map((e) => e.key)
        .toList(growable: false);
    if (expired.isEmpty) return;
    for (final key in expired) {
      credentialsCooldownUntil.remove(key);
    }
    credentialsCooldownUntil.refresh();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<String> get feeTypeOptions {
    final set = <String>{};
    for (final p in allProjects) {
      if (p.feeType.trim().isNotEmpty) set.add(p.feeType);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> get tierOptions {
    final set = <String>{};
    for (final p in allProjects) {
      if (p.tierName.trim().isNotEmpty) set.add(p.tierName.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Unique Created By values for filter dropdown.
  List<String> get createdByOptions {
    final set = <String>{};
    for (final p in allProjects) {
      final name = p.createdBy.trim().isNotEmpty
          ? p.createdBy.trim()
          : p.responsiblePerson.trim();
      if (name.isNotEmpty) set.add(name);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _recomputeVisible({bool append = false}) {
    final filtered = _repository.applyQuery(
      source: allProjects.toList(growable: false),
      search: searchQuery.value,
      filter: filter.value,
      paginate: false,
    );

    final size = pageSize.value;
    final take = page.value * size;
    hasMore.value = filtered.length > take;
    final slice = filtered.take(take).toList(growable: false);
    if (append) {
      visibleProjects.assignAll(slice);
    } else {
      visibleProjects.assignAll(slice);
    }
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
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: selectedBusinessId.value,
      );
      if (cached != null) {
        allProjects.assignAll(cached);
        servingFromCache.value = true;
        _recomputeVisible();
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
    selectedBusinessLabel.value =
        match.isEmpty ? 'Business $id' : match.first.businessName;
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }
}
