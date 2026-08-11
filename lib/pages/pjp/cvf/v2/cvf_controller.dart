import 'dart:async';
import 'dart:convert';

import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/cvf/get_cvf_request.dart';
import 'package:Intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:Intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:Intranet/api/response/cvf/get_all_cvf.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/firebase/anylatics.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/LocationHelper.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/pjp/cvf/add_cvf.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/share_report.dart';
import 'package:Intranet/pages/pjp/cvf/v2/cvf_location_map.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:Intranet/pages/widget/report.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum CvfFilter { all, completed, checkIn, fillCvf, cancelled }

/// Left-bar status colors for CVF cards.
class CvfStatusColor {
  CvfStatusColor._();

  static const Color accent = Color(0xFF4B39EF);
  static const Color pending = Color(0xFFFF8A65);
  static const Color approved = Color(0xFF4CAF90);
  static const Color rejected = Color(0xFFEF5350);
  static const Color cancelled = Color(0xFFEF5350);
  static const Color completed = Color(0xFF4CAF90);
  static const Color inProgress = Color(0xFF6488E4);
  static const Color neutral = Color(0xFF9D99A7);
}

class CVFController extends GetxController {
  CVFController({this.pjpInfo, this.isViewOnly = false});

  final PJPInfo? pjpInfo;
  final bool isViewOnly;



  final cvfList = <GetDetailedPJP>[].obs;
  final isLoading = true.obs;
  final isUpdating = false.obs;
  final filter = CvfFilter.all.obs;
  final offlineStatus = <String, String>{}.obs;
  final errorMessage = RxnString();

  var currentPJP = <PJPInfo>[].obs;

  int employeeId = 0;
  int businessId = 0;
  late Box hiveBox;

  bool get isPjpMode => pjpInfo != null;
  bool get canAddCvf => isPjpMode && !isViewOnly && pjpInfo!.isSelfPJP != '0';

  /// Filter is available on both My CVF and PJP CVF lists.
  bool get showFilter => true;

  /// Show Add action unless screen is view-only (matches legacy CVF list).
  bool get showAddCvf => !isViewOnly;
  String get screenTitle => 'My CVF';

  String get filterLabel {
    switch (filter.value) {
      case CvfFilter.completed:
        return 'Completed';
      case CvfFilter.checkIn:
        return 'Check In';
      case CvfFilter.cancelled:
        return 'Cancelled';
      case CvfFilter.fillCvf:
        return 'FILL CVF';
      case CvfFilter.all:
        return 'All';
    }
  }

  bool _isMounted(BuildContext? context) => context != null && context.mounted;

  static bool isContextMounted(BuildContext? context) =>
      context != null && context.mounted;

  @override
  void onInit() {
    super.onInit();
    _initUser();
  }

