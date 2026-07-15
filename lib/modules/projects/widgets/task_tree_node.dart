import 'package:flutter/material.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/widgets/task_figma_card.dart';

/// Pure widget tree node — no nested `Obx`.
/// Parent screen rebuilds when [TaskHierarchyController.treeRevision] changes.
class TaskTreeNode extends StatelessWidget {
  const TaskTreeNode({
    super.key,
    required this.controller,
    required this.task,
    required this.depth,
    required this.isLast,
    required this.onView,
    this.onMenuAction,
  });

  final TaskHierarchyController controller;
  final HierarchyTask task;
  final int depth;
  final bool isLast;
  final ValueChanged<HierarchyTask> onView;
  final void Function(TaskActionType action, HierarchyTask task)? onMenuAction;

  @override
  Widget build(BuildContext context) {
    final expanded = controller.isExpanded(task.id);
    final folder = controller.isFolder(task);
    final children =
        folder ? controller.childrenOf(task.id) : const <HierarchyTask>[];

    void dispatch(TaskActionType action) {
      if (onMenuAction != null) {
        onMenuAction!(action, task);
      } else {
        controller.handleAction(action, task);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TaskHierarchyRail(
            depth: depth,
            isLast: isLast,
            child: TaskFigmaCard(
              task: task,
              isFolder: folder,
              expanded: expanded,
              canMutate: controller.canMutate(task),
              onTap: folder
                  ? () => controller.toggleExpand(task.id)
                  : () => onView(task),
              onAction: dispatch,
            ),
          ),
        ),
        if (expanded && folder)
          Column(
            children: [
              for (var i = 0; i < children.length; i++)
                TaskTreeNode(
                  controller: controller,
                  task: children[i],
                  depth: depth + 1,
                  isLast: i == children.length - 1,
                  onView: onView,
                  onMenuAction: onMenuAction,
                ),
            ],
          ),
      ],
    );
  }
}
