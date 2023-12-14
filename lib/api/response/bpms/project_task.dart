class ProjectTaskResponse {
  ProjectTaskResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<List<ProjectTaskModel>> data;

  factory ProjectTaskResponse.fromJson(Map<String, dynamic> json){
    return ProjectTaskResponse(
      success: json["success"] ?? 0,
      data: json["data"] == null ? [] : List<List<ProjectTaskModel>>.from(json["data"]!.map((x) => x == null ? [] : List<ProjectTaskModel>.from(x!.map((x) => ProjectTaskModel.fromJson(x))))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.map((x) => x.map((x) => x?.toJson()).toList()).toList(),
  };

}

class ProjectTaskModel {
  ProjectTaskModel({
    required this.projectId,
    required this.title,
    required this.id,
    required this.note,
    required this.img,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.pStartDate,
    required this.dueDate,
    required this.responsiblePerson,
    required this.status,
    required this.statusname,
    required this.parentTaskId,
    required this.dependentTaskId,
    required this.taskcount,
    required this.isImageUpload,
    required this.done,
    required this.mtaskId,
    required this.taskcreateduser,
    required this.latestComment,
    required this.files,
    required this.manager,
    required this.treeStatus,
    required this.datumClass,
    required this.parantDate,
    required this.parantPlandate,
    required this.path
  });

  final String projectId;
  final String title;
  final String id;
  final String note;
  final String img;
  final String priority;
  final String startDate;
  final String endDate;
  final String pStartDate;
  final String dueDate;
  final String responsiblePerson;
  late int status;
  late String statusname;
  final String parentTaskId;
  final int dependentTaskId;
  final String taskcount;
  final int isImageUpload;
  final bool done;
  final String mtaskId;
  late String taskcreateduser;
  late String latestComment;
  late final String files;
  final String manager;
  final String treeStatus;
  final String datumClass;
  final String parantDate;
  final String parantPlandate;
  String path='';

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json){
    return ProjectTaskModel(
      projectId: json["project_id"] ?? "",
      title: json["title"] ?? "",
      id: json["id"] ?? "",
      note: json["note"] ?? "",
      img: json["img"] ?? "",
      priority: json["priority"] ?? "",
      startDate: json["Start_date"] ?? "",// DateTime.tryParse(json["Start_date"] ?? ""),
      endDate: json["End_date"] ?? "",// DateTime.tryParse(json["End_date"] ?? ""),
      pStartDate:json["p_start_date"] ?? "",// DateTime.tryParse(json["p_start_date"] ?? ""),
      dueDate:json["due_date"] ?? "",// DateTime.tryParse(json["due_date"] ?? ""),
      responsiblePerson: json["Responsible_person"] ?? "",
      status: json["status"] ?? 0,
      statusname: json["statusname"] ?? "",
      parentTaskId: json["parent_task_id"] ?? "",
      dependentTaskId: json["dependent_task_id"] ?? 0,
      taskcount: json["taskcount"] ?? "",
      isImageUpload: json["IsImageUpload"] ?? 0,
      done: json["done"] ?? false,
      mtaskId: json["mtask_id"] ?? "",
      taskcreateduser: json["taskcreateduser"] ?? "",
      latestComment: json["latest_comment"] ?? "",
      files: json["files"]  ?? "",
      manager: json["manager"] ?? "",
      treeStatus: json["treeStatus"] ?? "",
      datumClass: json["class"] ?? "",
      parantDate: json["parant_date"] ?? "",
      parantPlandate: json["parant_plandate"] ?? "",
      path: '',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> modelMap = Map();
    modelMap["project_id"] = projectId;
    modelMap["title"] = title;
    modelMap["id"] = id;
    modelMap["note"] = note;
    modelMap["img"] = img;
    modelMap["priority"] = priority;
    modelMap["Start_date"] = startDate;
    modelMap["End_date"] = endDate;
    modelMap["p_start_date"] = pStartDate;
    modelMap["due_date"] = dueDate;
    modelMap["taskcount"] = taskcount;
    modelMap["Responsible_person"] = responsiblePerson;
    modelMap["status"] =status;
    modelMap["statusname"] =statusname;
    modelMap["parent_task_id"] =parentTaskId;
    modelMap["dependent_task_id"] =dependentTaskId;
    modelMap["taskcount"] =taskcount;
    modelMap["IsImageUpload"] =isImageUpload;
    modelMap["done"] =done;
    modelMap["mtask_id"] =mtaskId;
    modelMap["taskcreateduser"] =taskcreateduser;
    modelMap["latest_comment"] =latestComment;
    modelMap["manager"] =manager;
    modelMap["treeStatus"] =treeStatus;
    modelMap["class"] =datumClass;
    modelMap["parant_date"] =parantDate;
    modelMap["parant_plandate"] =parantPlandate;
    return modelMap;
  }


  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "title": title,
    "id": id,
    "note": note,
    "img": img,
    "priority": priority,
    "Start_date": startDate,//?.toIso8601String(),
    "End_date": endDate,//?.toIso8601String(),
    "p_start_date": pStartDate,//?.toIso8601String(),
    "due_date": dueDate,//?.toIso8601String(),
    "Responsible_person": responsiblePerson,
    "status": status,
    "statusname": statusname,
    "parent_task_id": parentTaskId,
    "dependent_task_id": dependentTaskId,
    "taskcount": taskcount,
    "IsImageUpload": isImageUpload,
    "done": done,
    "mtask_id": mtaskId,
    "taskcreateduser": taskcreateduser,
    "latest_comment": latestComment,
    "files": files,
    "manager": manager,
    "treeStatus": treeStatus,
    "class": datumClass,
    "parant_date": parantDate,
    "parant_plandate": parantPlandate,
  };

}
