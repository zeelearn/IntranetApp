import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';

/// Parsed payload from `GetPJPCVFEmail` / body for `SendPJPCVFEmail`.
class ShareReportEmailData {
  const ShareReportEmailData({
    this.pjpId = '',
    this.cvfId = '',
    this.to = const [],
    this.cc = const [],
    this.subject = '',
    this.body = '',
    this.isHtml = true,
    this.contentType = 'text/html',
    this.attachmentUrl = '',
    this.workingWell = const [],
    this.urgentAttention = const [],
    this.teacherObservation = const [],
    this.trainingSupport = const [],
  });

  final String pjpId;
  final String cvfId;
  final List<String> to;
  final List<String> cc;
  final String subject;
  final String body;
  final bool isHtml;
  final String contentType;
  final String attachmentUrl;
  final List<WorkingWellItem> workingWell;
  final List<UrgentAttentionItem> urgentAttention;
  final List<TeacherObservationItem> teacherObservation;
  final List<TrainingSupportItem> trainingSupport;

  factory ShareReportEmailData.fromJson(Map<String, dynamic> json) {
    return ShareReportEmailData(
      pjpId: _str(json['PJP_Id'] ?? json['pjp_Id']),
      cvfId: _str(json['PJPCVF_Id'] ?? json['pjpcvf_Id']),
      // Recipients use capital-T `To` — do not fall back to lowercase `to`
      // (teacher observations).
      to: _stringList(json['To']),
      cc: _stringList(json['CC'] ?? json['cc']),
      subject: _str(json['Subject'] ?? json['subject']),
      body: _str(json['Body'] ?? json['body']),
      isHtml: _bool(json['IsHtml'] ?? json['isHtml'], fallback: true),
      contentType: _str(
        json['ContentType'] ?? json['contentType'],
        fallback: 'text/html',
      ),
      attachmentUrl: _str(json['AttachmentUrl'] ?? json['attachmentUrl']),
      workingWell: _parseWorkingWell(
        json['www'] ?? json["What'sWorkingWell"],
      ),
      urgentAttention: _parseUrgent(
        json['ua'] ?? json['UrgentAttention'],
      ),
      teacherObservation: _parseTeachers(
        json['to'] ?? json['TeacherObservation'],
      ),
      trainingSupport: _parseTraining(
        json['tasp'] ?? json['TrainingAndSupportProvided'],
      ),
    );
  }

  /// Inner JSON object expected by SendPJPCVFEmail (`InputData` string).
  ///
  /// Shape:
  /// - `www` / `tasp`: `List<String>`
  /// - `ua`: `List<{aoc, tl}>`
  /// - `to`: `List<{tn, class, app}>`
  /// - `Body`: always blank (preview-only)
  Map<String, dynamic> toApiPayload() {
    return <String, dynamic>{
      'PJP_Id': pjpId,
      'PJPCVF_Id': cvfId,
      'To': to,
      'CC': cc,
      'Subject': subject,
      'Body': '',
      'IsHtml': isHtml,
      'ContentType': contentType,
      'AttachmentUrl': attachmentUrl,
      'www': workingWell
          .map((e) => e.toApiString())
          .where((e) => e.isNotEmpty)
          .toList(),
      'ua': urgentAttention
          .map((e) => e.toApiObject())
          .whereType<Map<String, String>>()
          .toList(),
      'to': teacherObservation
          .map((e) => e.toApiObject())
          .whereType<Map<String, String>>()
          .toList(),
      'tasp': trainingSupport
          .map((e) => e.toApiString())
          .where((e) => e.isNotEmpty)
          .toList(),
    };
  }

  static String _str(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }

