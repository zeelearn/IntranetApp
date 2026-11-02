import 'dart:convert';

import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:hive/hive.dart';

/// Persists and filters login `myMobileApplications` for dashboard menus.
class MobileApplicationsStore {
  MobileApplicationsStore._();

  /// Only these apps are surfaced as dashboard quick-access menus.
  static const dashboardMenuNames = <String>{
    'Prospect Management',
  };

  static const legalMis = 'Legal MIS';
  static const bpManagement = 'Prospect Management';

  /// TEMP: on web, open Legal MIS / Create Contracts in a new browser tab
  /// instead of [MyWebsiteView]. Set to `false` to restore in-app WebView.
  static const bool openLegalMisInNewTabOnWeb = false;

  static Future<void> save(Box box, List<MyMobileApplication> apps) async {
    await box.put(
      LocalConstant.KEY_MY_MOBILE_APPLICATIONS,
      jsonEncode(apps.map((e) => e.toJson()).toList()),
    );
  }

  static List<MyMobileApplication> load(Box box) {
    try {
      final raw =
          box.get(LocalConstant.KEY_MY_MOBILE_APPLICATIONS)?.toString() ?? '';
      if (raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => MyMobileApplication.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Prefer dedicated Hive key; fall back to login response payload.
  static List<MyMobileApplication> loadWithFallback(Box box) {
    final fromKey = load(box);
    if (fromKey.isNotEmpty) return fromKey;

    try {
      final loginRaw =
          box.get(LocalConstant.KEY_LOGIN_RESPONSE)?.toString() ?? '';
      if (loginRaw.isEmpty) return const [];
      final decoded = jsonDecode(loginRaw);
      if (decoded is! Map) return const [];
      final map = Map<String, dynamic>.from(decoded);

      // Full LoginResponseModel or ResponseData-only payloads.
      final responseData = map['responseData'] is Map
          ? Map<String, dynamic>.from(map['responseData'] as Map)
          : map;
      final appsRaw = responseData['myMobileApplications'];
      if (appsRaw is! List) return const [];
      return appsRaw
          .whereType<Map>()
          .map((e) => MyMobileApplication.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Dashboard-visible apps only (BP Management with a valid URL).
  /// Legal MIS is opened from Contracts → Create Contracts, not the dashboard.
  static List<MyMobileApplication> forDashboard(List<MyMobileApplication> apps) {
    return apps
        .where(
          (app) =>
              dashboardMenuNames.contains(app.normalizedName) &&
              app.hasValidLaunchUrl,
        )
        .toList(growable: false);
  }

  static MyMobileApplication? findByName(
    List<MyMobileApplication> apps,
    String businessName,
  ) {
    final target = businessName.trim();
    for (final app in apps) {
      if (app.normalizedName == target && app.hasValidLaunchUrl) {
        return app;
      }
    }
    return null;
  }
}
