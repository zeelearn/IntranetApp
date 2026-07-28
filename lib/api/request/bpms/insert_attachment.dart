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

  /// Matches web payload: numeric `task_id` / `UserId`, string `file_path`.
  toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'task_id': int.tryParse(taskId.toString()) ?? taskId,
      'file_path': filePath,
      'UserId': int.tryParse(userId.toString()) ?? userId,
    };
  }
}