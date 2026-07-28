import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/services/project_detail_local_service.dart';
import 'package:Intranet/modules/projects/services/project_detail_remote_service.dart';

class ProjectDetailRepository {
  ProjectDetailRepository({
    required ProjectDetailRemoteService remoteService,
    required ProjectDetailLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final ProjectDetailRemoteService _remote;
  final ProjectDetailLocalService _local;

  Future<ProjectDetailData?> loadOffline({
    required int franchiseeId,
    required String crmId,
  }) {
    return _local.loadDetail(franchiseeId: franchiseeId, crmId: crmId);
  }

  Future<ProjectDetailData> sync({
    required int franchiseeId,
    required String crmId,
  }) async {
    final remote = await _remote.fetchDetail(
      franchiseeId: franchiseeId,
      crmId: crmId,
    );
    final withStamp = remote.copyWith(syncedAt: DateTime.now());
    await _local.saveDetail(
      franchiseeId: franchiseeId,
      crmId: crmId,
      detail: withStamp,
    );
    return withStamp;
  }

  Future<ProjectDetailData> refresh({
    required int franchiseeId,
    required String crmId,
  }) async {
    try {
      return await sync(franchiseeId: franchiseeId, crmId: crmId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(
        franchiseeId: franchiseeId,
        crmId: crmId,
      );
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }
}
