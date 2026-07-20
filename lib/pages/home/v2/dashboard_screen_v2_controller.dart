import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/projects_entry_args.dart';
import 'package:Intranet/modules/projects/views/projects_dashboard_page.dart';
import 'package:Intranet/pages/bpms/bpms_dashboard.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/helper/web_helper.dart';
import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:Intranet/pages/intro/intro.dart';
import 'package:Intranet/pages/legal_mis/all_legal_status_page.dart';
import 'package:Intranet/pages/model/filter.dart';
import 'package:Intranet/pages/pjp/cvf/v2/cvf.dart';
import 'package:Intranet/pages/pjp/mypjp.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager_exceptional.dart';
import 'package:Intranet/pages/report/myreport.dart';
import 'package:Intranet/pages/summary%20dashboard/summary_dashboard.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:expensestracker/app/hiveDatabase/hive_database.dart';
import 'package:expensestracker/presentation/app.dart' as expense_placeholder;
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_binding.dart';
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:saathi/zllsaathi.dart';

class DashboardScreenV2Controller extends GetxController {
  DashboardScreenV2Controller({
    required this.userId,
    this.receivedAction,
  });

  static const double kWideBreakpoint = 1000;

  final String userId;
  final ReceivedAction? receivedAction;

  final userFullName = ''.obs;
  final firstName = ''.obs;
  final userName = ''.obs;
  final employeeId = 0.obs;
  final employeeCode = ''.obs;
  final designation = ''.obs;
  final email = ''.obs;

  final businessId = 0.obs;
  final businessName = ''.obs;
  final businessApplications = <BusinessApplications>[].obs;
  final isBpms = false.obs;

  final profileImageUrl =
      'https://cdn-icons-png.flaticon.com/128/149/149071.png'.obs;
  final profileAvatarBytes = Rxn<Uint8List>();

  final appVersion = ''.obs;
  final sidebarExpanded = true.obs;
  final selectedNav = 'dashboard'.obs;
  final notificationCount = 0.obs;
  final isLoading = false.obs;
  final dateRangeLabel = 'May 20 – May 26, 2024'.obs;

  final kpiStats = <DashKpiStat>[].obs;
  final projectStatusSegments = <DashChartSegment>[].obs;
  final recentActivities = <DashActivityItem>[].obs;
  final upcomingReminders = <DashReminderItem>[].obs;

  static const _businessGuardedMenus = {
    'my_pjp',
    'my_cvf',
    'pjp_cvf_approval_exp',
    'zll_saathi',
    'pjp_dashboard',
    'approvals_pjp',
  };

  bool get isBusinessMapped => businessId.value != 0;

  List<DashQuickAccessItem> get quickAccessItems =>
      DashV2MenuCatalog.visibleQuickAccess(
        isBpms: isBpms.value,
        employeeCode: employeeCode.value,
      );

