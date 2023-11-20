import 'dart:convert';

class GetTaskCommentRequest {
  GetTaskCommentRequest({
    required this.task_id,
  });
  late final String task_id;

  GetTaskCommentRequest.fromJson(Map<String, dynamic> json){
    task_id = json['task_id'];
  }

  toJson() {
    return jsonEncode({
      'task_id': this.task_id,
    });
  }
  
}