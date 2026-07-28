import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/task_list_controller.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/services/task_local_service.dart';
import 'package:Intranet/modules/projects/services/task_remote_service.dart';

class TaskListBinding extends Bindings {
  TaskListBinding({
    required this.userId,
    required this.dashboardStatusId,
    required this.apiStatus,
    required this.statusName,
    required this.statusColor,
    required this.currentUserName,
    this.contributionId = 0,
  });

  final int userId;
  final int dashboardStatusId;
  final int apiStatus;
  final String statusName;
  final Color statusColor;
  final String currentUserName;
  final int contributionId;

  String get tag => 'task_list_${userId}_$apiStatus';

  static String makeTag(int userId, int apiStatus) =>
      'task_list_${userId}_$apiStatus';

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
    if (!Get.isRegistered<TaskListController>(tag: tag)) {
      Get.put<TaskListController>(
        TaskListController(
          userId: userId,
          dashboardStatusId: dashboardStatusId,
          apiStatus: apiStatus,
          statusName: statusName,
          statusColor: statusColor,
          currentUserName: currentUserName,
          contributionId: contributionId,
          repository: Get.find<TaskRepository>(tag: tag),
        ),
        tag: tag,
      );
    }
  }
}
