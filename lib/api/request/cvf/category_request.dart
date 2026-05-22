import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class CVFCategoryRequest {
  String Category_Id;
  int Business_id;

  CVFCategoryRequest({
    required this.Category_Id,
    required this.Business_id,
  });

  getJson() {
    return jsonEncode({
      'Category_Id': Category_Id,
      'Business_id': Business_id,
      'AppType': kIsWeb
          ? 'Web'
          : Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
                  ? 'IOS'
                  : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Category_Id': Category_Id.trim(),
      'Business_id': Business_id,
    };
    return map;
  }
}
