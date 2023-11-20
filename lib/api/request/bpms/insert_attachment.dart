import 'dart:convert';

class InsertTaskAttachmentRequest {
  InsertTaskAttachmentRequest({
    required this.taskId,
    required this.filePath,
    required this.userId,
  });
  late final String taskId;
  late final String filePath;
  late final String userId;

  InsertTaskAttachmentRequest.fromJson(Map<String, dynamic> json){
    taskId = json['task_id'];
    filePath = json['file_path'];
    userId = json['UserId'];
  }

  toJson() {
    return jsonEncode({
      'task_id': this.taskId,
      'file_path': this.filePath,
      'UserId': this.userId
    });
  }
}