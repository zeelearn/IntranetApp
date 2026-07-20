import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/controllers/dashboard_controller.dart';
import 'package:Intranet/modules/projects/models/quick_action_type.dart';
import 'package:Intranet/modules/projects/repositories/dashboard_repository.dart';
import 'package:Intranet/modules/projects/services/dashboard_local_service.dart';
import 'package:Intranet/modules/projects/services/dashboard_remote_service.dart';

class DashboardBinding extends Bindings {
  DashboardBinding({
    required this.userId,
    required this.userName,
    required this.businesses,
    this.businessId,
    this.businessName = '',
    this.onCardTap,
    this.onQuickAction,
  });

  final int userId;
  final int? businessId;
  final String userName;
  final String businessName;
  final List<BusinessApplications> businesses;
  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;

  String get tag => makeTag(userId);

  static String makeTag(int userId) => 'projects_dashboard_$userId';

  /// Removes previous dashboard deps so each open starts a clean load.
  static void deleteIfRegistered(int userId) {
    final tag = makeTag(userId);
    if (Get.isRegistered<DashboardController>(tag: tag)) {
      Get.delete<DashboardController>(tag: tag, force: true);
    }
    if (Get.isRegistered<DashboardRepository>(tag: tag)) {
      Get.delete<DashboardRepository>(tag: tag, force: true);
    }
    if (Get.isRegistered<DashboardLocalService>(tag: tag)) {
      Get.delete<DashboardLocalService>(tag: tag, force: true);
    }
    if (Get.isRegistered<DashboardRemoteService>(tag: tag)) {
      Get.delete<DashboardRemoteService>(tag: tag, force: true);
    }
  }

  @override
  void dependencies() {
    deleteIfRegistered(userId);

    final remote = Get.put<DashboardRemoteService>(
      DashboardRemoteService(),
      tag: tag,
    );
    final local = Get.put<DashboardLocalService>(
      DashboardLocalService(),
      tag: tag,
    );
    final repository = Get.put<DashboardRepository>(
      DashboardRepository(remoteService: remote, localService: local),
      tag: tag,
    );

    Get.put<DashboardController>(
      DashboardController(
        userId: userId,
        businessId: businessId,
        userName: userName,
        businessName: businessName,
        businesses: businesses,
        repository: repository,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
      ),
      tag: tag,
    );
  }
}
