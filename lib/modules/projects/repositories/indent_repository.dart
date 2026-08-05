import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/models/payment_link_result.dart';
import 'package:Intranet/modules/projects/services/indent_local_service.dart';
import 'package:Intranet/modules/projects/services/indent_remote_service.dart';

class IndentRepository {
  IndentRepository({
    required IndentRemoteService remoteService,
    required IndentLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final IndentRemoteService _remote;
  final IndentLocalService _local;

  Future<List<IndentItem>?> loadOffline({
    required int userId,
    required String businessId,
  }) {
    return _local.loadIndents(userId: userId, businessId: businessId);
  }

  Future<List<IndentItem>> sync({
    required int userId,
    required String businessId,
  }) async {
    final list = await _remote.fetchIndents(
      userId: userId,
      businessId: businessId,
    );
    await _local.saveIndents(
      userId: userId,
      businessId: businessId,
      indents: list,
    );
    return list;
  }

  Future<List<IndentItem>> refresh({
    required int userId,
    required String businessId,
  }) async {
    try {
      return await sync(userId: userId, businessId: businessId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(userId: userId, businessId: businessId);
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }

  Future<PaymentLinkResult> generatePaymentLink({required int indentId}) {
    return _remote.generatePaymentLink(indentId: indentId);
  }

  List<IndentItem> applyQuery({
    required List<IndentItem> source,
    required String search,
    required IndentListFilter filter,
  }) {
    var result = source;

    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((i) {
        return i.franchiseeName.toLowerCase().contains(q) ||
            i.franchiseeCode.toLowerCase().contains(q) ||
            i.agreementNo.toLowerCase().contains(q) ||
            i.createdBy.toLowerCase().contains(q) ||
            i.indentId.toString().contains(q) ||
            i.stateName.toLowerCase().contains(q) ||
            i.indentStatus.toLowerCase().contains(q) ||
            i.paymentStatus.toLowerCase().contains(q) ||
            i.projectStatus.toLowerCase().contains(q);
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
        if (filter.projectStatus != null &&
            filter.projectStatus!.isNotEmpty &&
            i.projectStatus.toLowerCase() !=
                filter.projectStatus!.toLowerCase()) {
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
        return true;
      }).toList(growable: false);
    }

    return result;
  }
}
