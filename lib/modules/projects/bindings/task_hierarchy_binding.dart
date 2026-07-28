import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/services/task_local_service.dart';
import 'package:Intranet/modules/projects/services/task_remote_service.dart';

class TaskHierarchyBinding extends Bindings {
  TaskHierarchyBinding({
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

  String get tag =>
      'tasks_${userId}_${project.crmId.isNotEmpty ? project.crmId : project.id}';

  @override
  void dependencies() {
    if (!Get.isRegistered<TaskRemoteService>(tag: tag)) {
      Get.put<TaskRemoteService>(TaskRemoteService(), tag: tag);
    }
    if (!Get.isRegistered<TaskLocalService>(tag: tag)) {
      Get.put<TaskLocalService>(TaskLocalService(), tag: tag);
    }
    if (!Get.isRegistered<TaskRepository>(tag: tag)) {
      Get.put<TaskRepository>(
        TaskRepository(
          remoteService: Get.find<TaskRemoteService>(tag: tag),
          localService: Get.find<TaskLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }
    if (!Get.isRegistered<TaskHierarchyController>(tag: tag)) {
      Get.put<TaskHierarchyController>(
        TaskHierarchyController(
          project: project,
          userId: userId,
          currentUserName: currentUserName,
          contributionId: contributionId,
          repository: Get.find<TaskRepository>(tag: tag),
          onTaskAction: onTaskAction,
        ),
        tag: tag,
      );
    }
  }

  static String makeTag(int userId, ProjectItem project) =>
      'tasks_${userId}_${project.crmId.isNotEmpty ? project.crmId : project.id}';
}
