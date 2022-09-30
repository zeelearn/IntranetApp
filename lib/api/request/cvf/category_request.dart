import 'dart:convert';
import 'dart:io';

class CVFCategoryRequest {
  String Category_Id;

  CVFCategoryRequest(
      {required this.Category_Id,
      });

  getJson(){
    return jsonEncode( {
      'Category_Id': Category_Id,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Category_Id': Category_Id.trim(),
    };
    return map;
  }
}