  @override
  void onInit() {
    super.onInit();
    seedPlaceholders();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    try {
      await loadUserFromHive();
      await loadBusinessApplications();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserFromHive() async {
    try {
      final box = await Utility.openBox();
      employeeId.value = int.tryParse(
              box.get(LocalConstant.KEY_EMPLOYEE_ID)?.toString() ?? '') ??
          0;
      employeeCode.value =
          box.get(LocalConstant.KEY_EMPLOYEE_CODE)?.toString() ?? '';
      firstName.value = box.get(LocalConstant.KEY_FIRST_NAME)?.toString() ?? '';
      final lastName = box.get(LocalConstant.KEY_LAST_NAME)?.toString() ?? '';
      userFullName.value = '${firstName.value} $lastName'.trim();
      userName.value = box.get(LocalConstant.KEY_USER_NAME)?.toString() ?? '';
      designation.value =
          box.get(LocalConstant.KEY_DESIGNATION)?.toString() ?? '';
      email.value = box.get(LocalConstant.KEY_EMAIL)?.toString() ?? '';
      businessId.value = int.tryParse(
              box.get(LocalConstant.KEY_BUSINESS_ID)?.toString() ?? '') ??
          0;
      businessName.value =
          box.get(LocalConstant.KEY_BUSINESS_NAME)?.toString() ?? '';
      isBpms.value = box.containsKey(LocalConstant.KEY_FRANCHISEE_ID);

      final imageUrl = box.get(LocalConstant.KEY_EMPLOYEE_AVTAR)?.toString();
      final gender = box.get(LocalConstant.KEY_GENDER)?.toString() ?? '';
      profileImageUrl.value = imageUrl?.isNotEmpty == true
          ? imageUrl!
          : gender == 'Male'
              ? 'https://cdn-icons-png.flaticon.com/128/149/149071.png'
              : 'https://cdn-icons-png.flaticon.com/128/727/727393.png';

      final encodedAvatar =
          box.get(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST)?.toString();
      if (encodedAvatar?.isNotEmpty == true) {
        profileAvatarBytes.value = base64.decode(encodedAvatar!);
      }
    } catch (error) {
      debugPrint('Dashboard V2 user load failed: $error');
    }
  }

  Future<void> loadBusinessApplications() async {
    if (!Get.isRegistered<DashboardPageController>()) {
      DashboardBinding().dependencies();
    }

    try {
      final box = await Utility.openBox();
      final loginResponse =
          box.get(LocalConstant.KEY_LOGIN_RESPONSE)?.toString() ?? '';
      if (loginResponse.isEmpty) return;

      final response = LoginResponseModel.fromJson(
        json.decode(loginResponse) as Map<String, dynamic>,
      );
      businessApplications.assignAll(
        response.responseData.businessApplications,
      );

      if (businessName.value.isEmpty && businessApplications.isNotEmpty) {
        final business = businessApplications.first;
        await updateCurrentBusiness(
          business.businessID,
          business.businessName,
          business.business_UserID,
        );
      }
    } catch (error) {
      debugPrint('Dashboard V2 business load failed: $error');
    }
  }

  void seedPlaceholders() {
    // PLACEHOLDER until KPI APIs exist
    kpiStats.assignAll(const [
      DashKpiStat(
        label: 'My PJP',
        value: '24',
        icon: Icons.electric_car,
        color: DashV2Colors.blue,
        progress: 0.75,
      ),
      DashKpiStat(
        label: 'My CVF',
        value: '12',
        icon: Icons.calendar_today,
        color: DashV2Colors.green,
        progress: 0.60,
      ),
      DashKpiStat(
        label: 'Pending',
        value: '05',
        icon: Icons.pending_actions,
        color: DashV2Colors.amber,
        progress: 0.25,
      ),
      DashKpiStat(
        label: 'Approved',
        value: '18',
        icon: Icons.check_circle_outline,
        color: DashV2Colors.purple,
        progress: 0.80,
      ),
    ]);
    projectStatusSegments.assignAll(const [
      DashChartSegment(
        label: 'Confirmed',
        value: 35,
        color: DashV2Colors.blue,
      ),
      DashChartSegment(
        label: 'Pending',
        value: 25,
        color: DashV2Colors.amber,
      ),
      DashChartSegment(
        label: 'Rejected',
        value: 15,
        color: DashV2Colors.red,
      ),
      DashChartSegment(
        label: 'Refund',
        value: 10,
        color: DashV2Colors.purple,
      ),
      DashChartSegment(
        label: 'Not Interested',
        value: 15,
        color: DashV2Colors.teal,
      ),
    ]);
    recentActivities.assignAll(const [
      DashActivityItem(
        title: 'PJP plan submitted',
        subtitle: 'July travel plan',
        timeAgo: '10 min ago',
        icon: Icons.route_outlined,
        color: DashV2Colors.blue,
      ),
      DashActivityItem(
        title: 'CVF updated',
        subtitle: 'Customer visit form',
        timeAgo: '1 hour ago',
        icon: Icons.edit_calendar_outlined,
        color: DashV2Colors.green,
      ),
      DashActivityItem(
        title: 'Project approved',
        subtitle: 'New center launch',
        timeAgo: '3 hours ago',
        icon: Icons.check_circle_outline,
        color: DashV2Colors.purple,
      ),
      DashActivityItem(
        title: 'Expense submitted',
        subtitle: 'Travel reimbursement',
        timeAgo: 'Yesterday',
        icon: Icons.receipt_long_outlined,
        color: DashV2Colors.amber,
      ),
    ]);
    upcomingReminders.assignAll(const [
      DashReminderItem(
        month: 'JUL',
        day: '22',
        title: 'Submit weekly PJP',
        when: 'Tomorrow, 10:00 AM',
      ),
      DashReminderItem(
        month: 'JUL',
        day: '24',
        title: 'Customer visit',
        when: 'Friday, 11:30 AM',
      ),
      DashReminderItem(
        month: 'JUL',
        day: '27',
        title: 'Project review',
        when: 'Monday, 3:00 PM',
      ),
      DashReminderItem(
        month: 'JUL',
        day: '30',
        title: 'Expense deadline',
        when: 'Thursday, 5:00 PM',
      ),
    ]);
    notificationCount.value = 3;
  }

  Future<void> updateCurrentBusiness(int bid, String name, int uid) async {
    final box = await Utility.openBox();
    businessId.value = bid;
    businessName.value = name;
    await box.put(LocalConstant.KEY_BUSINESS_ID, bid);
    await box.put(LocalConstant.KEY_BUSINESS_NAME, name);
    await box.put(LocalConstant.KEY_BUSINESS_USERID, uid);
  }

  bool validateBusiness(String menuKey) {
    if (_businessGuardedMenus.contains(menuKey) && !isBusinessMapped) {
      Utility.showMessage(
        Get.context!,
        'Business not mapped. Please connect with your manager.',
      );
      return false;
    }
    return true;
  }

  Future<void> openProjects() async {
    final args = await ProjectsEntryArgs.fromHive();
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (_) => ProjectsDashboardPage(
          userId: args.userId,
          userName: args.userName.isEmpty ? userName.value : args.userName,
          businessId: args.businessId,
          businessName: args.businessName,
          businesses: args.businesses,
        ),
      ),
    );
  }

