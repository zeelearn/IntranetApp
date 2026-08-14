import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_email_data.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Remote APIs for Share Centre Visit Report.
class ShareReportRepository {
  ShareReportRepository({
    APIService? api,
    http.Client? client,
    Duration? getTimeout,
    Duration? sendTimeout,
  })  : _api = api ?? APIService(),
        _client = client ?? http.Client(),
        _getTimeout = getTimeout ?? const Duration(seconds: 30),
        _sendTimeout = sendTimeout ?? const Duration(seconds: 45);

  final APIService _api;
  final http.Client _client;
  final Duration _getTimeout;
  final Duration _sendTimeout;

  static const _pjpHeaders = <String, String>{
    'accept': 'text/plain',
    'Content-Type': 'application/json-patch+json',
  };

  /// GET previously submitted CVF email payload (`GetPJPCVFEmail`).
  Future<GetCvfEmailResult> getCvfReportApi({
    required int empId,
    required String pjpId,
    required String cvfId,
  }) async {
    if (empId <= 0) {
      return GetCvfEmailResult.error('Employee ID is missing.', statusCode: 400);
    }
    if (pjpId.trim().isEmpty) {
      return GetCvfEmailResult.error('PJP ID is missing.', statusCode: 400);
    }
    if (cvfId.trim().isEmpty) {
      return GetCvfEmailResult.error('CVF ID is missing.', statusCode: 400);
    }

    final payload = <String, dynamic>{
      'emp_id': empId,
      'PJP_Id': _asIntOrString(pjpId),
      'PJPCVF_Id': _asIntOrString(cvfId),
    };

    try {
      final response = await _client
          .post(
            Uri.parse(_api.url + LocalStrings.GET_PJP_CVF_EMAIL),
            headers: {
              ...commonHeaders,
              ..._pjpHeaders,
            },
            body: jsonEncode(payload),
          )
          .timeout(_getTimeout);

      final mapped = GetCvfEmailResult.fromHttp(
        httpStatus: response.statusCode,
        json: _decodeMap(response.body),
      );
      return _mapHttpErrorsForGet(mapped, response.statusCode);
    } on TimeoutException {
      return GetCvfEmailResult.error(
        'Request timed out while loading the submitted report. Please try again.',
        statusCode: 408,
      );
    } on SocketException {
      return GetCvfEmailResult.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('getCvfReportApi ClientException: $e');
      return GetCvfEmailResult.error(
        'Unable to reach the server. Please try again.',
        statusCode: 0,
      );
    } catch (e, st) {
      debugPrint('getCvfReportApi error: $e\n$st');
      return GetCvfEmailResult.error(
        'Unable to load submitted report. Please try again.',
      );
    }
  }

  /// SEND CVF email (`SendPJPCVFEmail`) with `InputData` JSON string wrapper.
  Future<ShareReportResponse> sendReportApi({
    required ShareReportEmailData data,
  }) async {
    final validation = _validateSendPayload(data);
    if (validation != null) {
      return ShareReportResponse.error(validation, statusCode: 400);
    }

    final outer = <String, dynamic>{
      'InputData': jsonEncode(data.toApiPayload()),
    };

    try {
      final response = await _client
          .post(
            Uri.parse(_api.url + LocalStrings.SEND_PJP_CVF_EMAIL),
            headers: {
              ...commonHeaders,
              ..._pjpHeaders,
            },
            body: jsonEncode(outer),
          )
          .timeout(_sendTimeout);

      return _mapSendHttp(response);
    } on TimeoutException {
      return ShareReportResponse.error(
        'Request timed out while sending the report. Please try again.',
        statusCode: 408,
      );
    } on SocketException {
      return ShareReportResponse.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('sendReportApi ClientException: $e');
      return ShareReportResponse.error(
        'Unable to reach the server. Please try again.',
        statusCode: 0,
      );
    } catch (e, st) {
      debugPrint('sendReportApi error: $e\n$st');
      return ShareReportResponse.error(
        'Unable to send report. Please try again.',
      );
    }
  }

  /// Backward-compatible alias used by older call sites.
  Future<ShareReportResponse> shareReport({
    required ShareReportEmailData data,
  }) =>
      sendReportApi(data: data);

  ShareReportResponse _mapSendHttp(http.Response response) {
    final json = _decodeMap(response.body);
    final code = response.statusCode;

    if (code == 401) {
      return ShareReportResponse.error(
        'Session expired. Please sign in again.',
        statusCode: 401,
      );
    }
    if (code == 403) {
      return ShareReportResponse.error(
        'You do not have permission to share this report.',
        statusCode: 403,
      );
    }
    if (code == 404) {
      return ShareReportResponse.error(
        'CVF not found.',
        statusCode: 404,
      );
    }
    if (code == 409) {
      return ShareReportResponse.error(
        'Report is already being processed. Please wait.',
        statusCode: 409,
      );
    }
    if (code >= 500) {
      return ShareReportResponse.error(
        'Server error. Please try again later.',
        statusCode: code,
      );
    }

    return ShareReportResponse.fromJson(json, statusCode: code);
  }

  GetCvfEmailResult _mapHttpErrorsForGet(
    GetCvfEmailResult result,
    int httpStatus,
  ) {
    if (httpStatus == 401) {
      return GetCvfEmailResult.error(
        'Session expired. Please sign in again.',
        statusCode: 401,
      );
    }
    if (httpStatus == 403) {
      return GetCvfEmailResult.error(
        'You do not have permission to view this report.',
        statusCode: 403,
      );
    }
    if (httpStatus == 404) {
      return GetCvfEmailResult.error(
        'Submitted report not found.',
        statusCode: 404,
      );
    }
    if (httpStatus >= 500) {
      return GetCvfEmailResult.error(
        'Server error. Please try again later.',
        statusCode: httpStatus,
      );
    }
    return result;
  }

  String? _validateSendPayload(ShareReportEmailData data) {
    if (data.pjpId.trim().isEmpty) return 'PJP ID is missing.';
    if (data.cvfId.trim().isEmpty) return 'CVF ID is missing.';
    //if (data.to.isEmpty) return 'Recipient (To) email is required.';
    if (data.subject.trim().length < 5) return 'Subject is invalid.';
    // Body is preview-only and intentionally blank in the send payload.
    if (data.workingWell.isEmpty) {
      return "Add at least one What's Working Well entry.";
    }
    if (data.urgentAttention.isEmpty) {
      return 'Add at least one Urgent Attention entry.';
    }
    if (data.teacherObservation.isEmpty) {
      return 'Add at least one Teacher Observation entry.';
    }
    if (data.trainingSupport.isEmpty) {
      return 'Add at least one Training & Support entry.';
    }
    return null;
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return <String, dynamic>{};
  }

  /// API samples use numeric ids; keep string fallback when non-numeric.
  dynamic _asIntOrString(String value) {
    final trimmed = value.trim();
    return int.tryParse(trimmed) ?? trimmed;
  }
}
