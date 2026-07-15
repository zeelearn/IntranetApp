import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/bindings/dashboard_binding.dart';
import 'package:Intranet/modules/projects/controllers/dashboard_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';
import 'package:Intranet/modules/projects/views/project_list_screen.dart';
import 'package:Intranet/modules/projects/views/task_list_screen.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_empty_widget.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_error_widget.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_grid.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_header.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_shimmer.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';

/// Independent Projects Dashboard page.
///
/// Count cards expand to fill remaining screen height so all counts are
/// visible at once (no scroll). Open via [ProjectsDashboardPage.open] or
/// [Navigator.push].
class ProjectsDashboardPage extends StatelessWidget {
  const ProjectsDashboardPage({
    super.key,
    required this.userId,
    required this.displayName,
    required this.businesses,
    this.businessId,
    this.onCardTap,
    this.onQuickAction,
    this.onBackTap,
  });

  final int userId;
  final int? businessId;
  final String displayName;
  final List<BusinessApplications> businesses;
  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;
  final VoidCallback? onBackTap;

  /// Convenience opener with binding.
  static Future<T?>? open<T>({
    required int userId,
    required String displayName,
    required List<BusinessApplications> businesses,
    int? businessId,
    void Function(int statusId, String statusName)? onCardTap,
    void Function(QuickActionType action)? onQuickAction,
    VoidCallback? onBackTap,
  }) {
    return Get.to<T>(
      () => ProjectsDashboardPage(
        userId: userId,
        businessId: businessId,
        displayName: displayName,
        businesses: businesses,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
        onBackTap: onBackTap,
      ),
      binding: DashboardBinding(
        userId: userId,
        businessId: businessId,
        displayName: displayName,
        businesses: businesses,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      DashboardBinding(
        userId: userId,
        businessId: businessId,
        displayName: displayName,
        businesses: businesses,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
      ).dependencies();
    }

    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          Obx(
            () => DashboardHeader(
              displayName: displayName,
              businesses: businesses,
              selectedBusinessId: controller.selectedBusinessId.value,
              selectedBusinessLabel: controller.selectedBusinessLabel.value,
              onBusinessChanged: controller.selectBusiness,
              onBackTap: onBackTap,
            ),
          ),
          Expanded(
            child: Obx(() {
              final showOffline = controller.isOffline.value ||
                  controller.servingFromCache.value;

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
                                    child: _buildBody(controller),
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
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardController controller) {
    // Always show shimmer while the first/server load is in flight.
    if (controller.isLoading.value) {
      return const DashboardShimmer(fillHeight: true);
    }

    if (controller.errorMessage.value != null && controller.cards.isEmpty) {
      return DashboardErrorWidget(
        message: controller.errorMessage.value!,
        onRetry: controller.refreshDashboard,
      );
    }

    if (controller.cards.isEmpty &&
        controller.failureType.value == DashboardFailureType.empty) {
      return DashboardEmptyWidget(onRetry: controller.refreshDashboard);
    }

    if (controller.cards.isEmpty) {
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
        userId: userId,
        dashboardStatusId: card.statusId,
        statusName: card.statusName,
        statusColor: card.color,
        currentUserName: displayName,
        contributionId: controller.selectedBusinessId.value ?? 0,
      );
    } else if (card.kind == DashboardCardKind.project) {
      ProjectListScreen.open(
        userId: userId,
        businessId: controller.selectedBusinessId.value,
        projectTeamStatus: card.statusId,
        statusName: card.statusName,
        statusColor: card.color,
        businesses: businesses,
        currentUserName: displayName,
      );
    }
    controller.handleCardTap(card);
  }
}
