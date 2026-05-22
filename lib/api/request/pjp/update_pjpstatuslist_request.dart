import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class UpdatePJPStatusListRequest {
  late String DocXML;
  String Workflow_user = '';

  UpdatePJPStatusListRequest(
      {required this.DocXML, required this.Workflow_user});

  getJson() {
    return jsonEncode({
      'DocXML': DocXML,
      'Workflow_user': Workflow_user,
      'AppType': kIsWeb
          ? 'Web'
          : Platform.isAndroid
              ? 'Android'
              : Platform.isIOS
                  ? 'IOS'
                  : 'unknown'
    });
  }

  getExJson() {
    return jsonEncode({'xml': DocXML, 'created_by': Workflow_user});
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'DocXML': DocXML,
      'Workflow_user': Workflow_user,
    };
    return map;
  }
}
