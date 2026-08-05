import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/bindings/dashboard_binding.dart';
import 'package:Intranet/modules/projects/controllers/dashboard_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/projects_entry_args.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';
import 'package:Intranet/modules/projects/views/center_kit_report_screen.dart';
import 'package:Intranet/modules/projects/views/indent_list_screen.dart';
import 'package:Intranet/modules/projects/views/project_list_screen.dart';
import 'package:Intranet/modules/projects/views/task_list_screen.dart';
import 'package:Intranet/modules/projects/views/visual_charts_screen.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_empty_widget.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_error_widget.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_grid.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_header.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_shimmer.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/projects_sidebar.dart';

/// Independent Projects Dashboard page (library entry point).
///
/// Required host params: [userId], [userName], [businessId], [businessName],
/// [businesses]. Prefer [open] / [openFromHive].
class ProjectsDashboardPage extends StatefulWidget {
  const ProjectsDashboardPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.businesses,
    this.businessId,
    this.businessName = '',
    this.onCardTap,
    this.onQuickAction,
    this.onBackTap,
  });

  final int userId;
  final int? businessId;
  final String userName;
  final String businessName;
  final List<BusinessApplications> businesses;
  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;
  final VoidCallback? onBackTap;

  /// Opens dashboard with explicit args (portable / library use).
  static Future<T?>? open<T>({
    required int userId,
    required String userName,
    required List<BusinessApplications> businesses,
    int? businessId,
    String businessName = '',
    void Function(int statusId, String statusName)? onCardTap,
    void Function(QuickActionType action)? onQuickAction,
    VoidCallback? onBackTap,
  }) {
    return Get.to<T>(
      () => ProjectsDashboardPage(
        userId: userId,
        businessId: businessId,
        userName: userName,
        businessName: businessName,
        businesses: businesses,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
        onBackTap: onBackTap,
      ),
    );
  }

  /// Loads Hive session then opens the dashboard.
  static Future<T?> openFromHive<T>({
    void Function(int statusId, String statusName)? onCardTap,
    void Function(QuickActionType action)? onQuickAction,
    VoidCallback? onBackTap,
  }) async {
    final args = await ProjectsEntryArgs.fromHive();
    return open<T>(
      userId: args.userId,
      userName: args.userName,
      businessId: args.businessId,
      businessName: args.businessName,
      businesses: args.businesses,
      onCardTap: onCardTap,
      onQuickAction: onQuickAction,
      onBackTap: onBackTap,
    );
  }

  @override
  State<ProjectsDashboardPage> createState() => _ProjectsDashboardPageState();
}

class _ProjectsDashboardPageState extends State<ProjectsDashboardPage> {
  late final String _tag;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarVisible = true;

  static const double _wideBreakpoint = 900;

  @override
  void initState() {
    super.initState();
    _tag = DashboardBinding.makeTag(widget.userId);
    // Fresh controller every open — fixes stuck shimmer from stale GetX state.
    DashboardBinding(
      userId: widget.userId,
      businessId: widget.businessId,
      userName: widget.userName,
      businessName: widget.businessName,
      businesses: widget.businesses,
      onCardTap: widget.onCardTap,
      onQuickAction: widget.onQuickAction,
    ).dependencies();
  }

  @override
  void dispose() {
    DashboardBinding.deleteIfRegistered(widget.userId);
    super.dispose();
  }

  void _toggleMenu(bool isWide) {
    if (isWide) {
      setState(() => _sidebarVisible = !_sidebarVisible);
    } else {
      final scaffold = _scaffoldKey.currentState;
      if (scaffold == null) return;
      if (scaffold.isDrawerOpen) {
        scaffold.closeDrawer();
      } else {
        scaffold.openDrawer();
      }
    }
  }

