class CentersResponse {
  late String responseMessage;
  late int statusCode;
  late List<FranchiseeInfo> responseData;

  CentersResponse({required this.responseMessage,required this.statusCode,required this.responseData});

  CentersResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <FranchiseeInfo>[];
      json['responseData'].forEach((v) {
        responseData.add(new FranchiseeInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FranchiseeInfo {
  late double franchiseeId;
  late String franchiseeCode;
  late String franchiseeName;
  late String franchiseeZone;
  late String franchiseeState;
  late String franchiseeCity;

  FranchiseeInfo(
      {required this.franchiseeId,
        required this.franchiseeCode,
        required this.franchiseeName,
        required this.franchiseeZone,
        required this.franchiseeState,
        required this.franchiseeCity});

  FranchiseeInfo.fromJson(Map<String, dynamic> json) {
    franchiseeId = json['franchisee_Id'];
    franchiseeCode = json['franchisee_Code'];
    franchiseeName = json['franchisee_Name'];
    franchiseeZone = json['franchisee_Zone'];
    franchiseeState = json['franchisee_State'];
    franchiseeCity = json['franchisee_City'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['franchisee_Id'] = this.franchiseeId;
    data['franchisee_Code'] = this.franchiseeCode;
    data['franchisee_Name'] = this.franchiseeName;
    data['franchisee_Zone'] = this.franchiseeZone;
    data['franchisee_State'] = this.franchiseeState;
    data['franchisee_City'] = this.franchiseeCity;
    return data;
  }

}
