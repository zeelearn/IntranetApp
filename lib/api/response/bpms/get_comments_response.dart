class GetCommentResponse {
  GetCommentResponse({
    required this.success,
    required this.commentModelList,
  });
  late final int success;
  late final List<CommentModel> commentModelList;

  GetCommentResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    commentModelList = List.from(json['data']).map((e)=>CommentModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = commentModelList.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class CommentModel {
  CommentModel({
    required this.comment,
    required this.CreatedBy,
    required this.CreatedDate,
    required this.createdtime,
    required this.ModifiedBy,
    required this.ModifiedDate,
    required this.createduser,
  });
  late final String comment;
  late final String CreatedBy;
  late final String CreatedDate;
  late final String createdtime;
  late final String ModifiedBy;
  late final String ModifiedDate;
  late final String createduser;

  CommentModel.fromJson(Map<String, dynamic> json){
    comment = json['comment'] ?? '';
    CreatedBy = json['CreatedBy'] ?? '';
    CreatedDate = json['CreatedDate'] ?? '';
    createdtime = json['createdtime'] ?? '';
    ModifiedBy = json['ModifiedBy'] ?? '';
    ModifiedDate = json['ModifiedDate'] ?? '';
    createduser = json['createduser'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['comment'] = comment;
    _data['CreatedBy'] = CreatedBy;
    _data['CreatedDate'] = CreatedDate;
    _data['createdtime'] = createdtime;
    _data['ModifiedBy'] = ModifiedBy;
    _data['ModifiedDate'] = ModifiedDate;
    _data['createduser'] = createduser;
    return _data;
  }
}