import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/main.dart' show NotificationController;
import 'package:Intranet/modules/projects/models/projects_entry_args.dart';
import 'package:Intranet/modules/projects/views/projects_dashboard_page.dart';
import 'package:Intranet/pages/bpms/bpms_dashboard.dart';
import 'package:Intranet/pages/firebase/storageutil.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/helper/web_helper.dart';
import 'package:Intranet/pages/home/change_password_request.dart';
import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/profile/profile_screen_v2.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/iface/onUploadResponse.dart';
import 'package:Intranet/pages/intro/intro.dart';
import 'package:Intranet/pages/legal_mis/all_legal_status_page.dart';
import 'package:Intranet/pages/model/filter.dart';
import 'package:Intranet/pages/notification/UserNotification.dart';
import 'package:Intranet/pages/pjp/cvf/v2/cvf.dart';
import 'package:Intranet/pages/pjp/mypjp.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager_exceptional.dart';
import 'package:Intranet/pages/report/myreport.dart';
import 'package:Intranet/pages/summary%20dashboard/summary_dashboard.dart';
import 'package:Intranet/pages/utils/util.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:Intranet/pages/widget/VideoPlayer.dart';
import 'package:app_links/app_links.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:expensestracker/app/hiveDatabase/hive_database.dart';
import 'package:expensestracker/presentation/app.dart' as expense_placeholder;
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_binding.dart';
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_page_controller.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saathi/zllsaathi.dart';

import '../../firebase/notification.dart';
import '../../firebase/notification_service.dart';

typedef ProfileImageFetcher = void Function(
  String employeeId,
  onUploadResponse response,
);
typedef ForegroundNotificationRegistrar
    = Future<StreamSubscription<RemoteMessage>?> Function(String employeeId);