  Future<void> openMyPjp() async {
    if (!validateBusiness('my_pjp')) return;
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (_) => MyPjpListScreen(
          mFilterSelection: FilterSelection(
            filters: [],
            type: FILTERStatus.MYSELF,
          ),
        ),
      ),
    );
  }

  Future<void> openMyCvf() async {
    if (!validateBusiness('my_cvf')) return;
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(builder: (_) => MyCVFListScreenV2()),
    );
  }

  Future<void> openMyReport() async {
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(builder: (_) => MyReportsScreen()),
    );
  }

  Future<void> openPjpCvfApprovalExp() async {
    if (!validateBusiness('pjp_cvf_approval_exp')) return;
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(builder: (_) => PJPManagerExceptionalScreen()),
    );
  }

  Future<void> openBpms() async {
    final box = await Utility.openBox();
    try {
      final franchiseeId = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      await Navigator.of(Get.context!).push(
        MaterialPageRoute(
          builder: (_) => BPMSDashboard(userId: franchiseeId.toString()),
        ),
      );
    } catch (_) {
      Utility.showMessage(
        Get.context!,
        'BPMS is not applicable for the current user',
      );
    }
  }

  Future<void> openZllSaathi() async {
    if (!validateBusiness('zll_saathi')) return;
    final box = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    final username =
        box.get(LocalConstant.KEY_USER_NAME)?.toString() ?? userName.value;
    ZllSaathi(Get.context!, username, profileAvatarBytes.value);
  }

  Future<void> openExpenses() async {
    final box = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    final empCode = int.tryParse(
          box.get(LocalConstant.KEY_EMPLOYEE_CODE)?.toString() ?? '0',
        ) ??
        0;
    await expense_placeholder.openExpenseTracker(eCode: empCode.toString());
  }

  Future<void> openContracts() async {
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (_) => AllLegalStatusPage(email: email.value),
      ),
    );
  }

  Future<void> openPjpDashboard() async {
    if (!validateBusiness('pjp_dashboard')) return;
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(builder: (_) => SummaryDashboard()),
    );
  }

  Future<void> openNotiflow() async {
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (_) => MyWebsiteView(
          title: 'ZLLSaathi',
          url:
              'https://notiflow-51883.web.app/?u_name=${employeeCode.value}&password=12345&color=0277BD',
        ),
      ),
    );
  }

  Future<void> openPjpApprovals() async {
    if (!validateBusiness('approvals_pjp')) return;
    await Navigator.of(Get.context!).push(
      MaterialPageRoute(
        builder: (_) => PJPManagerScreen(employeeId: employeeId.value),
      ),
    );
  }

  void toggleSidebar() => sidebarExpanded.toggle();

  Future<void> openNewProject() => openProjects();

  Future<void> onQuickAccessTap(String key) async {
    switch (key) {
      case 'projects':
        await openProjects();
      case 'my_pjp':
        await openMyPjp();
      case 'my_cvf':
        await openMyCvf();
      case 'my_report':
        await openMyReport();
      case 'pjp_cvf_approval_exp':
        await openPjpCvfApprovalExp();
      case 'bpms':
        await openBpms();
      case 'zll_saathi':
        await openZllSaathi();
      case 'expenses':
        await openExpenses();
      case 'contracts':
        await openContracts();
      case 'pjp_dashboard':
        await openPjpDashboard();
      case 'notiflow':
        await openNotiflow();
    }
  }

  Future<void> onSidebarTap(String key) async {
    if (key == 'dashboard') {
      selectedNav.value = 'dashboard';
      return;
    }

    if (MediaQuery.sizeOf(Get.context!).width < kWideBreakpoint) {
      await Navigator.of(Get.context!).maybePop();
    }

    switch (key) {
      case 'pjp':
        await openMyPjp();
      case 'cvf':
        await openMyCvf();
      case 'projects_nav':
        await openProjects();
      case 'approvals_pjp':
        await openPjpApprovals();
      case 'logout':
        await signOut();
    }
  }

  Future<void> signOut() async {
    final context = Get.context!;
    final hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    await hiveBox.clear();
    await DBHelper().deleteAllData();
    await HiveDatabase.clear();
    expense_placeholder.clearAllExpenseControllers();
    await hiveBox.close();
    await Future<void>.delayed(const Duration(seconds: 1));
    resetWebUrl();
    if (!context.mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => IntroPage(),
        settings: const RouteSettings(name: '/'),
      ),
      (_) => false,
    );
  }

  Future<void> showBusinessPicker({required bool fromDrawer}) async {
    if (businessApplications.isEmpty) {
      await showDialog<void>(
        context: Get.context!,
        builder: (_) => const AlertDialog(
          title: Text('Alert'),
          content: Text(
            'Business not assigned in your account, please connect with your manager',
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: Get.context!,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Business'),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            itemCount: businessApplications.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final business = businessApplications[index];
              return Card(
                color: businessId.value == business.businessID
                    ? Colors.white54
                    : Colors.white,
                child: ListTile(
                  title: Text(business.businessName),
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    if (fromDrawer) {
                      await Navigator.of(Get.context!).maybePop();
                    }
                    await updateCurrentBusiness(
                      business.businessID,
                      business.businessName,
                      business.business_UserID,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void onSearchTap() => _showComingSoon();

  void onCustomizeTap() => _showComingSoon();

  void onNotificationsTap() => _showComingSoon();

  void onContactSupportTap() => _showComingSoon();

  void _showComingSoon() {
    Get.snackbar(
      'Coming soon',
      'This feature will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
