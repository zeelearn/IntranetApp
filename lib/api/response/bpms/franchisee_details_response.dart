import 'dart:convert';

class GetFranchiseeDetailsResponse {
  GetFranchiseeDetailsResponse({
    required this.success,
    required this.franchiseeInfoModel,
  });
  late final int success;
  late final List<FranchiseeInfoModel> franchiseeInfoModel;
  late final List<FranchiseeIndentModel> indentList;

  GetFranchiseeDetailsResponse.fromJson(Map<String, dynamic> json){
    success = json['success'];
    if(json.containsKey('data')) {
      franchiseeInfoModel = List.from(json['data'][0])
          .map((e) => FranchiseeInfoModel.fromJson(e))
          .toList();
      indentList = List.from(json['data'][1]).map((e) =>
          FranchiseeIndentModel.fromJson(e)).toList();
    }else{
      franchiseeInfoModel = List.from(json['franchiseeInfoModel'])
          .map((e) => FranchiseeInfoModel.fromJson(e))
          .toList();
      indentList = List.from(json['indentList']).map((e) =>
          FranchiseeIndentModel.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['franchiseeInfoModel'] = this.franchiseeInfoModel;
    _data['indentList'] = this.indentList;
    return _data;
  }
  String toJsonValue() => json.encode(toJson());

}

class FranchiseeInfoModel {

  FranchiseeInfoModel({
    required this.Attendee,
    required this.OperatingStatus,
    required this.FranchiseeCode,
    required this.FranchiseeName,
    required this.FranchiseeId,
    required this.Address1,
    required this.Address2,
    required this.Place,
    required this.PinCode,
    required this.CityName,
    required this.StateName,
    required this.EmailId,
    required this.MobileNo,
    required this.FranId,
    required this.leadId,
  });
  late final String Attendee;
  late final String OperatingStatus;
  late final String FranchiseeCode;
  late final String FranchiseeName;
  late final int FranchiseeId;
  late final String Address1;
  late final String Address2;
  late final String Place;
  late final String PinCode;
  late final String CityName;
  late final String StateName;
  late final String EmailId;
  late final String MobileNo;
  late final String FranId;
  late final String leadId;

  FranchiseeInfoModel.fromJson(Map<String, dynamic> json){
    Attendee = json['Attendee'] ?? '';
    OperatingStatus = json['Operating_Status'] ?? '';
    FranchiseeCode = json['Franchisee_Code'] ?? '';
    FranchiseeName = json['Franchisee_Name'] ?? '';
    FranchiseeId = json['Franchisee_Id'] ?? 0;
    Address1 = json['Address1'] ?? '';
    Address2 = json['Address2'] ?? '';
    Place = json['Place'] ?? '';
    PinCode = json['Pin_Code'] ?? '';
    CityName = json['City_Name'] ?? '';
    StateName = json['State_Name'] ?? '';
    EmailId = json['Email_Id'] ?? '';
    MobileNo = json['Mobile_No'] ?? '';
    FranId = json['FranId'] ?? '';
    leadId = json['LeadId'] ?? '';
  }

  Map<String, dynamic> toMap(FranchiseeInfoModel model) {
    Map<String, dynamic> modelMap = Map();
    modelMap["Operating_Status"] = model.OperatingStatus;
    modelMap["Franchisee_Code"] = model.FranchiseeCode;
    modelMap["Franchisee_Name"] = model.FranchiseeName;
    modelMap["Franchisee_Id"] = model.FranchiseeId;
    modelMap["Address1"] = model.Address1;
    modelMap["Address2"] = model.Address2;
    modelMap["Place"] = model.Place;
    modelMap["Pin_Code"] = model.PinCode;
    modelMap["City_Name"] = model.CityName;
    modelMap["State_Name"] = model.StateName;
    modelMap["Email_Id"] = model.EmailId;
    modelMap["Mobile_No"] = model.MobileNo;
    modelMap["FranId"] = model.FranId;
    modelMap["LeadId"] = model.leadId;
    return modelMap;
  }


  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Attendee'] = Attendee;
    _data['Operating_Status'] = OperatingStatus;
    _data['Franchisee_Code'] = FranchiseeCode;
    _data['Franchisee_Name'] = FranchiseeName;
    _data['Franchisee_Id'] = FranchiseeId;
    _data['Address1'] = Address1;
    _data['Address2'] = Address2;
    _data['Place'] = Place;
    _data['Pin_Code'] = PinCode;
    _data['City_Name'] = CityName;
    _data['State_Name'] = StateName;
    _data['Email_Id'] = EmailId;
    _data['Mobile_No'] = MobileNo;
    _data['FranId'] = FranId;
    _data['LeadId'] = leadId;
    return _data;
  }
  String toJsonValue() => json.encode(toJson());
}



class FranchiseeIndentModel {
  FranchiseeIndentModel({
    required this.IndentId,
    required this.AcademicyearId,
    required this.IndentType,
    required this.IndentNo,
    required this.IndentDate,
    required this.IndentAmount,
    required this.ApprAmount,
    required this.DocketNo,
    required this.IndentStatus,
    required this.CreatedBy,
  });
  late final int IndentId;
  late final int AcademicyearId;
  late final String IndentType;
  late final String IndentNo;
  late final String IndentDate;
  late final int IndentAmount;
  late final int ApprAmount;
  late final String DocketNo;
  late final String IndentStatus;
  late final String CreatedBy;

  FranchiseeIndentModel.fromJson(Map<String, dynamic> json){
    print('FranchiseeIndentModel started....');
    IndentId = json['Indent_Id'] ?? 0;
    AcademicyearId = json['Academicyear_Id'] ?? 0;
    IndentType = json['Indent_Type'] ?? '';
    IndentNo = json['Indent_No'] ?? '';
    IndentDate = json['Indent_Date'] ?? '';
    IndentAmount = json['Indent_Amount'] ?? '';
    ApprAmount = json['Appr_Amount'] ?? 0;
    DocketNo = json['DocketNo'] ?? '';
    IndentStatus = json['Indent_Status'] ?? '';
    CreatedBy = json['Created_By'] ?? '';
    print('FranchiseeIndentModel completed....');
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['Indent_Id'] = IndentId;
    _data['Academicyear_Id'] = AcademicyearId;
    _data['Indent_Type'] = IndentType;
    _data['Indent_No'] = IndentNo;
    _data['Indent_Date'] = IndentDate;
    _data['Indent_Amount'] = IndentAmount;
    _data['Appr_Amount'] = ApprAmount;
    _data['Docket_No'] = DocketNo;
    _data['Indent_Status'] = IndentStatus;
    _data['Created_By'] = CreatedBy;
    return _data;
  }

  Map<String, dynamic> toMap(FranchiseeIndentModel model) {
    Map<String, dynamic> modelMap = Map();
    modelMap["Indent_Id"] = model.IndentId;
    modelMap["Academicyear_Id"] = model.AcademicyearId;
    modelMap["Indent_Type"] = model.IndentType;
    modelMap["Indent_No"] = model.IndentNo;
    modelMap["Indent_Date"] = model.IndentDate;
    modelMap["Indent_Amount"] = model.IndentAmount;
    modelMap["Docket_No"] = model.DocketNo;
    modelMap["Indent_Status"] = model.IndentStatus;
    modelMap["Created_By"] = model.CreatedBy;
    return modelMap;
  }

}