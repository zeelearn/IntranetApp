import 'dart:async';

import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatuslist_request.dart';
import 'package:Intranet/api/response/general_response.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/pjp/managers/widgets/pjp_cvf_history_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

enum PjpApprovalStatusFilter { all, pending, approved, rejected }

enum PjpApprovalSort {
  pjpIdDesc,
  statusAsc,
  statusDesc,
  dateNewest,
  dateOldest,
}

enum PjpDatePreset {
  lastMonth,
  last3Months,
  thisYear,
  lastYear,
  custom,
}

class PjpApprovalController extends GetxController {
  static const _statusOrder = {
    'pending': 0,
    'approved': 1,
    'rejected': 2,
  };

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool showSearch = false.obs;
  final RxnString errorMessage = RxnString();

  final RxList<PJPInfo> allPjps = <PJPInfo>[].obs;
  final RxList<PJPInfo> visiblePjps = <PJPInfo>[].obs;
  final RxSet<String> selectedIds = <String>{}.obs;
  final RxSet<String> selectedEmployees = <String>{}.obs;
  final RxList<String> employeeNames = <String>[].obs;

  final Rx<PjpApprovalStatusFilter> statusFilter =
      PjpApprovalStatusFilter.all.obs;
  final Rx<PjpApprovalSort> sortBy = PjpApprovalSort.pjpIdDesc.obs;
  final Rx<PjpDatePreset> datePreset = PjpDatePreset.lastMonth.obs;
  final RxString searchQuery = ''.obs;

