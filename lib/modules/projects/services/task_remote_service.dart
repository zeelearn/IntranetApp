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
    this.addPath = '/api/bp/AddNewTask',
    this.byUserPath = '/api/bp/GettaskbyUser',
    this.timeout = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String fetchPath;
  final String addPath;
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

  /// Creates or updates a task. Returns true when API reports success.
  Future<AddTaskResult> addTask(AddTaskRequest request) async {
    final decoded = await _postJson(
      path: addPath,
      body: request.toJson(),
    );
    final successCode = decoded['success'];
    final ok = successCode == 200 ||
        successCode == true ||
        successCode?.toString() == '200';
    if (!ok) {
      throw DashboardFailure(
        type: DashboardFailureType.server,
        message: decoded['message']?.toString() ??
            'Unable to save task. Please try again.',
      );
    }
    return AddTaskResult(
      success: true,
      savedOffline: false,
      message: decoded['message']?.toString() ?? 'Task created successfully',
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

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(timeout);

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
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message: 'Unexpected response (${response.statusCode}).',
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
