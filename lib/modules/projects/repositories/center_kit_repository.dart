import 'package:Intranet/modules/projects/models/center_kit_item.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/services/center_kit_local_service.dart';
import 'package:Intranet/modules/projects/services/center_kit_remote_service.dart';

class CenterKitRepository {
  CenterKitRepository({
    required CenterKitRemoteService remoteService,
    required CenterKitLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final CenterKitRemoteService _remote;
  final CenterKitLocalService _local;

  Future<List<CenterKitItem>?> loadOffline({required int? businessId}) {
    return _local.loadReport(businessId: businessId);
  }

  Future<List<CenterKitItem>> sync({required int? businessId}) async {
    final list = await _remote.fetchReport(businessId: businessId);
    await _local.saveReport(businessId: businessId, items: list);
    return list;
  }

  Future<List<CenterKitItem>> refresh({required int? businessId}) async {
    try {
      return await sync(businessId: businessId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(businessId: businessId);
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }

  List<CenterKitItem> applyQuery({
    required List<CenterKitItem> source,
    required String search,
    required CenterKitFilter filter,
  }) {
    var result = source;

    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) {
        return i.franchiseeName.toLowerCase().contains(q) ||
            i.franchiseeCode.toLowerCase().contains(q) ||
            i.agreementNo.toLowerCase().contains(q) ||
            i.projectManager.toLowerCase().contains(q) ||
            i.indentId.toString().contains(q) ||
            i.stateName.toLowerCase().contains(q) ||
            i.indentStatus.toLowerCase().contains(q) ||
            i.paymentStatus.toLowerCase().contains(q) ||
            i.zoneCode.toLowerCase().contains(q);
      }).toList(growable: false);
    }

    if (filter.hasActiveFilters) {
      result = result.where((i) {
        if (filter.indentStatus != null &&
            filter.indentStatus!.isNotEmpty &&
            i.indentStatus.toLowerCase() !=
                filter.indentStatus!.toLowerCase()) {
          return false;
        }
        if (filter.paymentStatus != null &&
            filter.paymentStatus!.isNotEmpty &&
            i.paymentStatus.toLowerCase() !=
                filter.paymentStatus!.toLowerCase()) {
          return false;
        }
        if (filter.zoneCode != null &&
            filter.zoneCode!.isNotEmpty &&
            i.zoneCode.toLowerCase() != filter.zoneCode!.toLowerCase()) {
          return false;
        }
        if (filter.stateName != null &&
            filter.stateName!.isNotEmpty &&
            i.stateName.toLowerCase() != filter.stateName!.toLowerCase()) {
          return false;
        }
        if (filter.projectManager != null &&
            filter.projectManager!.isNotEmpty &&
            i.projectManager.toLowerCase() !=
                filter.projectManager!.toLowerCase()) {
          return false;
        }
        return true;
      }).toList(growable: false);
    }

    return result;
  }
}
