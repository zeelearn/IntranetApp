import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/task_comments_payload.dart';
import 'package:Intranet/modules/projects/services/task_comments_local_service.dart';
import 'package:Intranet/modules/projects/services/task_comments_remote_service.dart';

class TaskCommentsRepository {
  TaskCommentsRepository({
    required TaskCommentsRemoteService remoteService,
    required TaskCommentsLocalService localService,
  })  : _remote = remoteService,
        _local = localService;

  final TaskCommentsRemoteService _remote;
  final TaskCommentsLocalService _local;

  Future<TaskCommentsPayload?> loadOffline({required String taskId}) {
    return _local.load(taskId: taskId);
  }

  Future<TaskCommentsPayload> sync({required String taskId}) async {
    final remote = await _remote.fetchCommentsAndFiles(taskId: taskId);
    final stamped = remote.copyWith(syncedAt: DateTime.now());
    await _local.save(taskId: taskId, payload: stamped);
    return stamped;
  }

  Future<TaskCommentsPayload> refresh({required String taskId}) async {
    try {
      return await sync(taskId: taskId);
    } on DashboardFailure catch (failure) {
      final cached = await loadOffline(taskId: taskId);
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
