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
    required this.displayName,
    required this.businesses,
    this.businessId,
    this.onCardTap,
    this.onQuickAction,
  });

  final int userId;
  final int? businessId;
  final String displayName;
  final List<BusinessApplications> businesses;
  final void Function(int statusId, String statusName)? onCardTap;
  final void Function(QuickActionType action)? onQuickAction;

  @override
  void dependencies() {
    final remote = Get.put<DashboardRemoteService>(
      DashboardRemoteService(),
      permanent: false,
    );
    final local = Get.put<DashboardLocalService>(
      DashboardLocalService(),
      permanent: false,
    );
    final repository = Get.put<DashboardRepository>(
      DashboardRepository(remoteService: remote, localService: local),
      permanent: false,
    );

    Get.put<DashboardController>(
      DashboardController(
        userId: userId,
        businessId: businessId,
        displayName: displayName,
        businesses: businesses,
        repository: repository,
        onCardTap: onCardTap,
        onQuickAction: onQuickAction,
      ),
      permanent: false,
    );
  }
}
