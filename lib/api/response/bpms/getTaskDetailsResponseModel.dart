import 'package:Intranet/api/response/bpms/project_task.dart';

class GetTaskDetailsResponseModel {
  GetTaskDetailsResponseModel({
    required this.success,
    required this.taskDetail,
  });
  late final int success;
  late final List<ProjectTaskModel> taskDetail;

  GetTaskDetailsResponseModel.fromJson(Map<String, dynamic> json){
    success = json['success'];
    taskDetail = List.from(json['data']).map((e)=>ProjectTaskModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = taskDetail.map((e)=>e.toJson()).toList();
    return _data;
  }
}

/*
class ProjectTaskModel {
  ProjectTaskModel({
    required this.projectId,
    required this.title,
    required this.id,
    required this.note,
    required this.startDate,
    required this.endDate,
    required this.pStartDate,
    required this.dueDate,
    required this.status,
    required this.statusname,
    required this.parentTaskId,
    required this.dependentTaskId,
    required this.mtaskId,
    required this.taskcreateduser,
    required this.latestComment,
    required this.files,
  });
  late final String projectId;
  late final String title;
  late final String id;
  late final String note;
  late final String startDate;
  late final String endDate;
  late final String pStartDate;
  late final String dueDate;
  int status=0;
  String statusname='';
  late final String parentTaskId;
  late final int dependentTaskId;
  late final String mtaskId;
  late final String taskcreateduser;
  String latestComment='';
  String files='';

  ProjectTaskModel.fromJson(Map<String, dynamic> json){
    projectId = json['project_id'] ?? '';
    title = json['title'] ?? '';
    id = json['id'] ?? '';
    note = json['note'] ?? '';
    startDate = json['start_date'] ?? '';
    endDate = json['end_date'] ?? '';
    pStartDate = json['p_start_date'] ?? '';
    dueDate = json['due_date'] ?? '';
    status = json['status'] ?? 0;
    statusname = json['statusname'] ?? '';
    parentTaskId = json['parent_task_id'] ?? '';
    dependentTaskId = json['dependent_task_id'] ?? 0;
    mtaskId = json['mtask_id'] ?? '';
    taskcreateduser = json['taskcreateduser'] ?? '';
    latestComment = json['latest_comment'] ?? '';
    files = json['files'] ?? '';
    //print('File is ${files}');
  }

  Map<String, dynamic> toMap(ProjectTaskModel model) {
    Map<String, dynamic> modelMap = Map();
    modelMap["project_id"] = model.projectId;
    modelMap["title"] = model.title;
    modelMap["id"] = model.id;
    modelMap["note"] = model.note;
    modelMap["start_date"] = model.startDate;
    modelMap["end_date"] = model.endDate;
    modelMap["p_start_date"] = model.pStartDate;
    modelMap["due_date"] = model.dueDate;
    modelMap["status"] = model.status;
    modelMap["statusname"] = model.statusname;
    modelMap["parent_task_id"] = model.parentTaskId;
    modelMap["dependent_task_id"] = model.dependentTaskId;
    modelMap["mtask_id"] = model.mtaskId;
    modelMap["taskcreateduser"] = model.taskcreateduser;
    modelMap["latest_comment"] = model.latestComment;
    modelMap["files"] = model.files;
    return modelMap;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['project_id'] = projectId;
    _data['title'] = title;
    _data['id'] = id;
    _data['note'] = note;
    _data['start_date'] = startDate;
    _data['end_date'] = endDate;
    _data['p_start_date'] = pStartDate;
    _data['due_date'] = dueDate;
    _data['status'] = status;
    _data['statusname'] = statusname;
    _data['parent_task_id'] = parentTaskId;
    _data['dependent_task_id'] = dependentTaskId;
    _data['mtask_id'] = mtaskId;
    _data['taskcreateduser'] = taskcreateduser;
    _data['latest_comment'] = latestComment;
    _data['files'] = files;
    return _data;
  }
}*/
