import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

/// HTTP client for mass project reassignment BP endpoints.
class ProjectReassignmentRemoteService {
  ProjectReassignmentRemoteService({
    http.Client? client,
    this.baseUrl = LocalStrings.bpms,
    this.teamPath = '/api/bp/GetMyTeamForProjects',
    this.tasksPath = '/api/bp/GetMyTask',
    this.updatePath = '/api/bp/UpdateTaskUser',
    this.timeout = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String teamPath;
  final String tasksPath;
  final String updatePath;
  final Duration timeout;

  /// `GetMyTeamForProjects` — body `{ "ManagerCode": "..." }`.
  Future<List<TeamMemberDto>> fetchTeam({required String managerCode}) async {
    final code = managerCode.trim();
    if (code.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Manager employee code is missing. Please sign in again.',
      );
    }

    final decoded = await _postJson(
      path: teamPath,
      body: {'ManagerCode': code},
    );
    _ensureSuccess(
      decoded,
      fallbackMessage: 'Unable to load team members.',
    );

    final data = decoded['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((row) => TeamMemberDto.fromJson(Map<String, dynamic>.from(row)))
        .where((member) => member.businessUserId > 0)
        .toList(growable: false);
  }

  /// `GetMyTask` — body `{ "user_id": <Business_UserID> }`.
  /// Response rows are projects: project_id, Franchisee_Code, Franchisee_Name.
  Future<List<AssignedProjectDto>> fetchProjectsForUser({
    required int userId,
  }) async {
    if (userId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid employee user id.',
      );
    }

    final decoded = await _postJson(
      path: tasksPath,
      body: {'user_id': userId},
    );
    _ensureSuccess(
      decoded,
      fallbackMessage: 'Unable to load assigned projects.',
    );

    final data = decoded['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (row) => AssignedProjectDto.fromJson(Map<String, dynamic>.from(row)),
        )
        .where((project) => project.projectId.isNotEmpty)
        .toList(growable: false);
  }

  /// `UpdateTaskUser` — mass ownership update.
  Future<String> updateTaskUser({
    required int actingUserId,
    required List<UpdateTaskUserItemDto> inputData,
  }) async {
    if (actingUserId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid session user id. Please sign in again.',
      );
    }
    if (inputData.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Nothing selected to move.',
      );
    }

    final decoded = await _postJson(
      path: updatePath,
      body: {
        'user_id': actingUserId,
        'input_data': inputData.map((item) => item.toJson()).toList(),
      },
    );
    _ensureSuccess(
      decoded,
      fallbackMessage: 'Unable to update task assignment.',
    );
    return _successMessage(
      decoded,
      fallback: 'Projects moved successfully.',
    );
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
        message: _messageFrom(decoded) ?? fallbackMessage,
      );
    }
  }

  String? _messageFrom(Map<String, dynamic> decoded) {
    final direct = decoded['message']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
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
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  String _successMessage(
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    return _messageFrom(decoded) ?? fallback;
  }

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalized');
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

class TeamMemberDto {
  const TeamMemberDto({
    required this.businessUserId,
    required this.displayName,
    required this.employeeCode,
    required this.isActive,
  });

  final int businessUserId;
  final String displayName;
  final String employeeCode;
  final bool isActive;

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      businessUserId: _asInt(json['Business_UserID'] ?? json['business_UserID']),
      displayName: _asString(json['DisplayName'] ?? json['displayName']),
      employeeCode: _asString(json['Employee_Code'] ?? json['employee_Code']),
      isActive: _asBool(json['IsActive'] ?? json['isActive']),
    );
  }
}

class AssignedProjectDto {
  const AssignedProjectDto({
    required this.projectId,
    required this.franchiseeCode,
    required this.franchiseeName,
  });

  final String projectId;
  final String franchiseeCode;
  final String franchiseeName;

  factory AssignedProjectDto.fromJson(Map<String, dynamic> json) {
    return AssignedProjectDto(
      projectId: _asString(json['project_id'] ?? json['projectId']),
      franchiseeCode:
          _asString(json['Franchisee_Code'] ?? json['franchisee_Code']),
      franchiseeName:
          _asString(json['Franchisee_Name'] ?? json['franchisee_Name']),
    );
  }
}

class UpdateTaskUserItemDto {
  const UpdateTaskUserItemDto({
    required this.projectId,
    required this.taskId,
    required this.oldUserId,
    required this.newUserId,
    this.taskStatus = 0,
  });

  final String projectId;
  final int taskId;
  final String oldUserId;
  final String newUserId;

  /// 0 = all, 1 = Pending, 2 = In Progress.
  final int taskStatus;

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'task_id': taskId,
        'old_user_id': oldUserId,
        'new_user_id': newUserId,
        'task_status': taskStatus,
      };
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}

String _asString(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return text;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase() ?? '';
  return text == 'true' || text == '1' || text == 'yes' || text == 'y';
}
