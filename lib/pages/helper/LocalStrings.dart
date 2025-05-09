class LocalStrings {
  static String appName = "Kidzee";
  static var stepOneTitle = "Intranet ";
  static var stepOneContent = "Attendance, Leave and outdoor Requisition ";
  static var stepTwoTitle = "Permanent Journey Planner";
  static var stepTwoContent = "PJP Planning and approval for manager";
  static var stepThreeTitle = "Center Visit Form";
  static var stepThreeContent = "";

  static const String bpms = "https://commonapi.zeelearn.com/";
  static const String productionBaseUrl = "https://app.ekidzee.com";
  static const String developmentBaseUrl = "https://intranetapi.zeelearn.com";
  static const kGoogleApiKey = "AIzaSyD-x4HqYO1O0kwDpkxIc128nM4f1bZ3oDM";
  static const String GET_TOKEN = "/snltoken";
  static const String GET_LOGIN = '/api/Account/Login';
  static const String GET_ATTENDANCE_SUMMERY =
      '/api/EmployeeInfo/GetAttendance';
  static const String GET_LEAVE_SUMMERY = '/api/EmployeeInfo/CheckLeaveBalance';
  static const String GET_LEAVE_REQUISITION =
      '/api/EmployeeInfo/AttendanceRequisition';
  static const String GET_APPLY_LEAVE = '/api/Leave/RequisitionHeaderInsert';
  static const String GET_ATTENDANCE_MARKING =
      '/api/EmployeeInfo/SaveAttendanceMarking';
  static const String GET_OUTDOOR_REQUISITION =
      '/api/EmployeeInfo/GetOutdoorReqList';
  static const String GET_ATTENDANCE_REQUISITION_MAN =
      '/api/EmployeeInfo/GetAttendanceMarkingList';
  static const String GET_APPROVE_ATTENDANCE_REQUISITION =
      '/api/EmployeeInfo/AttendanceMarking';
  static const String GET_LEAVE_REQUISITION_MANAGER =
      '/api/EmployeeInfo/LeaveReqList';
  static const String GET_APPROVE_LEAVE_REQUISITION =
      '/api/Leave/UpdateWorkflowGeneric';
  static const String GET_APPROVE_LEAVE_REQUISITION_MULTIPLE =
      '/api/Leave/UpdateWorkflowGenericNew';
  static const String GET_APPROVE_ATTENDANCE_REQUISITION_NEW =
      '/api/EmployeeInfo/AttendanceMarkingNew';
  static const String UPDATE_FCM = '/api/EmployeeInfo/Insert_FCM_Table';
  static const String GET_PHPSTATUSBYEMPID = '/api/PJP/GetPJPByEmpID';

  static const String GET_EMPLOYEE_LIST = '/api/EmployeeInfo/GetEmployees';

  static const String CREATE_EMPLYEE_VISIT_PLANNER =
      '/api/PJP/CreateEmployeeVisitPlanner';

  static const String GET_VISIT_PLANNER_DATEWISE =
      '/api/PJP/GetVisitPlannerDateWise';

  static const String GET_EMPLOYEE_VISIT_DETAILS =
      '/api/PJP/GetEmployeeVisitDetails';

  static const String DELETE_EMPLOYEE_VISIT_PLAN =
      '/api/PJP/DeleteVisitPlanner';

  static const String GET_FRANCHISEE_LAST_VISIT =
      '/api/PJP/GetFranchiseeLastVisit';

  /*CVF*/
  static const String GET_CVF_CATEGORY = '/api/PJP/GetPJPCategory';
  static const String GET_CVF_CENTER_LIST = '/api/PJP/CenterSelect';
  static const String SAVE_NEW_PJP = '/api/PJP/ins_upd_pjp';
  static const String SAVE_CVF_PJP = '/api/PJP/ins_pjpcvf';
  static const String GET_CVF_QUESTIONS = '/api/PJP/GetPJPQuestion';
  static const String GET_PJP_LIST = '/api/PJP/GetAllVisitDetails';
  static const String GET_PJP_REPORT = '/api/PJP/RptMyTeamPJPCVF';
  static const String GET_PJP_EMPLOYEELIST =
      '/api/PJP/GetEmployeesBySuperiorID';
  static const String GET_ALL_CVF = '/api/PJP/GetAllCVFDetails';
  static const String GET_SAVE_CVF_ANSWERS = '/api/PJP/Ins_PJPCVF_Answers';
  static const String GET_UPDATE_CVF_STATUS = '/api/PJP/AddPJPAttendance';
  static const String GET_GETPJPREPORT = '/api/PJP/GetPJPReport';
  static const String UPDATE_MODIFY_STATUS = '/api/PJP/ModifyPJPStatus';
  static const String UPDATE_MODIFY_STATUS_MULTIPLE =
      '/api/PJP/ModifyPJPStatus_multiple';
  static const String GET_PJP_EXCEPTIONAL_LIST =
      '/api/PJP/GetCVFForExceptionalCases';
  static const String UPDATE_PJP_EXCEPTIONAL_LIST =
      '/api/PJP/ApproveCVFForExceptionalCases';

  static const String API_GET_TASKDETAILS = 'api/bp/GetPartnerTaskDetails';
  static const String API_UPDATE_TASKDETAILS = 'api/bp/UpdateTaskStatus';
  static const String API_GET_COMMENTS = 'api/bp/Getcomments';
  static const String API_INSERT_ATTACHMENT = 'api/bp/InserttaskAttachment';
  static const String API_GET_FRANCHISEEDETAILS =
      'api/bp/GetFranchiseeDetailInfo';
  static const String API_GET_COMMUNICATION = 'api/bp/Getcommunication';
  static const String API_GET_BPMS_COUNTS = 'api/bp//GetDashboardCount';
  static const String API_GET_BPMS_ALL_PROJECTS = 'api/bp//GetAllProjectList';
  static const String API_GET_BPMS_PROJECTS_BYSTATUS = 'api/bp//GettaskbyUser';
  static const String API_GET_BPMS_ALL_PROJECTTASK = 'api/bp//Gettaskdata';
  static const String API_INSERT_BPMS_NEW_TASK = 'api/bp//AddNewTask';
  static const String API_INSERT_BPMS_STATUS = 'api/bp//GetInputdata';
  static const String API_SEND_CREDENTIALS = 'api/bp/SendTempCredentialsEmail';
  static const String API_BPMS_DELETETASK = 'api/bp//deletetask';

  static const String API_ZOHO_RECIPIENT =
      'https://www.zohoapis.in/crm/v7/functions/get_zoho_sign_documnet_data/actions/execute?auth_type=apikey&zapikey=1003.e2dc28e888ffe4a032717981ed8fd253.c5db40b69abb74c9a47f51a6875f4248';
}
