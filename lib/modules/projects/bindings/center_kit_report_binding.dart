import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/center_kit_report_controller.dart';
import 'package:Intranet/modules/projects/repositories/center_kit_repository.dart';
import 'package:Intranet/modules/projects/services/center_kit_local_service.dart';
import 'package:Intranet/modules/projects/services/center_kit_remote_service.dart';

class CenterKitReportBinding extends Bindings {
  CenterKitReportBinding({this.businessId});

  final int? businessId;

  @override
  void dependencies() {
    final tag = makeTag(businessId);

    if (!Get.isRegistered<CenterKitRemoteService>(tag: tag)) {
      Get.put<CenterKitRemoteService>(CenterKitRemoteService(), tag: tag);
    }
    if (!Get.isRegistered<CenterKitLocalService>(tag: tag)) {
      Get.put<CenterKitLocalService>(CenterKitLocalService(), tag: tag);
    }
    if (!Get.isRegistered<CenterKitRepository>(tag: tag)) {
      Get.put<CenterKitRepository>(
        CenterKitRepository(
          remoteService: Get.find<CenterKitRemoteService>(tag: tag),
          localService: Get.find<CenterKitLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }

    Get.put<CenterKitReportController>(
      CenterKitReportController(
        businessId: businessId,
        repository: Get.find<CenterKitRepository>(tag: tag),
      ),
      tag: tag,
    );
  }

  static String makeTag(int? businessId) =>
      'center_kit_report_${businessId ?? 'all'}';

  static void deleteIfRegistered(int? businessId) {
    final tag = makeTag(businessId);
    if (Get.isRegistered<CenterKitReportController>(tag: tag)) {
      Get.delete<CenterKitReportController>(tag: tag);
    }
    if (Get.isRegistered<CenterKitRepository>(tag: tag)) {
      Get.delete<CenterKitRepository>(tag: tag);
    }
    if (Get.isRegistered<CenterKitLocalService>(tag: tag)) {
      Get.delete<CenterKitLocalService>(tag: tag);
    }
    if (Get.isRegistered<CenterKitRemoteService>(tag: tag)) {
      Get.delete<CenterKitRemoteService>(tag: tag);
    }
  }
}
