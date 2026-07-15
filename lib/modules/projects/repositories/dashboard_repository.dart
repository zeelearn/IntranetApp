import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/dashboard_summary.dart';
import 'package:Intranet/modules/projects/services/dashboard_local_service.dart';
import 'package:Intranet/modules/projects/services/dashboard_remote_service.dart';

class DashboardRepository {
  DashboardRepository({
    required DashboardRemoteService remoteService,
    required DashboardLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final DashboardRemoteService _remote;
  final DashboardLocalService _local;

  Future<DashboardSummary?> loadOffline({
    required int userId,
    int? businessId,
  }) {
    return _local.loadSummary(userId: userId, businessId: businessId);
  }

  Future<DashboardSummary> sync({
    required int userId,
    int? businessId,
  }) async {
    final summary = await _remote.fetchDashboard(
      userId: userId,
      businessId: businessId,
    );

    await _local.saveSummary(
      userId: userId,
      businessId: businessId,
      summary: summary,
    );

    return summary;
  }

  /// Tries network sync; on failure returns cache when available.
  Future<DashboardSummary> refresh({
    required int userId,
    int? businessId,
  }) async {
    try {
      return await sync(userId: userId, businessId: businessId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(
        userId: userId,
        businessId: businessId,
      );
      if (cached != null) {
        // Preserve cache for offline/network failures.
        if (failure.type == DashboardFailureType.noInternet ||
            failure.type == DashboardFailureType.timeout ||
            failure.type == DashboardFailureType.server) {
          return cached;
        }
      }
      rethrow;
    }
  }
}
