import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';
import 'package:Intranet/modules/projects/services/mock_project_reassignment_service.dart';

class ProjectConfigurationBinding extends Bindings {
  ProjectConfigurationBinding({required this.userId});

  final int userId;

  @override
  void dependencies() {
    final tag = makeTag(userId);

    if (!Get.isRegistered<ProjectReassignmentRepository>(tag: tag)) {
      Get.put<ProjectReassignmentRepository>(
        MockProjectReassignmentRepository(),
        tag: tag,
      );
    }

    Get.put<ProjectConfigurationController>(
      ProjectConfigurationController(
        repository: Get.find<ProjectReassignmentRepository>(tag: tag),
      ),
      tag: tag,
    );
  }

  static String makeTag(int userId) => 'project_configuration_$userId';

  static void deleteIfRegistered(int userId) {
    final tag = makeTag(userId);
    if (Get.isRegistered<ProjectConfigurationController>(tag: tag)) {
      Get.delete<ProjectConfigurationController>(tag: tag);
    }
    if (Get.isRegistered<ProjectReassignmentRepository>(tag: tag)) {
      Get.delete<ProjectReassignmentRepository>(tag: tag);
    }
  }
}
