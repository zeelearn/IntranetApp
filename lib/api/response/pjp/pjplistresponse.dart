import 'dart:developer';

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
      PJP_Id = (json['PJP_Id'] ?? json['pJPId'] ?? '').toString();
      displayName = json['DisplayName'] ?? 'NA';
      managerName = json['ManagerName'] ?? '';
      fromDate = json['FromDate'] ?? json['fromDate'] ?? '';
      toDate = json['ToDate'] ?? json['toDate'] ?? '';
      Status = json['Status'] ?? json['status'] ?? 'Check In';
      ApprovalStatus = json['ApprovalStatus'] ??
          json['approvalStatus'] ??
          json['Approval_Status'] ??
          '';
      zone = json['Zone'];
      remarks = json['Remarks'] == null || json['Remarks'] == 'null'
          ? ' '
          : json['Remarks'];
      isSelfPJP = json['isSelfPJP'] ?? ' 0';
      getDetailedPJP = <GetDetailedPJP>[];
      final detailedData = json['GetDetailedPJP'] ?? json['getDetailedPJP'];
      if (detailedData != null && detailedData != 'NA') {
        if (detailedData is List) {
          for (var v in detailedData) {
            if (v != null && v is Map<String, dynamic>) {
              getDetailedPJP!.add(GetDetailedPJP.fromJson(v));
            }
          }
        } else if (detailedData is Map<String, dynamic>) {
          getDetailedPJP!.add(GetDetailedPJP.fromJson(detailedData));
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
  String? PJP_Id;

  late String visitDate = '';
  late String visitTime = '';
  late String franchiseeCode = '';
  late String franchiseeId = '';
  late String franchiseeName = '';
  late double Latitude = 0.0;
  late double Longitude = 0.0;
  late String Address = '';
  late String CheckInAddress = '';
  late String CheckOutAddress = '';
  late String DateTimeIn = '';
  late String DateTimeOut = '';
  late String ActivityTitle = '';
  late double LatitudeIn = 0.0;
  late double LongitudeIn = 0.0;
  late String AddressIn = '';
  late double LatitudeOut = 0.0;
  late double LongitudeOut = 0.0;
  late String AddressOut = '';
  late String Status = '';
  late String remarks = '';
  late List<Purpose>? purpose = [];
  List<CVFHistory>? cvfHistory = [];

  late bool isSync = false;
  late bool isNotify = false;
  late bool isDelete = false;
  late bool isActive = false;
  late bool isCheckIn = false;
  late bool isCheckOut = false;
  late bool isCompleted = false;
  late bool IsCancelled = false;

  late String approvalStatus = 'Pending';

  GetDetailedPJP(
      {required this.PJPCVF_Id,
      this.PJP_Id,
      required this.visitDate,
      required this.visitTime,
      required this.franchiseeCode,
      required this.franchiseeId,
      required this.franchiseeName,
      required this.Latitude,
      required this.Longitude,
      required this.Address,
      required this.CheckInAddress,
      required this.CheckOutAddress,
      required this.DateTimeOut,
      required this.DateTimeIn,
      required this.LatitudeIn,
      required this.LongitudeIn,
      required this.AddressIn,
      required this.LatitudeOut,
      required this.LongitudeOut,
      required this.AddressOut,
      required this.Status,
      required this.remarks,
      required this.ActivityTitle,
      required this.purpose,
      required this.isActive,
      required this.isNotify,
      required this.isCheckIn,
      required this.isCheckOut,
      required this.isSync,
      required this.isCompleted,
      required this.IsCancelled,
      required this.approvalStatus,
      this.cvfHistory});

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
      PJPCVF_Id = (json['PJPCVF_Id'] ?? json['pJPCVF_Id'] ?? '0').toString();
      PJP_Id = json['PJP_Id'];
      visitDate =
          (json['Visit_Date'] ?? json['visit_Date']) == "1900-01-01T00:00:00"
              ? 'NA'
              : (json['Visit_Date'] ?? json['visit_Date'] ?? 'NA').toString();
      visitTime =
          (json['Visit_Time'] ?? json['visit_Time']) == "1900-01-01T00:00:00"
              ? 'NA'
              : (json['Visit_Time'] ?? json['visit_Time'] ?? 'NA').toString();
      Status = json['Status'] ?? (json['status'] ?? 'Check In');
      franchiseeCode =
          json['Franchisee_Code'] ?? json['franchisee_Code'] ?? 'NA';
      franchiseeId = json['Franchisee_Id'] ?? json['franchisee_Id'] ?? 'NA';
      franchiseeName =
          json['Franchisee_Name'] ?? json['franchisee_Name'] ?? 'NA';
      Address = json['Address'] ?? json['address'] ?? 'NA';
      CheckOutAddress =
          json['CheckOutAddress'] ?? json['checkOutAddress'] ?? 'NA';
      CheckInAddress = json['CheckinAddress'] ?? json['checkinAddress'] ?? 'NA';
      DateTimeOut =
          (json['DateTimeOut'] ?? json['dateTimeOut']) == "1900-01-01T00:00:00"
              ? 'NA'
              : (json['DateTimeOut'] ?? json['dateTimeOut'] ?? 'NA').toString();
      DateTimeIn =
          (json['DateTimeIn'] ?? json['dateTimeIn']) == "1900-01-01T00:00:00"
              ? 'NA'
              : (json['DateTimeIn'] ?? json['dateTimeIn'] ?? 'NA').toString();
      Latitude = double.tryParse(json['Latitude']?.toString() ?? "") ?? 0.0;
      Longitude = double.tryParse(json['Longitude']?.toString() ?? "") ?? 0.0;
      LatitudeIn = double.tryParse(json['LatitudeIn']?.toString() ?? "") ?? 0.0;
      LongitudeIn =
          double.tryParse(json['LongitudeIn']?.toString() ?? "") ?? 0.0;
      AddressIn = json['AddressIn'] ?? json['addressIn'] ?? 'NA';
      LatitudeOut =
          double.tryParse(json['LatitudeOut']?.toString() ?? "") ?? 0.0;
      LongitudeOut =
          double.tryParse(json['LongitudeOut']?.toString() ?? "") ?? 0.0;
      AddressOut = json['AddressOut'] ?? json['addressOut'] ?? 'NA';
      ActivityTitle = json['ActivityTitle'] ?? json['activityTitle'] ?? 'NA';
      approvalStatus = (json['Approval_Status'] ??
              json['approval_Status'] ??
              json['approvalStatus'] ??
              json['ApprovalStatus'] ??
              'Pending')
          .toString();
      remarks = json['Remarks'] ?? '';

      purpose = <Purpose>[];
      final purposeData = json['Purpose'] ?? json['purpose'];
      if (purposeData != null && purposeData != 'NA') {
        if (purposeData is List) {
          for (var v in purposeData) {
            bool isExists = false;
            if (purpose != null)
              for (int index = 0; index < purpose!.length; index++) {
                String vId = (v is Map
                        ? (v['Category_id'] ?? v['category_id'] ?? 'NA')
                        : 'NA')
                    .toString();
                if (vId == purpose![index].categoryId) {
                  isExists = true;
                  break;
                }
              }
            if (!isExists) {
              purpose!.add(Purpose.fromJson(v));
            }
          }
        } else if (purposeData is Map) {
          purpose!.add(Purpose.fromJson(purposeData));
        }
      }
      IsCancelled =
          (json['IsCancelled'] ?? '0').toString() == '1' ? true : false;
      log('CVF id - ${PJPCVF_Id} - ${json['IsCancelled']}  - $IsCancelled');
      final historyData = json['cvf_history'];
      cvfHistory = <CVFHistory>[];
      if (historyData != null && historyData != 'NA') {
        if (historyData is List) {
          for (var v in historyData) {
            if (v != null && v is Map<String, dynamic>) {
              cvfHistory!.add(CVFHistory.fromJson(v));
            }
          }
        } else if (historyData is Map<String, dynamic>) {
          cvfHistory!.add(CVFHistory.fromJson(historyData));
        }
      }
    } catch (e) {
      debugPrint("Error while parsing ${e.toString()}");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PJPCVF_Id'] = PJPCVF_Id;
    data['PJP_Id'] = PJP_Id;
    data['Visit_Date'] = visitDate;
    data['Visit_Time'] = visitTime;
    data['Franchisee_Id'] = franchiseeId;
    data['Franchisee_Name'] = franchiseeName;
    data['Status'] = Status;
    data['Latitude'] = Latitude;
    data['Longitude'] = Longitude;
    data['Address'] = Address;
    data['CheckInAddress'] = CheckInAddress;
    data['CheckOutAddress'] = CheckOutAddress;
    data['DateTimeIn'] = DateTimeIn;
    data['CheckOutAddress'] = CheckOutAddress;
    data['LatitudeIn'] = LatitudeIn;
    data['LongitudeIn'] = LongitudeIn;
    data['AddressIn'] = AddressIn;
    data['LatitudeOut'] = LatitudeOut;
    data['LongitudeOut'] = LongitudeOut;
    data['AddressOut'] = AddressOut;
    data['ActivityTitle'] = ActivityTitle;
    data['Remarks'] = remarks;
    data['approvalStatus'] = approvalStatus;
    data['IsCancelled'] = IsCancelled ? '1' : '0';
    if (purpose != null) {
      data['Purpose'] = purpose!.map((v) => v.toJson()).toList();
    } else {
      data['Purpose'] = [];
    }
    if (cvfHistory != null) {
      data['cvf_history'] = cvfHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CVFHistory {
  late String visitDate;
  late String visitTime;
  late String franchiseeId;
  late String franchiseeCode;
  late String franchiseeName;
  late String latitude;
  late String longitude;
  late String address;
  String? activityTitle;

  CVFHistory({
    required this.visitDate,
    required this.visitTime,
    required this.franchiseeId,
    required this.franchiseeCode,
    required this.franchiseeName,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.activityTitle,
  });

  CVFHistory.fromJson(Map<String, dynamic> json) {
    visitDate = json['Visit_Date'] ?? '';
    visitTime = json['Visit_Time'] ?? '';
    franchiseeId = (json['Franchisee_Id'] ?? '').toString();
    franchiseeCode = json['Franchisee_Code'] ?? '';
    franchiseeName = json['Franchisee_Name'] ?? '';
    latitude = (json['Latitude'] ?? '0').toString();
    longitude = (json['Longitude'] ?? '0').toString();
    address = json['Address'] ?? '';
    activityTitle = json['ActivityTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Visit_Date'] = visitDate;
    data['Visit_Time'] = visitTime;
    data['Franchisee_Id'] = franchiseeId;
    data['Franchisee_Code'] = franchiseeCode;
    data['Franchisee_Name'] = franchiseeName;
    data['Latitude'] = latitude;
    data['Longitude'] = longitude;
    data['Address'] = address;
    data['ActivityTitle'] = activityTitle;
    return data;
  }
}

class Purpose {
  late String categoryId;
  late String categoryName;

  Purpose({required this.categoryId, required this.categoryName});

  Purpose.fromJson(dynamic json) {
    if (json is Map) {
      categoryId =
          (json['Category_id'] ?? json['category_id'] ?? 'NA').toString();
      categoryName =
          (json['Category_Name'] ?? json['category_name'] ?? 'NA').toString();
    } else {
      categoryId = 'NA';
      categoryName = 'NA';
    }
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
