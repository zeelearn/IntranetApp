class ApplyLeaveRequest {
  int Requisition_Id;
  String Type;
  String Employee_Id;
  String Remarks;
  String Requisition_Date;
  String RequisitionTypeCode;
  String Start_Date;
  String End_Date;
  int NosDays;
  bool IsMaternityLeave;
  String noofChildren;
  String WorkLocation;

  ApplyLeaveRequest(
      {required this.Requisition_Id,
        required this.Type,
        required this.Employee_Id,
        required this.Remarks,
        required this.Requisition_Date,
        required this.RequisitionTypeCode,
        required this.Start_Date,
        required this.End_Date,
        required this.NosDays,
        required this.IsMaternityLeave,
        required this.noofChildren,
        required this.WorkLocation,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Requisition_Id': Requisition_Id,
      'Type': Type.trim(),
      'Employee_Id': Employee_Id.trim(),
      'Remarks': Remarks.trim(),
      'Requisition_Date': Requisition_Date.trim(),
      'RequisitionTypeCode': RequisitionTypeCode.trim(),
      'Start_Date': Start_Date.trim(),
      'End_Date': End_Date.trim(),
      'NosDays': NosDays,
      'IsMaternityLeave': IsMaternityLeave,
      'noofChildren': noofChildren,
      'WorkLocation': WorkLocation,
    };

    return map;
  }
}