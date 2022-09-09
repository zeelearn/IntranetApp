class CVFCategoryResponse {
  late String responseMessage;
  late int statusCode;
  late List<CategotyInfo> responseData;

  CVFCategoryResponse(
      {required this.responseMessage,required this.statusCode,required this.responseData});

  CVFCategoryResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <CategotyInfo>[];
      json['responseData'].forEach((v) {
        responseData.add(new CategotyInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategotyInfo {
  late int categoryId;
  late String categoryName;

  CategotyInfo({required this.categoryId,required this.categoryName});

  CategotyInfo.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_Id'];
    categoryName = json['category_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_Id'] = this.categoryId;
    data['category_Name'] = this.categoryName;
    return data;
  }
}
