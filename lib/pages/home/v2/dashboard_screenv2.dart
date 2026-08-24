import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_kpi_row.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_mobile_app_bar.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_project_status_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_grid.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_recent_activity_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_sidebar.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_upcoming_reminders_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_web_top_bar.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_welcome_banner.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Intranet/pages/firebase/notification.dart';
import 'package:Intranet/pages/helper/web_helper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

/// Dashboard Screen V2 — GetX-driven home shell that replaces
/// [Intranet/pages/home/IntranetHomePage.dart] as the post-login entry.
///
/// Responsive: mobile layout below [DashboardScreenV2Controller.kWideBreakpoint],
/// web/desktop layout above it.
class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({
    super.key,
    required this.userId,
    this.receivedAction,
  });

  final String userId;
  final ReceivedAction? receivedAction;

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  late final DashboardScreenV2Controller controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      DashboardScreenV2Controller(
        userId: widget.userId,
        receivedAction: widget.receivedAction,
      ),
    );
    controller.bootstrapShell(context);
  }

  @override
  void dispose() {
    if (Get.isRegistered<DashboardScreenV2Controller>()) {
      Get.delete<DashboardScreenV2Controller>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final scaffold = _scaffoldKey.currentState;
        if (scaffold?.isDrawerOpen ?? false) {
          scaffold!.closeDrawer();
          return;
        }
        controller.onBackPressed();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >=
              DashboardScreenV2Controller.kWideBreakpoint;
          return isWide ? _buildWeb(context) : _buildMobile(context);
        },
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Obx(
      () => _AppVersionFooter(version: controller.appVersion.value),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashV2Colors.scaffold,
      appBar: const DashMobileAppBar(),
      drawer: const Drawer(child: DashSidebar(isDrawer: true)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                if (!controller.showNotificationBanner.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNotificationBanner(context),
                    const SizedBox(height: 14),
                  ],
                );
              }),
              //const DashAdBanner(),
              const DashWelcomeBanner(),
              // const SizedBox(height: 18),
              // const DashKpiRow(),
              const SizedBox(height: 14),
              const DashQuickAccessGrid(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildVersionFooter(),
    );
  }

  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      backgroundColor: DashV2Colors.scaffold,
      body: Row(
        children: [
          Obx(
            () => SizedBox(
              width: controller.sidebarExpanded.value ? 248 : 78,
              child: const DashSidebar(showHelpCard: true),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: DashV2Colors.border),
          Expanded(
            child: Column(
              children: [
                const DashWebTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          if (!controller.showNotificationBanner.value) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildNotificationBanner(context),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        //const DashKpiRow(variant: DashKpiVariant.web),
                        //const SizedBox(height: 24),
                        _buildQuickAccessSection(),
                        // _buildInsightRow(),
                      ],
                    ),
                  ),
                ),
                _buildVersionFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(BuildContext context) {
    final permission = getWebNotificationPermissionState();
    final isBlocked = permission == 'denied';

    return LayoutBuilder(
      builder: (context, constraints) {
        final useVerticalLayout = constraints.maxWidth < 600;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Turn on notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1D2C4F),
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'Get real-time alerts for approvals, messages and updates — even when this tab is in the background. ',
                  ),
                  if (isBlocked)
                    const TextSpan(
                      text: 'Notifications are blocked — allow them for this site in your browser settings.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0071e3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Notifications Blocked'),
                      content: const Text(
                        'Notifications are blocked in your browser settings.\n\nTo enable them:\n1. Click the site settings icon (lock/sliders icon) on the left of the URL bar.\n2. Toggle Notification permission to "Allow".',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  await FirebaseMessaging.instance.requestPermission(
                    alert: true,
                    badge: true,
                    sound: true,
                  );
                  final newPermission = getWebNotificationPermissionState();
                  if (newPermission == 'granted') {
                    controller.showNotificationBanner.value = false;
                    final box = await Utility.openBox();
                    final empId = box.get(LocalConstant.KEY_EMPLOYEE_ID) ?? '';
                    FCM().setNotifications(empId.toString(), 'web_device', 'browser');
                  } else if (newPermission == 'denied') {
                    controller.showNotificationBanner.value = false;
                    controller.showNotificationBanner.value = true;
                  }
                }
              },
              child: const Text(
                'Enable',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0071e3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                controller.showNotificationBanner.value = false;
              },
              child: const Text(
                'Not now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5FF),
            border: Border.all(color: const Color(0xFFADC6FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: useVerticalLayout
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: content),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [actions],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: content),
                    const SizedBox(width: 16),
                    actions,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     // Expanded(
        //     //   child: Text('Quick Access', style: DashV2Text.sectionTitle),
        //     // ),
        //     TextButton.icon(
        //       onPressed: controller.onCustomizeTap,
        //       icon: const Icon(Icons.tune_rounded, size: 16),
        //       label: const Text('Customize'),
        //       style: TextButton.styleFrom(foregroundColor: DashV2Colors.blue),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 12),
        const DashQuickAccessGrid(),
      ],
    );
  }

  Widget _buildInsightRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              DashProjectStatusCard(),
              SizedBox(height: 16),
              DashRecentActivityCard(),
              SizedBox(height: 16),
              DashUpcomingRemindersCard(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: DashProjectStatusCard()),
            SizedBox(width: 16),
            Expanded(child: DashRecentActivityCard()),
            SizedBox(width: 16),
            Expanded(child: DashUpcomingRemindersCard()),
          ],
        );
      },
    );
  }
}

/// Sticky page footer: centered `Intranet_{version}`.
class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F2F5),
          border: Border(
            top: BorderSide(color: Color(0xFFE4E8EE), width: 0.8),
          ),
        ),
        child: Text(
          'Intranet_${version.isEmpty ? '—' : version}',
          style: DashV2Text.footer,
        ),
      ),
    );
  }
}
