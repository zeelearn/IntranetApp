import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/user_task_item.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

class TaskRemoteService {
  TaskRemoteService({
    http.Client? client,
    this.baseUrl = LocalStrings.bpms,
    this.fetchPath = '/api/bp/Gettaskdata',
    this.addPath = '/${LocalStrings.API_INSERT_BPMS_NEW_TASK}',
    this.updatePath = '/${LocalStrings.API_UPDATE_TASKDETAILS}',
    this.deletePath = '/${LocalStrings.API_BPMS_DELETETASK}',
    this.byUserPath = '/api/bp/GettaskbyUser',
    this.timeout = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String fetchPath;
  final String addPath;
  final String updatePath;
  final String deletePath;
  final String byUserPath;
  final Duration timeout;

  Future<List<HierarchyTask>> fetchTasks({
    required String projectId,
    required int userId,
  }) async {
    final decoded = await _postJson(
      path: fetchPath,
      body: {
        'projectID': projectId,
        'UserId': userId,
      },
    );
    return HierarchyTaskResponse.fromJson(decoded).tasks;
  }

  /// Creates a task via `API_INSERT_BPMS_NEW_TASK`. Returns saved task from data[].
  Future<AddTaskResult> addTask(AddTaskRequest request) async {
    final decoded = await _postJson(
      path: addPath,
      body: request.toJson(),
    );
    print('Add task response: $decoded');
    print(addPath);
    _ensureSuccess(decoded, fallbackMessage: 'Unable to create task.');
    final task = _parseFirstTask(decoded);
    return AddTaskResult(
      success: true,
      savedOffline: false,
      message: _successMessage(decoded, fallback: 'Task created successfully'),
      task: task,
    );
  }

  /// Updates task status / dates via `UpdateTaskStatus`.
  Future<AddTaskResult> updateTaskStatus(UpdateTaskStatusRequest request) async {
    if (request.taskId.trim().isEmpty || request.taskId == '0') {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid task id for update.',
      );
    }
    if (request.status.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Status is required.',
      );
    }
    if (request.startDate.trim().isEmpty || request.endDate.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Start and end dates are required.',
      );
    }

    final decoded = await _postJson(
      path: updatePath,
      body: request.toJson(),
    );
    _ensureSuccess(decoded, fallbackMessage: 'Unable to update task.');
    final task = _parseFirstTask(decoded);
    return AddTaskResult(
      success: true,
      savedOffline: false,
      message: _successMessage(decoded, fallback: 'Task updated successfully'),
      task: task,
    );
  }

  /// Deletes task via `deletetask` — payload `{ "taskid": "..." }`.
  Future<DeleteTaskResult> deleteTask({required String taskId}) async {
    final id = taskId.trim();
    if (id.isEmpty || id == '0') {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid task id for delete.',
      );
    }

    final decoded = await _postJson(
      path: deletePath,
      body: {'taskid': id},
    );
    _ensureSuccess(decoded, fallbackMessage: 'Unable to delete task.');
    return DeleteTaskResult(
      success: true,
      message: _deleteMessage(decoded) ?? 'Record Deleted Successfully',
    );
  }

  /// User-level task list by status (`GettaskbyUser`).
  /// [apiStatus]: 1=Pending, 2=In Progress, 4=Completed.
  Future<List<UserTaskItem>> fetchTasksByUser({
    required int userId,
    required int apiStatus,
  }) async {
    final decoded = await _postJson(
      path: byUserPath,
      body: {
        'User_Id': userId.toString(),
        'Status': apiStatus,
      },
    );
    return UserTaskListResponse.fromJson(decoded).tasks;
  }

  void _ensureSuccess(
    Map<String, dynamic> decoded, {
    required String fallbackMessage,
  }) {
    final successCode = decoded['success'];
    final ok = successCode == 200 ||
        successCode == true ||
        successCode?.toString() == '200';
    if (!ok) {
      throw DashboardFailure(
        type: DashboardFailureType.server,
        message: decoded['message']?.toString() ??
            _deleteMessage(decoded) ??
            fallbackMessage,
      );
    }
  }

  HierarchyTask? _parseFirstTask(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    if (data is! List || data.isEmpty) return null;
    final first = data.first;
    if (first is! Map) return null;
    try {
      return HierarchyTask.fromJson(Map<String, dynamic>.from(first));
    } catch (_) {
      return null;
    }
  }

  String _successMessage(
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    final direct = decoded['message']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
    return _deleteMessage(decoded) ?? fallback;
  }

  String? _deleteMessage(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final msg = first['Msg'] ?? first['msg'] ?? first['message'];
        if (msg != null && msg.toString().trim().isNotEmpty) {
          return msg.toString().trim();
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalized');
    try {
      print('POST $uri');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(timeout);
      print('Response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 401) {
        throw const DashboardFailure(
          type: DashboardFailureType.unauthorized,
          message: 'Unauthorized. Please sign in again.',
        );
      }
      if (response.statusCode == 403) {
        throw const DashboardFailure(
          type: DashboardFailureType.forbidden,
          message: 'You do not have permission for this action.',
        );
      }
      if (response.statusCode >= 500) {
        throw const DashboardFailure(
          type: DashboardFailureType.server,
          message: 'Server error. Please try again later.',
        );
      }
      if (response.statusCode != 200) {
        String detail = 'Unexpected response (${response.statusCode}).';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody is Map && errBody['message'] != null) {
            detail = errBody['message'].toString();
          }
        } catch (_) {}
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message: detail,
        );
      }

      if (response.body.trim().isEmpty) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Empty response from server.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Invalid response format.',
        );
      }
      return decoded;
    } on DashboardFailure {
      rethrow;
    } on TimeoutException {
      throw const DashboardFailure(
        type: DashboardFailureType.timeout,
        message: 'Request timed out. Please try again.',
      );
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid JSON response from server.',
      );
    } on http.ClientException {
      throw const DashboardFailure(
        type: DashboardFailureType.noInternet,
        message: 'Unable to reach the server.',
      );
    } catch (e) {
      if (e is DashboardFailure) rethrow;
      final message = e.toString().toLowerCase();
      if (message.contains('socket') ||
          message.contains('network') ||
          message.contains('failed host lookup')) {
        throw const DashboardFailure(
          type: DashboardFailureType.noInternet,
          message: 'No internet connection.',
        );
      }
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message: e.toString(),
      );
    }
  }

  Map<String, String> _headers() {
    String source = 'unknown';
    if (kIsWeb) {
      source = 'web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      source = 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      source = 'IOS';
    }
    return {
      'content-type': 'application/json',
      'dbid': '1',
      'source': source,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': 'false',
      'Access-Control-Allow-Headers':
          'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale',
      'Access-Control-Allow-Methods': '*',
    };
  }
}
