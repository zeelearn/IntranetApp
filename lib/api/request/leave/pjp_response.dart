class PJPListResponse {
  String responseMessage='';
  int statusCode=0;
  List<ResponseData> responseData=[];

  PJPListResponse({required this.responseMessage,required  this.statusCode,required  this.responseData});

  PJPListResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = [];
      json['responseData'].forEach((v) {
        responseData.add(new ResponseData.fromJson(v));
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

class ResponseData {
  String msg='';
  int count=-1;
  bool isMandatory=false;

  ResponseData({required this.msg,required this.count,required this.isMandatory});

  ResponseData.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    count = json['count'];
    isMandatory = json['isMandatory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['count'] = this.count;
    data['isMandatory'] = this.isMandatory;
    return data;
  }
}
