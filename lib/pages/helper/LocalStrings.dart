class LocalStrings {
  static String appName = "Kidzee";
  static var stepOneTitle = "Intranet ";
  static var stepOneContent =
      "Attendance, Leave and outdoor Requisition ";
  static var stepTwoTitle = "Permanent Journey Planner";
  static var stepTwoContent =
      "PJP Planning and approval for manager";
  static var stepThreeTitle = "Center Visit Form";
  static var stepThreeContent =
      "";

  static const String productionBaseUrl = "http://app.ekidzee.com";
  static const String developmentBaseUrl = "http://intranetapi.zeelearn.com";
  static const kGoogleApiKey = "AIzaSyAgCy6EgdEONhjl5PaTep3SHZgMVPe-04Q";
  static const String GET_TOKEN = "/snltoken";
  static const String GET_LOGIN = '/api/Account/Login';
  static const String GET_ATTENDANCE_SUMMERY = '/api/EmployeeInfo/GetAttendance';
  static const String GET_LEAVE_SUMMERY = '/api/EmployeeInfo/CheckLeaveBalance';
  static const String GET_LEAVE_REQUISITION = '/api/EmployeeInfo/AttendanceRequisition';
  static const String GET_APPLY_LEAVE = '/api/Leave/RequisitionHeaderInsert';
  static const String GET_ATTENDANCE_MARKING = '/api/EmployeeInfo/SaveAttendanceMarking';
  static const String GET_OUTDOOR_REQUISITION = '/api/EmployeeInfo/GetOutdoorReqList';
  static const String GET_ATTENDANCE_REQUISITION_MAN = '/api/EmployeeInfo/GetAttendanceMarkingList';
  static const String GET_APPROVE_ATTENDANCE_REQUISITION = '/api/EmployeeInfo/AttendanceMarking';
  static const String GET_LEAVE_REQUISITION_MANAGER = '/api/EmployeeInfo/LeaveReqList';
  static const String GET_APPROVE_LEAVE_REQUISITION = '/api/Leave/UpdateWorkflowGeneric';
  static const String GET_APPROVE_LEAVE_REQUISITION_MULTIPLE = '/api/Leave/UpdateWorkflowGenericNew';
  static const String GET_APPROVE_ATTENDANCE_REQUISITION_NEW = '/api/EmployeeInfo/AttendanceMarkingNew';
  static const String UPDATE_FCM = '/api/EmployeeInfo/Insert_FCM_Table';

  static const String GET_EMPLOYEE_LIST = '/api/EmployeeInfo/GetEmployees';

  /*CVF*/
  static const String GET_CVF_CATEGORY = '/api/PJP/GetPJPCategory';
  static const String GET_CVF_CENTER_LIST = '/api/PJP/CenterSelect';
  static const String SAVE_NEW_PJP = '/api/PJP/ins_upd_pjp';
  static const String SAVE_CVF_PJP = '/api/PJP/ins_pjpcvf';
  static const String GET_CVF_QUESTIONS = '/api/PJP/GetPJPQuestion';
  static const String GET_PJP_LIST = '/api/PJP/GetAllVisitDetails';
  static const String GET_PJP_REPORT = '/api/PJP/RptMyTeamPJPCVF';
  static const String GET_PJP_EMPLOYEELIST = '/api/PJP/GetEmployeesBySuperiorID';
  static const String GET_ALL_CVF = '/api/PJP/GetAllCVFDetails';
  static const String GET_SAVE_CVF_ANSWERS = '/api/PJP/Ins_PJPCVF_Answers';
  static const String GET_UPDATE_CVF_STATUS = '/api/PJP/AddPJPAttendance';
  static const String GET_GETPJPREPORT = '/api/PJP/GetPJPReport';
  static const String UPDATE_MODIFY_STATUS = '/api/PJP/ModifyPJPStatus';

}
