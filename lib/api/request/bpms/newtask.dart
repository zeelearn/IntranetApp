import 'dart:convert';

class NewTaskRequest {
  NewTaskRequest({
    required this.taskid,
    required this.mtaskId,
    required this.projectId,
    required this.title,
    required this.note,
    required this.startDate,
    required this.endDate,
    required this.pStartDate,
    required this.pEndDate,
    required this.status,
    required this.formurl,
    required this.parentTaskId,
    required this.dependentTaskId,
    required this.contributionId,
    required this.UserId,
  });
  late final int taskid;
  late final int mtaskId;
  late final String projectId;
  late final String title;
  late final String note;
  late final String startDate;
  late final String endDate;
  late final String pStartDate;
  late final String pEndDate;
  late final int status;
  late final String formurl;
  late final String parentTaskId;
  late final int dependentTaskId;
  late final int contributionId;
  late final int UserId;

  NewTaskRequest.fromJson(Map<String, dynamic> json){
    taskid = json['taskid'];
    mtaskId = json['mtask_id'];
    projectId = json['project_id'];
    title = json['title'];
    note = json['note'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    pStartDate = json['p_start_date'];
    pEndDate = json['p_end_date'];
    status = json['status'];
    formurl = json['formurl'];
    parentTaskId = json['parent_task_id'];
    dependentTaskId = json['dependent_task_id'];
    contributionId = json['contribution_id'];
    UserId = json['User_id'];
  }

  toJson() {
    return jsonEncode({
      'taskid': this.taskid,
      'mtask_id': this.mtaskId,
      'project_id': this.projectId,
      'title': this.title,
      'note': this.note,
      'start_date': this.startDate,
      'end_date': this.endDate,
      'p_start_date': this.pStartDate,
      'p_end_date': this.pEndDate,
      'status': this.status,
      'formurl': this.formurl,
      'parent_task_id': this.parentTaskId,
      'dependent_task_id': this.dependentTaskId,
      'contribution_id': this.contributionId,
      'User_id': this.UserId,
    });
  }

}