  void _closeDrawerIfOpen() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>(tag: _tag)) {
      DashboardBinding(
        userId: widget.userId,
        businessId: widget.businessId,
        userName: widget.userName,
        businessName: widget.businessName,
        businesses: widget.businesses,
        onCardTap: widget.onCardTap,
        onQuickAction: widget.onQuickAction,
      ).dependencies();
    }
    final controller = Get.find<DashboardController>(tag: _tag);
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashboardColors.scaffold,
      drawer: isWide
          ? null
          : Drawer(
              width: 300,
              child: Obx(
                () => ProjectsSidebar(
                  projectCards: controller.cards.toList(growable: false),
                  showProjects: controller.showProjectsMenu.value,
                  showAllIndents: controller.showAllIndentsMenu.value,
                  showCenterKitReport:
                      controller.showCenterKitReportMenu.value,
                  showVisualCharts: controller.showVisualChartsMenu.value,
                  onProjectTap: (card) {
                    _closeDrawerIfOpen();
                    _handleCardTap(controller, card);
                  },
                  onAllIndentsTap: () {
                    _closeDrawerIfOpen();
                    _openAllIndents();
                  },
                  onCenterKitReportTap: () {
                    _closeDrawerIfOpen();
                    _openCenterKitReport();
                  },
                  onVisualChartsTap: () {
                    _closeDrawerIfOpen();
                    _openVisualCharts();
                  },
                ),
              ),
            ),
      body: Column(
        children: [
          Obx(
            () => DashboardHeader(
              userName: controller.userName,
              subtitle: controller.headerSubtitle.value,
              businesses: controller.businesses.toList(growable: false),
              selectedBusinessId: controller.selectedBusinessId.value,
              selectedBusinessLabel: controller.selectedBusinessLabel.value,
              onBusinessChanged: controller.selectBusiness,
              onBackTap: widget.onBackTap ??
                  () => Navigator.of(context).maybePop(),
              onMenuTap: () => _toggleMenu(isWide),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isWide && _sidebarVisible)
                  Obx(
                    () => ProjectsSidebar(
                      projectCards: controller.cards.toList(growable: false),
                      showProjects: controller.showProjectsMenu.value,
                      showAllIndents: controller.showAllIndentsMenu.value,
                      showCenterKitReport:
                          controller.showCenterKitReportMenu.value,
                      showVisualCharts: controller.showVisualChartsMenu.value,
                      onProjectTap: (card) =>
                          _handleCardTap(controller, card),
                      onAllIndentsTap: _openAllIndents,
                      onCenterKitReportTap: _openCenterKitReport,
                      onVisualChartsTap: _openVisualCharts,
                    ),
                  ),
                Expanded(child: _buildMainContent(controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(DashboardController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final showOffline =
          controller.isOffline.value || controller.servingFromCache.value;
      // Touch reactive list so Obx rebuilds when cards arrive.
      final cardCount = controller.cards.length;
      final error = controller.errorMessage.value;

      return RefreshIndicator(
        color: DashboardColors.primary,
        onRefresh: controller.refreshDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OfflineBanner(
                            visible: showOffline,
                            onRetry: controller.refreshDashboard,
                            message: controller.isOffline.value
                                ? 'You are offline. Showing cached data.'
                                : 'Showing cached data. Pull to refresh.',
                          ),
                          if (showOffline) const SizedBox(height: 8),
                          Expanded(
                            child: _buildBody(
                              controller,
                              isLoading: isLoading,
                              cardCount: cardCount,
                              error: error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBody(
    DashboardController controller, {
    required bool isLoading,
    required int cardCount,
    required String? error,
  }) {
    if (isLoading) {
      return const DashboardShimmer(fillHeight: true);
    }

    if (error != null && cardCount == 0) {
      return DashboardErrorWidget(
        message: error,
        onRetry: controller.refreshDashboard,
      );
    }

    if (cardCount == 0 &&
        controller.failureType.value == DashboardFailureType.empty) {
      return DashboardEmptyWidget(onRetry: controller.refreshDashboard);
    }

    if (cardCount == 0) {
      return DashboardEmptyWidget(onRetry: controller.refreshDashboard);
    }

    return DashboardGrid(
      cards: controller.cards.toList(growable: false),
      onCardTap: (card) => _handleCardTap(controller, card),
      expandToFit: true,
    );
  }

  void _handleCardTap(
    DashboardController controller,
    DashboardCardModel card,
  ) {
    if (card.kind == DashboardCardKind.task) {
      TaskListScreen.open(
        userId: widget.userId,
        dashboardStatusId: card.statusId,
        statusName: card.statusName,
        statusColor: card.color,
        currentUserName: widget.userName,
        contributionId: controller.selectedBusinessId.value ?? 0,
      );
    } else if (card.kind == DashboardCardKind.project) {
      ProjectListScreen.open(
        userId: widget.userId,
        businessId: controller.selectedBusinessId.value,
        projectTeamStatus: card.statusId,
        statusName: card.statusName,
        statusColor: card.color,
        businesses: controller.businesses.toList(growable: false),
        currentUserName: widget.userName,
      );
    }
    controller.handleCardTap(card);
  }

  void _openAllIndents() {
    final controller = Get.find<DashboardController>(tag: _tag);
    final businessId =
        (controller.selectedBusinessId.value ?? widget.businessId ?? 1)
            .toString();
    IndentListScreen.open(
      userId: widget.userId,
      businessId: businessId,
    );
  }

  void _openCenterKitReport() {
    // API sample uses { "business_id": null } for full report.
    CenterKitReportScreen.open(businessId: null);
  }

  void _openVisualCharts() {
    final controller = Get.find<DashboardController>(tag: _tag);
    if (!controller.showVisualChartsMenu.value) return;
    VisualChartsScreen.openFromHive();
  }
}
