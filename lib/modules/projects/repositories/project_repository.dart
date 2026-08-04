import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/models/project_list_filter.dart';
import 'package:Intranet/modules/projects/models/send_credentials_result.dart';
import 'package:Intranet/modules/projects/services/credentials_cooldown_store.dart';
import 'package:Intranet/modules/projects/services/project_local_service.dart';
import 'package:Intranet/modules/projects/services/project_remote_service.dart';

class ProjectRepository {
  ProjectRepository({
    required ProjectRemoteService remoteService,
    required ProjectLocalService localService,
    CredentialsCooldownStore? credentialsCooldownStore,
  })  : _remote = remoteService,
        _local = localService,
        _cooldown = credentialsCooldownStore ?? CredentialsCooldownStore();

  final ProjectRemoteService _remote;
  final ProjectLocalService _local;
  final CredentialsCooldownStore _cooldown;

  static const int defaultPageSize = 20;

  CredentialsCooldownStore get credentialsCooldown => _cooldown;

  Future<List<ProjectItem>?> loadOffline({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) {
    return _local.loadProjects(
      userId: userId,
      projectTeamStatus: projectTeamStatus,
      businessId: businessId,
    );
  }

  Future<List<ProjectItem>> sync({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) async {
    final list = await _remote.fetchProjects(
      userId: userId,
      projectTeamStatus: projectTeamStatus,
      businessId: businessId,
    );
    await _local.saveProjects(
      userId: userId,
      projectTeamStatus: projectTeamStatus,
      businessId: businessId,
      projects: list,
    );
    return list;
  }

  Future<List<ProjectItem>> refresh({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) async {
    try {
      return await sync(
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: businessId,
      );
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(
        userId: userId,
        projectTeamStatus: projectTeamStatus,
        businessId: businessId,
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

  Future<SendCredentialsResult> sendTempCredentials({
    required String crmId,
  }) async {
    final canSend = await _cooldown.canSend(crmId);
    if (!canSend) {
      final left = await _cooldown.remaining(crmId);
      final label = CredentialsCooldownStore.formatRemaining(
        left ?? Duration.zero,
      );
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message:
            'Credentials were already sent. Please wait $label before sending again.',
      );
    }

    final result = await _remote.sendTempCredentials(crmId: crmId);
    await _cooldown.markSent(crmId);
    return result;
  }

  /// Client-side search + filter. Pagination-ready (page/pageSize applied last).
  List<ProjectItem> applyQuery({
    required List<ProjectItem> source,
    required String search,
    required ProjectListFilter filter,
    int page = 1,
    int pageSize = defaultPageSize,
    bool paginate = false,
  }) {
    var result = source;

    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) {
        return p.crmId.toLowerCase().contains(q) ||
            p.franchiseeName.toLowerCase().contains(q) ||
            p.createdBy.toLowerCase().contains(q) ||
            p.catchmentArea.toLowerCase().contains(q) ||
            p.tierName.toLowerCase().contains(q) ||
            p.feeType.toLowerCase().contains(q) ||
            p.title.toLowerCase().contains(q);
      }).toList(growable: false);
    }

    if (filter.hasActiveFilters) {
      result = result.where((p) {
        if (filter.feeType != null &&
            filter.feeType!.isNotEmpty &&
            p.feeType.toLowerCase() != filter.feeType!.toLowerCase()) {
          return false;
        }
        if (filter.tierName != null &&
            filter.tierName!.isNotEmpty &&
            p.tierName.toLowerCase() != filter.tierName!.toLowerCase()) {
          return false;
        }
        if (filter.createdBy != null &&
            filter.createdBy!.isNotEmpty &&
            !p.createdBy
                .toLowerCase()
                .contains(filter.createdBy!.toLowerCase())) {
          return false;
        }
        if (filter.catchmentArea != null &&
            filter.catchmentArea!.isNotEmpty &&
            !p.catchmentArea
                .toLowerCase()
                .contains(filter.catchmentArea!.toLowerCase())) {
          return false;
        }
        return true;
      }).toList(growable: false);
    }

    if (!paginate) return result;
    final start = (page - 1) * pageSize;
    if (start >= result.length) return const [];
    return result.skip(start).take(pageSize).toList(growable: false);
  }
}
