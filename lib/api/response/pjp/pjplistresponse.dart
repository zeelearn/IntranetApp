class PjpListResponse {
  late String responseMessage;
  late int statusCode;
  late List<PJPInfo> responseData;

  PjpListResponse(
      {required this.responseMessage,
      required this.statusCode,
      required this.responseData});

  PjpListResponse.fromJson(Map<String, dynamic> json) {
    try {
      responseMessage = json['responseMessage'];
      statusCode = json['statusCode'];
      if (json['responseData'] != null) {
        responseData = <PJPInfo>[];
        json['responseData'].forEach((v) {
          responseData.add(new PJPInfo.fromJson(v));
        });
      }
    } catch (e) {
      print('at line 19');
      print(e.toString());
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

class PJPInfo {
  late String displayName;
  late String fromDate;
  late String toDate;
  late String remarks;
  late String isSelfPJP = '';
  late String PJP_Id;
  List<GetDetailedPJP>? getDetailedPJP = [];

  PJPInfo(
      {required this.PJP_Id,
      required this.displayName,
      required this.fromDate,
      required this.toDate,
      required this.remarks,
      required this.isSelfPJP,
      this.getDetailedPJP});

  PJPInfo.fromJson(Map<String, dynamic> json) {
    try {
      print('at 56');
      PJP_Id = json['PJP_Id'];
      displayName = json['DisplayName'] ?? ' NA';
      fromDate = json['FromDate'] ?? ' NA';
      toDate = json['ToDate'] ?? ' NA';
      remarks = json['Remarks'] == null || json['Remarks'] == 'null'
          ? ' NA'
          : json['Remarks'];
      isSelfPJP = json['isSelfPJP'] ?? ' 0';
      if (json.containsKey('GetDetailedPJP')) {
        getDetailedPJP = <GetDetailedPJP>[];
        json['GetDetailedPJP'].forEach((v) {
          getDetailedPJP!.add(GetDetailedPJP.fromJson(v));
        });
      } else {
        //print('Data not ${json['GetDetailedPJP']} ----------------------------------');
        //getDetailedPJP = null;
      }
      print('at 76${getDetailedPJP.toString()}');
    } catch (e) {
      print('===================DATA ERROR=====71');
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PJP_Id'] = this.PJP_Id;
    data['DisplayName'] = this.displayName;
    data['FromDate'] = this.fromDate;
    data['ToDate'] = this.toDate;
    data['Remarks'] = this.remarks;
    data['isSelfPJP'] = this.isSelfPJP;
    if (this.getDetailedPJP != null) {
      data['GetDetailedPJP'] =
          this.getDetailedPJP!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetDetailedPJP {
  late String PJPCVF_Id;

  late String visitDate;
  late String visitTime;
  late String franchiseeCode;
  late String franchiseeName;
  late var Latitude;
  late var Longitude;
  late var Address;
  late var ActivityTitle;
  late List<Purpose>? purpose = [];

  late bool isSync = false;
  late bool isNotify = false;
  late bool isDelete = false;
  late bool isActive = false;
  late bool isCheckIn = false;
  late bool isCheckOut = false;
  late bool isCompleted = false;

  GetDetailedPJP({
    required this.PJPCVF_Id,
    required this.visitDate,
    required this.visitTime,
    required this.franchiseeCode,
    required this.franchiseeName,
    required this.Latitude,
    required this.Longitude,
    required this.Address,
    required this.ActivityTitle,
    required this.purpose,
    required this.isActive,
    required this.isNotify,
    required this.isCheckIn,
    required this.isCheckOut,
    required this.isSync,
    required this.isCompleted,
  });

  GetDetailedPJP.fromJson(Map<String, dynamic> json) {
    try {
      //pjpId = json['pjpId'];
      PJPCVF_Id = json['PJPCVF_Id'] ?? '0';
      visitDate = json['Visit_Date'] ?? ' NA';
      visitTime = json['Visit_Time'] ?? ' NA';
      franchiseeCode = json['Franchisee_Code'] ?? ' NA';
      franchiseeName = json['Franchisee_Name'] ?? ' NA';
      Latitude = json['Latitude'] ?? ' NA';
      Longitude = json['Longitude'] ?? ' NA';
      Address = json['Address'] ?? ' NA';
      ActivityTitle = json['ActivityTitle'] ?? ' NA';
      if (json['Purpose'] != null) {
        purpose = <Purpose>[];
        json['Purpose'].forEach((v) {
          purpose!.add(Purpose.fromJson(v));
        });
      }
    } catch (e) {
      print('at line 138');
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PJPCVF_Id'] = this.PJPCVF_Id;
    //data['pjpId'] = this.pjpId;
    data['Visit_Date'] = this.visitDate;
    data['Visit_Time'] = this.visitTime;
    data['Franchisee_Code'] = this.franchiseeCode;
    data['Franchisee_Name'] = this.franchiseeName;
    data['Latitude'] = this.Latitude;
    data['Longitude'] = this.Longitude;
    data['Address'] = this.Address;
    data['ActivityTitle'] = this.ActivityTitle;

    if (this.purpose != null) {
      data['Purpose'] = this.purpose!.map((v) => v.toJson()).toList();
    } else {
      data['Purpose'] = [];
    }
    return data;
  }
}

class Purpose {
  late String categoryId;
  late String categoryName;

  Purpose({required this.categoryId, required this.categoryName});

  Purpose.fromJson(Map<String, dynamic> json) {
    categoryId = json['Category_id'] == null ? ' NA' : json['Category_id'];
    categoryName =
        json['Category_Name'] == null ? ' NA' : json['Category_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category_id'] = this.categoryId;
    data['Category_Name'] = this.categoryName;
    return data;
  }
}
