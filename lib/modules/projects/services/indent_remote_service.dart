import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/models/payment_link_result.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

class IndentRemoteService {
  IndentRemoteService({
    http.Client? client,
    this.baseUrl = LocalStrings.bpms,
    this.path = '/api/bp/Pentemind_Illume_Status',
    this.paymentLinkPath = '/api/bp/IndentPaymentEmail',
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String path;
  final String paymentLinkPath;
  final Duration timeout;

  Future<List<IndentItem>> fetchIndents({
    required int userId,
    required String businessId,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final body = jsonEncode({
      'User_Id': userId,
      'Business_Id': businessId,
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
          message: 'You do not have permission to view indents.',
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
          message: 'Invalid indent list response.',
        );
      }

      final envelope = IndentListResponse.fromJson(decoded);
      if (envelope.success != 200 && envelope.data.isEmpty) {
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message: 'Unable to load indents (success=${envelope.success}).',
        );
      }
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
        message: 'Invalid indent JSON response.',
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

  /// POST `/api/bp/IndentPaymentEmail` with `{ "indentid": <id> }`.
  Future<PaymentLinkResult> generatePaymentLink({
    required int indentId,
  }) async {
    if (indentId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Invalid indent ID.',
      );
    }

    final uri = Uri.parse('$baseUrl$paymentLinkPath');
    final body = jsonEncode({'indentid': indentId});

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
          message: 'You do not have permission to generate payment link.',
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
          message: 'Invalid payment link response.',
        );
      }
      return PaymentLinkResult.fromJson(decoded);
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
        message: 'Invalid payment link JSON response.',
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
      'Accept': 'application/json, text/plain, */*',
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
