class MyReportResponse {
  late String responseMessage;
  late int statusCode;
  late List<ReportInfo> responseData;

  MyReportResponse({required this.responseMessage,required this.statusCode,required this.responseData});

  MyReportResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <ReportInfo>[];
      json['responseData'].forEach((v) {
        responseData.add(new ReportInfo.fromJson(v));
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

class ReportInfo {
  late String title;
  late String webViewURL;

  ReportInfo({required this.title,required this.webViewURL});

  ReportInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    webViewURL = json['webViewURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['webViewURL'] = this.webViewURL;
    return data;
  }
}
