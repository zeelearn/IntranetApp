import 'dart:convert';

class DeleteTaskRequest {
  DeleteTaskRequest({
    required this.taskId,

  });
  late final String taskId;


  DeleteTaskRequest.fromJson(Map<String, dynamic> json){
    taskId = json['taskid'];

  }

  toJson() {
    return jsonEncode({
      'taskid': this.taskId,
    });
  }

}