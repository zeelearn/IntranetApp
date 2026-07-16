import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/task_hierarchy_binding.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';
import 'package:Intranet/modules/projects/widgets/task_drill_down_tiles.dart';
import 'package:Intranet/modules/projects/widgets/task_summary_widget.dart';
import 'package:Intranet/modules/projects/widgets/task_tree_node.dart';

class TaskHierarchyScreen extends StatelessWidget {
  const TaskHierarchyScreen({
    super.key,
    required this.project,
    required this.userId,
    required this.currentUserName,
    this.contributionId = 0,
    this.onTaskAction,
  });

  final ProjectItem project;
  final int userId;
  final String currentUserName;
  final int contributionId;
  final void Function(TaskActionType action, HierarchyTask task)? onTaskAction;

  static Future<T?>? open<T>({
    required ProjectItem project,
    required int userId,
    required String currentUserName,
    int contributionId = 0,
    void Function(TaskActionType action, HierarchyTask task)? onTaskAction,
  }) {
    return Get.to<T>(
      () => TaskHierarchyScreen(
        project: project,
        userId: userId,
        currentUserName: currentUserName,
        contributionId: contributionId,
        onTaskAction: onTaskAction,
      ),
      binding: TaskHierarchyBinding(
        project: project,
        userId: userId,
        currentUserName: currentUserName,
        contributionId: contributionId,
        onTaskAction: onTaskAction,
      ),
    );
  }

  String get _tag => TaskHierarchyBinding.makeTag(userId, project);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TaskHierarchyController>(tag: _tag)) {
      TaskHierarchyBinding(
        project: project,
        userId: userId,
        currentUserName: currentUserName,
        contributionId: contributionId,
        onTaskAction: onTaskAction,
      ).dependencies();
    }
    final controller = Get.find<TaskHierarchyController>(tag: _tag);

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      floatingActionButton: FloatingActionButton(
        backgroundColor: DashboardColors.primary,
        onPressed: () => controller.openAddTask(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Obx(() {
            final mode = controller.viewMode.value;
            final title = controller.screenTitle;
            final canPopDrill = controller.navStack.isNotEmpty;
            return _Header(
              title: title,
              subtitle: controller.projectId.isNotEmpty
                  ? 'Project ID: ${controller.projectId}'
                  : '',
              mode: mode,
              onBack: () {
                if (mode == TaskListViewMode.drillDown && canPopDrill) {
                  controller.popDrill();
                  return;
                }
                Navigator.of(context).maybePop();
              },
              onSetMode: controller.setViewMode,
            );
          }),
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
          Obx(() {
            if (controller.viewMode.value != TaskListViewMode.drillDown) {
              return const SizedBox.shrink();
            }
            // Keep breadcrumb reactive to navStack.
            final _ = controller.navStack.length;
            return TaskBreadcrumbBar(controller: controller);
          }),
          _SearchRow(controller: controller),
          Obx(() {
            if (controller.viewMode.value == TaskListViewMode.drillDown) {
              return const SizedBox.shrink();
            }
            final total = controller.totalCount.value;
            final pending = controller.pendingCount.value;
            final inProgress = controller.inProgressCount.value;
            final completed = controller.completedCount.value;
            return _SummaryRow(
              total: total,
              pending: pending,
              inProgress: inProgress,
              completed: completed,
            );
          }),
          Expanded(
            child: Obx(() {
              final _ = controller.treeRevision.value;
              final mode = controller.viewMode.value;
              final navLen = controller.navStack.length;
              final loading = controller.isLoading.value;
              final error = controller.errorMessage.value;
              final taskCount = controller.allTasks.length;
              // Read filters so list rebuilds when My Tasks / search / filters change.
              final search = controller.searchQuery.value;
              final status = controller.statusFilter.value;
              final priority = controller.priorityFilter.value;
              final assignee = controller.assigneeFilter.value;
              final myTasks = controller.showMyTasksOnly.value;
              final filterKey = '$myTasks|$search|$status|$priority|$assignee';

              if (loading && taskCount == 0) {
                return const ProjectShimmer();
              }
              if (error != null && taskCount == 0) {
                return ProjectErrorWidget(
                  message: error,
                  onRetry: controller.refreshTasks,
                );
              }

              if (mode == TaskListViewMode.drillDown) {
                return _DrillDownList(
                  key: ValueKey('drill_${navLen}_$filterKey'),
                  controller: controller,
                  onOpenDetail: (task) =>
                      _openDetail(context, task, controller),
                  onNotify: (msg) => _notify(context, msg),
                  onCreateChild: (task) => controller.openAddTask(parent: task),
                  onEdit: (task) => controller.openEditTask(task),
                );
              }

              return _TreeList(
                key: ValueKey('tree_$filterKey'),
                controller: controller,
                onOpenDetail: (task) =>
                    _openDetail(context, task, controller),
                onNotify: (msg) => _notify(context, msg),
                onCreateChild: (task) => controller.openAddTask(parent: task),
                onEdit: (task) => controller.openEditTask(task),
              );
            }),
          ),
          const StatusLegendBar(),
        ],
      ),
    );
  }

  void _openDetail(
    BuildContext context,
    HierarchyTask task,
    TaskHierarchyController controller,
  ) {
    controller.handleAction(TaskActionType.view, task);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TaskDetailSheet(
        task: task,
        canMutate: controller.canMutate(task),
        onAction: (a) {
          Navigator.pop(context);
          if (a == TaskActionType.edit || a == TaskActionType.updateStatus) {
            controller.openEditTask(task);
            return;
          }
          if (a == TaskActionType.comments) {
            controller.openComments(task);
            return;
          }
          if (a == TaskActionType.delete) {
            controller.deleteTask(task);
            return;
          }
          controller.handleAction(a, task);
          if (a != TaskActionType.view) {
            _notify(context, '${a.name} — coming soon');
          }
        },
      ),
    );
  }

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TreeList extends StatelessWidget {
  const _TreeList({
    super.key,
    required this.controller,
    required this.onOpenDetail,
    required this.onNotify,
    required this.onCreateChild,
    required this.onEdit,
  });

  final TaskHierarchyController controller;
  final ValueChanged<HierarchyTask> onOpenDetail;
  final ValueChanged<String> onNotify;
  final ValueChanged<HierarchyTask> onCreateChild;
  final ValueChanged<HierarchyTask> onEdit;

  @override
  Widget build(BuildContext context) {
    final roots = controller.visibleRoots();
    if (roots.isEmpty) {
      return ProjectEmptyWidget(onRetry: controller.refreshTasks);
    }
    return RefreshIndicator(
      color: DashboardColors.primary,
      onRefresh: controller.refreshTasks,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        itemCount: roots.length,
        itemBuilder: (context, index) {
          return TaskTreeNode(
            key: ValueKey('root_${roots[index].id}'),
            controller: controller,
            task: roots[index],
            depth: 0,
            isLast: index == roots.length - 1,
            onView: onOpenDetail,
            onMenuAction: (action, task) {
              if (action == TaskActionType.view) {
                onOpenDetail(task);
                return;
              }
              if (action == TaskActionType.createChild) {
                onCreateChild(task);
                return;
              }
              if (action == TaskActionType.edit) {
                onEdit(task);
                return;
              }
              if (action == TaskActionType.comments) {
                controller.openComments(task);
                return;
              }
              if (action == TaskActionType.delete) {
                controller.deleteTask(task);
                return;
              }
              if (action == TaskActionType.updateStatus) {
                onEdit(task);
                return;
              }
              controller.handleAction(action, task);
              onNotify('${action.name} — coming soon');
            },
          );
        },
      ),
    );
  }
}

