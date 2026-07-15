import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/task_comments_controller.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';

class TaskCommentsBinding extends Bindings {
  TaskCommentsBinding({required this.args});

  final TaskCommentsArgs args;

  String get tag => makeTag(args);

  static String makeTag(TaskCommentsArgs args) =>
      'task_comments_${args.userId}_${args.task.id}';

  @override
  void dependencies() {
    if (!Get.isRegistered<TaskCommentsController>(tag: tag)) {
      Get.put<TaskCommentsController>(
        TaskCommentsController(args: args),
        tag: tag,
      );
    }
  }
}
