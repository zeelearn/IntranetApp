class CommonResponse {
  CommonResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<SendCredentialModel> data;

  CommonResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>SendCredentialModel.fromJson(e)).toList();
  }

  CommonResponse.fromJson1(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>SendCredentialModel.fromJson1(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class SendCredentialModel {
  SendCredentialModel({
    required this.msg,
  });
  late final String msg;

  SendCredentialModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'];
  }

  SendCredentialModel.fromJson1(Map<String, dynamic> json){
    msg = json['Msg'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    return _data;
  }
}