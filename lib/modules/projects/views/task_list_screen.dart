import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/task_list_binding.dart';
import 'package:Intranet/modules/projects/controllers/task_list_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/task_meta_info.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';

/// Flat user task list opened from dashboard Pending / In Progress / Completed task cards.
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    super.key,
    required this.userId,
    required this.dashboardStatusId,
    required this.statusName,
    required this.currentUserName,
    this.statusColor = DashboardColors.primary,
    this.contributionId = 0,
  });

  final int userId;
  final int dashboardStatusId;
  final String statusName;
  final String currentUserName;
  final Color statusColor;
  final int contributionId;

  static Future<T?>? open<T>({
    required int userId,
    required int dashboardStatusId,
    required String statusName,
    required String currentUserName,
    Color statusColor = DashboardColors.primary,
    int contributionId = 0,
  }) {
    final apiStatus =
        DashboardStatusIds.apiStatusForTaskCard(dashboardStatusId);
    return Get.to<T>(
      () => TaskListScreen(
        userId: userId,
        dashboardStatusId: dashboardStatusId,
        statusName: statusName,
        statusColor: statusColor,
        currentUserName: currentUserName,
        contributionId: contributionId,
      ),
      binding: TaskListBinding(
        userId: userId,
        dashboardStatusId: dashboardStatusId,
        apiStatus: apiStatus,
        statusName: statusName,
        statusColor: statusColor,
        currentUserName: currentUserName,
        contributionId: contributionId,
      ),
    );
  }

  String get _tag {
    final apiStatus =
        DashboardStatusIds.apiStatusForTaskCard(dashboardStatusId);
    return TaskListBinding.makeTag(userId, apiStatus);
  }

  @override
  Widget build(BuildContext context) {
    final apiStatus =
        DashboardStatusIds.apiStatusForTaskCard(dashboardStatusId);
    if (!Get.isRegistered<TaskListController>(tag: _tag)) {
      TaskListBinding(
        userId: userId,
        dashboardStatusId: dashboardStatusId,
        apiStatus: apiStatus,
        statusName: statusName,
        statusColor: statusColor,
        currentUserName: currentUserName,
        contributionId: contributionId,
      ).dependencies();
    }
    final controller = Get.find<TaskListController>(tag: _tag);

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          _Header(title: statusName, color: statusColor),
          Obx(() {
            final offline =
                controller.isOffline.value || controller.servingFromCache.value;
            return OfflineBanner(
              visible: offline,
              onRetry: controller.isOffline.value
                  ? null
                  : controller.refreshTasks,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached tasks.'
                  : 'Showing cached data. Pull to refresh.',
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: GoogleFonts.poppins(fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final loading = controller.isLoading.value;
              final error = controller.errorMessage.value;
              final count = controller.allTasks.length;
              final items =
                  controller.visibleTasks.toList(growable: false);

              if (loading && count == 0) {
                return const ProjectShimmer();
              }
              if (error != null && count == 0) {
                return ProjectErrorWidget(
                  message: error,
                  onRetry: controller.refreshTasks,
                );
              }
              if (items.isEmpty) {
                return ProjectEmptyWidget(onRetry: controller.refreshTasks);
              }
              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshTasks,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final task = items[index];
                    return _UserTaskCard(
                      task: task,
                      showMissed: DashboardStatusIds.showsMissedDeadline(
                        dashboardStatusId,
                      ),
                      onTap: () => controller.openTask(task),
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
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
      ),
    );
  }
}

class _UserTaskCard extends StatelessWidget {
  const _UserTaskCard({
    required this.task,
    required this.onTap,
    required this.showMissed,
  });

  final UserTaskItem task;
  final VoidCallback onTap;
  final bool showMissed;

  @override
  Widget build(BuildContext context) {
    final missed =
        showMissed && ProjectDateUtils.isMissed(task.dueDate);
    final projectLabel = task.franchiseeName.isNotEmpty
        ? task.franchiseeName
        : (task.projectId.isNotEmpty ? task.projectId : 'Project');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        shadowColor: const Color(0x14000000),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: task.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    task.statusChip == 'C'
                        ? Icons.check_circle_rounded
                        : Icons.task_alt_rounded,
                    color: task.statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.isEmpty ? 'Untitled Task' : task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        projectLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TaskMetaInfo(
                        responsiblePerson: task.responsiblePerson,
                        planStart: task.planStartDate,
                        planEnd: task.dueDate,
                        actualStart: task.startDate,
                        actualEnd: task.endDate,
                        highlightMissedPlanEnd: missed,
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: task.statusChip, color: task.statusColor),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: DashboardColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
