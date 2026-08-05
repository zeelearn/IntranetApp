import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/repositories/indent_repository.dart';
import 'package:Intranet/modules/projects/utils/indent_action_roles.dart';
import 'package:Intranet/modules/projects/widgets/branding_kit_sheet.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

class IndentListController extends GetxController {
  IndentListController({
    required this.userId,
    required this.businessId,
    required IndentRepository repository,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity();

  final int userId;
  final String businessId;
  final IndentRepository _repository;
  final Connectivity _connectivity;

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxnString errorMessage = RxnString();

  final RxBool isGeneratingPaymentLink = false.obs;
  final RxnInt generatingPaymentLinkIndentId = RxnInt();

  /// Employee role from Hive (`KEY_EMP_TYPE`), e.g. MAN / BH / ZM.
  final RxString employeeType = ''.obs;

  final RxString searchQuery = ''.obs;
  final Rx<IndentListFilter> filter = IndentListFilter.empty.obs;

  final RxList<IndentItem> allIndents = <IndentItem>[].obs;
  final RxList<IndentItem> visibleIndents = <IndentItem>[].obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _searchDebounce;

  /// Payment Link / finance actions — MAN & BH only.
  bool get canAccessFinanceActions =>
      IndentActionRoles.canAccessFinanceActions(employeeType.value);

  bool showPaymentLinkFor(IndentItem item) =>
      canAccessFinanceActions && item.canGeneratePaymentLink;

  @override
  void onInit() {
    super.onInit();
    _loadEmployeeType();
    observeConnectivity();
    loadIndents();
  }

  Future<void> _loadEmployeeType() async {
    try {
      final box = await Utility.openBox();
      employeeType.value =
          (box.get(LocalConstant.KEY_EMP_TYPE)?.toString() ?? '').trim();
    } catch (_) {
      employeeType.value = '';
    }
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

  Future<void> loadIndents() async {
    isLoading.value = true;
    errorMessage.value = null;
    await loadOffline();
    await sync();
    isLoading.value = false;
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(
      userId: userId,
      businessId: businessId,
    );
    if (cached != null) {
      allIndents.assignAll(cached);
      servingFromCache.value = true;
      _recomputeVisible();
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = allIndents.isNotEmpty;
      if (allIndents.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
      return;
    }
    try {
      final remote = await _repository.sync(
        userId: userId,
        businessId: businessId,
      );
      allIndents.assignAll(remote);
      servingFromCache.value = false;
      errorMessage.value = null;
      _recomputeVisible();
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshIndents() async {
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

  void applyFilter(IndentListFilter value) {
    filter.value = value;
    _recomputeVisible();
  }

  void clearFilters() {
    filter.value = IndentListFilter.empty;
    searchQuery.value = '';
    _recomputeVisible();
  }

  List<String> get indentStatusOptions => _uniqueValues((i) => i.indentStatus);
  List<String> get paymentStatusOptions =>
      _uniqueValues((i) => i.paymentStatus);
  List<String> get projectStatusOptions =>
      _uniqueValues((i) => i.projectStatus);
  List<String> get zoneOptions => _uniqueValues((i) => i.zoneCode);
  List<String> get stateOptions => _uniqueValues((i) => i.stateName);

  List<String> _uniqueValues(String Function(IndentItem) picker) {
    final set = <String>{};
    for (final item in allIndents) {
      final v = picker(item).trim();
      if (v.isNotEmpty) set.add(v);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _recomputeVisible() {
    final filtered = _repository.applyQuery(
      source: allIndents.toList(growable: false),
      search: searchQuery.value,
      filter: filter.value,
    );
    visibleIndents.assignAll(filtered);
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
        businessId: businessId,
      );
      if (cached != null) {
        allIndents.assignAll(cached);
        servingFromCache.value = true;
        _recomputeVisible();
      }
    }
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }

  Future<void> confirmAndGeneratePaymentLink(
    BuildContext context,
    IndentItem item,
  ) async {
    if (!canAccessFinanceActions) {
      _showMessage(
        context,
        'Payment link is available only for MAN and BH roles.',
      );
      return;
    }
    if (!item.canGeneratePaymentLink) {
      _showMessage(
        context,
        'Payment link is not available when payment status is Completed.',
      );
      return;
    }
    if (item.indentId <= 0) {
      _showMessage(context, 'Indent ID is missing for this record.');
      return;
    }
    if (isOffline.value) {
      _showMessage(context, 'No internet connection.');
      return;
    }
    if (isGeneratingPaymentLink.value) return;

    final name = item.franchiseeName.isNotEmpty
        ? item.franchiseeName
        : (item.franchiseeCode.isNotEmpty
            ? item.franchiseeCode
            : '#${item.indentId}');

    final dueLabel = item.dueAmount > 0
        ? '\nDue amount: ${item.dueAmount.toStringAsFixed(0)}'
        : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Generate Payment Link?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: DashboardColors.textDark,
          ),
        ),
        content: Text(
          'Send payment link email for "$name"?\n\n'
          'Indent ID: ${item.indentId}$dueLabel\n\n'
          'This will email the payment link to the franchisee.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: DashboardColors.primaryFilledButton(),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Generate & Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _generatePaymentLink(context, item);
  }

  Future<void> _generatePaymentLink(
    BuildContext context,
    IndentItem item,
  ) async {
    if (isGeneratingPaymentLink.value) return;

    isGeneratingPaymentLink.value = true;
    generatingPaymentLinkIndentId.value = item.indentId;

    try {
      final result =
          await _repository.generatePaymentLink(indentId: item.indentId);
      if (!context.mounted) return;
      _showMessage(
        context,
        result.message,
        success: result.success,
      );
    } on DashboardFailure catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.message);
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, e.toString());
    } finally {
      isGeneratingPaymentLink.value = false;
      generatingPaymentLinkIndentId.value = null;
    }
  }

  /// Opens Branding Kit bottom sheet (GetBrandingProduct / InsertBrandingIndent).
  Future<void> onBrandingKitTap(
    BuildContext context,
    IndentItem item,
  ) async {
    if (item.franchiseeId <= 0) {
      _showMessage(
        context,
        'Franchisee ID is missing. Cannot open Branding Kit.',
      );
      return;
    }
    if (isOffline.value) {
      _showMessage(context, 'No internet connection.');
      return;
    }
    await showBrandingKitSheet(context: context, item: item);
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? DashboardColors.success : DashboardColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
