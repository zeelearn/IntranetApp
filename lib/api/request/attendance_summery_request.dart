class AttendanceSummeryRequestModel {
  int Employee_Id;
  int PayrollFromMonth;
  int PayrollFromYear;
  int PayrollToMonth;
  int PayrollToYear;

  AttendanceSummeryRequestModel(
      {required this.Employee_Id,
        required this.PayrollFromMonth,
        required this.PayrollFromYear,
        required this.PayrollToMonth,
        required this.PayrollToYear,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Employee_Id': Employee_Id,
      'PayrollFromMonth': PayrollFromMonth,
      'PayrollFromYear': PayrollFromYear,
      'PayrollToMonth': PayrollToMonth,
      'PayrollToYear': PayrollToYear,
    };

    return map;
  }
}