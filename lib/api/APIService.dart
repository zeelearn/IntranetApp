import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:Intranet/api/request/apply_leave_request.dart';
import 'package:Intranet/api/request/approve_leave_request.dart';
import 'package:Intranet/api/request/attendance_marking_man_request.dart';
import 'package:Intranet/api/request/attendance_marking_request.dart';
import 'package:Intranet/api/request/attendance_summery_request.dart';
import 'package:Intranet/api/request/cvf/add_cvf_request.dart';
import 'package:Intranet/api/request/cvf/category_request.dart';
import 'package:Intranet/api/request/cvf/centers_request.dart';
import 'package:Intranet/api/request/cvf/get_cvf_request.dart';
import 'package:Intranet/api/request/cvf/questions_request.dart';
import 'package:Intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:Intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:Intranet/api/request/fcm_request.dart';
import 'package:Intranet/api/request/leave/leave_approve_request.dart';
import 'package:Intranet/api/request/leave/php_checker.dart';
import 'package:Intranet/api/request/leave/pjp_response.dart';
import 'package:Intranet/api/request/leave_balance_req.dart';
import 'package:Intranet/api/request/leave_request.dart';
import 'package:Intranet/api/request/leavelist_request_man.dart';
import 'package:Intranet/api/request/login_request.dart';
import 'package:Intranet/api/request/outdoor_request.dart';
import 'package:Intranet/api/request/pjp/add_pjp_request.dart';
import 'package:Intranet/api/request/pjp/employee_request.dart';
import 'package:Intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatuslist_request.dart';
import 'package:Intranet/api/request/report/myreport_request.dart';
import 'package:Intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:Intranet/api/response/apply_leave_response.dart';
import 'package:Intranet/api/response/approve_attendance_response.dart';
import 'package:Intranet/api/response/attendance_marking_man.dart';
import 'package:Intranet/api/response/attendance_marking_response.dart';
import 'package:Intranet/api/response/attendance_response.dart';
import 'package:Intranet/api/response/cvf/QuestionResponse.dart';
import 'package:Intranet/api/response/cvf/add_cvf_response.dart';
import 'package:Intranet/api/response/cvf/category_response.dart';
import 'package:Intranet/api/response/cvf/centers_respinse.dart';
import 'package:Intranet/api/response/cvf/cvfanswers_response.dart';
import 'package:Intranet/api/response/cvf/get_all_cvf.dart';
import 'package:Intranet/api/response/cvf/update_status_response.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/api/response/fcm_response.dart';
import 'package:Intranet/api/response/general_response.dart';
import 'package:Intranet/api/response/leave_list_manager.dart';
import 'package:Intranet/api/response/leave_response.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/api/response/outdoor_response.dart';
import 'package:Intranet/api/response/pjp/add_pjp_response.dart';
import 'package:Intranet/api/response/pjp/employee_response.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/api/response/pjp/update_pjpstatus_response.dart';
import 'package:Intranet/api/response/report/my_report.dart';

import '../pages/helper/LocalStrings.dart';

class APIService {
  String url = LocalStrings.developmentBaseUrl;

  Future<dynamic> login(LoginRequestModel requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());
      var body = jsonEncode( {
        'userName': requestModel.userName,
        'password': requestModel.password,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      debugPrint(Uri.parse(url + LocalStrings.GET_LOGIN).toString());
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
      e.toString();
    }
  }

  Future<dynamic> attendanceSummery(AttendanceSummeryRequestModel requestModel) async {
    try {
      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'PayrollFromMonth': requestModel.PayrollFromMonth,
        'PayrollFromYear': requestModel.PayrollFromYear,
        'PayrollToMonth': requestModel.PayrollToMonth,
        'PayrollToYear': requestModel.PayrollToYear,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_SUMMERY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
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
      e.toString();
    }
  }

