import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/modules/projects/models/branding_kit_models.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

/// Finance / branding APIs on kubapi (HTTPS) — `dbid: 0`.
class BrandingRemoteService {
  BrandingRemoteService({
    http.Client? client,
    this.getProductsUrl = LocalStrings.API_GET_BRANDING_PRODUCT,
    this.insertIndentUrl = LocalStrings.API_INSERT_BRANDING_INDENT,
    this.dbId = LocalStrings.kidzeeBrandingDbId,
    this.timeout = const Duration(seconds: 45),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String getProductsUrl;
  final String insertIndentUrl;
  final String dbId;
  final Duration timeout;

  Uri getProductsUri() => Uri.parse(getProductsUrl);

  Uri buildInsertUri() => Uri.parse(insertIndentUrl);

  Future<BrandingProductData> fetchBrandingProducts({
    required int franchiseeId,
  }) async {
    if (franchiseeId <= 0) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Franchisee ID is missing for branding kit.',
      );
    }

    final uri = getProductsUri();
    if (kDebugMode) {
      debugPrint('[BrandingAPI] GET products → $uri (dbid=$dbId)');
    }

    final body = jsonEncode({'Franchisee_Id': franchiseeId});

    try {
      final response = await _client
          .post(uri, headers: _headers(), body: body)
          .timeout(timeout);
      _ensureOk(response, action: 'load branding products');

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Invalid branding products response.',
        );
      }

      final envelope = BrandingProductResponse.fromJson(decoded);
      if (envelope.success != 200) {
        throw DashboardFailure(
          type: DashboardFailureType.unknown,
          message:
              'Unable to load branding products (success=${envelope.success}).',
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
        message: 'Unable to reach the branding server.',
      );
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid branding JSON response.',
      );
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  Future<InsertBrandingIndentResult> insertBrandingIndent({
    required InsertBrandingIndentRequest request,
  }) async {
    final validationError = request.validate();
    if (validationError != null) {
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message: validationError,
      );
    }

    final uri = buildInsertUri();
    if (kDebugMode) {
      debugPrint('[BrandingAPI] INSERT indent → $uri (dbid=$dbId)');
    }
    final body = jsonEncode(request.toJson());

    try {
      final response = await _client
          .post(uri, headers: _headers(), body: body)
          .timeout(timeout);
      _ensureOk(response, action: 'save branding order');

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Invalid branding order response.',
        );
      }
      return InsertBrandingIndentResult.fromJson(decoded);
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
        message: 'Unable to reach the branding server.',
      );
    } on FormatException {
      throw const DashboardFailure(
        type: DashboardFailureType.invalidJson,
        message: 'Invalid branding order JSON response.',
      );
    } catch (e) {
      throw _mapUnknown(e);
    }
  }

  void _ensureOk(http.Response response, {required String action}) {
    if (response.statusCode == 401) {
      throw const DashboardFailure(
        type: DashboardFailureType.unauthorized,
        message: 'Unauthorized. Please sign in again.',
      );
    }
    if (response.statusCode == 403) {
      throw DashboardFailure(
        type: DashboardFailureType.forbidden,
        message: 'You do not have permission to $action.',
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
  }

  DashboardFailure _mapUnknown(Object e) {
    final message = e.toString().toLowerCase();
    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('failed host lookup') ||
        message.contains('ssl') ||
        message.contains('certificate')) {
      return const DashboardFailure(
        type: DashboardFailureType.noInternet,
        message: 'Unable to reach the branding server.',
      );
    }
    return DashboardFailure(
      type: DashboardFailureType.unknown,
      message: e.toString(),
    );
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
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer admin-token',
      'dbid': dbId,
      'source': source,
    };
  }
}
