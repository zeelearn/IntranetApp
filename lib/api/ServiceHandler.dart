import 'package:Intranet/api/request/bpms/get_task_comments.dart';
import 'package:Intranet/api/request/bpms/insert_attachment.dart';
import 'package:Intranet/api/request/bpms/update_task.dart';
import 'package:Intranet/api/request/pjp/pjp_exceptional_list.dart';
import 'package:Intranet/api/response/bpms/get_comments_response.dart';
import 'package:Intranet/api/response/bpms/insert_attachment_response.dart';
import 'package:Intranet/api/response/bpms/update_task_response.dart';
import 'package:Intranet/api/response/pjp/pjp_exceptional_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:Intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:Intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatuslist_request.dart';
import 'package:Intranet/api/request/report/myreport_request.dart';
import 'package:Intranet/api/response/cvf/update_status_response.dart';
import 'package:Intranet/api/response/general_response.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/api/response/pjp/update_pjpstatus_response.dart';
import 'package:Intranet/api/response/report/my_report.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:location/location.dart';
import 'package:path/path.dart';

import '../pages/helper/LocationHelper.dart';
import '../pages/iface/onResponse.dart';
import 'APIService.dart';

class IntranetServiceHandler{

  static loadPjpSummery(int employeeId,int pjpId,int bid,onResponse onResponse) {
    onResponse.onStart();
    PJPListRequest request = PJPListRequest(Employee_id: employeeId,PJP_id: pjpId, Business_id: bid);
    debugPrint(request.toJson().toString());
    APIService apiService = APIService();
    apiService.getPJPList(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable ');
        } else if (value is PjpListResponse) {
          try {
            onResponse.onSuccess(value);
          }catch(e){
            onResponse.onError('PJP List not avaliable ');
          }

        } else {
          onResponse.onError('PJP List not avaliable ');
        }
      }else{
        onResponse.onError('PJP List not avaliable ');
      }
    });
  }

  static loadPjpExceptionalSummery(int employeeId,onResponse onResponse) {
    onResponse.onStart();
    PJPExceptionalRequest request = PJPExceptionalRequest(Manager_Emp_id: employeeId);
    debugPrint(request.toJson().toString());
    APIService apiService = APIService();
    apiService.getPJPExceptionalList(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable 1');
        } else if (value is PjpExceptionalResponse) {
          try {
            onResponse.onSuccess(value);
          }catch(e){
            onResponse.onError('PJP List not avaliable 2 ${e.toString()}');
          }

        } else {
          onResponse.onError('PJP List not avaliable 3');
        }
      }else{
        onResponse.onError('PJP List not avaliable 4');
      }
    });
  }

  static loadPjpReport(PJPReportRequest request,onResponse onResponse) {
    onResponse.onStart();
    debugPrint(request.toJson().toString());
    APIService apiService = APIService();
    apiService.getPJPReport(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        /*String data = value.toString().replaceAll('null', '\"NA\"');
        PjpListResponse response = PjpListResponse.fromJson(
          json.decode(data),
        );
        onResponse.onSuccess(response);*/
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable ');
        } else if (value is PjpListResponse) {
          PjpListResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('PJP List not avaliable ');

        }
      }else{
        onResponse.onError('PJP List not avaliable ');
      }
    });
  }

  static updateCVFStatus(int employeeId,GetDetailedPJP cvfView,String date,String status,onResponse onResponse) async{

    double latitude=0.0;
    double longitude=0.0;
    LocationData location = await LocationHelper.getLocation(null);
    if(location!=null){
      latitude = location.latitude!;
      longitude = location.longitude!;
      print('Location is ${latitude} ${longitude}');
    }else{
      print('location data not found');
    }

    /*if (await Permission.location.request().isGranted) {

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      longitude = position.longitude;
      latitude = position.latitude;
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
      }
    }*/
    String address = await Utility.getAddress(latitude, longitude);
      // Either the permission was already granted before or the user just granted it.
    onResponse.onStart();
    UpdateCVFStatusRequest request = UpdateCVFStatusRequest(PJPCVF_id: cvfView.PJPCVF_Id, DateTime: date,
        Status: status, Employee_id: employeeId,
        Latitude: cvfView.Status=='FILL CVF' ? cvfView.Latitude : latitude,
        Longitude: cvfView.Status=='FILL CVF' ? cvfView.Longitude : longitude,
        CheckOutLatitude: status=='Completed' ? latitude : 0.0, CheckOutLongitude: status=='Completed' ? longitude : 0.0, CheckOutAddress: status.trim()=='Check In' ? '' : address , Address: cvfView.Status.trim()=='Check In' ? address : cvfView.Address);
    APIService apiService = APIService();
    apiService.updateCVFStatus(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to update the status');
        } else if (value is UpdateCVFStatusResponse) {
          UpdateCVFStatusResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to update the status ');
        }
      }else{
        onResponse.onError('Unable to update the status');
      }
    });

  }

  static updateCVFOfflineStatus(UpdateCVFStatusRequest request,onResponse onResponse) async{

      APIService apiService = APIService();
      apiService.updateCVFStatus(request).then((value) {
        debugPrint(value.toString());
        if (value != null) {
          if (value == null || value.responseData == null) {
            onResponse.onError('Unable to update the status');
          } else if (value is UpdateCVFStatusResponse) {
            UpdateCVFStatusResponse response = value;
            onResponse.onSuccess(response);
          } else {
            onResponse.onError('Unable to update the status ');
          }
        }else{
          onResponse.onError('Unable to update the status');
        }
      });

  }


  static getMyReport(MyReportRequest request,onResponse onResponse) {

    onResponse.onStart();
    APIService apiService = APIService();
    apiService.getMyReports(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is MyReportResponse) {
          MyReportResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      }else{
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatusList(UpdatePJPStatusListRequest request,onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatusList(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is GeneralResponse) {
          GeneralResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      }else{
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatusExceptional(UpdatePJPStatusListRequest request,onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatusExceptionalList(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is GeneralResponse) {
          GeneralResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      }else{
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatus(UpdatePJPStatusRequest request,onResponse onResponse) {

    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatus(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is UpdatePJPStatusResponse) {
          UpdatePJPStatusResponse response = value;
          response.responseData = request.Is_Approved;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      }else{
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  void updateTaskDetails(UpdateBpmsTaskRequest requestModel,
      bool isLoadingRequired, onResponse response) {
    APIService apiService = APIService();
    if (isLoadingRequired) {
      response.onStart();
    }
    print(requestModel.status);
    apiService.updateTaskDetails(requestModel).then((value) {
      if (value != null) {
        print(value);
        UpdateBpmsTaskResponse responseModel;
        if (value != null) {
          responseModel = value;
          print('update bpms ${responseModel.toJson()}');
          response.onSuccess(responseModel);
        } else {
          print('Unable to update Task');
          response.onError('Unable to update the Task Details Please try again later');
        }
      } else {
        print('Unable to update Task else');
        response.onError('Unable to Update the Task Details Please try again later');
      }
    });
  }

  void insertTaskAttachment(
      InsertTaskAttachmentRequest requestModel, onResponse response) {
    APIService apiService = APIService();
    response.onStart();
    apiService.insertTaskAttachment(requestModel).then((value) {
      if (value != null) {
        InsertTaskAttachmentResponse responseModel;
        if (value != null) {
          responseModel = value;
          response.onSuccess(responseModel);
        } else {
          response.onError('Unable to update the Task File Upload Please try again later');
        }
      } else {
        response.onError('Unable to Update the Task File Upload Please try again later');
      }
    });
  }

  void getTaskComments(
      GetTaskCommentRequest requestModel, onResponse response) {
    APIService apiService = APIService();
    response.onStart();
    apiService.getTaskComments(requestModel).then((value) {
      if (value != null) {
        GetCommentResponse responseModel;
        if (value != null) {
          responseModel = value;
          response.onSuccess(responseModel);
        } else {
          response.onError('Unable to update the Task Details Please try again later');
        }
      } else {
        response.onError('Unable to Update the Task Details Please try again later');
      }
    });
  }
}