  Future<void> _initUser() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    await loadData();
  }

  String _cacheKey() {
    if (isPjpMode && pjpInfo!.PJP_Id.isNotEmpty) {
      return '${employeeId}_${LocalConstant.KEY_MY_CVF}_${pjpInfo!.PJP_Id}';
    }
    return '${employeeId}_${LocalConstant.KEY_MY_CVF}';
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    final helper = DBHelper();
    offlineStatus.assignAll(await helper.getCheckInStatus());

    try {
      final hasInternet = await Utility.isInternet();
      if (hasInternet) {
        await _fetchFromApi();
      } else if (!_loadFromCache()) {
        await _fetchFromApi();
      }
    } catch (e) {
      if (!_loadFromCache()) {
        errorMessage.value = 'Unable to load CVF list. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async => loadData();

  bool _loadFromCache() {
    try {
      final cached = hiveBox.get(_cacheKey());
      if (cached == null) return false;

      cvfList.clear();
      if (isPjpMode) {
        final response = PjpListResponse.fromJson(json.decode(cached));
        if (response.responseData != null) {
          for (final item in response.responseData) {
            cvfList.addAll(item.getDetailedPJP ?? []);
          }
        }
      } else {
        final response = GetAllCVFResponse.fromJson(json.decode(cached));
        if (response.responseData.isNotEmpty) {
          cvfList.addAll(response.responseData);
          _sortByDate();
        }
      }
      return cvfList.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchFromApi() async {
    if (isPjpMode) {
      await _fetchPjpCvf();
    } else {
      await _fetchAllCvf();
    }
  }

  Future<void> _fetchAllCvf() async {
    cvfList.clear();
    final request = GetAllCVF(Employee_id: employeeId, Business_id: businessId);
    final value = await APIService().getAllCVF(request);
    if (value is GetAllCVFResponse && value.responseData.isNotEmpty) {
      hiveBox.put(_cacheKey(), jsonEncode(value.toJson()));
      cvfList.addAll(value.responseData);
      _sortByDate();
    }
  }

  Future<void> _fetchPjpCvf() async {
    cvfList.clear();
    final request = PJPListRequest(
      Employee_id: employeeId,
      PJP_id: int.parse(pjpInfo!.PJP_Id),
      Business_id: businessId,
    );
    final value = await APIService().getPJPList(request);
    if (value is PjpListResponse && value.responseData.isNotEmpty) {
      await _applyPjpResponse(value);
    }
  }

  Future<void> _applyPjpResponse(PjpListResponse response) async {
    hiveBox.put(_cacheKey(), jsonEncode(response));
    cvfList.clear();
    final helper = DBHelper();
    for (final item in response.responseData) {
      cvfList.addAll(item.getDetailedPJP ?? []);
      for (final cvf in item.getDetailedPJP ?? []) {
        await helper.deleteCheckInStatus(cvf.PJPCVF_Id);
      }
    }
    offlineStatus.assignAll(await helper.getCheckInStatus());
  }

  void _sortByDate() {
    cvfList.sort(
      (a, b) =>
          DateTime.parse(a.visitDate).compareTo(DateTime.parse(b.visitDate)),
    );
  }

  List<GetDetailedPJP> get filteredList {
    final list = cvfList.toList();
    switch (filter.value) {
      case CvfFilter.completed:
        return list
            .where((c) => c.Status == 'Completed')
            .toList()
            .reversed
            .toList();
      case CvfFilter.cancelled:
        return list
            .where((c) => c.IsCancelled == true)
            .toList()
            .reversed
            .toList();
      case CvfFilter.checkIn:
        return list
            .where((c) =>
                c.approvalStatus.toLowerCase().contains('appro') &&
                !c.IsCancelled &&
                c.Status.trim() == 'Check In')
            .toList()
            .reversed
            .toList();
      case CvfFilter.fillCvf:
        return list
            .where((c) => !c.IsCancelled && c.Status == 'FILL CVF')
            .toList()
            .reversed
            .toList();
      case CvfFilter.all:
        return list.reversed.toList();
    }
  }

  GetDetailedPJP normalizeCvf(GetDetailedPJP cvf) {
    if (cvf.Status.trim() == 'NA') cvf.Status = 'Check In';
    if (offlineStatus.containsKey(cvf.PJPCVF_Id)) {
      cvf.Status = offlineStatus[cvf.PJPCVF_Id]!;
      if (offlineStatus.containsKey('date')) {
        cvf.DateTimeIn = offlineStatus['date']!;
      }
    }
    return cvf;
  }

  bool isApproved(GetDetailedPJP cvf) {
    if (isPjpMode) {
      return pjpInfo!.ApprovalStatus.toLowerCase().contains('approv');
    }
    return cvf.approvalStatus.toLowerCase().contains('approv');
  }

  bool isRejected(GetDetailedPJP cvf) {
    if (isPjpMode) {
      return pjpInfo!.ApprovalStatus == 'Rejected';
    }
    return cvf.approvalStatus.toLowerCase().contains('reject');
  }

  bool isCancelled(GetDetailedPJP cvf) =>
      cvf.IsCancelled || cvf.Status == 'Cancelled';

  bool isCompleted(GetDetailedPJP cvf) => cvf.Status == 'Completed';

  bool canManageVisit(GetDetailedPJP cvf) {
    if (isViewOnly) return false; 
    if (isPjpMode && pjpInfo!.isSelfPJP == '0') return false;
    return !isCancelled(cvf);
  }

  bool canRescheduleOrCancel(GetDetailedPJP cvf) {
    //print('canRescheduleOrCancel: ${cvf.PJPCVF_Id} ${cvf.Status}, ${cvf.approvalStatus}');
    if (!canManageVisit(cvf)) return false;
    //if (!isApproved(cvf)) return false;
    if (cvf.approvalStatus == 'Rejected') return false;
    return cvf.Status == 'FILL CVF' ||
        cvf.Status == 'Check In' ||
        cvf.Status == 'NA';
  }

  Future<void> generateReportEmailBody(
    BuildContext context,
    GetDetailedPJP cvf,
  ) async {
    if (!isCompleted(cvf)) {
      Utility.showMessage(
        context,
        'Share Report is available only after check-out.',
      );
      return;
    }

    var facilitator = '';
    var facilitatorEmail = '';
    try {
      final first = (hiveBox.get(LocalConstant.KEY_FIRST_NAME) ?? '').toString();
      final last = (hiveBox.get(LocalConstant.KEY_LAST_NAME) ?? '').toString();
      facilitator = '$first $last'.trim();
      if (facilitator.isEmpty) {
        facilitator =
            (hiveBox.get(LocalConstant.KEY_USER_NAME) ?? '').toString();
      }
      facilitatorEmail =
          (hiveBox.get(LocalConstant.KEY_EMAIL) ?? '').toString().trim();
    } catch (_) {}

    // To/CC are static in the share UI (masked). Prefer franchisee/BP email
    // when available on the visit payload; otherwise leave empty for backend.
    final bpEmail = ''; // populate when franchisee email is available on CVF
    final cc = <String>[
      if (facilitatorEmail.isNotEmpty) facilitatorEmail,
    ];

    await ShareReportPage.open(
      ShareReportArgs(
        cvf: cvf,
        pjp: pjpInfo ??
            (currentPJP.isNotEmpty ? currentPJP.first : null),
        facilitatorName: facilitator,
        bpEmail: 'sudhir.patil@zeelearn.com',
        ccEmails: ['hemant.jathar@zeelearn.com'], //cc,
      ),
    );
  }

  openWebsiteReport(BuildContext context, GetDetailedPJP cvf) {
    final url = LocalStrings.CVF_REPORT_URL + cvf.PJPCVF_Id;
    if (url.isEmpty) {
      Utility.showMessage(context, 'Report URL not available');
      return;
    }
    if (kIsWeb) {
      launchUrl(
        Uri.parse(url),
        mode: LaunchMode.platformDefault,
      );
    } else {
      Get.to(() => CVFReportWebView(url: url));
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => MyWebsiteView(
    //       url: url,
    //       title: 'CVF Report',
    //     ),
    //   ),
    // );
    //Utility.openUrl(context, url);
  }

  /// Reschedule is hidden when today is past the PJP end date or no valid dates remain.
  bool canReschedule(GetDetailedPJP cvf) {
    if (!canRescheduleOrCancel(cvf)) return false;

    final today = _dateOnly(DateTime.now());
    final pjpEnd = _pjpRangeEnd(cvf);
    if (pjpEnd != null && today.isAfter(pjpEnd)) return false;

    final minDate = _rescheduleMinDate(cvf);
    final maxDate = _rescheduleMaxDate(cvf);
    if (maxDate != null && minDate.isAfter(maxDate)) return false;

    return true;
  }

  /// Left accent bar color — pending, approved, rejected, cancelled, etc.
  Color statusBarColor(GetDetailedPJP cvf) {
    if (isCancelled(cvf)) return CvfStatusColor.cancelled;
    if (isRejected(cvf)) return CvfStatusColor.rejected;
    if (!isApproved(cvf)) return CvfStatusColor.pending;

    final status = cvf.Status.trim();
    if (status == 'Completed') return CvfStatusColor.completed;
    if (status == 'FILL CVF') return CvfStatusColor.inProgress;
    if (status == 'Check Out') return CvfStatusColor.inProgress;
    if (status == 'Check In' || status == 'NA') return CvfStatusColor.approved;
    return CvfStatusColor.neutral;
  }

  String statusLabel(GetDetailedPJP cvf) {
    if (isCancelled(cvf)) return 'Cancelled';
    if (isRejected(cvf)) return 'Rejected';
    if (!isApproved(cvf)) return 'Pending Approval';
    final status = cvf.Status.trim();
    if (status == 'Completed') return 'Completed';
    if (status == 'FILL CVF') return 'Fill CVF';
    if (status == 'Check Out') return 'Check Out';
    if (status == 'Check In' || status == 'NA') return 'Approved';
    return status;
  }

  void onCvfTap(BuildContext context, GetDetailedPJP cvf) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyCVF_Tap');
    if (isCancelled(cvf)) {
      Utility.showMessage(context, 'This CVF is cancelled');
      return;
    }
    if (isRejected(cvf)) {
      Utility.showMessage(context, 'This PJP is rejected by your manager');
      return;
    }
    if (!isApproved(cvf) &&
        (cvf.Status == 'Check In' ||
            cvf.Status == ' Check In' ||
            cvf.Status == 'NA')) {
      if (isPjpMode) {
        Utility.showMessageSingleButton(
          context,
          'This pjp is not approved yet, Please connect with your manager',
          _DismissListener(),
        );
      } else {
        Utility.showMessage(
          context,
          'PJP not yet approve, Please connect with your manager',
        );
      }
      return;
    }
    if (isPjpMode && pjpInfo!.isSelfPJP == '0') {
      selectCategory(context, cvf);
      return;
    }
    if (cvf.Status == 'Check In' ||
        cvf.Status == ' Check In' ||
        cvf.Status == 'NA') {
      _showCheckInConfirmation(context, cvf);
      return;
    }
    selectCategory(context, cvf);
  }

  void _showCheckInConfirmation(BuildContext context, GetDetailedPJP cvf) {
    Utility.onConfirmationBox(
      context,
      'Check In',
      'Cancel',
      'PJP Status Update?',
      'Would you like to Check In?',
      cvf,
      _CheckInListener(this, cvf),
    );
  }

  Future<void> checkIn(GetDetailedPJP cvf) async {
    // print('checkIn called from cvf_controller.dart for PJPCVF_Id: ${cvf.PJPCVF_Id}, Current Status: ${cvf.Status}');
    final context = Get.context;
    if (!_isMounted(context)) return;

    final hasInternet = await Utility.isInternet();
    if (!hasInternet) {
      if (_isMounted(context)) await _saveOffline(context!, cvf);
      return;
    }

    isUpdating.value = true;
    Utility.showLoaderDialog(context!);
    try {
      await _updateCvfStatusOnline(cvf);
      Navigator.of(context).pop(); // Dismiss loader dialog
      isUpdating.value = false;
      if (_isMounted(context)) {
        Utility.onSuccessMessage(
          context,
          'Status Updated',
          'Thanks for updating the CVF status',
          _ReloadListener(this),
        );
        await loadData();
      }
    } catch (e) {
      if (_isMounted(context)) {
        Utility.showMessage(context, 'Unable to update the status');
      }
    } finally {
      isUpdating.value = false;
      if (_isMounted(context) && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _updateCvfStatusOnline(GetDetailedPJP cvf) async {
    final nextStatus = _nextStatus(cvf.Status);
    final completer = Completer<void>();
    // print('Updating CVF Status Online _updateCvfStatusOnline for PJPCVF_Id: ${cvf.PJPCVF_Id}, Current Status: ${cvf.Status}, Next Status: $nextStatus');
    IntranetServiceHandler.updateCVFStatus(
      employeeId,
      cvf,
      Utility.getDateTime(),
      nextStatus,
      _ServiceCallback(
        onSuccessCallback: (_) => completer.complete(),
        onErrorCallback: (msg) => completer.completeError(msg),
      ),
    );
    await completer.future;
  }

  Future<void> _saveOffline(BuildContext context, GetDetailedPJP cvf) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Internet not avaliable'),
        content: const Text('Would you like to save CVF Offline'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
        ],
      ),
    );
    if (confirmed != true || !_isMounted(context)) return;

    final location = await LocationHelper.getLocation(context);
    if (!_isMounted(context)) return;
    final address = '';
    final request = UpdateCVFStatusRequest(
      PJPCVF_id: cvf.PJPCVF_Id,
      DateTime: Utility.getDateTime(),
      Status: cvf.Status,
      Employee_id: employeeId,
      Latitude:
          cvf.Status != 'FILL CVF' ? cvf.Latitude : location?.latitude ?? 0.0,
      Longitude:
          cvf.Status != 'FILL CVF' ? cvf.Longitude : location?.longitude ?? 0.0,
      Address: address,
      CheckOutLatitude:
          cvf.Status == 'FILL CVF' ? location?.latitude ?? 0.0 : 0.0,
      CheckOutLongitude:
          cvf.Status == 'FILL CVF' ? location?.longitude ?? 0.0 : 0.0,
      CheckOutAddress: cvf.Status == 'FILL CVF' ? address : '',
    );

    final helper = DBHelper();
    await helper.insertCheckIn(
      cvf.PJPCVF_Id,
      jsonEncode(request.toJson()),
      _nextStatus(cvf.Status),
      0,
    );
    offlineStatus.assignAll(await helper.getCheckInStatus());
    if (!_loadFromCache()) await loadData();
    if (_isMounted(context)) {
      Utility.onSuccessMessage(
        context,
        'Status Updated',
        'Thanks for updating the CVF status',
        _ReloadListener(this),
      );
    }
  }

  String _nextStatus(String key) {
    switch (key.trim()) {
      case 'Check In':
      case 'NA':
        return 'FILL CVF';
      case 'FILL CVF':
        return 'Completed';
      case 'Completed':
        return 'Check Out';
      default:
        return 'FILL CVF';
    }
  }

  void selectCategory(BuildContext context, GetDetailedPJP cvf) {
    if (cvf.purpose == null || cvf.purpose!.isEmpty) {
      Utility.showMessageSingleButton(
        context,
        'Category Not mapped for this CVF, Please create another CVF',
        _DismissListener(),
      );
      return;
    }
    if (cvf.purpose!.length == 1) {
      navigateQuestions(context, cvf, cvf.purpose![0].categoryId,
          cvf.purpose![0].categoryName);
      return;
    }
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: cvf.purpose!.length + 1,
        shrinkWrap: true,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Container(
              color: CvfStatusColor.accent,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
          final purpose = cvf.purpose![index - 1];
          return ListTile(
            title: Text(purpose.categoryName),
            onTap: () {
              Navigator.pop(ctx);
              navigateQuestions(
                  context, cvf, purpose.categoryId, purpose.categoryName);
            },
          );
        },
      ),
    );
  }

  void navigateQuestions(
    BuildContext context,
    GetDetailedPJP cvf,
    String categoryId,
    String categoryName,
  ) {
    final viewOnly = isPjpMode && pjpInfo!.isSelfPJP == '0';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionListScreen(
          cvfView: cvf,
          PJPCVF_Id: int.parse(cvf.PJPCVF_Id),
          employeeId: employeeId,
          mCategory: categoryName,
          mCategoryId: categoryId,
          isViewOnly: viewOnly,
        ),
      ),
    );
  }

  void onCategoryTap(BuildContext context, GetDetailedPJP cvf) {
    if (cvf.IsCancelled || cvf.Status == 'Cancelled') {
      Utility.showMessage(context, 'This CVF is cancelled');
    } else if (cvf.Status == 'Check In' ||
        cvf.Status == ' Check In' ||
        cvf.Status == 'NA') {
      Utility.showMessage(context, 'Please Click on Check In button');
    } else {
      selectCategory(context, cvf);
    }
  }

  Future<void> navigateToAddCvf(BuildContext context) async {
    if (!showAddCvf) return;
    if (!canAddCvf || pjpInfo == null) {
      Utility.showMessage(
        context,
        'Please open a PJP from My PJP to add a new CVF',
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCVFScreen(mPjpModel: pjpInfo!)),
    );
    await loadData();
  }

  void showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _filterTile(ctx, CvfFilter.all, Icons.select_all, 'All'),
          _filterTile(ctx, CvfFilter.completed, Icons.check, 'Completed'),
          _filterTile(ctx, CvfFilter.checkIn, Icons.login, 'Check In'),
          _filterTile(
              ctx, CvfFilter.fillCvf, Icons.pending_actions, 'FILL CVF'),
          _filterTile(ctx, CvfFilter.cancelled, Icons.cancel, 'Cancelled'),
        ],
      ),
    );
  }

  Widget _filterTile(
      BuildContext ctx, CvfFilter value, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: filter.value == value
          ? const Icon(Icons.check, color: kPrimaryLightColor)
          : null,
      onTap: () {
        filter.value = value;
        Navigator.pop(ctx);
      },
    );
  }

  void showActionSheet(BuildContext context, GetDetailedPJP cvf) {
    final hasMap = hasLocation(cvf);
    final canRescheduleVisit = canReschedule(cvf);
    final canCancelVisit = canRescheduleOrCancel(cvf);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasMap)
              ListTile(
                leading: const Icon(Icons.map, color: CvfStatusColor.accent),
                title: const Text('View on Map'),
                onTap: () {
                  Navigator.pop(ctx);
                  openLocationMap(context, cvf);
                },
              ),
            if (canRescheduleVisit)
              ListTile(
                leading: const Icon(Icons.edit_calendar,
                    color: CvfStatusColor.accent),
                title: const Text('Reschedule'),
                onTap: () {
                  Navigator.pop(ctx);
                  showRescheduleDialog(context, cvf,null);
                },
              ),
            if (canCancelVisit)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel CVF'),
                onTap: () {
                  Navigator.pop(ctx);
                  showCancelDialog(context, cvf,null);
                },
              ),
          ],
        ),
      ),
    );
  }

  bool hasLocation(GetDetailedPJP cvf) =>
      (cvf.Latitude != 0 || cvf.Longitude != 0) ||
      (cvf.LatitudeIn != 0 || cvf.LongitudeIn != 0) ||
      (cvf.LatitudeOut != 0 || cvf.LongitudeOut != 0);

  bool showCardActions(GetDetailedPJP cvf) {
    if (isViewOnly || (isPjpMode && pjpInfo!.isSelfPJP == '0')) return false;
    return hasLocation(cvf) || canReschedule(cvf) || canRescheduleOrCancel(cvf);
  }

  void showCancelDialog(BuildContext context, GetDetailedPJP cvf,Function(GetDetailedPJP)? onVisitUpdated) {
    final remarkController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CvfDialogHeader(
                title: 'Cancel CVF',
                icon: Icons.cancel_outlined,
                headerColor: const Color(0xFFD32F2F),
                cvf: cvf,
                visitDateTimeLabel: _cvfVisitDateTimeLabel(cvf),
                description: _cvfDescription(cvf),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to cancel this visit?',
                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Cancellation reason',
                        hintText: 'Enter mandatory reason',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep CVF'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (remarkController.text.trim().isEmpty) {
                          Utility.showMessage(
                              context, 'Please enter a cancellation reason');
                          return;
                        }
                        Navigator.pop(ctx);
                        cancelCvf(cvf, remarkController.text.trim(),onVisitUpdated);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Cancel CVF'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancelCvf(GetDetailedPJP cvf, String remark,Function(GetDetailedPJP)? onVisitUpdated) async {
    final context = Get.context;
    if (!_isMounted(context)) return;
    Utility.showLoaderDialog(context!);
    try {
      final docXml = _buildDocXml(cvf, remark);
      final pjpId =
          isPjpMode ? int.parse(pjpInfo!.PJP_Id) : int.parse(cvf.PJP_Id ?? '0');
      final response =
          await APIService().cancelCVF(pjpId, docXml, employeeId, true);
      if (_isMounted(context) && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!_isMounted(context)) return;
      if (response != null) {
        cvf.IsCancelled=true;
        cvf.remarks = remark;
        debugPrint('IsCancelled ${cvf.toJson()}');
        debugPrint('isCancell ${cvf.IsCancelled}');
        if(onVisitUpdated!=null){
          debugPrint('isCancelling --- ${cvf.IsCancelled}');
          onVisitUpdated!(cvf);
        }
        Utility.showMessage(context, 'CVF Cancelled successfully');
        await loadData();
        
      } else {
        Utility.showMessage(context, 'Failed to cancel CVF');
      }
    } catch (_) {
      if (_isMounted(context)) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Utility.showMessage(context, 'Failed to cancel CVF');
      }
    }
  }

  String _cvfDescription(GetDetailedPJP cvf) {
    if (cvf.ActivityTitle.isNotEmpty && cvf.ActivityTitle != 'NA') {
      return cvf.ActivityTitle;
    }
    if (cvf.Address.isNotEmpty &&
        cvf.Address != 'NA' &&
        cvf.Address != 'Search Location') {
      return cvf.Address;
    }
    return cvf.franchiseeCode;
  }

  String _cvfVisitDateTimeLabel(GetDetailedPJP cvf) {
    final date = Utility.shortDate(Utility.convertDate(cvf.visitDate));
    final time = Utility.convertTime(cvf.visitTime);
    return '$date  ${DateFormat('hh:mm a').format(time)}';
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _currentVisitDate(GetDetailedPJP cvf) =>
      _dateOnly(Utility.convertDate(cvf.visitDate));

  DateTime? _pjpRangeStart(GetDetailedPJP cvf) {
    final from = isPjpMode ? pjpInfo!.fromDate : (cvf.pjpFromDate ?? '');
    if (from.isEmpty || from == 'NA') return null;
    return _dateOnly(Utility.convertDate(from));
  }

  DateTime? _pjpRangeEnd(GetDetailedPJP cvf) {
    final to = isPjpMode ? pjpInfo!.toDate : (cvf.pjpToDate ?? '');
    if (to.isEmpty || to == 'NA') return null;
    return _dateOnly(Utility.convertDate(to));
  }

  /// Earliest allowed reschedule date: today or PJP start, whichever is later.
  DateTime _rescheduleMinDate(GetDetailedPJP cvf) {
    final today = _dateOnly(DateTime.now());
    final pjpStart = _pjpRangeStart(cvf);
    if (pjpStart == null) return today;
    return pjpStart.isAfter(today) ? pjpStart : today;
  }

  DateTime? _rescheduleMaxDate(GetDetailedPJP cvf) => _pjpRangeEnd(cvf);

  TimeOfDay _currentVisitTime(GetDetailedPJP cvf) {
    final time = Utility.convertTime(cvf.visitTime);
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  bool _isSameVisitDateTime(
    GetDetailedPJP cvf,
    DateTime date,
    TimeOfDay time,
  ) {
    if (_dateOnly(date) != _currentVisitDate(cvf)) return false;
    final current = _currentVisitTime(cvf);
    return time.hour == current.hour && time.minute == current.minute;
  }

  DateTime _suggestedRescheduleDate(GetDetailedPJP cvf) {
    final min = _rescheduleMinDate(cvf);
    final max = _rescheduleMaxDate(cvf);
    final current = _currentVisitDate(cvf);
    if (!current.isBefore(min) && (max == null || !current.isAfter(max))) {
      return current;
    }
    return _clampDate(min, min, max);
  }

  String? _validateRescheduleSelection(
    GetDetailedPJP cvf,
    DateTime newDate,
    TimeOfDay newTime,
  ) {
    if (_isSameVisitDateTime(cvf, newDate, newTime)) {
      return 'Please select a different date or time from the current visit';
    }

    final selected = _dateOnly(newDate);
    final min = _rescheduleMinDate(cvf);
    final max = _rescheduleMaxDate(cvf);

    if (selected.isBefore(min)) {
      final rangeEnd =
          max != null ? DateFormat('dd-MMM-yyyy').format(max) : 'end of PJP';
      return 'Reschedule date must be today or later within the PJP period '
          '(${DateFormat('dd-MMM-yyyy').format(min)} – $rangeEnd)';
    }

    if (max != null && selected.isAfter(max)) {
      return 'Reschedule date must be within the PJP date range '
          '(until ${DateFormat('dd-MMM-yyyy').format(max)})';
    }

    return null;
  }

  void showRescheduleDialog(BuildContext context, GetDetailedPJP cvf,Function(GetDetailedPJP)? onVisitUpdated) {
    if (!isPjpMode && !cvf.hasPjpRange) {
      Utility.showMessage(
          context, 'Cannot reschedule: PJP range not available.');
      return;
    }

    final minDate = _rescheduleMinDate(cvf);
    final maxDate = _rescheduleMaxDate(cvf);
    if (maxDate != null && minDate.isAfter(maxDate)) {
      Utility.showMessage(
        context,
        'No available dates within the PJP period to reschedule.',
      );
      return;
    }

    DateTime selectedDate = _clampDate(
      _suggestedRescheduleDate(cvf),
      minDate,
      maxDate ?? DateTime(2101),
    );
    final visitTimeDt = Utility.convertTime(cvf.visitTime);
    TimeOfDay selectedTime = _currentVisitTime(cvf);

    final remarkController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('dd-MMM-yyyy').format(selectedDate),
    );
    final timeController = TextEditingController(
      text: DateFormat('hh:mm a').format(visitTimeDt),
    );

    final firstDate = minDate;
    final lastDate = maxDate ?? DateTime(2101);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CvfDialogHeader(
                  title: 'Reschedule CVF',
                  icon: Icons.edit_calendar,
                  headerColor: kPrimaryLightColor,
                  cvf: cvf,
                  visitDateTimeLabel: _cvfVisitDateTimeLabel(cvf),
                  description: _cvfDescription(cvf),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a new date and time for this visit.',
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                        ),
                        if (maxDate != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: kPrimaryLightColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    kPrimaryLightColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 18, color: kPrimaryLightColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Allowed: ${DateFormat('dd-MMM-yyyy').format(firstDate)}'
                                    ' – ${DateFormat('dd-MMM-yyyy').format(lastDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kPrimaryLightColor.withValues(
                                          alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'New visit date',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon:
                                const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: kPrimaryLightColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate:
                                  _clampDate(selectedDate, firstDate, lastDate),
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                                dateController.text = DateFormat('dd-MMM-yyyy')
                                    .format(selectedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: timeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'New visit time',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: kPrimaryLightColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              if (_isSameVisitDateTime(
                                  cvf, selectedDate, picked)) {
                                Utility.showMessage(
                                  ctx,
                                  'Please select a different time from the current visit',
                                );
                                return;
                              }
                              setDialogState(() {
                                selectedTime = picked;
                                final dt = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                timeController.text =
                                    DateFormat('hh:mm a').format(dt);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: remarkController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Reason for rescheduling',
                            hintText: 'Enter mandatory reason',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: kPrimaryLightColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimaryLightColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (remarkController.text.trim().isEmpty) {
                            Utility.showMessage(context,
                                'Please enter a reason for rescheduling');
                            return;
                          }
                          final validationError = _validateRescheduleSelection(
                            cvf,
                            selectedDate,
                            selectedTime,
                          );
                          if (validationError != null) {
                            Utility.showMessage(context, validationError);
                            return;
                          }
                          Navigator.pop(ctx);
                          rescheduleCvf(
                            cvf,
                            selectedDate,
                            selectedTime,
                            remarkController.text.trim(),onVisitUpdated
                          );
                        },
                        icon: const Icon(Icons.event_repeat, size: 18),
                        label: const Text('Reschedule'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _clampDate(DateTime selected, DateTime? first, DateTime? last) {
    if (first != null && selected.isBefore(first)) return first;
    if (last != null && selected.isAfter(last)) return last;
    return selected;
  }

  Future<void> rescheduleCvf(
    GetDetailedPJP cvf,
    DateTime newDate,
    TimeOfDay newTime,
    String remark,
    Function(GetDetailedPJP)? onVisitUpdated
  ) async {
    final context = Get.context;
    if (!_isMounted(context)) return;

    final validationError = _validateRescheduleSelection(cvf, newDate, newTime);
    if (validationError != null) {
      Utility.showMessage(context!, validationError);
      return;
    }

    Utility.showLoaderDialog(context!);
    try {
      final visitDateFormatted = Utility.convertShortDate(newDate);
      final visitTimeFormatted = '${newTime.hour}:${newTime.minute}';
      final docXml = _buildDocXml(
        cvf,
        remark,
        visitDate: visitDateFormatted,
        visitTime: visitTimeFormatted,
      );
      final pjpId =
          isPjpMode ? int.parse(pjpInfo!.PJP_Id) : int.parse(cvf.PJP_Id ?? '0');
      final response =
          await APIService().cancelCVF(pjpId, docXml, employeeId, false);
      if (_isMounted(context) && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!_isMounted(context)) return;
      if (response != null) {
        if(onVisitUpdated!=null){
          if(cvf.cvfHistory ==null || cvf.cvfHistory!.isEmpty) {
            cvf.cvfHistory = [];
          }
          cvf.cvfHistory!.add(CVFHistory(visitDate: cvf.visitDate, visitTime: cvf.visitTime, franchiseeId: cvf.franchiseeId, franchiseeCode: cvf.franchiseeCode, franchiseeName: cvf.franchiseeName, latitude: '${cvf.Latitude}', longitude: '${cvf.Longitude}', address: cvf.Address, remarks: remark));
          cvf.visitDate = visitDateFormatted;
          cvf.visitTime = visitTimeFormatted;
          debugPrint('rescheduling ${cvf.toJson()}');
          onVisitUpdated!(cvf);
        }
        Utility.showMessage(context, 'CVF Rescheduled successfully');
        await loadData();
      } else {
        Utility.showMessage(context, 'Failed to reschedule CVF');
      }
    } catch (_) {
      if (_isMounted(context)) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Utility.showMessage(context, 'Failed to reschedule CVF');
      }
    }
  }

  String _buildDocXml(
    GetDetailedPJP cvf,
    String remark, {
    String? visitDate,
    String? visitTime,
  }) {
    final categoryId = cvf.purpose != null && cvf.purpose!.isNotEmpty
        ? cvf.purpose![0].categoryId
        : '0';
    return '<root><tblPJPCVF>'
        '<CVF_Id>${cvf.PJPCVF_Id}</CVF_Id>'
        '<Business_Id>$businessId</Business_Id>'
        '<Employee_Id>$employeeId</Employee_Id>'
        '<Franchisee_Id>${cvf.franchiseeId}</Franchisee_Id>'
        '<Visit_Date>${visitDate ?? cvf.visitDate}</Visit_Date>'
        '<Visit_Time>${visitTime ?? cvf.visitTime}</Visit_Time>'
        '<Category_Id>$categoryId</Category_Id>'
        '<Latitude>${cvf.Latitude}</Latitude>'
        '<Longitude>${cvf.Longitude}</Longitude>'
        '<ActivityTitle>${cvf.ActivityTitle}</ActivityTitle>'
        '<Address>${cvf.Address}</Address>'
        '<Remarks>$remark</Remarks>'
        '</tblPJPCVF></root>';
  }

  void openLocationMap(BuildContext context, GetDetailedPJP cvf) {
    openCvfLocationMap(context, cvf);
  }
}

class _CheckInListener implements onClickListener {
  _CheckInListener(this.controller, this.cvf);
  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  void onClick(int action, value) {
    final context = Get.context;
    if (!CVFController.isContextMounted(context)) return;
    if (action == Utility.ACTION_OK) {
      Navigator.of(context!).pop();
      controller.checkIn(cvf);
    } else if (action == Utility.ACTION_CCNCEL) {
      Navigator.of(context!).pop();
    }
  }
}

class _ReloadListener implements onResponse {
  _ReloadListener(this.controller);
  final CVFController controller;

  @override
  void onError(value) {}

  @override
  void onStart() {}

  @override
  void onSuccess(value) => controller.loadData();
}

class _DismissListener implements onClickListener {
  @override
  void onClick(int action, value) {}
}

class _ServiceCallback implements onResponse {
  _ServiceCallback(
      {required this.onSuccessCallback, required this.onErrorCallback});
  final void Function(dynamic) onSuccessCallback;
  final void Function(String) onErrorCallback;

  @override
  void onError(value) => onErrorCallback(value?.toString() ?? 'Error');

  @override
  void onStart() {}

  @override
  void onSuccess(value) => onSuccessCallback(value);
}

class _CvfDialogHeader extends StatelessWidget {
  const _CvfDialogHeader({
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.cvf,
    required this.visitDateTimeLabel,
    required this.description,
  });

  final String title;
  final IconData icon;
  final Color headerColor;
  final GetDetailedPJP cvf;
  final String visitDateTimeLabel;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CvfDialogDetailRow(
            icon: Icons.storefront_outlined,
            label: 'Franchisee',
            value: cvf.franchiseeName,
          ),
          const SizedBox(height: 8),
          _CvfDialogDetailRow(
            icon: Icons.description_outlined,
            label: 'Description',
            value: description,
          ),
          const SizedBox(height: 8),
          _CvfDialogDetailRow(
            icon: Icons.event_outlined,
            label: 'CVF Date',
            value: visitDateTimeLabel,
          ),
          const SizedBox(height: 8),
          _CvfDialogDetailRow(
            icon: Icons.tag_outlined,
            label: 'Ref Id',
            value: cvf.PJPCVF_Id,
          ),
        ],
      ),
    );
  }
}

class _CvfDialogDetailRow extends StatelessWidget {
  const _CvfDialogDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
