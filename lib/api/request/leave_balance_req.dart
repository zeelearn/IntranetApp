class LeaveBalanceRequest {
  int Employee_Id;
  String FDay;
  String TDay;

  LeaveBalanceRequest(
      {required this.Employee_Id,
        required this.FDay,
        required this.TDay,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_Id': Employee_Id,
      'FDay': FDay.trim(),
      'TDay': TDay.trim(),
    };

    return map;
  }
}