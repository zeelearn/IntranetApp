import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intranet/api/request/ApproveAttendanceMarking.dart';
import 'package:intranet/api/request/apply_leave_request.dart';
import 'package:intranet/api/request/approve_leave_request.dart';
import 'package:intranet/api/request/attendance_marking_man_request.dart';
import 'package:intranet/api/request/attendance_marking_request.dart';
import 'package:intranet/api/request/attendance_summery_request.dart';
import 'package:intranet/api/request/cvf/add_cvf_request.dart';
import 'package:intranet/api/request/cvf/category_request.dart';
import 'package:intranet/api/request/cvf/centers_request.dart';
import 'package:intranet/api/request/cvf/get_cvf_request.dart';
import 'package:intranet/api/request/cvf/questions_request.dart';
import 'package:intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:intranet/api/request/fcm_request.dart';
import 'package:intranet/api/request/leave/leave_approve_request.dart';
import 'package:intranet/api/request/leave/php_checker.dart';
import 'package:intranet/api/request/leave/pjp_response.dart';
import 'package:intranet/api/request/leave_balance_req.dart';
import 'package:intranet/api/request/leave_request.dart';
import 'package:intranet/api/request/leavelist_request_man.dart';
import 'package:intranet/api/request/login_request.dart';
import 'package:intranet/api/request/outdoor_request.dart';
import 'package:intranet/api/request/pjp/add_pjp_request.dart';
import 'package:intranet/api/request/pjp/employee_request.dart';
import 'package:intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:intranet/api/request/pjp/update_pjpstatuslist_request.dart';
import 'package:intranet/api/request/report/myreport_request.dart';
import 'package:intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:intranet/api/response/apply_leave_response.dart';
import 'package:intranet/api/response/approve_attendance_response.dart';
import 'package:intranet/api/response/attendance_marking_man.dart';
import 'package:intranet/api/response/attendance_marking_response.dart';
import 'package:intranet/api/response/attendance_response.dart';
import 'package:intranet/api/response/cvf/QuestionResponse.dart';
import 'package:intranet/api/response/cvf/add_cvf_response.dart';
import 'package:intranet/api/response/cvf/category_response.dart';
import 'package:intranet/api/response/cvf/centers_respinse.dart';
import 'package:intranet/api/response/cvf/cvfanswers_response.dart';
import 'package:intranet/api/response/cvf/get_all_cvf.dart';
import 'package:intranet/api/response/cvf/update_status_response.dart';
import 'package:intranet/api/response/employee_list_response.dart';
import 'package:intranet/api/response/fcm_response.dart';
import 'package:intranet/api/response/general_response.dart';
import 'package:intranet/api/response/leave_list_manager.dart';
import 'package:intranet/api/response/leave_response.dart';
import 'package:intranet/api/response/login_response.dart';
import 'package:intranet/api/response/outdoor_response.dart';
import 'package:intranet/api/response/pjp/add_pjp_response.dart';
import 'package:intranet/api/response/pjp/employee_response.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';
import 'package:intranet/api/response/pjp/update_pjpstatus_response.dart';
import 'package:intranet/api/response/report/my_report.dart';

import '../pages/helper/LocalStrings.dart';

class APIService {
  String url = LocalStrings.developmentBaseUrl;

