class ProjectStatusResponse {
  ProjectStatusResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<List<ProjectStatusModel>> data;

  factory ProjectStatusResponse.fromJson(Map<String, dynamic> json){
    return ProjectStatusResponse(
      success: json["success"] ?? 0,
      data: json["data"] == null ? [] : List<List<ProjectStatusModel>>.from(json["data"]!.map((x) => x == null ? [] : List<ProjectStatusModel>.from(x!.map((x) => ProjectStatusModel.fromJson(x))))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.map((x) => x.map((x) => x?.toJson()).toList()).toList(),
  };

}

class ProjectStatusModel {
  ProjectStatusModel({
    required this.TaskStatusId,
    required this.Status,
    required this.Color,
  });
  late final int TaskStatusId;
  late final String Status;
  late final String Color;

  factory ProjectStatusModel.fromJson(Map<String, dynamic> json){
    return ProjectStatusModel(
      TaskStatusId: json["TaskStatusId"] ?? 0,
      Status: json["Status"] ?? "",
      Color: json["Color"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> modelMap = Map();
    modelMap["TaskStatusId"] = TaskStatusId;
    modelMap["Status"] = Status;
    modelMap["Color"] = Color;
    return modelMap;
  }


  Map<String, dynamic> toJson() => {
    "TaskStatusId": TaskStatusId,
    "Status": Status,
    "Color": Color,
  };

}