class DashboardScreenV2Controller extends GetxController
    with WidgetsBindingObserver {
  DashboardScreenV2Controller({
    required this.userId,
    this.receivedAction,
    ProfileImageFetcher? profileImageFetcher,
    ForegroundNotificationRegistrar? foregroundNotificationRegistrar,
  })  : _profileImageFetcher = profileImageFetcher,
        _foregroundNotificationRegistrar = foregroundNotificationRegistrar;

  static const double kWideBreakpoint = 1000;

  final String userId;
  final ReceivedAction? receivedAction;
  final ProfileImageFetcher? _profileImageFetcher;
  final ForegroundNotificationRegistrar? _foregroundNotificationRegistrar;

  final userFullName = ''.obs;
  final firstName = ''.obs;
  final userName = ''.obs;
  final employeeId = 0.obs;
  final employeeCode = ''.obs;
  final designation = ''.obs;
  final email = ''.obs;

  final businessId = 0.obs;
  final businessName = 'Select Business'.obs;
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

  bool _shellBootstrapped = false;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<Uri?>? _incomingLinkSubscription;

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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_messageOpenedAppSubscription?.cancel());
    unawaited(_foregroundMessageSubscription?.cancel());
    unawaited(_incomingLinkSubscription?.cancel());
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(loadNotificationCount());
      if (!kDebugMode && !kIsWeb) {
        if (Platform.isAndroid) {
          unawaited(checkForUpdate());
        } else if (Platform.isIOS) {
          final context = Get.context;
          if (context != null) unawaited(_verifyVersion(context));
        }
      }
    }
  }

  Future<void> _initialize() async {
    isLoading.value = true;
    try {
      await loadUserFromHive();
      await loadBusinessApplications();
      if (Get.isRegistered<DashboardPageController>() &&
          employeeCode.value.isNotEmpty) {
        Get.find<DashboardPageController>()
            .getMaxAdvanceLimit(employeeCode.value);
      }
      await loadAppVersion();
      await loadNotificationCount();
      if (employeeId.value != 0) {
        await registerForegroundNotifications(employeeId.value.toString());
      }
      unawaited(getProfileImage());
    } finally {
      isLoading.value = false;
    }
  }

  /// Registers Firebase messaging, deep-link handlers, in-app update checks
  /// and password-expiry prompts — parity with `IntranetHomePage.initState`.
  /// Call once from the screen's `initState` after `Get.put`.
  Future<void> bootstrapShell(BuildContext context) async {
    if (_shellBootstrapped) return;
    _shellBootstrapped = true;

    WidgetsBinding.instance.addObserver(this);
    _handleReceivedAction();

    await initFirebase();
    await NotificationController.initializeLocalNotifications();
    _messageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      debugPrint('Dashboard V2: onMessageOpenedApp received');
      final ctx = Get.context;
      if (ctx == null) return;
      await Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => const UserNotification()),
      );
      await loadNotificationCount();
    });

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        unawaited(checkForUpdate());
      } else if (Platform.isIOS) {
        unawaited(_verifyVersion(context));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _incomingLinkHandler());
  }

  void _handleReceivedAction() {
    final action = receivedAction;
    final payload = action?.payload;
    final context = Get.context;
    if (context == null || payload == null) return;

    if (payload['type'] == 'td') {
      Util.openSaathiNotification(action!);
    } else if (payload['Video_path'] != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPlayer(
            Title: payload['Video_path']!,
            path: payload['Video_path']!,
          ),
        ),
      );
    } else if (payload['url']?.isNotEmpty == true) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UserNotification()),
      );
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
      // print('Dashboard V2 user loaded: ${userFullName.value}, ${employeeCode.value}, ${businessName.value}');
      final imageUrl = box.get(LocalConstant.KEY_EMPLOYEE_AVTAR)?.toString();
      final gender = box.get(LocalConstant.KEY_GENDER)?.toString() ?? '';
      profileImageUrl.value = imageUrl?.isNotEmpty == true
          ? imageUrl!
          : gender == 'Male'
              ? 'https://cdn-icons-png.flaticon.com/128/149/149071.png'
              : gender == 'Female'
                  ? 'https://cdn-icons-png.flaticon.com/128/727/727393.png'
                  : 'https://cdn-icons-png.flaticon.com/128/149/149071.png';

      final encodedAvatar =
          box.get(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST)?.toString();
      if (encodedAvatar?.isNotEmpty == true) {
        profileAvatarBytes.value = base64.decode(encodedAvatar!);
      }

      final passwordExpired = int.tryParse(
              box.get(LocalConstant.KEY_PASSWORD_EXPIRED)?.toString() ?? '0') ??
          0;
      if (passwordExpired == 1) {
        Future.delayed(Duration.zero, _showUpdatePasswordDialog);
      }
    } catch (error) {
      debugPrint('Dashboard V2 user load failed: $error');
    }
  }

  Future<void> loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (error) {
      debugPrint('Dashboard V2 app version load failed: $error');
    }
  }

  Future<void> registerForegroundNotifications(String employeeId) async {
    await _foregroundMessageSubscription?.cancel();
    final registrar =
        _foregroundNotificationRegistrar ?? _registerForegroundNotifications;
    _foregroundMessageSubscription = await registrar(employeeId);
  }

  Future<StreamSubscription<RemoteMessage>?> _registerForegroundNotifications(
      String employeeId) async {
    var deviceId = '0';
    var userAgent = 'Android';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        userAgent = 'Web';
      } else if (Platform.isIOS) {
        final iosDeviceInfo = await deviceInfo.iosInfo;
        deviceId = iosDeviceInfo.identifierForVendor ?? '0';
        userAgent = 'IOS_${iosDeviceInfo.model}_${appVersion.value}';
      } else if (Platform.isAndroid) {
        final androidDeviceInfo = await deviceInfo.androidInfo;
        deviceId = androidDeviceInfo.id;
        userAgent =
            'Android_${androidDeviceInfo.brand}_${androidDeviceInfo.model}';
      }
    } catch (error) {
      debugPrint('Dashboard V2 device info failed: $error');
    }

    FCM().setNotifications(employeeId, deviceId, userAgent);
    return FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Dashboard V2 foreground notification: ${message.toMap()}');
      NotificationService().parseNotification(message);
      unawaited(loadNotificationCount());
    });
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
    // PLACEHOLDER until KPI APIs exist — values/icons match Figma mobile.
    kpiStats.assignAll(const [
      DashKpiStat(
        label: 'My PJP',
        value: '24',
        icon: Icons.directions_car_filled_rounded,
        color: DashV2Colors.blue,
        progress: 0.27,
      ),
      DashKpiStat(
        label: 'My CVF',
        value: '12',
        icon: Icons.calendar_month_rounded,
        color: DashV2Colors.green,
        progress: 0.72,
      ),
      DashKpiStat(
        label: 'Pending',
        value: '05',
        icon: Icons.access_time_filled_rounded,
        color: DashV2Colors.amber,
        progress: 0.21,
      ),
      DashKpiStat(
        label: 'Approved',
        value: '18',
        icon: Icons.check_rounded,
        color: DashV2Colors.purple,
        progress: 0.79,
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
  }

  Future<void> loadNotificationCount() async {
    try {
      final list = await DBHelper().getData(LocalConstant.TABLE_NOTIFICATION);
      notificationCount.value = list.length;
    } catch (error) {
      debugPrint('Dashboard V2 notification count failed: $error');
    }
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
      default:
        debugPrint('Dashboard V2: unknown quick access key: $key');
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
      case 'profile':
        selectedNav.value = 'profile';
        await openProfile();
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
      default:
        debugPrint('Dashboard V2: unknown sidebar key: $key');
    }
  }

  Future<void> openProfile() async {
    final context = Get.context;
    if (context == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreenV2()),
    );
    selectedNav.value = 'dashboard';
  }

  Future<void> signOut() async {
    final context = Get.context!;
    final hiveBox = await Utility.openBox();

    if (kIsWeb) {
      var oldtoken = hiveBox.get(LocalConstant.KEY_FCM_ID);
      if (oldtoken != null && oldtoken.isNotEmpty) {
        APIService().unsubscribeToTopicForWeb('saathi', oldtoken);
        APIService().unsubscribeToTopicForWeb('intranet', oldtoken);
      }
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('saathi');
      FirebaseMessaging.instance.unsubscribeFromTopic('intranet');
    }
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

  Future<void> onNotificationsTap() async {
    final context = Get.context;
    if (context == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserNotification()),
    );
    await loadNotificationCount();
  }

  void onContactSupportTap() => _showComingSoon();

  void _showComingSoon() {
    Get.snackbar(
      'Coming soon',
      'This feature will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ---------------------------------------------------------------------
  // Shell lifecycle parity — Firebase, deep links, in-app update, password.
  // Ported from IntranetHomePage (read-only reference); behavior preserved.
  // ---------------------------------------------------------------------

  Future<void> initFirebase() async {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Handles app links received while the app is already running.
  void _incomingLinkHandler() {
    if (kIsWeb) return;
    final appLinks = AppLinks();
    _incomingLinkSubscription = appLinks.uriLinkStream.listen(
      (Uri? uri) {
        debugPrint('Dashboard V2: Received URI: $uri');
        deepLinkCommonFunction(uri);
      },
      onError: (Object err) {
        debugPrint('Dashboard V2: deep link error: $err');
      },
    );
  }

  void deepLinkCommonFunction(Uri? initialURI) {
    if (initialURI == null) return;
    final context = Get.context;
    if (context == null) return;
    if (initialURI.toString().contains('zllsaathi.zeelearn.com/ticketDetail')) {
      final params = initialURI.queryParameters;
      final id = params['id'];
      final bId = params['b_id'];
      final buId = params['bu_id'];
      final uId = params['u_id'];
      if (id == null || bId == null || buId == null || uId == null) return;
      ZllTicket(
        context,
        id,
        bId,
        buId,
        uId.replaceAll('.', ''),
        DashV2Colors.primary,
      );
    }
  }

  Future<void> checkForUpdate() async {
    if (kIsWeb) return;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (error) {
      debugPrint('Dashboard V2 update check failed: $error');
    }
  }

  Future<void> _verifyVersion(BuildContext context) async {
    try {
      final result = await AppVersionUpdate.checkForUpdates(
        appleId: '6443464060',
        playStoreId: 'com.zeelearn.intranet',
        country: 'in',
      );
      if (result.canUpdate == true && context.mounted) {
        await AppVersionUpdate.showBottomSheetUpdate(
          context: context,
          appVersionResult: result,
          mandatory: true,
          title: 'App Update Avaliable',
          content: const Text(
            'New version of our Intranet application is now available, and we highly recommend that you install it to benefit from its enhanced features and improved security.',
          ),
        );
      }
    } catch (error) {
      debugPrint('Dashboard V2 iOS version check failed: $error');
    }
  }

  void onBackPressed() {
    final context = Get.context;
    if (context == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alert'),
        content: const Text('Would you like to Exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              if (!kIsWeb && Platform.isAndroid) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                });
              } else if (!kIsWeb && Platform.isIOS) {
                exit(0);
              }
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  // -- Profile avatar --------------------------------------------------

  Future<void> getProfileImage({bool force = false}) async {
    if (!force && profileAvatarBytes.value != null) return;
    try {
      final fetcher =
          _profileImageFetcher ?? FirebaseStorageUtil().getProfileImage;
      fetcher(
        employeeId.value.toString(),
        _ProfileAvatarFetchResponse(this),
      );
    } catch (error) {
      debugPrint('Dashboard V2 profile image fetch failed: $error');
    }
  }

  Future<void> uploadProfilePicture() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 800,
        imageQuality: 100,
      );
      if (pickedFile == null) return;
      FirebaseStorageUtil().uploadAvtar(
        pickedFile.path,
        employeeId.value.toString(),
        _AvatarUploadResponse(this),
      );
    } catch (error) {
      debugPrint('Dashboard V2 avatar upload failed: $error');
    }
  }

  Future<void> _cacheAvatarBytes(Uint8List bytes) async {
    final box = await Utility.openBox();
    await box.put(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST, base64.encode(bytes));
  }

  Future<void> _applyUploadedAvatarUrl(String muggedUrl) async {
    var url = muggedUrl.replaceAll('___', '&');
    url = Uri.decodeFull(url);
    if (url.isEmpty) return;
    profileImageUrl.value = url;
    final box = await Utility.openBox();
    await box.put(LocalConstant.KEY_EMPLOYEE_AVTAR, url);
    unawaited(getProfileImage(force: true));
  }

  // -- Password expiry ---------------------------------------------------

  void _showUpdatePasswordDialog() {
    final context = Get.context;
    if (context == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: !kReleaseMode,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Fluttertoast.showToast(
              msg: 'Please update your password to continue.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              fontSize: 14,
            );
          }
        },
        child: _UpdatePasswordDialog(
          onSubmit: (newPassword, ctx) =>
              _performPasswordUpdate(ctx, newPassword),
        ),
      ),
    );
  }

  void _performPasswordUpdate(BuildContext dialogContext, String newPassword) {
    final context = Get.context;
    if (context == null) return;
    final request = ChangePasswordRequest(
      userName: employeeCode.value,
      password: newPassword,
    );
    IntranetServiceHandler.changePassword(
      request,
      _PasswordUpdateResponse(
        context: context,
        dialogContext: dialogContext,
        onSuccessCallback: () async {
          final box = await Utility.openBox();
          await box.put(LocalConstant.KEY_USER_PASSWORD, newPassword);
          await box.put(LocalConstant.KEY_PASSWORD_EXPIRED, 0);
        },
      ),
    );
  }
}

