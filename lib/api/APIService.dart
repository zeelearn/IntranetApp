import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Intranet/api/request/bpms/bpms_stats.dart';
import 'package:Intranet/api/request/bpms/bpms_task.dart';
import 'package:Intranet/api/request/bpms/deletetask.dart';
import 'package:Intranet/api/request/bpms/franchisee_details_request.dart';
import 'package:Intranet/api/request/bpms/getTaskDetailsRequest.dart';
import 'package:Intranet/api/request/bpms/get_communication.dart';
import 'package:Intranet/api/request/bpms/get_task_comments.dart';
import 'package:Intranet/api/request/bpms/insert_attachment.dart';
import 'package:Intranet/api/request/bpms/newtask.dart';
import 'package:Intranet/api/request/bpms/projects.dart';
import 'package:Intranet/api/request/bpms/send_cred.dart';
import 'package:Intranet/api/request/bpms/update_task.dart';
import 'package:Intranet/api/response/bpms/bpms_stats.dart';
import 'package:Intranet/api/response/bpms/bpms_status.dart';
import 'package:Intranet/api/response/bpms/franchisee_details_response.dart';
import 'package:Intranet/api/response/bpms/getTaskDetailsResponseModel.dart';
import 'package:Intranet/api/response/bpms/get_comments_response.dart';
import 'package:Intranet/api/response/bpms/get_communication_response.dart';
import 'package:Intranet/api/response/bpms/insert_attachment_response.dart';
import 'package:Intranet/api/response/bpms/newtask.dart';
import 'package:Intranet/api/response/bpms/project_task.dart';
import 'package:Intranet/api/response/bpms/send_cred.dart';
import 'package:Intranet/api/response/bpms/update_task_response.dart';
import 'package:Intranet/api/response/uploadimage.dart';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:aws_s3_upload/enum/acl.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
import 'package:path_provider/path_provider.dart';

import '../pages/helper/LocalStrings.dart';
import '../pages/helper/utils.dart';
import '../pages/iface/onClick.dart';
import 'aws_s3_upload.dart';

class APIService {
  String url = LocalStrings.developmentBaseUrl;
  String bpms_url = LocalStrings.bpms;

