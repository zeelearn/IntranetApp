import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/visual_charts_controller.dart';
import 'package:Intranet/modules/projects/repositories/visual_charts_repository.dart';
import 'package:Intranet/modules/projects/services/visual_charts_local_service.dart';
import 'package:Intranet/modules/projects/services/visual_charts_remote_service.dart';

class VisualChartsBinding extends Bindings {
  VisualChartsBinding({
    required this.userId,
    required this.userType,
  });

  final int userId;
  final String userType;

  @override
  void dependencies() {
    final tag = makeTag(userId, userType);

    if (!Get.isRegistered<VisualChartsRemoteService>(tag: tag)) {
      Get.put<VisualChartsRemoteService>(VisualChartsRemoteService(), tag: tag);
    }
    if (!Get.isRegistered<VisualChartsLocalService>(tag: tag)) {
      Get.put<VisualChartsLocalService>(VisualChartsLocalService(), tag: tag);
    }
    if (!Get.isRegistered<VisualChartsRepository>(tag: tag)) {
      Get.put<VisualChartsRepository>(
        VisualChartsRepository(
          remoteService: Get.find<VisualChartsRemoteService>(tag: tag),
          localService: Get.find<VisualChartsLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }

    Get.put<VisualChartsController>(
      VisualChartsController(
        userId: userId,
        userType: userType,
        repository: Get.find<VisualChartsRepository>(tag: tag),
      ),
      tag: tag,
    );
  }

  static String makeTag(int userId, String userType) =>
      'visual_charts_${userType}_$userId';

  static void deleteIfRegistered(int userId, String userType) {
    final tag = makeTag(userId, userType);
    if (Get.isRegistered<VisualChartsController>(tag: tag)) {
      Get.delete<VisualChartsController>(tag: tag);
    }
    if (Get.isRegistered<VisualChartsRepository>(tag: tag)) {
      Get.delete<VisualChartsRepository>(tag: tag);
    }
    if (Get.isRegistered<VisualChartsLocalService>(tag: tag)) {
      Get.delete<VisualChartsLocalService>(tag: tag);
    }
    if (Get.isRegistered<VisualChartsRemoteService>(tag: tag)) {
      Get.delete<VisualChartsRemoteService>(tag: tag);
    }
  }
}