  final Rx<DateTime> fromDate =  DateTime(
    DateTime.now().year,
    DateTime.now().month - 6,
    DateTime.now().day,
  ).obs;
  final Rx<DateTime> toDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 12,
    DateTime.now().day,
  ).obs;

  int employeeId = 0;
  int businessId = 0;
  String employeeCode = '';

  Timer? _searchDebounce;
  late final TextEditingController searchController;

  int get selectedCount => selectedIds.length;

  int get pendingCount =>
      allPjps.where((p) => _isPending(p.ApprovalStatus)).length;

  int get approvedCount =>
      allPjps.where((p) => _isApproved(p.ApprovalStatus)).length;

  int get rejectedCount =>
      allPjps.where((p) => _isRejected(p.ApprovalStatus)).length;

  int get activeFilterCount {
    var count = 0;
    if (statusFilter.value != PjpApprovalStatusFilter.all) count++;
    if (selectedEmployees.isNotEmpty) count++;
    if (datePreset.value != PjpDatePreset.lastMonth) count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  List<PJPInfo> get selectedPjps =>
      visiblePjps.where((p) => selectedIds.contains(p.PJP_Id)).toList();

  List<PJPInfo> get selectableVisible =>
      visiblePjps.where((p) => _isPending(p.ApprovalStatus)).toList();

  bool get allPendingSelected {
    final pending = selectableVisible;
    if (pending.isEmpty) return false;
    return pending.every((p) => selectedIds.contains(p.PJP_Id));
  }

  String get datePresetLabel {
    switch (datePreset.value) {
      case PjpDatePreset.lastMonth:
        return 'Last Month';
      case PjpDatePreset.last3Months:
        return 'Last 3 Months';
      case PjpDatePreset.thisYear:
        return 'This Year';
      case PjpDatePreset.lastYear:
        return 'Last Year';
      case PjpDatePreset.custom:
        return 'Custom';
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchController.addListener(_onSearchChanged);
    //_applyDatePreset(PjpDatePreset.lastMonth);
    _bootstrap();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await _loadUserInfo();
    await loadPjps();
  }

  Future<void> _loadUserInfo() async {
    final hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = searchController.text.trim();
      _applyFilters();
    });
  }

  void toggleSearch() {
    showSearch.toggle();
    if (!showSearch.value) {
      searchController.clear();
      searchQuery.value = '';
      _applyFilters();
    }
  }

  Future<void> loadPjps({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }
    errorMessage.value = null;
    selectedIds.clear();

    final isInternet = await Utility.isInternet();
    if (!isInternet) {
      isLoading.value = false;
      isRefreshing.value = false;
      errorMessage.value = 'No internet connection. Please try again.';
      return;
    }

    final request = PJPReportRequest(
      employeeCode: employeeCode,
      businessId: businessId.toString(),
      fromDate: Utility.convertShortDate(fromDate.value),
      toDate: Utility.convertShortDate(toDate.value),
    );

    IntranetServiceHandler.loadPjpReport(
      request,
      _ServiceCallback(
        onStartCallback: () {},
        onSuccessCallback: (value) {
          isLoading.value = false;
          isRefreshing.value = false;
          if (value is PjpListResponse) {
            final teamPjps = value.responseData
                .where((p) => p.isSelfPJP.trim() == '0')
                .toList();
            allPjps.assignAll(teamPjps);
            _rebuildEmployeeNames();
            _applyFilters();
          } else {
            errorMessage.value = 'Unable to load PJP list.';
          }
        },
        onErrorCallback: (message) {
          isLoading.value = false;
          isRefreshing.value = false;
          errorMessage.value = message;
          allPjps.clear();
          visiblePjps.clear();
          employeeNames.clear();
        },
      ),
    );
  }

  Future<void> refreshList() => loadPjps(silent: true);

  void _rebuildEmployeeNames() {
    final names = allPjps
        .map((p) => p.displayName.trim())
        .where((n) => n.isNotEmpty && n.toUpperCase() != 'NA')
        .toSet()
        .toList()
      ..sort();
    employeeNames.assignAll(names);
    selectedEmployees
        .removeWhere((name) => !employeeNames.contains(name));
  }

  void setStatusFilter(PjpApprovalStatusFilter filter) {
    statusFilter.value = filter;
    selectedIds.clear();
    _applyFilters();
  }

  void setSort(PjpApprovalSort sort) {
    sortBy.value = sort;
    _applyFilters();
  }

  void toggleEmployee(String name) {
    if (selectedEmployees.contains(name)) {
      selectedEmployees.remove(name);
    } else {
      selectedEmployees.add(name);
    }
    selectedEmployees.refresh();
    selectedIds.clear();
    _applyFilters();
  }

  void clearEmployeeFilter() {
    selectedEmployees.clear();
    _applyFilters();
  }

  Future<void> applyDatePreset(PjpDatePreset preset) async {
    //_applyDatePreset(preset);
    await loadPjps();
  }

  void _applyDatePreset(PjpDatePreset preset) {
    final now = DateTime.now();
    datePreset.value = preset;
    switch (preset) {
      case PjpDatePreset.lastMonth:
        final firstOfThisMonth = DateTime(now.year, now.month, 1);
        final lastMonthEnd = firstOfThisMonth.subtract(const Duration(days: 1));
        fromDate.value = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);
        toDate.value =
            DateTime(lastMonthEnd.year, lastMonthEnd.month, lastMonthEnd.day);
      case PjpDatePreset.last3Months:
        fromDate.value = DateTime(now.year, now.month - 2, 1);
        toDate.value = DateTime(now.year, now.month, now.day);
      case PjpDatePreset.thisYear:
        fromDate.value = DateTime(now.year, 1, 1);
        toDate.value = DateTime(now.year, now.month, now.day);
      case PjpDatePreset.lastYear:
        fromDate.value = DateTime(now.year - 1, 1, 1);
        toDate.value = DateTime(now.year - 1, 12, 31);
      case PjpDatePreset.custom:
        break;
    }
  }

  Future<void> pickCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(
        start: fromDate.value,
        end: toDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryLightColor,
              onPrimary: Colors.white,
              secondary: kPrimaryLightColor,
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A237E),
            ),
            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor:
                  kPrimaryLightColor.withValues(alpha: 0.18),
              headerBackgroundColor: kPrimaryLightColor,
              headerForegroundColor: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryLightColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    datePreset.value = PjpDatePreset.custom;
    fromDate.value = picked.start;
    toDate.value = picked.end;
    await loadPjps();
  }

  void openCvfHistory(BuildContext context, PJPInfo pjp) {
    showPjpCvfHistorySheet(context, pjp);
  }

  void toggleSelection(PJPInfo pjp) {
    if (!_isPending(pjp.ApprovalStatus)) return;
    if (selectedIds.contains(pjp.PJP_Id)) {
      selectedIds.remove(pjp.PJP_Id);
    } else {
      selectedIds.add(pjp.PJP_Id);
    }
    selectedIds.refresh();
  }

  void toggleSelectAllPending() {
    final pending = selectableVisible;
    if (pending.isEmpty) return;
    if (allPendingSelected) {
      for (final p in pending) {
        selectedIds.remove(p.PJP_Id);
      }
    } else {
      for (final p in pending) {
        selectedIds.add(p.PJP_Id);
      }
    }
    selectedIds.refresh();
  }

  void clearSelection() => selectedIds.clear();

  bool isSelected(PJPInfo pjp) => selectedIds.contains(pjp.PJP_Id);

  bool canSelect(PJPInfo pjp) => _isPending(pjp.ApprovalStatus);

  void clearAllFilters() {
    statusFilter.value = PjpApprovalStatusFilter.all;
    selectedEmployees.clear();
    sortBy.value = PjpApprovalSort.pjpIdDesc;
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  Future<void> confirmAndUpdateStatus({
    required BuildContext context,
    required bool approve,
  }) async {
    final selected = selectedPjps;
    if (selected.isEmpty) {
      Utility.showMessage(
        context,
        'Please select at least one pending PJP.',
      );
      return;
    }

    final action = approve ? 'Approve' : 'Reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$action PJP?'),
        content: Text(
          'You are about to ${action.toLowerCase()} ${selected.length} '
          'pending PJP request(s).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: approve ? const Color(0xFF2E7D32) : Colors.red,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _submitStatusUpdate(
      context: context,
      approve: approve,
      pjps: selected,
    );
  }

  Future<void> _submitStatusUpdate({
    required BuildContext context,
    required bool approve,
    required List<PJPInfo> pjps,
  }) async {
    final isInternet = await Utility.isInternet();
    if (!context.mounted) return;
    if (!isInternet) {
      Utility.showMessage(context, 'No internet connection.');
      return;
    }

    isSubmitting.value = true;
    final docXml = _buildDocXml(pjps, approve);
    final request = UpdatePJPStatusListRequest(
      DocXML: docXml,
      Workflow_user: employeeId.toString(),
    );

    IntranetServiceHandler.updatePJPStatusList(
      request,
      _ServiceCallback(
        onStartCallback: () {},
        onSuccessCallback: (value) async {
          isSubmitting.value = false;
          if (!context.mounted) return;
          if (value is GeneralResponse) {
            Utility.showMessage(
              context,
              approve
                  ? 'PJP(s) approved successfully'
                  : 'PJP(s) rejected successfully',
            );
            selectedIds.clear();
            await loadPjps(silent: true);
          } else {
            Utility.showMessage(context, 'Unable to update PJP status.');
          }
        },
        onErrorCallback: (message) {
          isSubmitting.value = false;
          if (!context.mounted) return;
          Utility.showMessage(context, message);
        },
      ),
    );
  }

  String _buildDocXml(List<PJPInfo> pjps, bool approve) {
    final buffer = StringBuffer('<root>');
    final isApproved = approve ? 1 : 0;
    for (final pjp in pjps) {
      buffer.write(
        '<subroot><PJP_id>${pjp.PJP_Id}</PJP_id>'
        '<Is_Approved>$isApproved</Is_Approved></subroot>',
      );
    }
    buffer.write('</root>');
    return buffer.toString();
  }

  void _applyFilters() {
    Iterable<PJPInfo> filtered = allPjps;

    switch (statusFilter.value) {
      case PjpApprovalStatusFilter.pending:
        filtered = filtered.where((p) => _isPending(p.ApprovalStatus));
      case PjpApprovalStatusFilter.approved:
        filtered = filtered.where((p) => _isApproved(p.ApprovalStatus));
      case PjpApprovalStatusFilter.rejected:
        filtered = filtered.where((p) => _isRejected(p.ApprovalStatus));
      case PjpApprovalStatusFilter.all:
        break;
    }

    if (selectedEmployees.isNotEmpty) {
      filtered = filtered.where(
        (p) => selectedEmployees.contains(p.displayName.trim()),
      );
    }

    final query = searchQuery.value.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((p) => _matchesSearch(p, query));
    }

    final list = filtered.toList();
    list.sort(_compare);
    visiblePjps.assignAll(list);

    selectedIds.removeWhere(
      (id) => !visiblePjps.any(
        (p) => p.PJP_Id == id && _isPending(p.ApprovalStatus),
      ),
    );
  }

  bool _matchesSearch(PJPInfo pjp, String query) {
    if (pjp.displayName.toLowerCase().contains(query) ||
        (pjp.employeeCode ?? '').toLowerCase().contains(query) ||
        pjp.PJP_Id.toLowerCase().contains(query) ||
        pjp.remarks.toLowerCase().contains(query) ||
        (pjp.zone ?? '').toLowerCase().contains(query) ||
        pjp.ApprovalStatus.toLowerCase().contains(query)) {
      return true;
    }

    for (final cvf in pjp.getDetailedPJP ?? const <GetDetailedPJP>[]) {
      if (cvf.franchiseeName.toLowerCase().contains(query) ||
          cvf.franchiseeCode.toLowerCase().contains(query) ||
          cvf.ActivityTitle.toLowerCase().contains(query) ||
          cvf.PJPCVF_Id.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }

  int _compare(PJPInfo a, PJPInfo b) {
    switch (sortBy.value) {
      case PjpApprovalSort.pjpIdDesc:
        return _pjpIdValue(b).compareTo(_pjpIdValue(a));
      case PjpApprovalSort.statusAsc:
        return _statusRank(a.ApprovalStatus)
            .compareTo(_statusRank(b.ApprovalStatus));
      case PjpApprovalSort.statusDesc:
        return _statusRank(b.ApprovalStatus)
            .compareTo(_statusRank(a.ApprovalStatus));
      case PjpApprovalSort.dateNewest:
        return b.fromDate.compareTo(a.fromDate);
      case PjpApprovalSort.dateOldest:
        return a.fromDate.compareTo(b.fromDate);
    }
  }

  int _pjpIdValue(PJPInfo pjp) => int.tryParse(pjp.PJP_Id.trim()) ?? 0;

  int _statusRank(String status) {
    final key = status.trim().toLowerCase();
    return _statusOrder[key] ?? 99;
  }

  static bool _isPending(String status) =>
      status.trim().toLowerCase() == 'pending';

  static bool _isApproved(String status) =>
      status.trim().toLowerCase().contains('approv');

  static bool _isRejected(String status) =>
      status.trim().toLowerCase() == 'rejected';
}

class _ServiceCallback implements onResponse {
  _ServiceCallback({
    required this.onSuccessCallback,
    required this.onErrorCallback,
    this.onStartCallback,
  });

  final void Function(dynamic) onSuccessCallback;
  final void Function(String) onErrorCallback;
  final void Function()? onStartCallback;

  @override
  void onStart() => onStartCallback?.call();

  @override
  void onSuccess(value) => onSuccessCallback(value);

  @override
  void onError(value) =>
      onErrorCallback(value?.toString() ?? 'Something went wrong');
}
