import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_response.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ShareReportRepository {
  ShareReportRepository({APIService? api, http.Client? client})
      : _api = api ?? APIService(),
        _client = client ?? http.Client();

  final APIService _api;
  final http.Client _client;

  Future<ShareReportResponse> shareReport({
    required String pjpId,
    required String cvfId,
    required String to,
    required List<String> cc,
    required String subject,
    required String body,
    required List<WorkingWellItem> workingWell,
    required List<UrgentAttentionItem> urgentAttention,
    required List<TeacherObservationItem> teacherObservation,
    required List<TrainingSupportItem> trainingSupport,
  }) async {
    final payload = <String, dynamic>{
      'PJP_Id': pjpId,
      'PJPCVF_Id': cvfId,
      'To': [to.trim()],
      'CC': cc,
      'Subject': subject.trim(),
      'Body': body.trim(),
      'IsHtml': true,
      "AttachmentUrl": "https://literanovalms.s3.ap-south-1.amazonaws.com/cvf_report.pdf",
      'ContentType': 'text/html',
      "What'sWorkingWell": workingWell.map((e) => e.toJson()).toList(),
      'UrgentAttention': urgentAttention.map((e) => e.toJson()).toList(),
      'TeacherObservation':
          teacherObservation.map((e) => e.toJson()).toList(),
      'TrainingAndSupportProvided':
          trainingSupport.map((e) => e.toJson()).toList(),
    };

    try {
      final response = await _client
          .post(
            Uri.parse('http://localhost:3000/api/cvf/share-report'),
            headers: commonHeaders,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));

      Map<String, dynamic> json = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        } else if (decoded is Map) {
          json = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}

      if (response.statusCode == 401) {
        return ShareReportResponse.error(
          'Session expired. Please sign in again.',
          statusCode: 401,
        );
      }
      if (response.statusCode == 403) {
        return ShareReportResponse.error(
          'You do not have permission to share this report.',
          statusCode: 403,
        );
      }
      if (response.statusCode == 404) {
        return ShareReportResponse.error(
          'CVF not found.',
          statusCode: 404,
        );
      }
      if (response.statusCode == 409) {
        return ShareReportResponse.error(
          'Report is already being processed. Please wait.',
          statusCode: 409,
        );
      }
      if (response.statusCode == 400 || response.statusCode == 422) {
        return ShareReportResponse.fromJson(json, statusCode: response.statusCode);
      }
      if (response.statusCode >= 500) {
        return ShareReportResponse.error(
          'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      }

      return ShareReportResponse.fromJson(json, statusCode: response.statusCode);
    } on TimeoutException {
      return ShareReportResponse.error(
        'Request timed out. Please try again.',
        statusCode: 408,
      );
    } on SocketException {
      return ShareReportResponse.error(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } catch (e, st) {
      debugPrint('ShareReportRepository error: $e\n$st');
      return ShareReportResponse.error(
        'Unable to send report. Please try again.',
      );
    }
  }
}