class _ProfileAvatarFetchResponse implements onUploadResponse {
  _ProfileAvatarFetchResponse(this.controller);

  final DashboardScreenV2Controller controller;

  @override
  void onStart() {}

  @override
  void onUploadProgress(int value) {}

  @override
  void onUploadError(dynamic value) {}

  @override
  void onUploadSuccess(dynamic value) {
    if (value is Uint8List) {
      controller.profileAvatarBytes.value = value;
      unawaited(controller._cacheAvatarBytes(value));
    }
  }
}

class _AvatarUploadResponse implements onUploadResponse {
  _AvatarUploadResponse(this.controller);

  final DashboardScreenV2Controller controller;

  @override
  void onStart() {
    final context = Get.context;
    if (context != null) Utility.showLoaderDialog(context);
  }

  @override
  void onUploadProgress(int value) {}

  @override
  void onUploadError(dynamic value) {
    final context = Get.context;
    if (context != null) Navigator.of(context).pop();
  }

  @override
  void onUploadSuccess(dynamic value) {
    final context = Get.context;
    if (context != null) Navigator.of(context).pop();
    if (value is String) {
      unawaited(controller._applyUploadedAvatarUrl(value));
    }
  }
}

class _PasswordUpdateResponse implements onResponse {
  _PasswordUpdateResponse({
    required this.context,
    required this.dialogContext,
    required this.onSuccessCallback,
  });

