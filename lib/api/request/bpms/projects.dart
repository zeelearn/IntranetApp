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
    this.TierName,
    this.FeeType,
  });
  late final String CRMId;
  late final String DocUrl;
  late final String approvedDate;
  late final String? FranchiseeCode;
  late final String? FranchiseeName;
  late final String? responsiblePerson;
  late final int? FranchiseeId;
  late final String deadline;
  late final String CreatedBy;
  late final int TotalNoOfTask;
  late final String CatchmentArea;
  late final String taskcount;
  late final String? TierName;
  late final String? FeeType;
  late final String? Title;

  ProjectModel.fromJson(Map<String, dynamic> json){
    CRMId = json['CRM_id'];
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
    Title = json['Title'] ?? '';
  }

  ProjectModel.fromJsonByStatus(Map<String, dynamic> json){
    CRMId = json['project_id'];
    DocUrl = json['Doc_url'] ?? '';
    approvedDate = json['approved_date'] ?? '';
    FranchiseeCode = json['Franchisee_Code'] ?? '';
    FranchiseeName = json['Franchisee_Name'] ?? '';
    FranchiseeId = json['Franchisee_Id'] ?? 0;
    deadline = json['deadline'] ?? '';
    CreatedBy = json['CreatedBy'];
    responsiblePerson = json['Responsible_person'];
    TotalNoOfTask = json['TotalNoOfTask'] ?? 0;
    CatchmentArea = json['CatchmentArea'];
    taskcount = json['taskcount'];
    TierName = json['Tier_Name'];
    FeeType = json['Fee_Type'];
    Title = json['Title'] ?? '';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> modelMap = Map();
    modelMap["CRM_id"] = CRMId;
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
    return modelMap;
  }

  bool isContains(String value){
    if(CRMId.toString().toLowerCase().contains(value.toLowerCase()) ||
        FranchiseeName.toString().toLowerCase().contains(value.toLowerCase()) ||
        FranchiseeCode.toString().toLowerCase().contains(value.toLowerCase()) ||
        TierName.toString().toLowerCase().contains(value.toLowerCase()) ||
        FeeType.toString().toLowerCase().contains(value.toLowerCase()) ||
        CreatedBy.toString().toLowerCase().contains(value.toLowerCase())
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