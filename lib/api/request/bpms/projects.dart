import 'package:Intranet/api/response/bpms/project_task.dart';

class ProjectResponse {
  ProjectResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<ProjectModel> data;

  ProjectResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>ProjectModel.fromJson(e)).toList();
  }
  ProjectResponse.fromJsonByStatus(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>ProjectModel.fromJsonByStatus(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class ProjectModel {
  ProjectModel({
    required this.CRMId,
    required this.DocUrl,
    required this.approvedDate,
    this.FranchiseeCode,
    this.FranchiseeName,
    this.FranchiseeId,
    required this.deadline,
    required this.CreatedBy,
    required this.TotalNoOfTask,
    required this.CatchmentArea,
    required this.taskcount,
    required this.responsiblePerson,
    required this.status,
    required this.statusname,
    this.TierName,
    this.FeeType,
    this.Remark,
    this.StartDate,
    this.End_date,
    this.p_start_date,
    this.due_date,
    this.taskcreateduser,
    required this.files,
    required this.parenttaskid,
    required this.dependentTaskId,
    required this.mtaskId,
    required this.id,
  });
  late final String CRMId;
  late final String id;
  late final String DocUrl;
  late final String approvedDate;
  late final String? FranchiseeCode;
  late final String? FranchiseeName;
  String responsiblePerson='';
  late final int? FranchiseeId;
  late final String deadline;
  late final String CreatedBy;
  late final int TotalNoOfTask;
  late final int status;
  late final String CatchmentArea;
  late final String taskcount;
  late final String? TierName;
  late final String? FeeType;
  late final String? Title;
  late final String? Remark;
  late final String? StartDate;
  late final String? End_date;
  late final String? p_start_date;
  late final String? due_date;
  late final String? taskcreateduser;
  late final String files;
  late final String statusname;
  late final String parenttaskid;
  late final int dependentTaskId;
  late final String mtaskId;

  getModel(){
    return ProjectTaskModel(projectId: CRMId, title: Title!, id: id, note: Remark!, img: files, priority: '', startDate: StartDate!, endDate: End_date!, pStartDate: p_start_date!, dueDate: due_date!, responsiblePerson: responsiblePerson, status: status, statusname: statusname, parentTaskId: parenttaskid, dependentTaskId: dependentTaskId, taskcount: taskcount, isImageUpload: 0, done: false, mtaskId: mtaskId, taskcreateduser: taskcreateduser!, latestComment: Remark!, files: files, manager: '', treeStatus: '', datumClass: '', parantDate: '', parantPlandate: '', path: '');
  }

  ProjectModel.fromJson(Map<String, dynamic> json){
    CRMId = json['CRM_id'] ?? '';
    id = json['id'] ?? '';
    DocUrl = json['Doc_url'];
    approvedDate = json['approved_date'] ?? '';
    FranchiseeCode = json['Franchisee_Code'] ?? '';
    FranchiseeName = json['Franchisee_Name'] ?? '';
    FranchiseeId = json['Franchisee_Id'] ?? 0;
    deadline = json['deadline'] ?? '';
    CreatedBy = json['CreatedBy'] ?? '';
    TotalNoOfTask = json['TotalNoOfTask'] ?? 0;
    CatchmentArea = json['CatchmentArea'] ?? '';
    taskcount = json['taskcount'] ?? '';
    TierName = json['Tier_Name'] ?? '';
    FeeType = json['Fee_Type'] ?? '';
    Title = json['Title'] ?? '';
    Remark = json['latest_comment'] ?? '';
    StartDate = json['Start_date'] ?? '';
    End_date = json['End_date'] ?? '';
    p_start_date = json['p_start_date'] ?? '';
    due_date = json['due_date'] ?? '';
    taskcreateduser = json['taskcreateduser'] ?? '';
    files = json['files'] ?? '';
    status = json['status'] ?? 0;
    statusname = json['statusname'] ?? '';
    parenttaskid = json['parent_task_id'] ?? '';
    dependentTaskId = json['dependent_task_id'] ?? 0;
    mtaskId = json['mtask_id'] ?? '';
  }
  ProjectModel.fromJsonStatus(Map<String, dynamic> json){
    CRMId = json['CRM_id'];
    id = json['id'];
    DocUrl = json['Doc_url'];
    approvedDate = json['approved_date'];
    FranchiseeCode = json['Franchisee_Code'];
    FranchiseeName = json['Franchisee_Name'];
    FranchiseeId = json['Franchisee_Id'];
    deadline = json['deadline'];
    CreatedBy = json['CreatedBy'];
    TotalNoOfTask = json['TotalNoOfTask'] ?? 0;
    CatchmentArea = json['CatchmentArea'];
    taskcount = json['taskcount'];
    TierName = json['Tier_Name'];
    FeeType = json['Fee_Type'];
    Title = json['title'] ?? '';
    Remark = json['latest_comment'] ?? '';
    StartDate = json['Start_date'] ?? '';
    End_date = json['End_date'] ?? '';
    p_start_date = json['p_start_date'] ?? '';
    due_date = json['due_date'] ?? '';
    taskcreateduser = json['taskcreateduser'] ?? '';
    files = json['files'] ?? '';
    status = json['status'] ?? 0;
    statusname = json['statusname'] ?? '';
    parenttaskid = json['parent_task_id'] ?? '';
    dependentTaskId = json['dependent_task_id'] ?? 0;
    mtaskId = json['mtask_id'] ?? '';

  }

  ProjectModel.fromJsonByStatus(Map<String, dynamic> json){
    CRMId = json['project_id'] ?? '';
    id = json['id'] ?? '';
    DocUrl = json['Doc_url'] ?? '';
    approvedDate = json['approved_date'] ?? '';
    FranchiseeCode = json['Franchisee_Code'] ?? '';
    FranchiseeName = json['Franchisee_Name'] ?? '';
    FranchiseeId = json['Franchisee_Id'] ?? 0;
    deadline = json['deadline'] ?? '';
    CreatedBy = json['CreatedBy'] ?? '';
    responsiblePerson = json['Responsible_person'] ?? '';
    TotalNoOfTask = json['TotalNoOfTask'] ?? 0;
    CatchmentArea = json['CatchmentArea'] ?? '';
    taskcount = json['taskcount'] ?? 0;
    TierName = json['Tier_Name'] ?? '';
    FeeType = json['Fee_Type'] ?? '';
    Title = json['title'] ?? '';
    Remark = json['latest_comment'] ?? '';
    StartDate = json['Start_date'] ?? '';
    p_start_date = json['p_start_date'] ?? '';
    End_date = json['End_date'] ?? '';
    due_date = json['due_date'] ?? '';
    taskcreateduser = json['taskcreateduser'] ?? '';
    files = json['files'] ?? '';
    status = json['status'] ?? 0;
    statusname = json['statusname'] ?? '';
    parenttaskid = json['parent_task_id'] ?? '';
    dependentTaskId = json['dependent_task_id'] ?? 0;
    mtaskId = json['mtask_id'] ?? '';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> modelMap = Map();
    modelMap["CRM_id"] = CRMId;
    modelMap["id"] = id;
    modelMap["Doc_url"] = DocUrl;
    modelMap["approved_date"] = approvedDate;
    modelMap["Franchisee_Code"] = FranchiseeCode;
    modelMap["Franchisee_Name"] = FranchiseeName;
    modelMap["Franchisee_Id"] = FranchiseeId;
    modelMap["deadline"] = deadline;
    modelMap["CreatedBy"] = CreatedBy;
    modelMap["TotalNoOfTask"] = TotalNoOfTask;
    modelMap["CatchmentArea"] = CatchmentArea;
    modelMap["taskcount"] = taskcount;
    modelMap["Tier_Name"] = TierName;
    modelMap["Fee_Type"] =FeeType;
    modelMap["title"] =Title;
    modelMap["latest_comment"] =Remark;
    modelMap["Start_date"] =StartDate;
    modelMap["End_date"] =End_date;
    modelMap["p_start_date"] =p_start_date;
    modelMap["due_date"] =due_date;
    modelMap["files"] =files;
    modelMap["status"] =status;
    modelMap["statusname"] =statusname;
    modelMap["parent_task_id"] =parenttaskid;
    modelMap["dependent_task_id"] =dependentTaskId;
    modelMap["mtask_id"] =mtaskId;
    return modelMap;
  }

  bool isContains(String value){
    if(CRMId.toString().toLowerCase().contains(value.toLowerCase()) ||
        FranchiseeName.toString().toLowerCase().contains(value.toLowerCase()) ||
        FranchiseeCode.toString().toLowerCase().contains(value.toLowerCase()) ||
        TierName.toString().toLowerCase().contains(value.toLowerCase()) ||
        FeeType.toString().toLowerCase().contains(value.toLowerCase()) ||
        CreatedBy.toString().toLowerCase().contains(value.toLowerCase()) ||
        Title.toString().toLowerCase().contains(value.toLowerCase())
    ){
      return true;
    }else{
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['CRM_id'] = CRMId;
    _data['Doc_url'] = DocUrl;
    _data['approved_date'] = approvedDate;
    _data['Franchisee_Code'] = FranchiseeCode;
    _data['Franchisee_Name'] = FranchiseeName;
    _data['Franchisee_Id'] = FranchiseeId;
    _data['deadline'] = deadline;
    _data['CreatedBy'] = CreatedBy;
    _data['TotalNoOfTask'] = TotalNoOfTask;
    _data['CatchmentArea'] = CatchmentArea;
    _data['taskcount'] = taskcount;
    _data['Tier_Name'] = TierName;
    _data['Fee_Type'] = FeeType;
    return _data;
  }
}