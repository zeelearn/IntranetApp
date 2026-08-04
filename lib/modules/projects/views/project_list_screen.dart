import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/bindings/project_list_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_list_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/business_selector.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_card.dart';
import 'package:Intranet/modules/projects/widgets/project_filter_sheet.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/project_search_bar.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';

/// Project listing screen opened from dashboard status cards.
class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({
    super.key,
    required this.userId,
    required this.projectTeamStatus,
    required this.statusName,
    required this.businesses,
    this.businessId,
    this.statusColor = DashboardColors.primary,
    this.currentUserName = '',
  });

  final int userId;
  final int? businessId;
  final int projectTeamStatus;
  final String statusName;
  final Color statusColor;
  final List<BusinessApplications> businesses;
  final String currentUserName;

  /// Opens with GetX binding.
  static Future<T?>? open<T>({
    required int userId,
    required int projectTeamStatus,
    required String statusName,
    required List<BusinessApplications> businesses,
    int? businessId,
    Color statusColor = DashboardColors.primary,
    String currentUserName = '',
  }) {
    return Get.to<T>(
      () => ProjectListScreen(
        userId: userId,
        businessId: businessId,
        projectTeamStatus: projectTeamStatus,
        statusName: statusName,
        statusColor: statusColor,
        businesses: businesses,
        currentUserName: currentUserName,
      ),
      binding: ProjectListBinding(
        userId: userId,
        businessId: businessId,
        projectTeamStatus: projectTeamStatus,
        statusName: statusName,
        statusColor: statusColor,
        businesses: businesses,
        currentUserName: currentUserName,
      ),
    );
  }

  String get _tag =>
      ProjectListBinding.tag(userId, projectTeamStatus, businessId);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProjectListController>(tag: _tag)) {
      ProjectListBinding(
        userId: userId,
        businessId: businessId,
        projectTeamStatus: projectTeamStatus,
        statusName: statusName,
        statusColor: statusColor,
        businesses: businesses,
        currentUserName: currentUserName,
      ).dependencies();
    }

    final controller = Get.find<ProjectListController>(tag: _tag);

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          _AppBar(controller: controller, businesses: businesses),
          Obx(() {
            final showOffline =
                controller.isOffline.value || controller.servingFromCache.value;
            return OfflineBanner(
              visible: showOffline,
              onRetry: controller.isOffline.value
                  ? null
                  : controller.refreshProjects,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached projects.'
                  : 'Showing cached data. Pull to refresh.',
            );
          }),
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: controller.showSearchBar.value
                  ? ProjectSearchBar(
                      key: const ValueKey('search'),
                      onChanged: controller.onSearchChanged,
                      onFilterTap: () async {
                        final result = await showProjectFilterSheet(
                          context: context,
                          current: controller.filter.value,
                          feeTypes: controller.feeTypeOptions,
                          tiers: controller.tierOptions,
                          createdByOptions: controller.createdByOptions,
                        );
                        if (result != null) {
                          controller.applyFilter(result);
                        }
                      },
                    )
                  : const SizedBox.shrink(key: ValueKey('no-search')),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.visibleProjects.isEmpty) {
                return const ProjectShimmer();
              }
              if (controller.errorMessage.value != null &&
                  controller.visibleProjects.isEmpty) {
                return ProjectErrorWidget(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refreshProjects,
                );
              }
              if (controller.visibleProjects.isEmpty) {
                return ProjectEmptyWidget(onRetry: controller.refreshProjects);
              }

              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshProjects,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 1024
                        ? 3
                        : width >= 600
                            ? 2
                            : 1;

                    if (columns == 1) {
                      return NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels >=
                                  n.metrics.maxScrollExtent - 200 &&
                              controller.hasMore.value) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: controller.visibleProjects.length +
                              (controller.hasMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= controller.visibleProjects.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('Loading more...'),
                                ),
                              );
                            }
                            final project =
                                controller.visibleProjects[index];
                            return Obx(() {
                              final crmId = project.crmId;
                              final cooldownHint =
                                  controller.sendCredentialsCooldownHint(crmId);
                              final sending =
                                  controller.isSendingCredentials.value &&
                                      controller.sendingCredentialsCrmId
                                              .value ==
                                          crmId;
                              return ProjectCard(
                                project: project,
                                index: index,
                                statusLabel: controller.statusName,
                                statusColor: controller.statusColor,
                                showMissedDeadline:
                                    DashboardStatusIds.showsMissedDeadline(
                                  controller.projectTeamStatus,
                                ),
                                onCardTap: () {
                                  controller.openTaskScreen(project, 0);
                                },
                                onCommunication: () =>
                                    controller.onCommunication(project),
                                onIndentDetails: () =>
                                    controller.onIndentDetails(project),
                                onDocuments: () =>
                                    controller.onDocuments(project),
                                onViewReport: () =>
                                    controller.viewReport(project),
                                onSendCredentials: () => controller
                                    .confirmAndSendCredentials(
                                  context,
                                  project,
                                ),
                                sendCredentialsEnabled:
                                    controller.canSendCredentials(crmId),
                                sendCredentialsHint: cooldownHint,
                                isSendingCredentials: sending,
                              );
                            });
                          },
                        ),
                      );
                    }

                    // Web/tablet: content-sized Wrap avoids fixed-height card
                    // whitespace. Mobile (columns == 1) keeps ListView above.
                    const horizontalPadding = 32.0;
                    const crossSpacing = 12.0;
                    const runSpacing = 12.0;
                    final cardWidth = (width -
                            horizontalPadding -
                            crossSpacing * (columns - 1)) /
                        columns;

                    return NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >=
                                n.metrics.maxScrollExtent - 200 &&
                            controller.hasMore.value) {
                          controller.loadMore();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: crossSpacing,
                              runSpacing: runSpacing,
                              children: [
                                for (var index = 0;
                                    index <
                                        controller.visibleProjects.length;
                                    index++)
                                  SizedBox(
                                    width: cardWidth,
                                    child: Obx(() {
                                      final project = controller
                                          .visibleProjects[index];
                                      final crmId = project.crmId;
                                      final cooldownHint = controller
                                          .sendCredentialsCooldownHint(
                                        crmId,
                                      );
                                      final sending = controller
                                              .isSendingCredentials.value &&
                                          controller.sendingCredentialsCrmId
                                                  .value ==
                                              crmId;
                                      return ProjectCard(
                                        project: project,
                                        index: index,
                                        compact: true,
                                        statusLabel: controller.statusName,
                                        statusColor: controller.statusColor,
                                        showMissedDeadline: DashboardStatusIds
                                            .showsMissedDeadline(
                                          controller.projectTeamStatus,
                                        ),
                                        onCardTap: () => controller
                                            .openTaskScreen(project, 0),
                                        onCommunication: () => controller
                                            .onCommunication(project),
                                        onIndentDetails: () => controller
                                            .onIndentDetails(project),
                                        onDocuments: () =>
                                            controller.onDocuments(project),
                                        onViewReport: () =>
                                            controller.viewReport(project),
                                        onSendCredentials: () => controller
                                            .confirmAndSendCredentials(
                                          context,
                                          project,
                                        ),
                                        sendCredentialsEnabled: controller
                                            .canSendCredentials(crmId),
                                        sendCredentialsHint: cooldownHint,
                                        isSendingCredentials: sending,
                                      );
                                    }),
                                  ),
                              ],
                            ),
                            if (controller.hasMore.value)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('Loading more...'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const StatusLegendBar(),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.controller,
    required this.businesses,
  });

  final ProjectListController controller;
  final List<BusinessApplications> businesses;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            controller.statusName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${controller.visibleProjects.length} projects',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150, minWidth: 110),
              child: Obx(
                () => BusinessSelector(
                  businesses: businesses,
                  selectedBusinessId: controller.selectedBusinessId.value,
                  selectedLabel: controller.selectedBusinessLabel.value,
                  onChanged: controller.selectBusiness,
                  compact: true,
                ),
              ),
            ),
            // IconButton(
            //   onPressed: controller.toggleSearchBar,
            //   icon: const Icon(Icons.search_rounded, color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }
}
