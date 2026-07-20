import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/project_detail_binding.dart';
import 'package:Intranet/modules/projects/bindings/task_hierarchy_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_detail_controller.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/views/task_hierarchy_screen.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_detail_widgets.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';

/// Figma-aligned Project Details with Communication / Indent / Tasks / Documents.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.userId,
    required this.currentUserName,
    required this.statusName,
    required this.statusColor,
    this.initialTab = ProjectDetailTab.communication,
    this.contributionId = 0,
    this.showMissedDeadline = false,
  });

  final ProjectItem project;
  final int userId;
  final String currentUserName;
  final String statusName;
  final Color statusColor;
  final ProjectDetailTab initialTab;
  final int contributionId;
  final bool showMissedDeadline;

  static Future<T?>? open<T>({
    required ProjectItem project,
    required int userId,
    required String currentUserName,
    required String statusName,
    required Color statusColor,
    ProjectDetailTab initialTab = ProjectDetailTab.communication,
    int contributionId = 0,
    bool showMissedDeadline = false,
  }) {
    return Get.to<T>(
      () => ProjectDetailScreen(
        project: project,
        userId: userId,
        currentUserName: currentUserName,
        statusName: statusName,
        statusColor: statusColor,
        initialTab: initialTab,
        contributionId: contributionId,
        showMissedDeadline: showMissedDeadline,
      ),
      binding: ProjectDetailBinding(
        project: project,
        userId: userId,
        currentUserName: currentUserName,
        statusName: statusName,
        statusColor: statusColor,
        initialTab: initialTab,
        contributionId: contributionId,
      ),
    );
  }

  String get _tag => ProjectDetailBinding.makeTag(userId, project);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProjectDetailController>(tag: _tag)) {
      ProjectDetailBinding(
        project: project,
        userId: userId,
        currentUserName: project.crmId.isNotEmpty ? project.crmId : currentUserName,
        statusName: statusName,
        statusColor: statusColor,
        initialTab: initialTab,
        contributionId: contributionId,
      ).dependencies();
    }
    final controller = Get.find<ProjectDetailController>(tag: _tag);

    // Ensure project tasks are available for the Tasks tab.
    TaskHierarchyBinding(
      project: project,
      userId: userId,
      currentUserName: project.crmId.isNotEmpty ? project.crmId : currentUserName,
      contributionId: contributionId,
    ).dependencies();

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      appBar: AppBar(
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            project.franchiseeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            project.crmId.isNotEmpty ? project.crmId : 'No CRM ID',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),

        actions: [
          Obx(() {
            final busy = controller.isRefreshing.value;
            return IconButton(
              tooltip: 'Refresh',
              onPressed: busy ? null : controller.refreshDetail,
              icon: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
            );
          }),
          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.more_vert, color: Colors.white),
          //   onSelected: (v) {
          //     if (v == 'refresh') controller.refreshDetail();
          //     if (v == 'tasks') {
          //       TaskHierarchyScreen.open(
          //         project: project,
          //         userId: userId,
          //         currentUserName: currentUserName,
          //         contributionId: contributionId,
          //       );
          //     }
          //   },
          //   itemBuilder: (_) => const [
          //     PopupMenuItem(value: 'refresh', child: Text('Refresh')),
          //     PopupMenuItem(value: 'tasks', child: Text('Open Task List')),
          //   ],
          // ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            final show = controller.isOffline.value ||
                controller.servingFromCache.value;
            return OfflineBanner(
              visible: show,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached data.'
                  : 'Showing cached data. Pull to refresh.',
              onRetry: controller.refreshDetail,
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.detail.value == null) {
                return const ProjectShimmer();
              }
              final err = controller.errorMessage.value;
              if (err != null && controller.detail.value == null) {
                return ProjectErrorWidget(
                  message: err,
                  onRetry: controller.refreshDetail,
                );
              }
              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshDetail,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    ProjectDetailHeaderCard(controller: controller),
                    const SizedBox(height: 12),
                    ProjectDetailTabBar(controller: controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedTab.value != ProjectDetailTab.tasks) {
          return const SizedBox.shrink();
        }
        final tag = TaskHierarchyBinding.makeTag(userId, project);
        if (!Get.isRegistered<TaskHierarchyController>(tag: tag)) {
          return const SizedBox.shrink();
        }
        final tasks = Get.find<TaskHierarchyController>(tag: tag);
        return FloatingActionButton(
          backgroundColor: DashboardColors.primary,
          onPressed: () => tasks.openAddTask(),
          child: const Icon(Icons.add, color: Colors.white),
        );
      }),
    );
  }
}
