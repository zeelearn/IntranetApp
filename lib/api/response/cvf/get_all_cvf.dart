import 'package:intranet/api/response/pjp/pjplistresponse.dart';

class GetAllCVFResponse {
  late String responseMessage;
  late int statusCode;
  late List<GetDetailedPJP> responseData;

  GetAllCVFResponse({required this.responseMessage,required this.statusCode,required this.responseData});

  GetAllCVFResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <GetDetailedPJP>[];
      json['responseData'].forEach((v) {
        responseData.add(new GetDetailedPJP.fromJson(v));
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

class CVFListModel {
  late String visitDate;
  late String visitTime;
  late String franchiseeCode;
  late String franchiseeName;
  late String latitude;
  late String longitude;
  late String address;
  late String activityTitle;
  late List<Purpose> purpose;

  CVFListModel(
      {required this.visitDate,
        required this.visitTime,
        required this.franchiseeCode,
        required this.franchiseeName,
        required this.latitude,
        required this.longitude,
        required this.address,
        required this.activityTitle,
        required this.purpose});

  CVFListModel.fromJson(Map<String, dynamic> json) {
    visitDate = json['Visit_Date'];
    visitTime = json['Visit_Time'];
    franchiseeCode = json['Franchisee_Code'];
    franchiseeName = json['Franchisee_Name'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    address = json['Address'];
    activityTitle = json['ActivityTitle'];
    if (json['Purpose'] != null) {
      purpose = <Purpose>[];
      json['Purpose'].forEach((v) {
        purpose.add(new Purpose.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Visit_Date'] = this.visitDate;
    data['Visit_Time'] = this.visitTime;
    data['Franchisee_Code'] = this.franchiseeCode;
    data['Franchisee_Name'] = this.franchiseeName;
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    data['Address'] = this.address;
    data['ActivityTitle'] = this.activityTitle;
    if (this.purpose != null) {
      data['Purpose'] = this.purpose.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Purpose {
  late String categoryId;
  late String categoryName;

  Purpose({required this.categoryId,required  this.categoryName});

  Purpose.fromJson(Map<String, dynamic> json) {
    categoryId = json['Category_id'];
    categoryName = json['Category_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category_id'] = this.categoryId;
    data['Category_Name'] = this.categoryName;
    return data;
  }
}
