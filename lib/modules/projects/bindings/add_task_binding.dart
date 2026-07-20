import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/add_task_controller.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/services/task_local_service.dart';
import 'package:Intranet/modules/projects/services/task_remote_service.dart';

class AddTaskBinding extends Bindings {
  AddTaskBinding({required this.args});

  final AddTaskArgs args;

  String get tag =>
      'add_task_${args.userId}_${args.projectId}_${args.taskId}_${args.parentTaskId}';

  static String makeTag(AddTaskArgs args) =>
      'add_task_${args.userId}_${args.projectId}_${args.taskId}_${args.parentTaskId}';

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
    if (!Get.isRegistered<AddTaskController>(tag: tag)) {
      Get.put<AddTaskController>(
        AddTaskController(
          args: args,
          repository: Get.find<TaskRepository>(tag: tag),
        ),
        tag: tag,
      );
    }
  }
}
