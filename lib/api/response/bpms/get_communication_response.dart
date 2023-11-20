class GetCommunicationResponse {
  GetCommunicationResponse({
    required this.success,
    required this.data,
  });
  late final int success;
  late final List<CommunicationModel> data;

  GetCommunicationResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    data = List.from(json['data']).map((e)=>CommunicationModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class CommunicationModel {
  CommunicationModel({
    required this.RowID,
    required this.ID,
    required this.MsgType,
    required this.BatchId,
    required this.ToAddress,
    required this.CCAddress,
    required this.BCCAddress,
    required this.FromAddress,
    required this.EmailSubject,
    required this.EmailBody,
    required this.EmailStatus,
    required this.FranchiseeId,
    required this.BusinessId,
    required this.IsActive,
    required this.CreatedBy,
    required this.CreatedDate,
    required this.ModifiedBy,
    required this.ModifiedDate,
  });

  late final String RowID;
  late final String ID;
  late final String MsgType;
  late final int BatchId;
  late final String ToAddress;
  late final String CCAddress;
  late final String BCCAddress;
  late final String FromAddress;
  late final String EmailSubject;
  late final String EmailBody;
  late final String EmailStatus;
  late final String FranchiseeId;
  late final String BusinessId;
  late final bool IsActive;
  late final String CreatedBy;
  late final String CreatedDate;
  late final String ModifiedBy;
  late final String ModifiedDate;

  CommunicationModel.fromJson(Map<String, dynamic> json){
    print('CommunicationModel 64');
    RowID = json['RowID'] ?? '';
    ID = json['ID'] ?? '';
    MsgType = json['Msg_Type'] ?? '';
    print('CommunicationModel 68');
    BatchId = json['Batch_Id'] ?? 0;
    ToAddress = json['To_Address']  ?? '';;
    CCAddress = json['CC_Address']  ?? '';
    BCCAddress = json['BCC_Address']  ?? '';
    FromAddress = json['From_Address']  ?? '';
    EmailSubject = json['Email_Subject'] ?? '';
    EmailBody = json['Email_Body'] ?? '';
    EmailStatus = json['Email_Status'] ?? '';
    FranchiseeId = json['Franchisee_Id'] ?? '';
    BusinessId = json['Business_Id'] ?? '';
    IsActive = json['Is_Active'] ?? '';
    CreatedBy = json['Created_By'] ?? '';
    CreatedDate = json['Created_Date'] ?? '';
    ModifiedBy = json['Modified_By'] ?? '';
    ModifiedDate = json['Modified_Date'] ?? '';
  }

  Map<String, dynamic> toMap(CommunicationModel model) {
    Map<String, dynamic> modelMap = Map();
    modelMap["RowID"] = model.RowID;
    modelMap["ID"] = model.ID;
    modelMap["Msg_Type"] = model.MsgType;
    modelMap["Batch_Id"] = model.BatchId;
    modelMap["To_Address"] = model.ToAddress;
    modelMap["CC_Address"] = model.CCAddress;
    modelMap["BCC_Address"] = model.BCCAddress;
    modelMap["From_Address"] = model.FromAddress;
    modelMap["Email_Subject"] = model.EmailBody;
    modelMap["Email_Status"] = model.EmailStatus;
    modelMap["Franchisee_Id"] = model.FranchiseeId;
    modelMap["Business_Id"] = model.BusinessId;
    modelMap["Is_Active"] = model.IsActive;
    modelMap["Created_By"] = model.CreatedDate;
    modelMap["Modified_By"] = model.ModifiedBy;
    modelMap["Modified_Date"] = model.ModifiedDate;
    return modelMap;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['RowID'] = RowID;
    _data['ID'] = ID;
    _data['Msg_Type'] = MsgType;
    _data['Batch_Id'] = BatchId;
    _data['To_Address'] = ToAddress;
    _data['CC_Address'] = CCAddress;
    _data['BCC_Address'] = BCCAddress;
    _data['From_Address'] = FromAddress;
    _data['Email_Subject'] = EmailSubject;
    _data['Email_Body'] = EmailBody;
    _data['Email_Status'] = EmailStatus;
    _data['Franchisee_Id'] = FranchiseeId;
    _data['Business_Id'] = BusinessId;
    _data['Is_Active'] = IsActive;
    _data['Created_By'] = CreatedBy;
    _data['Created_Date'] = CreatedDate;
    _data['Modified_By'] = ModifiedBy;
    _data['Modified_Date'] = ModifiedDate;
    return _data;
  }
}