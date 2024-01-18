class GetVisitPlanDateWise {
  String? responseMessage;
  int? statusCode;
  List<VisitPlanDateWise>? responseData;

  GetVisitPlanDateWise(
      {this.responseMessage, this.statusCode, this.responseData});

  GetVisitPlanDateWise.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <VisitPlanDateWise>[];
      json['responseData'].forEach((v) {
        responseData!.add(VisitPlanDateWise.fromJson(v));
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

class VisitPlanDateWise {
  int? id;
  String? businessUserRole;
  int? businessId;
  int? businessUserId;
  int? employeeId;
  int? centerId;
  String? fromDate;
  String? toDate;
  String? status;
  String? remarks;
  dynamic eventName;
  dynamic url;
  bool? isActive;
  String? createdBy;
  String? createdDate;
  dynamic modifiedBy;
  dynamic modifiedDate;

  VisitPlanDateWise(
      {this.id,
      this.businessUserRole,
      this.businessId,
      this.businessUserId,
      this.employeeId,
      this.centerId,
      this.fromDate,
      this.toDate,
      this.status,
      this.remarks,
      this.eventName,
      this.url,
      this.isActive,
      this.createdBy,
      this.createdDate,
      this.modifiedBy,
      this.modifiedDate});

  VisitPlanDateWise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessUserRole = json['business_user_role'];
    businessId = json['business_id'];
    businessUserId = json['business_user_id'];
    employeeId = json['employee_id'];
    centerId = json['center_id'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    status = json['status'];
    remarks = json['remarks'];
    eventName = json['eventName'];
    url = json['url'];
    isActive = json['is_active'];
    createdBy = json['created_by'];
    createdDate = json['created_date'];
    modifiedBy = json['modified_by'];
    modifiedDate = json['modified_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['business_user_role'] = businessUserRole;
    data['business_id'] = businessId;
    data['business_user_id'] = businessUserId;
    data['employee_id'] = employeeId;
    data['center_id'] = centerId;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['status'] = status;
    data['remarks'] = remarks;
    data['eventName'] = eventName;
    data['url'] = url;
    data['is_active'] = isActive;
    data['created_by'] = createdBy;
    data['created_date'] = createdDate;
    data['modified_by'] = modifiedBy;
    data['modified_date'] = modifiedDate;
    return data;
  }
}
