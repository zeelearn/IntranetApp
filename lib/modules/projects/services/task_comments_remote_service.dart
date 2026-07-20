import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/task_comments_payload.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

class TaskCommentsRemoteService {
  TaskCommentsRemoteService({
    http.Client? client,
    this.baseUrl = LocalStrings.bpms,
    this.path = '/${LocalStrings.API_GET_TASK_ATTACHMENTS_AND_COMMENTS}',
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String path;
  final Duration timeout;

  Future<TaskCommentsPayload> fetchCommentsAndFiles({
    required String taskId,
  }) async {
    final id = taskId.trim();
    if (id.isEmpty || id == '0') {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid task id.',
      );
    }

    final decoded = await _postJson(
      path: path,
      body: {'task_id': int.tryParse(id) ?? id},
    );

    final success = decoded['success'];
    final ok = success == 200 ||
        success == true ||
        success?.toString() == '200';
    if (!ok) {
      throw DashboardFailure(
        type: DashboardFailureType.server,
        message: decoded['message']?.toString() ??
            'Unable to load comments.',
      );
    }

    return TaskCommentsPayload.fromApiEnvelope(decoded);
  }

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final normalized = path.startsWith('/') ? path : '/$path';
    // API path may contain `//` like other BPMS endpoints.
    final uri = Uri.parse('$baseUrl$normalized'.replaceAll('///', '//'));
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
          message: 'You do not have permission to view comments.',
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
          message: 'Invalid comments response.',
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
        message: 'Invalid comments JSON.',
      );
    } on http.ClientException {
      throw const DashboardFailure(
        type: DashboardFailureType.noInternet,
        message: 'Unable to reach the server.',
      );
    } catch (e) {
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
    };
  }
}
