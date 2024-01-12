class GetPlanDetails {
  String? responseMessage;
  int? statusCode;
  List<GetPlanData>? responseData;
  String? error;

  GetPlanDetails.setMessage(String errorMessage) {
    error = errorMessage;
  }

  GetPlanDetails({this.responseMessage, this.statusCode, this.responseData});

  GetPlanDetails.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    if (json['responseData'] != null) {
      responseData = <GetPlanData>[];
      json['responseData'].forEach((v) {
        responseData!.add(GetPlanData.fromJson(v));
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

class GetPlanData {
  int? id;
  num? employeeId;
  num? businessId;
  num? franchiseeId;
  String? visitDate;
  String? status;
  String? remarks, eventName, url;
  String? priority;

  GetPlanData(
      {this.id,
      this.employeeId,
      this.businessId,
      this.franchiseeId,
      this.visitDate,
      this.status,
      this.remarks,
      this.eventName,
      this.url,
      this.priority});

  GetPlanData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_Id'] ?? json['employee_id'];
    businessId = json['business_Id'] ?? json['business_id'];
    franchiseeId = json['franchisee_Id'] ?? json['franchisee_id'];
    visitDate = json['visit_Date'];
    status = json['status'];
    remarks = json['remarks'];
    eventName = json['eventName'];
    url = json['url'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_Id'] = employeeId;
    data['business_Id'] = businessId;
    data['franchisee_Id'] = franchiseeId;
    data['visit_Date'] = visitDate;
    data['status'] = status;
    data['remarks'] = remarks;
    data['eventName'] = eventName;
    data['url'] = url;
    data['priority'] = priority;
    return data;
  }
}
