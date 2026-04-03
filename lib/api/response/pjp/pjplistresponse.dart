import 'package:flutter/cupertino.dart';

class PjpListResponse {
  late String responseMessage;
  late int statusCode;
  late List<PJPInfo> responseData = <PJPInfo>[];
  late List<MYTEAM> myTeamData = <MYTEAM>[];

  PjpListResponse(
      {required this.responseMessage,
      required this.statusCode,
      required this.responseData,
      this.myTeamData = const []});

  PjpListResponse.fromJson(Map<String, dynamic> json) {
    try {
      responseMessage = json['responseMessage'] ?? '';
      statusCode = json['statusCode'] ?? 0;
      responseData = <PJPInfo>[];
      myTeamData = <MYTEAM>[];

      final dynamic data = json['responseData'];
      if (data != null) {
        if (data is List) {
          // Case 1: responseData is a direct list of PJPInfo
          for (var v in data) {
            try {
              responseData.add(PJPInfo.fromJson(v));
            } catch (e) {}
          }
        } else if (data is Map<String, dynamic>) {
          // Case 2: responseData is an object (ResponseData structure)
          if (data.containsKey('PJP') && data['PJP'] is List) {
            for (var v in data['PJP']) {
              try {
                responseData.add(PJPInfo.fromJson(v));
              } catch (e) {}
            }
          }
          if (data.containsKey('MYTEAM') && data['MYTEAM'] is List) {
            for (var v in data['MYTEAM']) {
              try {
                myTeamData.add(MYTEAM.fromJson(v));
              } catch (e) {}
            }
          }
          // Fallback: If it's a Map but not the wrapper, treat as single PJPInfo
          if (!data.containsKey('PJP') && !data.containsKey('MYTEAM')) {
            try {
              responseData.add(PJPInfo.fromJson(data));
            } catch (e) {}
          }
        }
      }
    } catch (e) {
      print('error ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseMessage'] = responseMessage;
    data['statusCode'] = statusCode;
    data['responseData'] = responseData.map((v) => v.toJson()).toList();
    data['myTeamData'] = myTeamData.map((v) => v.toJson()).toList();
    return data;
  }
}

class KESLogbookModel {
  String? responseMessage;
  int? statusCode;
  ResponseData? responseData;

  KESLogbookModel({this.responseMessage, this.statusCode, this.responseData});

  KESLogbookModel.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = json['responseData'] != null
        ? new ResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  List<PJP>? pJP;
  List<MYTEAM>? mYTEAM;

  ResponseData({this.pJP, this.mYTEAM});

