import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

/// Portable entry args for the Projects module (library-friendly).
///
/// Host apps can build this from Hive via [fromHive] or pass values manually.
class ProjectsEntryArgs {
  const ProjectsEntryArgs({
    required this.userId,
    required this.userName,
    required this.businessId,
    required this.businessName,
    required this.businesses,
  });

  /// BPMS / business user id (`KEY_BUSINESS_USERID`).
  final int userId;

  /// Display user name (`KEY_USER_NAME`).
  final String userName;

  /// Selected business id (`KEY_BUSINESS_ID`). Null = All Business.
  final int? businessId;

  /// Selected business name (`KEY_BUSINESS_NAME`).
  final String businessName;

  /// Full business list from login response.
  final List<BusinessApplications> businesses;

  /// Loads user/business context from Hive using LocalConstant keys.
  static Future<ProjectsEntryArgs> fromHive() async {
    final box = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);

    var userId = _asInt(box.get(LocalConstant.KEY_BUSINESS_USERID));
    final userName = "${_asString(box.get(LocalConstant.KEY_FIRST_NAME)) } ${_asString(box.get(LocalConstant.KEY_LAST_NAME))}";
    //"${hiveBox.get(LocalConstant.KEY_FIRST_NAME)} ${hiveBox.get(LocalConstant.KEY_LAST_NAME)}"
    final businessIdRaw = box.get(LocalConstant.KEY_BUSINESS_ID);
    final businessId = _asInt(businessIdRaw);
    final businessName = _asString(box.get(LocalConstant.KEY_BUSINESS_NAME));

    final businesses = <BusinessApplications>[];
    final loginRaw = box.get(LocalConstant.KEY_LOGIN_RESPONSE);
    if (loginRaw != null && loginRaw.toString().trim().isNotEmpty) {
      try {
        final response = LoginResponseModel.fromJson(
          json.decode(loginRaw.toString()),
        );
        businesses.addAll(response.responseData.businessApplications);
        /***As discuss with Anurag Set BP Management Project Id */
        try {
          userId = businesses
              .firstWhere((business) => business.businessID == 4)
              .business_UserID;
        } catch (e) {
          //userId = userId;
        }
        
      } catch (_) {
        // Keep empty list if login payload cannot be parsed.
      }
    }

    return ProjectsEntryArgs(
      userId: userId,
      userName: userName.isEmpty ? 'User' : userName,
      businessId: businessId == 0 ? null : businessId,
      businessName: businessName == 'null' ? '' : businessName,
      businesses: businesses,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return '';
    return s;
  }
}
