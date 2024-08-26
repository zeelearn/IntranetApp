class GetFranchiseeLastVisit {
  String? responseMessage;
  int? statusCode;
  List<ResponseData>? responseData;

  GetFranchiseeLastVisit(
      {this.responseMessage, this.statusCode, this.responseData});

  GetFranchiseeLastVisit.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = <ResponseData>[];
    if (json['responseData'] != null) {
      json['responseData'].forEach((v) {
        responseData!.add(ResponseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseMessage'] = responseMessage;
    data['statusCode'] = statusCode;
    if (responseData != null) {
      data['responseData'] = responseData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResponseData {
  String? pJPId;
  String? pJPCVFId;
  String? franchiseeId;
  String? franchiseeCode;
  String? franchiseeName;
  String? lastCheckIn;
  String? lastCheckOut;
  String? lastVisitedBy;

  ResponseData(
      {this.pJPId,
      this.pJPCVFId,
      this.franchiseeId,
      this.franchiseeCode,
      this.franchiseeName,
      this.lastCheckIn,
      this.lastCheckOut,
      this.lastVisitedBy});

  ResponseData.fromJson(Map<String, dynamic> json) {
    pJPId = json['PJP_Id'];
    pJPCVFId = json['PJPCVF_Id'];
    franchiseeId = json['Franchisee_Id'];
    franchiseeCode = json['Franchisee_Code'];
    franchiseeName = json['Franchisee_Name'];
    lastCheckIn = json['LastCheckIn'];
    lastCheckOut = json['LastCheckOut'];
    lastVisitedBy = json['LastVisitedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PJP_Id'] = pJPId;
    data['PJPCVF_Id'] = pJPCVFId;
    data['Franchisee_Id'] = franchiseeId;
    data['Franchisee_Code'] = franchiseeCode;
    data['Franchisee_Name'] = franchiseeName;
    data['LastCheckIn'] = lastCheckIn;
    data['LastCheckOut'] = lastCheckOut;
    data['LastVisitedBy'] = lastVisitedBy;
    return data;
  }
}
