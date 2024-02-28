// ignore_for_file: public_member_api_docs, sort_constructors_first

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
  num? centerId;
  String? franchiseeCode;
  String? franchiseeName;
  String? latitude;
  String? longitude;
  String? visitDate;
  String? status;
  String? remarks;
  String? eventName;
  String? url;
  String? checkIn;
  String? checkOut;
  String? priority;

  GetPlanData(
      {this.id,
      this.employeeId,
      this.businessId,
      this.centerId,
      this.franchiseeCode,
      this.franchiseeName,
      this.latitude,
      this.longitude,
      this.visitDate,
      this.status,
      this.remarks,
      this.eventName,
      this.url,
      this.checkIn,
      this.checkOut,
      this.priority});

  GetPlanData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_Id'] ?? json['employee_id'];
    businessId = json['business_Id'] ?? json['business_id'];
    centerId = json['center_id'] ?? json['franchisee_id'];
    franchiseeCode = json['franchisee_Code'] ?? json['franchisee_code'];
    franchiseeName = json['franchisee_Name'] ?? json['franchisee_name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    visitDate = json['visit_Date'];
    status = json['status'];
    remarks = json['remarks'];
    eventName = json['eventName'];
    url = json['url'];
    checkIn = json['checkIn'];
    checkOut = json['checkOut'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_Id'] = employeeId;
    data['business_Id'] = businessId;
    data['center_id'] = centerId;
    data['franchisee_Code'] = franchiseeCode;
    data['franchisee_Name'] = franchiseeName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['visit_Date'] = visitDate;
    data['status'] = status;
    data['remarks'] = remarks;
    data['eventName'] = eventName;
    data['url'] = url;
    data['checkIn'] = checkIn;
    data['checkOut'] = checkOut;
    data['priority'] = priority;
    return data;
  }

  @override
  bool operator ==(covariant GetPlanData other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.employeeId == employeeId &&
        other.businessId == businessId &&
        other.centerId == centerId &&
        other.franchiseeCode == franchiseeCode &&
        other.franchiseeName == franchiseeName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.visitDate == visitDate &&
        other.status == status &&
        other.remarks == remarks &&
        other.eventName == eventName &&
        other.url == url &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        employeeId.hashCode ^
        businessId.hashCode ^
        centerId.hashCode ^
        franchiseeCode.hashCode ^
        franchiseeName.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        visitDate.hashCode ^
        status.hashCode ^
        remarks.hashCode ^
        eventName.hashCode ^
        url.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        priority.hashCode;
  }
}