  final BuildContext context;
  final BuildContext dialogContext;
  final Future<void> Function() onSuccessCallback;

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onSuccess(dynamic value) async {
    Navigator.of(context).pop();
    Navigator.of(dialogContext).pop();
    await onSuccessCallback();
    Utility.showMessage(context, 'Password updated successfully');
  }

  @override
  void onError(dynamic value) {
    Navigator.of(context).pop();
    Utility.showMessage(context, value.toString());
  }
}

typedef _PasswordSubmitCallback = void Function(
  String newPassword,
  BuildContext dialogContext,
);

class _UpdatePasswordDialog extends StatefulWidget {
  const _UpdatePasswordDialog({required this.onSubmit});

  final _PasswordSubmitCallback onSubmit;

  @override
  State<_UpdatePasswordDialog> createState() => _UpdatePasswordDialogState();
}

class _UpdatePasswordDialogState extends State<_UpdatePasswordDialog> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_newPasswordController.text, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Password Expired',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your password has expired. For security reasons, please set a new password to continue accessing the application.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    textInputAction: TextInputAction.next,
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                      prefixIcon:
                          const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DashV2Colors.primary,
                          width: 2,
                        ),
                      ),
                      errorStyle: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                      prefixIcon:
                          const Icon(Icons.lock_reset_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DashV2Colors.primary,
                          width: 2,
                        ),
                      ),
                      errorStyle: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DashV2Colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Update and Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
