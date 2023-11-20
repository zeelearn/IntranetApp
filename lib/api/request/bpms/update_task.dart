import 'dart:convert';

class UpdateBpmsTaskRequest {
  UpdateBpmsTaskRequest({
    required this.taskid,
    required this.status,
    required this.remark,
    required this.startDate,
    required this.endDate,
    required this.userId,
  });
  late final int taskid;
  late final String status;
  late final String remark;
  late final String startDate;
  late final String endDate;
  late final String userId;

  UpdateBpmsTaskRequest.fromJson(Map<String, dynamic> json){
    taskid = json['taskid'];
    status = json['status'];
    remark = json['remark'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    userId = json['user_id'];
  }


  toJson() {
    return jsonEncode({
      'taskid': this.taskid,
      'status': this.status,
      'remark': this.remark,
      'start_date': this.startDate,
      'end_date': this.endDate,
      'user_id': this.userId,
    });
  }
}