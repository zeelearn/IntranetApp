import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/task_comments_controller.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';
import 'package:Intranet/modules/projects/repositories/task_comments_repository.dart';
import 'package:Intranet/modules/projects/services/task_comments_local_service.dart';
import 'package:Intranet/modules/projects/services/task_comments_remote_service.dart';

class TaskCommentsBinding extends Bindings {
  TaskCommentsBinding({required this.args});

  final TaskCommentsArgs args;

  String get tag => makeTag(args);

  static String makeTag(TaskCommentsArgs args) =>
      'task_comments_${args.userId}_${args.task.id}';

  @override
  void dependencies() {
    if (!Get.isRegistered<TaskCommentsRemoteService>(tag: tag)) {
      Get.put<TaskCommentsRemoteService>(
        TaskCommentsRemoteService(),
        tag: tag,
      );
    }
    if (!Get.isRegistered<TaskCommentsLocalService>(tag: tag)) {
      Get.put<TaskCommentsLocalService>(
        TaskCommentsLocalService(),
        tag: tag,
      );
    }
    if (!Get.isRegistered<TaskCommentsRepository>(tag: tag)) {
      Get.put<TaskCommentsRepository>(
        TaskCommentsRepository(
          remoteService: Get.find<TaskCommentsRemoteService>(tag: tag),
          localService: Get.find<TaskCommentsLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }
    if (!Get.isRegistered<TaskCommentsController>(tag: tag)) {
      Get.put<TaskCommentsController>(
        TaskCommentsController(
          args: args,
          repository: Get.find<TaskCommentsRepository>(tag: tag),
        ),
        tag: tag,
      );
    }
  }
}
