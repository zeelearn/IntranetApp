import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/models/send_credentials_result.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

class ProjectRemoteService {
  ProjectRemoteService({
    http.Client? client,
    this.baseUrl = LocalStrings.bpms,
    this.path = '/api/bp/GetAllProjectList_new',
    this.sendCredentialsPath = '/${LocalStrings.API_SEND_CREDENTIALS}',
    this.saveDispatchConfirmationPath =
        LocalStrings.API_SAVE_DISPATCH_CONFIRMATION,
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String path;
  final String sendCredentialsPath;
  final String saveDispatchConfirmationPath;
  final Duration timeout;

  Future<List<ProjectItem>> fetchProjects({
    required int userId,
    required int projectTeamStatus,
    int? businessId,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final body = jsonEncode({
      'userID': userId,
      'projectTeam_status': projectTeamStatus.toString(),
      'Business_id': businessId ?? null,
    });

    try {
      final response = await _client
          .post(uri, headers: _headers(), body: body)
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
          message: 'You do not have permission to view projects.',
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
          message: 'Invalid project list response.',
        );
      }

      final envelope = ProjectListResponse.fromJson(decoded);
      return envelope.data;
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
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid project JSON response.',
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

  Future<SendCredentialsResult> sendTempCredentials({
    required String crmId,
  }) async {
    final id = crmId.trim();
    if (id.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'CRM ID is missing for this project.',
      );
    }

    final uri = Uri.parse('$baseUrl$sendCredentialsPath');
    final body = jsonEncode({'crm_id': id});

    try {
      final response = await _client
          .post(uri, headers: _headers(), body: body)
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
          message: 'You do not have permission to send credentials.',
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
          message: 'Unable to send credentials (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Invalid credentials response.',
        );
      }

      final result = SendCredentialsResult.fromJson(decoded);
      if (!result.success) {
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message: result.message,
        );
      }
      return result;
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
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid credentials JSON response.',
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

  /// Confirms CK (Illume) or BK (Branding) dispatch for a project.
  ///
  /// Body matches Postman: `{ "indent_id": <number>, "user_id": <number> }`.
  Future<String> saveDispatchConfirmation({
    required int userId,
    required ProjectItem project,
    required DispatchConfirmType type,
  }) async {
    final indentRaw = type == DispatchConfirmType.ck
        ? project.illumeIndentId?.trim()
        : project.brandingIndentId?.trim();
    if (indentRaw == null || indentRaw.isEmpty) {
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message:
            '${type.label} indent is missing. Dispatch cannot be confirmed.',
      );
    }

    if (type == DispatchConfirmType.ck && !project.canConfirmCKDispatch) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'CK dispatch is not available for this project.',
      );
    }
    if (type == DispatchConfirmType.bk && !project.canConfirmBKDispatch) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'BK dispatch is not available for this project.',
      );
    }

    // Postman sends numeric indent_id (e.g. 1028443), not a string.
    final indentId = int.tryParse(indentRaw) ?? indentRaw;

    final uri = Uri.parse(saveDispatchConfirmationPath.startsWith('http')
        ? saveDispatchConfirmationPath
        : '$baseUrl$saveDispatchConfirmationPath');

    final body = jsonEncode({
      'indent_id': indentId,
      'user_id': userId,
    });

    if (kDebugMode) {
      debugPrint('[DispatchAPI] POST $uri body=$body');
    }

    try {
      final response = await _client
          .post(uri, headers: _kidzeeHeaders(), body: body)
          .timeout(timeout);

      if (kDebugMode) {
        debugPrint(
          '[DispatchAPI] status=${response.statusCode} body=${response.body}',
        );
      }

      if (response.statusCode == 401) {
        throw const DashboardFailure(
          type: DashboardFailureType.unauthorized,
          message: 'Unauthorized. Please sign in again.',
        );
      }
      if (response.statusCode == 403) {
        throw const DashboardFailure(
          type: DashboardFailureType.forbidden,
          message: 'You do not have permission to confirm dispatch.',
        );
      }
      if (response.statusCode >= 500) {
        throw DashboardFailure(
          type: DashboardFailureType.server,
          message: _safeResponseMessage(response.body) ??
              'Server error. Please try again later.',
        );
      }
      if (response.statusCode != 200) {
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message: _safeResponseMessage(response.body) ??
              'Unable to confirm ${type.label} dispatch (${response.statusCode}).',
        );
      }

      if (response.body.trim().isEmpty) {
        return 'Dispatch Confirmation updated!';
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return 'Dispatch Confirmation updated!';
      }

      final success = decoded['success'];
      final ok = success == 200 ||
          success == true ||
          success?.toString() == '200';
      if (!ok && success != null) {
        throw DashboardFailure(
          type: DashboardFailureType.server,
          message: _messageFromDispatch(decoded) ??
              'Unable to confirm ${type.label} dispatch.',
        );
      }
      return _messageFromDispatch(decoded) ??
          'Dispatch Confirmation updated!';
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
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid dispatch confirmation response.',
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

  String? _safeResponseMessage(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return _messageFromDispatch(decoded);
      }
    } catch (_) {
      // fall through
    }
    final trimmed = body.trim();
    if (trimmed.length > 160) return trimmed.substring(0, 160);
    return trimmed;
  }

  String? _messageFromDispatch(Map<String, dynamic> decoded) {
    final direct = decoded['message']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final data = decoded['data'];
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      final msg = data['Msg'] ?? data['msg'] ?? data['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    }
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

  /// Same headers as other kidzee APIs (branding) — `dbid: 0`.
  Map<String, String> _kidzeeHeaders() {
    String source = 'unknown';
    if (kIsWeb) {
      source = 'web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      source = 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      source = 'IOS';
    }
    return {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'dbid': LocalStrings.kidzeeBrandingDbId,
      'source': source,
    };
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
