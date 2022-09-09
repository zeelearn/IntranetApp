import 'dart:convert';

class CVFCategoryRequest {
  String Category_Id;

  CVFCategoryRequest(
      {required this.Category_Id,
      });

  getJson(){
    return jsonEncode( {
      'Category_Id': Category_Id
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Category_Id': Category_Id.trim(),
    };
    return map;
  }
}