import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_business.dart';
import 'package:Intranet/modules/projects/services/project_business_local_service.dart';
import 'package:Intranet/modules/projects/services/project_business_remote_service.dart';

class ProjectBusinessRepository {
  ProjectBusinessRepository({
    required ProjectBusinessRemoteService remoteService,
    required ProjectBusinessLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final ProjectBusinessRemoteService _remote;
  final ProjectBusinessLocalService _local;

  /// Tries network first; on success caches. On failure returns cache (may be empty).
  Future<List<ProjectBusiness>> sync({bool allowOfflineFallback = true}) async {
    try {
      final remote = await _remote.fetchBusinesses();
      await _local.saveBusinesses(remote);
      return remote;
    } on DashboardFailure {
      if (!allowOfflineFallback) rethrow;
      return _local.loadBusinesses();
    } catch (_) {
      if (!allowOfflineFallback) rethrow;
      return _local.loadBusinesses();
    }
  }

  Future<List<ProjectBusiness>> loadOffline() => _local.loadBusinesses();
}
