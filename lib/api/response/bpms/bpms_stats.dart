class ProjectStatsResponse {
  ProjectStatsResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<ProjectStatsModel> data;

  ProjectStatsResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>ProjectStatsModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class ProjectStatsModel {
  ProjectStatsModel({
    required this.TotalProject,
    required this.pendingtask,
    required this.completedTask,
    required this.InprogressTask,
    required this.CancelledTask,
  });
  late final int TotalProject;
  late final int pendingtask;
  late final int completedTask;
  late final int InprogressTask;
  late final int CancelledTask;

  ProjectStatsModel.fromJson(Map<String, dynamic> json){
    TotalProject = json['TotalProject'];
    pendingtask = json['pendingtask'];
    completedTask = json['completedTask'];
    InprogressTask = json['InprogressTask'];
    CancelledTask = json['CancelledTask'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['TotalProject'] = TotalProject;
    _data['pendingtask'] = pendingtask;
    _data['completedTask'] = completedTask;
    _data['InprogressTask'] = InprogressTask;
    _data['CancelledTask'] = CancelledTask;
    return _data;
  }
}