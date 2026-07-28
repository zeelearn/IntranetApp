import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'dashboard_failure.dart';
import 'dashboard_summary.dart';

class DashboardResponse extends Equatable {
  const DashboardResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<DashboardDataEnvelope> data;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final envelopes = <DashboardDataEnvelope>[];
    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          envelopes.add(
            DashboardDataEnvelope.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return DashboardResponse(
      success: _asInt(json['success']),
      data: envelopes,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.map((e) => e.toJson()).toList(growable: false),
      };

  /// Safely parses the nested JSON string into [DashboardSummary].
  DashboardSummary parseInnerSummary() {
    if (data.isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.empty,
        message: 'Dashboard data is empty',
      );
    }

    final raw = data.first.data;
    if (raw.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.empty,
        message: 'Dashboard inner data is empty',
      );
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        if (decoded.isEmpty) {
          throw const DashboardFailure(
            type: DashboardFailureType.empty,
            message: 'Dashboard inner list is empty',
          );
        }
        final first = decoded.first;
        if (first is! Map) {
          throw const DashboardFailure(
            type: DashboardFailureType.invalidJson,
            message: 'Dashboard inner item is not an object',
          );
        }
        return DashboardSummary.fromJson(Map<String, dynamic>.from(first));
      }
      if (decoded is Map) {
        return DashboardSummary.fromJson(Map<String, dynamic>.from(decoded));
      }
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Unexpected dashboard inner JSON shape',
      );
    } on DashboardFailure {
      rethrow;
    } catch (e) {
      throw DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Failed to parse dashboard JSON: $e',
      );
    }
  }

  DashboardResponse copyWith({
    int? success,
    List<DashboardDataEnvelope>? data,
  }) {
    return DashboardResponse(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [success, data];
}

class DashboardDataEnvelope extends Equatable {
  const DashboardDataEnvelope({required this.data});

  /// Nested JSON string returned by the API.
  final String data;

  factory DashboardDataEnvelope.fromJson(Map<String, dynamic> json) {
    final value = json['data'];
    if (value is String) {
      return DashboardDataEnvelope(data: value);
    }
    if (value is Map || value is List) {
      return DashboardDataEnvelope(data: jsonEncode(value));
    }
    return DashboardDataEnvelope(data: value?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'data': data};

  DashboardDataEnvelope copyWith({String? data}) {
    return DashboardDataEnvelope(data: data ?? this.data);
  }

  @override
  List<Object?> get props => [data];
}
