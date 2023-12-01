class AddNewTaskResponse {
  AddNewTaskResponse({
    required this.success,
    required this.data,
  });

  late final int success;
  late final List<AddNewTaskModel> data;

  AddNewTaskResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = List.from(json['data']).map((e) => AddNewTaskModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e) => e.toJson()).toList();
    return _data;
  }
}

class AddNewTaskModel {
  AddNewTaskModel({
    required this.projectId,
    required this.title,
    required this.id,
    required this.note,
    required this.img,
    required this.priority,
    required this.StartDate,
    required this.EndDate,
    required this.pStartDate,
    required this.dueDate,
    required this.ResponsiblePerson,
    required this.taskcount,
    required this.status,
    required this.statusname,
    required this.parentTaskId,
    required this.dependentTaskId,
    required this.done,
    required this.mtaskId,
    required this.taskcreateduser,
    required this.latestComment,
    this.files,
    required this.manager,
    required this.treeStatus,
    required this.className,
  });

  late final String projectId;
  late final String title;
  late final String id;
  late final String note;
  late final String img;
  late final String priority;
  late final String StartDate;
  late final String EndDate;
  late final String pStartDate;
  late final String dueDate;
  late final String ResponsiblePerson;
  late final String taskcount;
  late final int status;
  late final String statusname;
  late final String parentTaskId;
  late final int dependentTaskId;
  late final bool done;
  late final String mtaskId;
  late final String taskcreateduser;
  late final String latestComment;
  late final Null files;
  late final String manager;
  late final String treeStatus;
  late final String className;

  AddNewTaskModel.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    title = json['title'];
    id = json['id'];
    note = json['note'];
    img = json['img'];
    priority = json['priority'];
    StartDate = json['Start_date'];
    EndDate = json['End_date'];
    pStartDate = json['p_start_date'];
    dueDate = json['due_date'];
    ResponsiblePerson = json['Responsible_person'];
    taskcount = json['taskcount'];
    status = json['status'];
    statusname = json['statusname'];
    parentTaskId = json['parent_task_id'];
    dependentTaskId = json['dependent_task_id'];
    done = json['done'];
    mtaskId = json['mtask_id'];
    taskcreateduser = json['taskcreateduser'];
    latestComment = json['latest_comment'];
    files = null;
    manager = json['manager'];
    treeStatus = json['treeStatus'];
    className = json['class'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['project_id'] = projectId;
    _data['title'] = title;
    _data['id'] = id;
    _data['note'] = note;
    _data['img'] = img;
    _data['priority'] = priority;
    _data['Start_date'] = StartDate;
    _data['End_date'] = EndDate;
    _data['p_start_date'] = pStartDate;
    _data['due_date'] = dueDate;
    _data['Responsible_person'] = ResponsiblePerson;
    _data['taskcount'] = taskcount;
    _data['status'] = status;
    _data['statusname'] = statusname;
    _data['parent_task_id'] = parentTaskId;
    _data['dependent_task_id'] = dependentTaskId;
    _data['done'] = done;
    _data['mtask_id'] = mtaskId;
    _data['taskcreateduser'] = taskcreateduser;
    _data['latest_comment'] = latestComment;
    _data['files'] = files;
    _data['manager'] = manager;
    _data['treeStatus'] = treeStatus;
    _data['class'] = className;
    return _data;
  }
}
