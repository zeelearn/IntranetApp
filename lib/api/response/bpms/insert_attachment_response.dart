class InsertTaskAttachmentResponse {
  InsertTaskAttachmentResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<InsertTaskAttachmentModel> data;

  InsertTaskAttachmentResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>InsertTaskAttachmentModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class InsertTaskAttachmentModel {
  InsertTaskAttachmentModel({
    required this.msg,
  });
  late final String msg;

  InsertTaskAttachmentModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    return _data;
  }
}