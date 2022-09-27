class UpdatePJPStatusResponse {
  late int statusCode;
  late String responseMessage;
  late int responseData;

  UpdatePJPStatusResponse({required this.statusCode,required this.responseMessage,required this.responseData});

  UpdatePJPStatusResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['responseMessage'] = this.responseMessage;
    data['responseData'] = this.responseData;
    return data;
  }
}