  ResponseData.fromJson(Map<String, dynamic> json) {
    if (json['PJP'] != null) {
      pJP = <PJP>[];
      json['PJP'].forEach((v) {
        pJP!.add(new PJP.fromJson(v));
      });
    }
    if (json['MYTEAM'] != null) {
      mYTEAM = <MYTEAM>[];
      json['MYTEAM'].forEach((v) {
        mYTEAM!.add(new MYTEAM.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pJP != null) {
      data['PJP'] = this.pJP!.map((v) => v.toJson()).toList();
    }
    if (this.mYTEAM != null) {
      data['MYTEAM'] = this.mYTEAM!.map((v) => v.toJson()).toList();
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
  late String Status;
  late String ApprovalStatus;
  String? managerName;
  String? zone;
  List<GetDetailedPJP>? getDetailedPJP = [];

  PJPInfo(
      {required this.PJP_Id,
      required this.displayName,
      required this.fromDate,
      required this.toDate,
      required this.remarks,
      required this.isSelfPJP,
      required this.Status,
      required this.ApprovalStatus,
      this.zone,
      this.managerName,
      this.getDetailedPJP});

  PJPInfo.fromJson(Map<String, dynamic> json) {
    try {
      PJP_Id = json['PJP_Id'];
      displayName = json['DisplayName'] ?? 'NA';
      managerName = json['ManagerName'] ?? '';
      fromDate = json['FromDate'] ?? '';
      toDate = json['ToDate'] ?? '';
      Status = json['Status'] ?? 'Check In';
      ApprovalStatus = json['ApprovalStatus'] ?? '';
      zone = json['Zone'];
      remarks = json['Remarks'] == null || json['Remarks'] == 'null'
          ? ' '
          : json['Remarks'];
      isSelfPJP = json['isSelfPJP'] ?? ' 0';
      getDetailedPJP = <GetDetailedPJP>[];
      if (json.containsKey('GetDetailedPJP')) {
        if (json['GetDetailedPJP'] is List) {
          json['GetDetailedPJP'].forEach((v) {
            getDetailedPJP!.add(GetDetailedPJP.fromJson(v));
          });
        } else {
          getDetailedPJP!.add(GetDetailedPJP.fromJson(json['GetDetailedPJP']));
        }
      }
    } catch (e) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PJP_Id'] = PJP_Id;
    data['DisplayName'] = displayName;
    data['FromDate'] = fromDate;
    data['ToDate'] = toDate;
    data['Status'] = Status;
    data['ApprovalStatus'] = ApprovalStatus;
    data['Remarks'] = remarks;
    data['Zone'] = zone;
    data['isSelfPJP'] = isSelfPJP;
    if (getDetailedPJP != null) {
      data['GetDetailedPJP'] = getDetailedPJP!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PJP {
  String? pJPId;
  String? displayName;
  String? fromDate;
  String? toDate;
  String? remarks;
  String? approvalStatus;
  String? isSelfPJP;
  String? managerName;
  GetDetailedPJP? getDetailedPJP;
  String? businessID;
  String? businessName;
  String? zone;

  PJP(
      {this.pJPId,
      this.displayName,
      this.fromDate,
      this.toDate,
      this.remarks,
      this.approvalStatus,
      this.isSelfPJP,
      this.managerName,
      this.getDetailedPJP,
      this.businessID,
      this.businessName,
      this.zone});

  PJP.fromJson(Map<String, dynamic> json) {
    pJPId = json['PJP_Id'];
    displayName = json['DisplayName'];
    fromDate = json['FromDate'];
    toDate = json['ToDate'];
    remarks = json['Remarks'];
    approvalStatus = json['ApprovalStatus'];
    isSelfPJP = json['isSelfPJP'];
    managerName = json['ManagerName'];
    getDetailedPJP = json['GetDetailedPJP'] != null
        ? new GetDetailedPJP.fromJson(json['GetDetailedPJP'])
        : null;
    businessID = json['Business_ID'];
    businessName = json['Business_Name'];
    zone = json['Zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PJP_Id'] = this.pJPId;
    data['DisplayName'] = this.displayName;
    data['FromDate'] = this.fromDate;
    data['ToDate'] = this.toDate;
    data['Remarks'] = this.remarks;
    data['ApprovalStatus'] = this.approvalStatus;
    data['isSelfPJP'] = this.isSelfPJP;
    data['ManagerName'] = this.managerName;
    if (this.getDetailedPJP != null) {
      data['GetDetailedPJP'] = this.getDetailedPJP!.toJson();
    }
    data['Business_ID'] = this.businessID;
    data['Business_Name'] = this.businessName;
    data['Zone'] = this.zone;
    return data;
  }
}

class GetDetailedPJP implements Comparable<GetDetailedPJP> {
  late String PJPCVF_Id = '';

  late String visitDate = '';
  late String visitTime = '';
  late String franchiseeCode = '';
  late String franchiseeName = '';
  late double Latitude = 0.0;
  late double Longitude = 0.0;
  late String Address = '';
  late String CheckInAddress = '';
  late String CheckOutAddress = '';
  late String DateTimeIn = '';
  late String DateTimeOut = '';
  late String ActivityTitle = '';
  late String Status = '';
  late List<Purpose>? purpose = [];

  late bool isSync = false;
  late bool isNotify = false;
  late bool isDelete = false;
  late bool isActive = false;
  late bool isCheckIn = false;
  late bool isCheckOut = false;
  late bool isCompleted = false;
  late String approvalStatus = 'Pending';

  GetDetailedPJP(
      {required this.PJPCVF_Id,
      required this.visitDate,
      required this.visitTime,
      required this.franchiseeCode,
      required this.franchiseeName,
      required this.Latitude,
      required this.Longitude,
      required this.Address,
      required this.CheckInAddress,
      required this.CheckOutAddress,
      required this.DateTimeOut,
      required this.DateTimeIn,
      required this.Status,
      required this.ActivityTitle,
      required this.purpose,
      required this.isActive,
      required this.isNotify,
      required this.isCheckIn,
      required this.isCheckOut,
      required this.isSync,
      required this.isCompleted,
      required this.approvalStatus});

  @override
  int compareTo(GetDetailedPJP other) {
    if (int.parse(PJPCVF_Id) < int.parse(other.PJPCVF_Id)) {
      return -1;
    } else {
      return 0;
    }
  }

  GetDetailedPJP.fromJson(Map<String, dynamic> json) {
    try {
      PJPCVF_Id = json['PJPCVF_Id'] ?? '0';
      visitDate = json['Visit_Date'] ?? 'NA';
      visitTime = json['Visit_Time'] ?? 'NA';
      Status = json['Status'] ?? ' Check In';
      franchiseeCode = json['Franchisee_Code'] ?? 'NA';
      franchiseeName = json['Franchisee_Name'] ?? 'NA';
      Address = json['Address'] ?? 'NA';
      CheckOutAddress = json['CheckOutAddress'] ?? 'NA';
      CheckInAddress = json['CheckinAddress'] ?? 'NA';
      DateTimeOut = json['DateTimeOut'] ?? 'NA';
      DateTimeIn = json['DateTimeIn'] ?? 'NA';
      Latitude = double.parse(json['Latitude']?.toString() ?? "0.0");
      Longitude = double.parse(json['Longitude']?.toString() ?? "0.0");
      ActivityTitle = json['ActivityTitle'] ?? 'NA';
      approvalStatus = json.containsKey('Approval_Status')
          ? json['Approval_Status']
          : 'Pending';
      purpose = <Purpose>[];
      if (json.containsKey('Purpose')) {
        if (json['Purpose'] is List) {
          if (json['Purpose'] != null) {
            json['Purpose'].forEach((v) {
              bool isExists = false;
              if (purpose != null)
                for (int index = 0; index < purpose!.length; index++) {
                  if (v['Category_id'] == purpose![index].categoryId) {
                    isExists = true;
                  }
                }
              if (!isExists) {
                purpose!.add(Purpose.fromJson(v));
              }
            });
          }
        } else {
          purpose!.add(Purpose.fromJson(json['Purpose']));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PJPCVF_Id'] = PJPCVF_Id;
    //data['pjpId'] = this.pjpId;
    data['Visit_Date'] = visitDate;
    data['Visit_Time'] = visitTime;
    data['Franchisee_Code'] = franchiseeCode;
    data['Franchisee_Name'] = franchiseeName;
    data['Status'] = Status;
    data['Latitude'] = Latitude;
    data['Longitude'] = Longitude;
    data['Address'] = Address;
    data['CheckInAddress'] = CheckInAddress;
    data['CheckOutAddress'] = CheckOutAddress;
    data['DateTimeIn'] = DateTimeIn;
    data['CheckOutAddress'] = CheckOutAddress;
    data['ActivityTitle'] = ActivityTitle;
    data['approvalStatus'] = approvalStatus;
    if (purpose != null) {
      data['Purpose'] = purpose!.map((v) => v.toJson()).toList();
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

  Purpose.fromJson(Map<dynamic, dynamic> json) {
    categoryId = json['Category_id'] ?? 'NA';
    categoryName = json['Category_Name'] ?? 'NA';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Category_id'] = categoryId;
    data['Category_Name'] = categoryName;
    return data;
  }
}

class MYTEAM {
  String? employeeId;
  String? employeeCode;
  String? displayName;
  String? zone;

  MYTEAM({this.employeeId, this.employeeCode, this.displayName, this.zone});

  MYTEAM.fromJson(Map<String, dynamic> json) {
    employeeId = json['Employee_Id'];
    employeeCode = json['Employee_Code'];
    displayName = json['DisplayName'];
    zone = json['Zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Employee_Id'] = this.employeeId;
    data['Employee_Code'] = this.employeeCode;
    data['DisplayName'] = this.displayName;
    data['Zone'] = this.zone;
    return data;
  }
}