  Future<dynamic> LeaveBalance(LeaveBalanceRequest requestModel) async {
    try {
      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'FDay': requestModel.FDay,
        'TDay': requestModel.TDay,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_SUMMERY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> LeaveRequisition(LeaveListRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());
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
      debugPrint(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> leaveRequisitionManager(ApplyLeaveManRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());
      var body = jsonEncode( {
        'Employee_Id': requestModel.Employee_Id,
        'device': requestModel.device,
        'ToDate': requestModel.ToDate,
        'Role': requestModel.Role,
        'FromDate': requestModel.FromDate,
        'LeaveType': requestModel.LeaveType,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      debugPrint(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION_MANAGER).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_LEAVE_REQUISITION_MANAGER),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> approveLeave(ApproveLeaveRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());
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
      debugPrint(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> approveLeaveManager(ApproveLeaveRequestManager request) async {
    try {
      debugPrint(request.toJson().toString());
      var body = jsonEncode( {
        'xml': request.xml,
        'User_Id': request.userId,
        'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
      });
      debugPrint('request body');
      debugPrint(body);
      debugPrint(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION_MULTIPLE).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_LEAVE_REQUISITION_MULTIPLE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> applyLeave(ApplyLeaveRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());

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
      debugPrint(body);
      debugPrint(Uri.parse(url + LocalStrings.GET_APPLY_LEAVE).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPLY_LEAVE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> attendanceMarking(AttendanceMarkingRequest requestModel) async {
    try {
      debugPrint(requestModel.getJson());
      debugPrint(Uri.parse(url + LocalStrings.GET_ATTENDANCE_MARKING).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_MARKING),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
      debugPrint(requestModel.getJson());
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> outdoorRequisition(OutdoorRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());

      debugPrint(Uri.parse(url + LocalStrings.GET_OUTDOOR_REQUISITION).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_OUTDOOR_REQUISITION),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getAttendanceRequisitionMan(AttendanceMarkingManRequest requestModel) async {
    try {
      debugPrint(requestModel.toJson().toString());
      debugPrint(Uri.parse(url + LocalStrings.GET_ATTENDANCE_REQUISITION_MAN).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_ATTENDANCE_REQUISITION_MAN),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
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
      debugPrint('request body');
      debugPrint(body);
      debugPrint(Uri.parse(url + LocalStrings.GET_APPROVE_ATTENDANCE_REQUISITION_NEW).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_APPROVE_ATTENDANCE_REQUISITION_NEW),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:body);
      debugPrint(response.body);
      debugPrint(response.statusCode.toString());
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
        debugPrint('NULL Response....');
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getEmployeeList() async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_EMPLOYEE_LIST).toString());
      final response = await http.get(Uri.parse(url + LocalStrings.GET_EMPLOYEE_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },);
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFCategoties(CVFCategoryRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_CVF_CATEGORY).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_CATEGORY),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFCenters(CentersRequestModel requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_CVF_CENTER_LIST).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_CENTER_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> addNewPJP(AddPJPRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.SAVE_NEW_PJP).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.SAVE_NEW_PJP),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> saveCVF(AddCVFRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.SAVE_CVF_PJP).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.SAVE_CVF_PJP),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getCVFQuestions(QuestionsRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_CVF_QUESTIONS).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_CVF_QUESTIONS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(requestModel.toJson().toString());
      //debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPJPList(PJPListRequest requestModel) async {
    try {
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        return PjpListResponse.fromJson(
          json.decode(data),
        );
      } else {
        return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
      }
    } catch (e) {
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPJPReport(PJPReportRequest requestModel) async {
    try {
      //debugPrint('in getPJP list ');
      debugPrint(Uri.parse(url + LocalStrings.GET_PJP_REPORT).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_REPORT),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        return PjpListResponse.fromJson(
          json.decode(data),
        );
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getEmployeeListPJP(EmployeeListRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_PJP_EMPLOYEELIST).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_EMPLOYEELIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
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
      debugPrint(response.body);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', 'NA');
        debugPrint(data);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> saveCVFAnswers(SaveCVFAnswers requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_SAVE_CVF_ANSWERS).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_SAVE_CVF_ANSWERS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(requestModel.getJson());
      //debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updateCVFStatus(UpdateCVFStatusRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_UPDATE_CVF_STATUS).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_UPDATE_CVF_STATUS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      //debugPrint(requestModel.toJson());
      //debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getMyReports(MyReportRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_GETPJPREPORT).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_GETPJPREPORT),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updatePjpStatus(UpdatePJPStatusRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updatePjpStatusList(UpdatePJPStatusListRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS_MULTIPLE).toString());
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_MODIFY_STATUS_MULTIPLE),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> updateFCM(FcmRequestModel requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.UPDATE_FCM).toString());
      debugPrint(requestModel.getJson());
      final response = await http.post(Uri.parse(url + LocalStrings.UPDATE_FCM),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

  Future<dynamic> getPhpByDate(CheckPhpRequest requestModel) async {
    try {
      debugPrint(Uri.parse(url + LocalStrings.GET_PHPSTATUSBYEMPID).toString());
      debugPrint(requestModel.toJson());
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PHPSTATUSBYEMPID),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.toJson());
      debugPrint(response.body);
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
      debugPrint(e.toString());
      e.toString();
    }
  }

}
