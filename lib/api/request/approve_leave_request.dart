class ApproveLeaveRequest {
  String RequisitionTypeCode;
  String User_Id;
  String Requisition_Id;
  String WorkflowTypeCode;
  String Requistion_Status_Code;
  bool Is_Approved;
  String Workflow_UserType;
  String Workflow_Remark;

  ApproveLeaveRequest(
      {required this.RequisitionTypeCode,
        required this.User_Id,
        required this.Requisition_Id,
        required this.WorkflowTypeCode,
        required this.Requistion_Status_Code,
        required this.Is_Approved,
        required this.Workflow_UserType,
        required this.Workflow_Remark,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'RequisitionTypeCode': RequisitionTypeCode.trim(),
      'User_Id': User_Id.trim(),
      'Requisition_Id': Requisition_Id.trim(),
      'WorkflowTypeCode': WorkflowTypeCode.trim(),
      'Requistion_Status_Code': Requistion_Status_Code.trim(),
      'Is_Approved': Is_Approved,
      'Workflow_UserType': Workflow_UserType.trim(),
      'Workflow_Remark': Workflow_Remark.trim(),
    };

    return map;
  }
}