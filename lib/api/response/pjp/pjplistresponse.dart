import 'package:flutter/cupertino.dart';

class PjpListResponse {
  late String responseMessage;
  late int statusCode;
  late List<PJPInfo> responseData = <PJPInfo>[];

  PjpListResponse(
      {required this.responseMessage,
      required this.statusCode,
      required this.responseData});

  PjpListResponse.fromJson(Map<String, dynamic> json) {
    try {
      responseMessage = json['responseMessage'];
      statusCode = json['statusCode'];
      responseData = <PJPInfo>[];
      if (json['responseData'] is List) {
        json['responseData'].forEach((v) {
          try {
            responseData.add(PJPInfo.fromJson(v));
          } catch (e) {}
        });
      } else {
        responseData.add(PJPInfo.fromJson(json['responseData']));
      }
    } catch (e) {
      print('error ${e.toString()}');
    }
    print('json comple ${responseData.toString()}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseMessage'] = responseMessage;
    data['statusCode'] = statusCode;
    data['responseData'] = responseData.map((v) => v.toJson()).toList();
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
      this.getDetailedPJP});

  PJPInfo.fromJson(Map<String, dynamic> json) {
    try {
      PJP_Id = json['PJP_Id'];
      displayName = json['DisplayName'] ?? ' NA';
      fromDate = json['FromDate'] ?? ' NA';
      toDate = json['ToDate'] ?? ' NA';
      Status = json['Status'] ?? 'Check In';
      ApprovalStatus = json['ApprovalStatus'] ?? 'NA';
      remarks = json['Remarks'] == null || json['Remarks'] == 'null'
          ? ' NA'
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
    data['isSelfPJP'] = isSelfPJP;
    if (getDetailedPJP != null) {
      data['GetDetailedPJP'] = getDetailedPJP!.map((v) => v.toJson()).toList();
    }
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
      visitDate = json['Visit_Date'] ?? ' NA';
      visitTime = json['Visit_Time'] ?? ' NA';
      Status = json['Status'] ?? ' Check In';
      franchiseeCode = json['Franchisee_Code'] ?? 'NA';
      franchiseeName = json['Franchisee_Name'] ?? 'NA';
      Address = json['Address'] ?? ' NA';
      CheckOutAddress = json['CheckOutAddress'] ?? ' NA';
      CheckInAddress = json['CheckinAddress'] ?? ' NA';
      DateTimeOut = json['DateTimeOut'] ?? ' NA';
      DateTimeIn = json['DateTimeIn'] ?? ' NA';
      Latitude = double.parse(json['Latitude'].toString() ?? "0.0");
      Longitude = double.parse(json['Longitude'].toString() ?? "0.0") ?? 0.0;
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
    categoryId = json['Category_id'] ?? ' NA';
    categoryName = json['Category_Name'] ?? ' NA';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Category_id'] = categoryId;
    data['Category_Name'] = categoryName;
    return data;
  }
}
