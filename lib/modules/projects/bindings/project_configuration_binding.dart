import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';
import 'package:Intranet/modules/projects/services/api_project_reassignment_repository.dart';

class ProjectConfigurationBinding extends Bindings {
  ProjectConfigurationBinding({
    required this.userId,
    required this.managerCode,
  });

  /// BPMS business user id (`UpdateTaskUser.user_id`).
  final int userId;

  /// Logged-in employee code (`GetMyTeamForProjects.ManagerCode`).
  final String managerCode;

  @override
  void dependencies() {
    final tag = makeTag(userId);

    if (!Get.isRegistered<ProjectReassignmentRepository>(tag: tag)) {
      Get.put<ProjectReassignmentRepository>(
        ApiProjectReassignmentRepository(
          managerCode: managerCode,
          actingUserId: userId,
        ),
        tag: tag,
      );
    }

    if (!Get.isRegistered<ProjectConfigurationController>(tag: tag)) {
      Get.put<ProjectConfigurationController>(
        ProjectConfigurationController(
          repository: Get.find<ProjectReassignmentRepository>(tag: tag),
        ),
        tag: tag,
      );
    }
  }

  static String makeTag(int userId) => 'project_configuration_$userId';

  static void deleteIfRegistered(int userId) {
    final tag = makeTag(userId);
    if (Get.isRegistered<ProjectConfigurationController>(tag: tag)) {
      Get.delete<ProjectConfigurationController>(tag: tag, force: true);
    }
    if (Get.isRegistered<ProjectReassignmentRepository>(tag: tag)) {
      Get.delete<ProjectReassignmentRepository>(tag: tag, force: true);
    }
  }
}
