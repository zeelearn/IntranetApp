class LeaveListRequest {
  String Employee_ID;
  String Employee_Name;
  String FromDate;
  String Role;
  String Status;
  String ToDate;
  String device;

  LeaveListRequest(
      {required this.Employee_ID,
        required this.Employee_Name,
        required this.FromDate,
        required this.Role,
        required this.Status,
        required this.ToDate,
        required this.device,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_ID': Employee_ID.trim(),
      'Employee_Name': Employee_Name.trim(),
      'FromDate': FromDate.trim(),
      'Role': Role.trim(),
      'Status': Status.trim(),
      'ToDate': ToDate.trim(),
      'device': device.trim(),
    };

    return map;
  }
}