import 'dart:io';

import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens http(s) links with platform-aware handling.
///
/// Zoho campaign / NPS short links (e.g. https://zohsy.in/xVqM → survey.zohopublic.in)
/// often fail inside iOS WKWebView after redirect; Safari opens them reliably.
class AppUrlLauncher {
  AppUrlLauncher._();

  static bool isZohoSurveyUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.trim().toLowerCase();
    return lower.contains('zohsy.in') ||
        lower.contains('survey.zohopublic') ||
        lower.contains('zohopublic.in/zs/') ||
        lower.contains('zoho.com/survey') ||
        lower.contains('zohosurvey');
  }

  /// Prefer external Safari/Chrome for Zoho surveys on iOS (and optionally Android).
  static bool shouldOpenExternally(String url) {
    if (kIsWeb) return false;
    if (!isZohoSurveyUrl(url)) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static Uri? _parseHttpUri(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  /// Opens [url] externally. Returns true when launch was attempted successfully.
  static Future<bool> openExternal(String url) async {
    final uri = _parseHttpUri(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[AppUrlLauncher] openExternal failed: $e');
      return false;
    }
  }

  /// Opens Zoho survey links in the system browser; otherwise uses in-app WebView.
  static Future<void> open(
    BuildContext context, {
    required String url,
    String title = '',
  }) async {
    final uri = _parseHttpUri(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link.')),
        );
      }
      return;
    }

    if (shouldOpenExternally(url)) {
      final ok = await openExternal(url);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open link. Please try again.'),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyWebsiteView(title: title, url: url),
      ),
    );
  }
}
