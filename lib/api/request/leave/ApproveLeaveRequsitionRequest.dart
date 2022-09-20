class ApproveLeaveRequsitionRequest {
  Xml? xml;

  ApproveLeaveRequsitionRequest({required this.xml});

  ApproveLeaveRequsitionRequest.fromJson(Map<String, dynamic> json) {
    xml = json['xml'] != null ? new Xml.fromJson(json['xml']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xml != null) {
      data['xml'] = this.xml!.toJson();
    }
    return data;
  }
}

class Xml {
  Root? root;
  int? userId;

  Xml({this.root, this.userId});

  Xml.fromJson(Map<String, dynamic> json) {
    root = json['root'] != null ? new Root.fromJson(json['root']) : null;
    userId = json['User_Id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.root != null) {
      data['root'] = this.root!.toJson();
    }
    data['User_Id'] = this.userId;
    return data;
  }
}

class Root {
  List<Subroot>? subroot;

  Root({this.subroot});

  Root.fromJson(Map<String, dynamic> json) {
    if (json['subroot'] != null) {
      subroot = <Subroot>[];
      json['subroot'].forEach((v) {
        subroot!.add(new Subroot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.subroot != null) {
      data['subroot'] = this.subroot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subroot {
  int? requisitionId;
  String? workflowTypeCode;
  String? requisitionTypeCode;
  String? requistionStatusCode;
  String? isApproved;
  String? workflowUserType;

  Subroot(
      {this.requisitionId,
        this.workflowTypeCode,
        this.requisitionTypeCode,
        this.requistionStatusCode,
        this.isApproved,
        this.workflowUserType});

  Subroot.fromJson(Map<String, dynamic> json) {
    requisitionId = json['Requisition_Id'];
    workflowTypeCode = json['WorkflowTypeCode'];
    requisitionTypeCode = json['RequisitionTypeCode'];
    requistionStatusCode = json['Requistion_Status_Code'];
    isApproved = json['Is_Approved'];
    workflowUserType = json['Workflow_UserType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Requisition_Id'] = this.requisitionId;
    data['WorkflowTypeCode'] = this.workflowTypeCode;
    data['RequisitionTypeCode'] = this.requisitionTypeCode;
    data['Requistion_Status_Code'] = this.requistionStatusCode;
    data['Is_Approved'] = this.isApproved;
    data['Workflow_UserType'] = this.workflowUserType;
    return data;
  }
}