  Future<dynamic> login(LoginRequestModel requestModel) async {
    try {
      print(requestModel.toJson());


      var body = jsonEncode( {
        'userName': requestModel.userName,
        'password': requestModel.password,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });

      print(Uri.parse(url + LocalStrings.GET_LOGIN));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LOGIN),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
            "Access-Control-Allow-Origin": "*", // Required for CORS support to work
            "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
            "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "POST, OPTIONS"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is LoginResponseInvalid){
          return LoginResponseInvalid.fromJson(
            json.decode(response.body),
          );
        }else {
          return LoginResponseModel.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> attendanceSummery(AttendanceSummeryRequestModel requestModel) async {
    try {
      print(requestModel.toJson());

      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'PayrollFromMonth': requestModel.PayrollFromMonth,
        'PayrollFromYear': requestModel.PayrollFromYear,
        'PayrollToMonth': requestModel.PayrollToMonth,
        'PayrollToYear': requestModel.PayrollToYear,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });

      print(Uri.parse(url + LocalStrings.GET_ATTENDANCE_SUMMERY));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_SUMMERY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return AttendanceSummeryResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return AttendanceSummeryResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> LeaveBalance(LeaveBalanceRequest requestModel) async {
    try {
      print(requestModel.toJson());

      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'FDay': requestModel.FDay,
        'TDay': requestModel.TDay,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });

      print(Uri.parse(url + LocalStrings.GET_LEAVE_SUMMERY));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_SUMMERY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return LeaveBalanceResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return LeaveBalanceResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> LeaveRequisition(LeaveListRequest requestModel) async {
    try {
      print(requestModel.toJson());

      var body = jsonEncode( {
        'device': requestModel.device,
        'Employee_ID': requestModel.Employee_ID,
        'Employee_Name': requestModel.Employee_Name,
        'FromDate': requestModel.FromDate,
        'Role': requestModel.Role,
        'Status': requestModel.Status,
        'ToDate': requestModel.ToDate,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });

      print(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return LeaveRequisitionResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return LeaveRequisitionResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> leaveRequisitionManager(ApplyLeaveManRequest requestModel) async {
    try {
      print(requestModel.toJson());
      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'device': requestModel.device,
        'ToDate': requestModel.ToDate,
        'Role': requestModel.Role,
        'FromDate': requestModel.FromDate,
        'LeaveType': requestModel.LeaveType,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      print(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION_MANAGER));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION_MANAGER),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return LeaveListManagerResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return LeaveListManagerResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> approveLeave(ApproveLeaveRequest requestModel) async {
    try {
      print(requestModel.toJson());
      var body = jsonEncode( {
        'User_Id': requestModel.User_Id,
        'RequisitionTypeCode': requestModel.RequisitionTypeCode,
        'Is_Approved': requestModel.Is_Approved,
        'Requisition_Id': requestModel.Requisition_Id,
        'Requistion_Status_Code': requestModel.Requistion_Status_Code,
        'Workflow_Remark': requestModel.Workflow_Remark,
        'Workflow_UserType': requestModel.Workflow_UserType,
        'WorkflowTypeCode': requestModel.WorkflowTypeCode,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      print(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> approveLeaveManager(ApproveLeaveRequestManager request) async {
    try {
      print(request.toJson());
      var body = jsonEncode( {
        'xml': request.xml,
        'User_Id': request.userId,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      print('request body');
      print(body);
      print(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION_MULTIPLE));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION_MULTIPLE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200) {
        if(response.body is ApplyLeaveResponse){
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> applyLeave(ApplyLeaveRequest requestModel) async {
    try {
      print(requestModel.toJson());

      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'End_Date': requestModel.End_Date,
        'IsMaternityLeave': requestModel.IsMaternityLeave,
        'noofChildren': requestModel.noofChildren,
        'NosDays': requestModel.NosDays,
        'Remarks': requestModel.Remarks,
        'Start_Date': requestModel.Start_Date,
        'Requisition_Date': requestModel.Requisition_Date,
        'Type': requestModel.Type,
        'RequisitionTypeCode': requestModel.RequisitionTypeCode,
        'WorkLocation': requestModel.WorkLocation,
        'IsHappinessLeave': requestModel.IsHappinessLeave,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      print(body);
      print(Uri.parse(url + LocalStrings.GET_APPLY_LEAVE));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPLY_LEAVE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return ApplyLeaveResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> attendanceMarking(AttendanceMarkingRequest requestModel) async {
    try {
      print(requestModel.getJson());
      print(Uri.parse(url + LocalStrings.GET_ATTENDANCE_MARKING));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_MARKING),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      print(requestModel.getJson());
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return AttendanceMarkingResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return AttendanceMarkingResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> outdoorRequisition(OutdoorRequest requestModel) async {
    try {
      print(requestModel.toJson());

      print(Uri.parse(url + LocalStrings.GET_OUTDOOR_REQUISITION));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_OUTDOOR_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return OutdoorResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return OutdoorResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getAttendanceRequisitionMan(AttendanceMarkingManRequest requestModel) async {
    try {
      print(requestModel.toJson());
      print(Uri.parse(url + LocalStrings.GET_ATTENDANCE_REQUISITION_MAN));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_REQUISITION_MAN),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is AttendanceSummeryResponse){
          return AttendanceMarkingManResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return AttendanceMarkingManResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> approveAttendance(ApproveLeaveRequestManager requestModel) async {
    try {
      var body = jsonEncode( {
        'xml': requestModel.xml,
        'Modified_By': requestModel.userId,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      print('request body');
      print(body);
      print(Uri.parse(url + LocalStrings.GET_APPROVE_ATTENDANCE_REQUISITION_NEW));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_ATTENDANCE_REQUISITION_NEW),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        if(response.body is AttendanceSummeryResponse){
          return ApproveAttendanceResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return ApproveAttendanceResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        print('NULL Response....');
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getEmployeeList() async {
    try {
      print(Uri.parse(url + LocalStrings.GET_EMPLOYEE_LIST));
      final response = await http.get(Uri.parse(url + LocalStrings.GET_EMPLOYEE_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is EmployeeListResponse){
          return EmployeeListResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return EmployeeListResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFCategoties(CVFCategoryRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_CVF_CATEGORY));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_CATEGORY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is CVFCategoryResponse){
          return CVFCategoryResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return CVFCategoryResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFCenters(CentersRequestModel requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_CVF_CENTER_LIST));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_CENTER_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is CentersResponse){
          return CentersResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return CentersResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> addNewPJP(AddPJPRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.SAVE_NEW_PJP));
      final response = await http.post(Uri.parse(url + LocalStrings.SAVE_NEW_PJP),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is NewPJPResponse){
          return NewPJPResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return NewPJPResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> saveCVF(AddCVFRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.SAVE_CVF_PJP));
      final response = await http.post(Uri.parse(url + LocalStrings.SAVE_CVF_PJP),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is NewCVFResponse){
          return NewCVFResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return NewCVFResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFQuestions(QuestionsRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_CVF_QUESTIONS));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_QUESTIONS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(requestModel.toJson());
      //print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is QuestionResponse){
          return QuestionResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return QuestionResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPJPList(PJPListRequest requestModel) async {
    try {
      //print('in getPJP list ');
      //print(Uri.parse(url + LocalStrings.GET_PJP_LIST));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      //print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        return PjpListResponse.fromJson(
          json.decode(data),
        );
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPJPReport(PJPReportRequest requestModel) async {
    try {
      //print('in getPJP list ');
      print(Uri.parse(url + LocalStrings.GET_PJP_REPORT));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_REPORT),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        return PjpListResponse.fromJson(
          json.decode(data),
        );
        /*if(response.body is PjpListResponse){

          return PjpListResponse.fromJson(
            json.decode(data),
          );
        }else {
          return PjpListResponse.fromJson(
            json.decode(data),
          );
        }*/
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getEmployeeListPJP(EmployeeListRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_PJP_EMPLOYEELIST));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_EMPLOYEELIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is EmployeeListPJPResponse){
          return EmployeeListPJPResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return EmployeeListPJPResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getAllCVF(GetAllCVF requestModel) async {
    try {
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ALL_CVF),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', 'NA');
        print(data);
        if(response.body is GetAllCVFResponse){
          return GetAllCVFResponse.fromJson(
            json.decode(data),
          );
        }else {
          return GetAllCVFResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> saveCVFAnswers(SaveCVFAnswers requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_SAVE_CVF_ANSWERS));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_SAVE_CVF_ANSWERS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      //print(requestModel.getJson());
      //print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is CVFAnswersResponse){
          return CVFAnswersResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return CVFAnswersResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updateCVFStatus(UpdateCVFStatusRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_UPDATE_CVF_STATUS));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_UPDATE_CVF_STATUS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      //print(requestModel.toJson());
      //print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is UpdateCVFStatusResponse){
          return UpdateCVFStatusResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return UpdateCVFStatusResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getMyReports(MyReportRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_GETPJPREPORT));
      final response = await http.post(Uri.parse(url + LocalStrings.GET_GETPJPREPORT),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is MyReportResponse){
          return MyReportResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return MyReportResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updatePjpStatus(UpdatePJPStatusRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS));
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is UpdatePJPStatusResponse){
          return UpdatePJPStatusResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return UpdatePJPStatusResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updatePjpStatusList(UpdatePJPStatusListRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS_MULTIPLE));
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS_MULTIPLE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is GeneralResponse){
          return GeneralResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return GeneralResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updateFCM(FcmRequestModel requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.UPDATE_FCM));
      print(requestModel.getJson());
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_FCM),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is FcmResponse){
          return FcmResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return FcmResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPhpByDate(CheckPhpRequest requestModel) async {
    try {
      print(Uri.parse(url + LocalStrings.GET_PHPSTATUSBYEMPID));
      print(requestModel.toJson());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PHPSTATUSBYEMPID),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.toJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        if(response.body is PJPListResponse){
          return PJPListResponse.fromJson(
            json.decode(response.body),
          );
        }else {
          return PJPListResponse.fromJson(
            json.decode(response.body),
          );
        }
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

}
