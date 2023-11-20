class UpdateBpmsTaskResponse {
  UpdateBpmsTaskResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<UpdateBpmsTaskModel> data;

  UpdateBpmsTaskResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    try {
      data = List.from(json['data'])
          .map((e) => UpdateBpmsTaskModel.fromJson(e))
          .toList();
    }catch(e){}
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class UpdateBpmsTaskModel {
  UpdateBpmsTaskModel({
    required this.msg,
  });
  late final String msg;

  UpdateBpmsTaskModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    return _data;
  }
}