  static bool _bool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    final text = value.toString().trim().toLowerCase();
    if (text == '1' || text == 'true' || text == 'yes') return true;
    if (text == '0' || text == 'false' || text == 'no') return false;
    return fallback;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is! List) {
      final single = _str(value);
      return single.isEmpty ? const [] : [single];
    }
    return value
        .map((e) => _str(e))
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  static List<WorkingWellItem> _parseWorkingWell(dynamic value) {
    final items = <WorkingWellItem>[];
    for (final entry in _entries(value)) {
      if (entry is String) {
        final t = entry.trim();
        if (t.isNotEmpty) items.add(WorkingWellItem(observation: t));
      } else if (entry is Map) {
        final map = Map<String, dynamic>.from(entry);
        final t = _str(map['Observation'] ?? map['observation'] ?? map['text']);
        if (t.isNotEmpty) items.add(WorkingWellItem(observation: t));
      }
    }
    return items;
  }

  static List<UrgentAttentionItem> _parseUrgent(dynamic value) {
    final items = <UrgentAttentionItem>[];
    for (final entry in _entries(value)) {
      if (entry is String) {
        final parsed = UrgentAttentionItem.fromApiString(entry);
        if (parsed.areaOfConcern.isNotEmpty || parsed.timeline.isNotEmpty) {
          items.add(parsed);
        }
      } else if (entry is Map) {
        final parsed =
            UrgentAttentionItem.fromApiObject(Map<String, dynamic>.from(entry));
        if (parsed.areaOfConcern.isNotEmpty || parsed.timeline.isNotEmpty) {
          items.add(parsed);
        }
      }
    }
    return items;
  }

  static List<TeacherObservationItem> _parseTeachers(dynamic value) {
    final items = <TeacherObservationItem>[];
    for (final entry in _entries(value)) {
      if (entry is String) {
        final parsed = TeacherObservationItem.fromApiString(entry);
        if (parsed.teacherName.isNotEmpty ||
            parsed.className.isNotEmpty ||
            parsed.appStatus.isNotEmpty) {
          items.add(parsed);
        }
      } else if (entry is Map) {
        final parsed = TeacherObservationItem.fromApiObject(
          Map<String, dynamic>.from(entry),
        );
        if (parsed.teacherName.isNotEmpty ||
            parsed.className.isNotEmpty ||
            parsed.appStatus.isNotEmpty) {
          items.add(parsed);
        }
      }
    }
    return items;
  }

  static List<TrainingSupportItem> _parseTraining(dynamic value) {
    final items = <TrainingSupportItem>[];
    for (final entry in _entries(value)) {
      if (entry is String) {
        final t = entry.trim();
        if (t.isNotEmpty) items.add(TrainingSupportItem(details: t));
      } else if (entry is Map) {
        final map = Map<String, dynamic>.from(entry);
        final t = _str(map['Details'] ?? map['details'] ?? map['text']);
        if (t.isNotEmpty) items.add(TrainingSupportItem(details: t));
      }
    }
    return items;
  }

  static Iterable<dynamic> _entries(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value;
    return [value];
  }
}

/// Envelope for GetPJPCVFEmail.
class GetCvfEmailResult {
  const GetCvfEmailResult({
    required this.success,
    required this.message,
    this.statusCode = 200,
    this.data,
  });

  final bool success;
  final String message;
  final int statusCode;
  final ShareReportEmailData? data;

  factory GetCvfEmailResult.error(String message, {int statusCode = 500}) {
    return GetCvfEmailResult(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  factory GetCvfEmailResult.fromHttp({
    required int httpStatus,
    required Map<String, dynamic> json,
  }) {
    final apiCode = json['statusCode'];
    final code = apiCode is int ? apiCode : httpStatus;
    final msg = (json['responseMessage'] ?? json['message'] ?? '').toString();
    final ok = httpStatus >= 200 &&
        httpStatus < 300 &&
        (apiCode == null || apiCode == 200);

    ShareReportEmailData? data;
    final raw = json['responseData'];
    if (raw is Map) {
      data = ShareReportEmailData.fromJson(Map<String, dynamic>.from(raw));
    }

    if (!ok) {
      return GetCvfEmailResult(
        success: false,
        message: msg.isEmpty ? 'Unable to load submitted report.' : msg,
        statusCode: code,
      );
    }
    if (data == null) {
      return GetCvfEmailResult(
        success: false,
        message: 'Submitted report data not found.',
        statusCode: code,
      );
    }
    return GetCvfEmailResult(
      success: true,
      message: msg.isEmpty ? 'Success' : msg,
      statusCode: code,
      data: data,
    );
  }
}
