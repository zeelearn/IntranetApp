import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/indent_list_controller.dart';
import 'package:Intranet/modules/projects/repositories/indent_repository.dart';
import 'package:Intranet/modules/projects/services/indent_local_service.dart';
import 'package:Intranet/modules/projects/services/indent_remote_service.dart';

class IndentListBinding extends Bindings {
  IndentListBinding({
    required this.userId,
    required this.businessId,
  });

  final int userId;
  final String businessId;

  @override
  void dependencies() {
    final tag = makeTag(userId, businessId);

    if (!Get.isRegistered<IndentRemoteService>(tag: tag)) {
      Get.put<IndentRemoteService>(IndentRemoteService(), tag: tag);
    }
    if (!Get.isRegistered<IndentLocalService>(tag: tag)) {
      Get.put<IndentLocalService>(IndentLocalService(), tag: tag);
    }
    if (!Get.isRegistered<IndentRepository>(tag: tag)) {
      Get.put<IndentRepository>(
        IndentRepository(
          remoteService: Get.find<IndentRemoteService>(tag: tag),
          localService: Get.find<IndentLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }

    Get.put<IndentListController>(
      IndentListController(
        userId: userId,
        businessId: businessId,
        repository: Get.find<IndentRepository>(tag: tag),
      ),
      tag: tag,
    );
  }

  static String makeTag(int userId, String businessId) =>
      'indent_list_${userId}_$businessId';

  static void deleteIfRegistered(int userId, String businessId) {
    final tag = makeTag(userId, businessId);
    if (Get.isRegistered<IndentListController>(tag: tag)) {
      Get.delete<IndentListController>(tag: tag);
    }
    if (Get.isRegistered<IndentRepository>(tag: tag)) {
      Get.delete<IndentRepository>(tag: tag);
    }
    if (Get.isRegistered<IndentLocalService>(tag: tag)) {
      Get.delete<IndentLocalService>(tag: tag);
    }
    if (Get.isRegistered<IndentRemoteService>(tag: tag)) {
      Get.delete<IndentRemoteService>(tag: tag);
    }
  }
}