class _DrillDownList extends StatelessWidget {
  const _DrillDownList({
    super.key,
    required this.controller,
    required this.onOpenDetail,
    required this.onNotify,
    required this.onCreateChild,
    required this.onEdit,
  });

  final TaskHierarchyController controller;
  final ValueChanged<HierarchyTask> onOpenDetail;
  final ValueChanged<String> onNotify;
  final ValueChanged<HierarchyTask> onCreateChild;
  final ValueChanged<HierarchyTask> onEdit;

  void _onMenuAction(TaskActionType action, HierarchyTask task) {
    if (action == TaskActionType.view) {
      onOpenDetail(task);
      return;
    }
    if (action == TaskActionType.createChild) {
      onCreateChild(task);
      return;
    }
    if (action == TaskActionType.edit) {
      onEdit(task);
      return;
    }
    if (action == TaskActionType.comments) {
      controller.openComments(task);
      return;
    }
    if (action == TaskActionType.delete) {
      controller.deleteTask(task);
      return;
    }
    if (action == TaskActionType.updateStatus) {
      onEdit(task);
      return;
    }
    controller.handleAction(action, task);
    onNotify('${action.name} — coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.drillDownItems();
    if (items.isEmpty) {
      return ProjectEmptyWidget(onRetry: controller.refreshTasks);
    }

    final folders = items.where(controller.isFolder).toList(growable: false);
    final leaves =
        items.where((t) => !controller.isFolder(t)).toList(growable: false);

    // Prefer folder cards when any folder exists; otherwise timeline for leaves.
    // Mixed levels (rare): show folders first, then timeline leaves.
    return RefreshIndicator(
      color: DashboardColors.primary,
      onRefresh: controller.refreshTasks,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        children: [
          for (final folder in folders)
            TaskFolderTile(
              task: folder,
              canMutate: controller.canMutate(folder),
              onTap: () => controller.drillInto(folder),
              onAction: (action) => _onMenuAction(action, folder),
            ),
          for (var i = 0; i < leaves.length; i++)
            TaskTimelineTile(
              task: leaves[i],
              isFirst: i == 0 && folders.isEmpty,
              isLast: i == leaves.length - 1,
              canMutate: controller.canMutate(leaves[i]),
              onTap: () => onOpenDetail(leaves[i]),
              onAction: (action) => _onMenuAction(action, leaves[i]),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.onBack,
    required this.onSetMode,
  });

  final String title;
  final String subtitle;
  final TaskListViewMode mode;
  final VoidCallback onBack;
  final ValueChanged<TaskListViewMode> onSetMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            _ViewToggle(mode: mode, onSetMode: onSetMode),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.mode,
    required this.onSetMode,
  });

  final TaskListViewMode mode;
  final ValueChanged<TaskListViewMode> onSetMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleBtn(
              icon: Icons.account_tree_rounded,
              selected: mode == TaskListViewMode.tree,
              tooltip: 'Tree view',
              onTap: () => onSetMode(TaskListViewMode.tree),
            ),
            _toggleBtn(
              icon: Icons.view_list_rounded,
              selected: mode == TaskListViewMode.drillDown,
              tooltip: 'List view',
              onTap: () => onSetMode(TaskListViewMode.drillDown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn({
    required IconData icon,
    required bool selected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? DashboardColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller});

  final TaskHierarchyController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          Expanded(
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
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openFilter(context),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: DashboardColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilter(BuildContext context) async {
    String? status = controller.statusFilter.value;
    String? priority = controller.priorityFilter.value;
    String? assignee = controller.assigneeFilter.value;
    var myTasksOnly = controller.showMyTasksOnly.value;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filter Tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'My Tasks only',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      controller.effectiveMyTaskUserName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                    value: myTasksOnly,
                    activeThumbColor: DashboardColors.primary,
                    onChanged: (v) => setState(() => myTasksOnly = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    key: ValueKey('st_$status'),
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'P', child: Text('Pending')),
                      DropdownMenuItem(value: 'IP', child: Text('In Progress')),
                      DropdownMenuItem(value: 'C', child: Text('Completed')),
                    ],
                    onChanged: (v) => setState(() => status = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    key: ValueKey('pr_$priority'),
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                    ],
                    onChanged: (v) => setState(() => priority = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    key: ValueKey('as_$assignee'),
                    initialValue: assignee,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Assignee'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...controller.assigneeOptions.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (v) => setState(() => assignee = v),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          style: DashboardColors.primaryFilledButton(),
                          onPressed: () {
                            controller.applyFilters(
                              status: status,
                              priority: priority,
                              assignee: assignee,
                              myTasksOnly: myTasksOnly,
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          _chip('Total', '$total', DashboardColors.primary),
          _chip('Pending', '$pending', DashboardColors.warning),
          _chip('In Progress', '$inProgress', DashboardColors.purple),
          _chip('Completed', '$completed', DashboardColors.success),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: DashboardColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  const _TaskDetailSheet({
    required this.task,
    required this.canMutate,
    required this.onAction,
  });

  final HierarchyTask task;
  final bool canMutate;
  final void Function(TaskActionType action) onAction;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(label: task.statusName.isEmpty ? task.statusChip : task.statusName, color: task.statusColor),
                const SizedBox(width: 8),
                Text(
                  'ID: ${task.mtaskId.isNotEmpty ? task.mtaskId : task.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: DashboardColors.textMuted,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _row('Responsible', task.responsiblePerson),
            _row('Priority', task.priority),
            _row('Plan Start', ProjectDateUtils.formatReadable(task.displayPlanStart)),
            _row('Plan End', ProjectDateUtils.formatReadable(task.displayPlanEnd)),
            _row('Actual Start', ProjectDateUtils.formatReadable(task.displayActualStart)),
            _row('Actual End', ProjectDateUtils.formatReadable(task.displayActualEnd)),
            const SizedBox(height: 8),
            Text('Description', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              task.note.isEmpty ? '—' : task.note,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            if (task.attachmentList.isNotEmpty) ...[
              const SizedBox(height: 16),
              TaskAttachmentList(files: task.attachmentList),
            ],
            if (task.latestComment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Latest Comment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              Text(task.latestComment),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => onAction(TaskActionType.comments),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Comments'),
            ),
            const SizedBox(height: 8),
            if (canMutate)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAction(TaskActionType.edit),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onAction(TaskActionType.delete),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            if (canMutate) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                style: DashboardColors.primaryFilledButton(),
                onPressed: () => onAction(TaskActionType.updateStatus),
                icon: const Icon(Icons.check),
                label: const Text('Update Status'),
              ),
            ] else
              FilledButton(
                style: DashboardColors.primaryFilledButton(),
                onPressed: () => onAction(TaskActionType.view),
                child: const Text('Close'),
              ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
