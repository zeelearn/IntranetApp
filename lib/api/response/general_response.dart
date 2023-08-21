class GeneralResponse {
  late String responseMessage;
  late int statusCode;
  late int responseData;

  GeneralResponse({required this.responseMessage,required  this.statusCode,required  this.responseData});

  GeneralResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = json['responseData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    data['responseData'] = this.responseData;
    return data;
  }
}