  Future<dynamic> login(LoginRequestModel requestModel) async {
    try {
      debugPrint('Login Request ${requestModel.toJson().toString()}');
      var body = jsonEncode({
        'userName': requestModel.userName,
        'password': requestModel.password,
        'AppType': kIsWeb ? 'Web' : Platform.isAndroid ? 'Android' : Platform.isIOS
            ? 'IOS'
            : 'unknown'
      });
      debugPrint('URL ${url + LocalStrings.GET_LOGIN}');
      debugPrint('URL PARSE ${Uri.parse(url + LocalStrings.GET_LOGIN).toString()}');
      try {
        final response = await http.post(
            Uri.parse(url + LocalStrings.GET_LOGIN),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json",
              "Access-Control-Allow-Origin": "*",
              // Required for CORS support to work
              "Access-Control-Allow-Credentials": "true",
              // Required for cookies, authorization headers with HTTPS
              "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
              "Access-Control-Allow-Methods": "*"
            },
            body: body);
        debugPrint('Response ${response}');
        debugPrint(Uri.parse(url + LocalStrings.GET_LOGIN).toString());
        if (response.statusCode == 200 || response.statusCode == 400) {
          if (response.body is LoginResponseInvalid) {
            return LoginResponseInvalid.fromJson(
              json.decode(response.body),
            );
          } else {
            return LoginResponseModel.fromJson(
              json.decode(response.body),
            );
          }
        } else {
          return null; //LoginResponseModel(token:"",Status:"Invalid/Wrong Login Details");
        }
      }catch(e){
        print(e.toString());
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
      print('pjp list ');
      final response = await http.post(Uri.parse(url + LocalStrings.GET_PJP_LIST),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body:requestModel.getJson());
      print('RRR ${response.body.toString()}');
      print('status ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        print('data ${data}');
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
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 400) {
        String data = response.body.replaceAll('null', '\"NA\"');
        print(data);
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
      print('Updatting fcm token');
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

  Future<Either<String, dynamic>> uploadFileDYNTube(String filepath,
      bool isVideoFile, Function(int bytes, int totalBytes) progress) async {
    XFile? fileResult;
    File? targetFile;
    if (!isVideoFile) {
      File file = File(filepath);
      print('start compresition....');
      print('befour ${file.lengthSync()}');
      String dir = (await getTemporaryDirectory()).path;

      targetFile = File('$dir/${DateTime.now().millisecondsSinceEpoch}.jpeg');
      fileResult = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path, targetFile.path,
          quality: 72);

      dynamic awsFileUpload = await AwsS3FileUpload.uploadFile(
        file: !isVideoFile ? File(fileResult!.path) : File(filepath),
        progress: (int bytes, int totalBytes) async {
          // log('Uploading file progressvin AwsS3Upload function is - $p0');
          // await progress(bytes, totalBytes);
        },
      );
      print('after compression ${await fileResult?.length() as int}');

      if (awsFileUpload is UploadImageResponse) {
        return Right(awsFileUpload);
      } else {
        print('in else awes');
        String? result = await AwsS3.uploadFile(
          accessKey: "AKIAU6ELV2UB4Z6KRIHM",
          secretKey: "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",
          file: !isVideoFile ? File(fileResult!.path) : File(filepath),
          contentType: "image/jpeg",
          acl: ACL.public_read_write,
          bucket:
          "https://s3.console.aws.amazon.com/s3/buckets/pentemindimg/intranet/",
          region: "ap-south-1",
          metadata: {"accept-encoding": "gzip"},
        );
        targetFile.deleteSync();
        print('completed....');
        print(result);
        UploadImageResponse response = UploadImageResponse.fromJson(
          json.decode(result!) as Map<String, dynamic>,
        );
        if (response.imageModel != null && response.imageModel!.isNotEmpty) {
          return Right(response);
        } else {
          return const Left('Something went wrong');
        }
      }
    } else {
      try {
        var formData = FormData.fromMap({
          'file': !isVideoFile
              ? await MultipartFile.fromFile(fileResult!.path)
              : await MultipartFile.fromFile(filepath),
          'projectId': 'iKwExHJsh06H6fBWhCZqw'
        });

        var dynFileUpload = await Dio().post(
          'https://upload.dyntube.com/v1/videos',
          data: formData,
          options: Options(headers: {
            'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkb21haW5AemVlbGVhcm4uY29tIiwianRpIjoiNmRlNjRlZDgtMzAxNC00ZmMyLWI5MDMtZTcxZDhmYjIzNWE5IiwidXNlcklkIjoiNjBmZWFhYWU3Yzc1ZDU5YWI1NDM3NzcyIiwiYWNjb3VudElkIjoiWFBXYURQQUVFV2k2a3VjVjhDYnciLCJleHAiOjI1MzQwMjMwMDgwMCwiaXNzIjoiaHR0cHM6Ly9keW50dWJlLmNvbSIsImF1ZCI6Ik1hbmFnZSJ9.gmyVqUAVVg-kFlIK3obEl2zj-EDVMeO_lPfP1Cvv0lY'
            // 'Content-Type': 'multipart/form-data',
          }),
          onReceiveProgress: (count, total) async {
            debugPrint(
                'onReceiveProgress is getting called - $count and $total');
            // await progress(count, total);
          },
          onSendProgress: (count, total) async {
            //debugPrint('onSendProgress is getting called - $count and $total');
            await progress(count, total);
          },
        );

        if (dynFileUpload.statusCode == 200) {
          try {
            //debugPrint('Response from dyntube api is - $dynFileUpload');
            final fileID = dynFileUpload.data['videoId'];
            // Future.delayed(const Duration(seconds: 2));
            var fileLocation =
            await Dio().get('https://api.dyntube.com/v1/videos/$fileID',
                options: Options(headers: {
                  'Authorization':
                  'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkb21haW5AemVlbGVhcm4uY29tIiwianRpIjoiNmRlNjRlZDgtMzAxNC00ZmMyLWI5MDMtZTcxZDhmYjIzNWE5IiwidXNlcklkIjoiNjBmZWFhYWU3Yzc1ZDU5YWI1NDM3NzcyIiwiYWNjb3VudElkIjoiWFBXYURQQUVFV2k2a3VjVjhDYnciLCJleHAiOjI1MzQwMjMwMDgwMCwiaXNzIjoiaHR0cHM6Ly9keW50dWJlLmNvbSIsImF1ZCI6Ik1hbmFnZSJ9.gmyVqUAVVg-kFlIK3obEl2zj-EDVMeO_lPfP1Cvv0lY'
                }));
            if (fileLocation.statusCode == 200) {
              log('Response from Location api is - ${fileLocation.data}');
              //debugPrint('Response from Location is - ${fileLocation.data['hlsLink']}');
              return Right('https://api.dyntube.com/v1/apps/hls/${fileLocation.data['hlsLink']}.m3u8');
            } else {
              return Left(fileLocation.toString());
            }
          } catch (e) {
            debugPrint(
                'error while getting location of  file - ${e.toString()}');
            return Left(e.toString());
          }
        } else {
          return Left(dynFileUpload.toString());
        }
      } catch (e) {
        debugPrint('error while uploading file - ${e.toString()}');
        return Left(e.toString());
      }
    }
  }


  Future<Either<String, UploadImageResponse>> uploadImage(
      String userId, String image,
      {onClickListener? listener,
        bool isVideoFile =  false,
        Function(int bytes, int totalBytes)? progress}) async {
    print('uploading images ...');
    isVideoFile= image.contains('.mp4')  ? true : false;
    var result = await uploadFileDYNTube(
      image,
      isVideoFile,
          (int bytes, int totalBytes) async {
        log('Uploading file progress in ApiService is - $bytes $totalBytes');
        await progress!(bytes, totalBytes);
      },
    );
    if (isVideoFile) {
      return result.fold((left) {
        listener?.onClick(
            Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK,
            UploadImageResponse(message: 'Successfully', imageModel: [
              UploadImageModel(
                  fieldname: '',
                  originalname: '',
                  encoding: '',
                  mimetype: '',
                  size: 0,
                  bucket: '',
                  key: '',
                  acl: '',
                  contentType: '',
                  storageClass: '',
                  metadata: Metadata(fieldName: ''),
                  location: left,
                  etag: '')
            ]));
        return Left(left);
      }, (right) {
        listener?.onClick(
            Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK,
            UploadImageResponse(message: 'Successfully', imageModel: [
              UploadImageModel(
                  fieldname: '',
                  originalname: '',
                  encoding: '',
                  mimetype: '',
                  size: 0,
                  bucket: '',
                  key: '',
                  acl: '',
                  contentType: '',
                  storageClass: '',
                  metadata: Metadata(fieldName: ''),
                  location: right,
                  etag: '')
            ]));
        return Right(UploadImageResponse(message: '', imageModel: [
          UploadImageModel(
              fieldname: '',
              originalname: '',
              encoding: '',
              mimetype: '',
              size: 0,
              bucket: '',
              key: '',
              acl: '',
              contentType: '',
              storageClass: '',
              metadata: Metadata(fieldName: ''),
              location: right,
              etag: '')
        ]));
      });
    } else {
      Either<String, UploadImageResponse>? eitherReturn;
      result.fold((left) async {
        var postUri = Uri.parse(''/*pentemind_url + LocalStrings.API_GET_PENTEMIND_LG_CHILD_ADVANCEMENT_UPLOAD_IMAGE*/);
        var request = http.MultipartRequest('POST', postUri);
        request.files
            .add(await http.MultipartFile.fromPath('inputFile', image));
        request.send().then((response) async {
          try {
            var responseData = await response.stream.toBytes();
            var responseString = String.fromCharCodes(responseData);
            print('Response OK');
            listener?.onClick(
                Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK,
                UploadImageResponse.fromJson(
                  json.decode(responseString) as Map<String, dynamic>,
                ));

            eitherReturn = Right(UploadImageResponse.fromJson(
              json.decode(responseString) as Map<String, dynamic>,
            ));
          } catch (e) {
            print('error');
            print(e.toString());
            listener?.onClick(Utility.ACTION_IMAGE_UPLOAD_RESPONSE_ERROR, e.toString());
            eitherReturn = Left(e.toString());
          }
        });
      }, (right) {
        print('Response OK Right');
        listener?.onClick(Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK, right);
        eitherReturn = Right(right);
      });
      return eitherReturn ?? const Left('Something went wrong');
    }
  }

  Future<dynamic> updateTaskDetails(UpdateBpmsTaskRequest requestModel) async {
    try {
      //print(getHeader(''));
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_UPDATE_TASKDETAILS),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      print(response.request!.url);
      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        return UpdateBpmsTaskResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('statusCode null');
        return null;
      }
    } catch (e) {
      print('error e');
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> sendCredentials(SendCredentialsRequest requestModel) async {
    try {
      //print(getHeader(''));
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_SEND_CREDENTIALS),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      print(response.request!.url);
      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        return CommonResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('SendCredentialResponse null');
        return null;
      }
    } catch (e) {
      print('SendCredentialResponse error e');
      print(e.toString());
      e.toString();
    }
  }

