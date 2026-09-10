import 'package:Intranet/api/request/bpms/get_task_comments.dart';
import 'package:Intranet/api/request/bpms/insert_attachment.dart';
import 'package:Intranet/api/request/bpms/update_task.dart';
import 'package:Intranet/api/request/pjp/pjp_exceptional_list.dart';
import 'package:Intranet/api/response/bpms/get_comments_response.dart';
import 'package:Intranet/api/response/bpms/insert_attachment_response.dart';
import 'package:Intranet/api/response/bpms/update_task_response.dart';
import 'package:Intranet/api/response/pjp/pjp_exceptional_list.dart';
import 'package:Intranet/pages/home/change_password_request.dart';
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

class IntranetServiceHandler {
  static loadPjpSummery(
      int employeeId, int pjpId, int bid, onResponse onResponse) {
        debugPrint('IntranetServiceHandler loadPjpSummery for ${employeeId}');
    onResponse.onStart();
    PJPListRequest request = PJPListRequest(
        Employee_id: employeeId, PJP_id: pjpId, Business_id: bid);
    APIService apiService = APIService();
    apiService.getPJPList(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          debugPrint('PJP List not avaliable ');
          onResponse.onError('PJP List not avaliable ');
        } else if (value is PjpListResponse) {
          try {
            debugPrint('PjpListResponse in response ${value} ');
            onResponse.onSuccess(value);
          } catch (e) {
            debugPrint('PJP List not avaliable ${e.toString()} ');
            onResponse.onError('PJP List not avaliable ${e.toString()} ');
          }
        } else {
          debugPrint('PJP List not avaliable else 52');
          onResponse.onError('PJP List not avaliable ');
        }
      } else {
        debugPrint('PJP List not avaliable else 56');
        onResponse.onError('PJP List not avaliable ');
      }
    });
  }

  static loadPjpExceptionalSummery(int employeeId, onResponse onResponse) {
    onResponse.onStart();
    PJPExceptionalRequest request =
        PJPExceptionalRequest(Manager_Emp_id: employeeId);
    APIService apiService = APIService();
    apiService.getPJPExceptionalList(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable 1');
        } else if (value is PjpExceptionalResponse) {
          try {
            onResponse.onSuccess(value);
          } catch (e) {
            onResponse.onError('PJP List not avaliable 2 ${e.toString()}');
          }
        } else {
          onResponse.onError('PJP List not avaliable 3');
        }
      } else {
        onResponse.onError('PJP List not avaliable 4');
      }
    });
  }

  static loadPjpReport(PJPReportRequest request, onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.getPJPMYTEAMReport(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable ');
        } else if (value is PjpListResponse) {
          PjpListResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('PJP List not avaliable ');
        }
      } else {
        onResponse.onError('PJP List not avaliable ');
      }
    });
  }

  static updateCVFStatus(int employeeId, GetDetailedPJP cvfView, String date,
      String status, onResponse onResponse) async {
    double latitude = 0.0;
    double longitude = 0.0;
    onResponse.onStart();
    LocationData? location = await LocationHelper.getLocation(null);
    if (location != null) {
      latitude = location.latitude!;
      longitude = location.longitude!;
    }

    String? address = await Utility.getAddress(latitude, longitude);
    // Either the permission was already granted before or the user just granted it.

    UpdateCVFStatusRequest request = UpdateCVFStatusRequest(
        PJPCVF_id: cvfView.PJPCVF_Id,
        DateTime: date,
        Status: status,
        Employee_id: employeeId,
        Latitude: cvfView.Status == 'FILL CVF' ? cvfView.Latitude : latitude,
        Longitude: cvfView.Status == 'FILL CVF' ? cvfView.Longitude : longitude,
        CheckOutLatitude: status == 'Completed' ? latitude : 0.0,
        CheckOutLongitude: status == 'Completed' ? longitude : 0.0,
        CheckOutAddress: status == 'Completed' ? (address ?? '') : '',
        Address: (cvfView.Status.trim() == 'Check In' ||
                cvfView.Status.trim() == 'NA')
            ? (address ?? '')
            : cvfView.Address);

    APIService apiService = APIService();
    apiService.updateCVFStatus(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to update the status');
        } else if (value is UpdateCVFStatusResponse) {
          // UpdateCVFStatusResponse response = value;
          if (status == 'Completed') {
            cvfView.DateTimeOut = date;
            cvfView.CheckOutAddress = address ?? '';
            cvfView.LatitudeOut = latitude;
            cvfView.LongitudeOut = longitude;
            cvfView.Status = 'Completed';
            cvfView.approvalStatus = 'Completed';
          } else if (cvfView.Status.trim() == 'Check In' ||
              cvfView.Status.trim() == 'NA') {
            cvfView.DateTimeIn = date;
            cvfView.CheckInAddress = address ?? '';
            cvfView.LatitudeIn = latitude;
            cvfView.LongitudeIn = longitude;
            cvfView.Status = 'FILL CVF';
          }
          onResponse.onSuccess(cvfView);
        } else {
          onResponse.onError('Unable to update the status ');
        }
      } else {
        onResponse.onError('Unable to update the status');
      }
    });
  }

  static updateCVFOfflineStatus(
      UpdateCVFStatusRequest request, onResponse onResponse) async {
    APIService apiService = APIService();
    apiService.updateCVFStatus(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to update the status');
        } else if (value is UpdateCVFStatusResponse) {
          UpdateCVFStatusResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to update the status ');
        }
      } else {
        onResponse.onError('Unable to update the status');
      }
    });
  }

  static getMyReport(MyReportRequest request, onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.getMyReports(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is MyReportResponse) {
          MyReportResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      } else {
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatusList(
      UpdatePJPStatusListRequest request, onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatusList(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is GeneralResponse) {
          GeneralResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      } else {
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatusExceptional(
      UpdatePJPStatusListRequest request, onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatusExceptionalList(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is GeneralResponse) {
          GeneralResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      } else {
        onResponse.onError('Unable to get Reports');
      }
    });
  }

  static updatePJPStatus(
      UpdatePJPStatusRequest request, onResponse onResponse) {
    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatus(request).then((value) {
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
      } else {
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
    apiService.updateTaskDetails(requestModel).then((value) {
      if (value != null) {
        UpdateBpmsTaskResponse responseModel;
        if (value != null) {
          responseModel = value;
          response.onSuccess(responseModel);
        } else {
          response.onError(
              'Unable to update the Task Details Please try again later');
        }
      } else {
        response.onError(
            'Unable to Update the Task Details Please try again later');
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
          response.onError(
              'Unable to update the Task File Upload Please try again later');
        }
      } else {
        response.onError(
            'Unable to Update the Task File Upload Please try again later');
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
          response.onError(
              'Unable to update the Task Details Please try again later');
        }
      } else {
        response.onError(
            'Unable to Update the Task Details Please try again later');
      }
    });
  }

  static changePassword(ChangePasswordRequest request, onResponse response) {
    response.onStart();
    APIService apiService = APIService();
    apiService.changePassword(request).then((value) {
      if (value != null) {
        if (value is GeneralResponse) {
          response.onSuccess(value);
        } else {
          response.onError('Failed to update password');
        }
      } else {
        response
            .onError('Unable to Update the Password. Please try again later');
      }
    });
  }
}
