class ApplyLeaveManRequest {
  int device=0;
  String LeaveType;
  String Employee_Id;
  String Role;
  String FromDate;
  String ToDate;

  ApplyLeaveManRequest(
      {required this.device,
        required this.LeaveType,
        required this.Employee_Id,
        required this.Role,
        required this.FromDate,
        required this.ToDate,

      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'device': device,
      'LeaveType': LeaveType.trim(),
      'Employee_Id': Employee_Id.trim(),
      'Role': Role.trim(),
      'FromDate': FromDate.trim(),
      'ToDate': ToDate.trim(),
    };

    return map;
  }
}