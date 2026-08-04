import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/visual_chart_item.dart';
import 'package:Intranet/modules/projects/services/visual_charts_local_service.dart';
import 'package:Intranet/modules/projects/services/visual_charts_remote_service.dart';

class VisualChartsRepository {
  VisualChartsRepository({
    required VisualChartsRemoteService remoteService,
    required VisualChartsLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final VisualChartsRemoteService _remote;
  final VisualChartsLocalService _local;

  Future<List<VisualChartItem>?> loadOffline({
    required String userType,
    required int userId,
  }) {
    return _local.loadCharts(userType: userType, userId: userId);
  }

  Future<List<VisualChartItem>> sync({
    required String userType,
    required int userId,
  }) async {
    final list = await _remote.fetchCharts(
      userType: userType,
      userId: userId,
    );
    await _local.saveCharts(
      userType: userType,
      userId: userId,
      charts: list,
    );
    return list;
  }

  Future<List<VisualChartItem>> refresh({
    required String userType,
    required int userId,
  }) async {
    try {
      return await sync(userType: userType, userId: userId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(userType: userType, userId: userId);
      if (cached != null &&
          (failure.type == DashboardFailureType.noInternet ||
              failure.type == DashboardFailureType.timeout ||
              failure.type == DashboardFailureType.server)) {
        return cached;
      }
      rethrow;
    }
  }

  List<VisualChartItem> applySearch({
    required List<VisualChartItem> source,
    required String search,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
