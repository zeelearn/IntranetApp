import 'package:Intranet/pages/helper/utils.dart';
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
import 'package:get/get.dart';

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
    Get.delete<DashboardScreenV2Controller>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.onBackPressed();
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

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: DashV2Colors.scaffold,
      appBar: const DashMobileAppBar(),
      drawer: const Drawer(child: DashSidebar(isDrawer: true)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashWelcomeBanner(),
              const SizedBox(height: 16),
              const DashKpiRow(),
              const SizedBox(height: 20),
              Text('Quick Access', style: DashV2Text.sectionTitle),
              const SizedBox(height: 12),
              const DashQuickAccessGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Utility.footer(controller.appVersion.value),
      ),
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
                        const DashKpiRow(variant: DashKpiVariant.web),
                        const SizedBox(height: 24),
                        _buildQuickAccessSection(),
                        const SizedBox(height: 24),
                        _buildInsightRow(),
                        const SizedBox(height: 20),
                        Obx(
                          () => Center(
                            child: Text(
                              'Intranet_${controller.appVersion.value}',
                              style: DashV2Text.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Quick Access', style: DashV2Text.sectionTitle),
            ),
            TextButton.icon(
              onPressed: controller.onCustomizeTap,
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Customize'),
              style: TextButton.styleFrom(foregroundColor: DashV2Colors.blue),
            ),
          ],
        ),
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