  Future<dynamic> insertTaskAttachment(
      InsertTaskAttachmentRequest requestModel) async {
    try {
      print(getHeader(''));
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_INSERT_ATTACHMENT),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      print(response.request!.url);
      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        return InsertTaskAttachmentResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('statusCode null');
        return null;
      }
    } catch (e) {
      print('statusCode null error');
      print(e.toString());
      e.toString();
      return null;
    }
  }

  Map<String, String> getHeader(token) {
    return {
      //"Accept": "application/json",
      "content-type": "application/json",
      //'Authorization': 'Bearer $token',
      'dbid': '1',
      'source': kIsWeb ? 'web' : Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'IOS'
          : 'unknown',
    };
  }

  dynamic getCommunication(GetCommunicationRequest requestModel) async {
    try {
      print('Header -- ${getHeader('')}');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_COMMUNICATION),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      print(response.request!.url);
      print(response.statusCode);
      print('2914 response ${response.body}');
      if (response.statusCode == 200) {
        return GetCommunicationResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('statusCode null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  Future<dynamic> getTaskComments(GetTaskCommentRequest requestModel) async {
    try {
      print(getHeader(''));
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_COMMENTS),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      //print(response.request!.url);
      //print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        return GetCommentResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('statusCode null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  Future<GetTaskDetailsResponseModel> getBPMSTaskDetails(GetTaskDetailsRequest requestModel) async {
    try {
      print(getHeader(''));
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_TASKDETAILS),
          headers: getHeader(''),
          body: requestModel.toJson());
      print(requestModel.toJson());
      print(response.request!.url);
      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        return GetTaskDetailsResponseModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        return GetTaskDetailsResponseModel(success: 400, taskDetail: []);
      }
    } catch (e) {
      print(e.toString());
      e.toString();
      return GetTaskDetailsResponseModel(success: 401, taskDetail: []);
    }
  }

  dynamic getFranDetailInfo(GetFranchiseeDetailsRequest requestModel) async {
    try {
      print('getFranDetails ....');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_FRANCHISEEDETAILS),
          headers: getHeader(''),
          body: requestModel.toJson());

      if (response.statusCode == 200) {
        return GetFranchiseeDetailsResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('statusCode null');
        return 500;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
  }

  dynamic getBpmsStats(BpmsStatRequest requestModel) async {
    try {
      print('Header -- ${getHeader('')}');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_BPMS_COUNTS),
          headers: getHeader(''),
          body: requestModel.toJson());

      if (response.statusCode == 200) {
        return ProjectStatsResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('ProjectStatsResponse null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic getAllProject(BpmsStatRequest requestModel) async {
    try {
      print('Header -- ${getHeader('')}');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_BPMS_ALL_PROJECTS),
          headers: getHeader(''),
          body: requestModel.toJson1());

      if (response.statusCode == 200) {
        return ProjectResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('ProjectResponse null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic getProjectByStatus(BpmsStatRequest requestModel) async {
    try {
      print('Header -- ${getHeader('')}');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_BPMS_PROJECTS_BYSTATUS),
          headers: getHeader(''),
          body: requestModel.toStatusJson());
      /*print(bpms_url + LocalStrings.API_GET_BPMS_PROJECTS_BYSTATUS);
      print(response.body.toString());
      print(response.statusCode);*/
      if (response.statusCode == 200) {
        try {
          if (requestModel.status == 0) {
            return ProjectResponse.fromJson(
              json.decode(response.body) as Map<String, dynamic>,
            );
          } else {
            return ProjectResponse.fromJsonByStatus(
              json.decode(response.body) as Map<String, dynamic>,
            );
          }
        }catch(e){
          print(e.toString());
        }
      } else {
        print('ProjectResponse null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic getAllProjectTask(BpmsTaskRequest requestModel) async {
    try {
      print('Header -- ${getHeader('')}');
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_GET_BPMS_ALL_PROJECTTASK),
          headers: getHeader(''),
          body: requestModel.toJson());

      if (response.statusCode == 200) {
        return ProjectTaskResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('ProjectResponse null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic getBPMSStatus() async {
    try {
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_INSERT_BPMS_STATUS),
          headers: getHeader(''));
      print('getBPMSStatus ${response}');
      if (response.statusCode == 200) {
        return ProjectStatusResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('getBPMSStatus null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic addNewTask(NewTaskRequest request) async {
    try {
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_INSERT_BPMS_NEW_TASK),
          headers: getHeader(''),
      body: request.toJson());
      print('addNewTask request ${ request.toJson()}');
      print('addNewTask ${response}');
      if (response.statusCode == 200) {
        return AddNewTaskResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('addNewTask null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }

  dynamic deleteTask(DeleteTaskRequest request) async {
    try {
      final response = await http.post(
          Uri.parse(bpms_url + LocalStrings.API_BPMS_DELETETASK),
          headers: getHeader(''),
      body: request.toJson());
      print('delte request ${ request.toJson()}');
      print('deleteTask ${response.toString()}');
      if (response.statusCode == 200) {
        return CommonResponse.fromJson1(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        print('addNewTask null');
        return null;
      }
    } catch (e) {
      print(e.toString());
      e.toString();
    }
    return null;
  }
}
