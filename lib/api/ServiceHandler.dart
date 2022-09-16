import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:intranet/api/request/report/myreport_request.dart';
import 'package:intranet/api/response/cvf/update_status_response.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';
import 'package:intranet/api/response/pjp/update_pjpstatus_response.dart';
import 'package:intranet/api/response/report/my_report.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/iface/onResponse.dart';
import 'APIService.dart';

class IntranetServiceHandler{

  static loadPjpSummery(int employeeId,int pjpId,onResponse onResponse) {
    List<PJPInfo> pjpList = [];
    print('IntranetServiceHandler');
    onResponse.onStart();
    PJPListRequest request = PJPListRequest(Employee_id: employeeId,PJP_id: pjpId);
    print(request.toJson());
    APIService apiService = APIService();
    apiService.getPJPList(request).then((value) {
      print(value.toString());
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

  static updateCVFStatus(int employeeId,String cvfId,String date,String status,onResponse onResponse) async{

    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

      onResponse.onStart();
      UpdateCVFStatusRequest request = UpdateCVFStatusRequest(PJPCVF_id: cvfId, DateTime: date, Status: status, Employee_id: employeeId,
          Latitude: position.latitude,Longitude: position.longitude);
      APIService apiService = APIService();
      apiService.updateCVFStatus(request).then((value) {
        print(value.toString());
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
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
      print(statuses[Permission.location]);
    }

  }


  static getMyReport(MyReportRequest request,onResponse onResponse) {

    onResponse.onStart();
    APIService apiService = APIService();
    apiService.getMyReports(request).then((value) {
      print(value.toString());
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

  static updatePJPStatus(UpdatePJPStatusRequest request,onResponse onResponse) {

    onResponse.onStart();
    APIService apiService = APIService();
    apiService.updatePjpStatus(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('Unable to get Reports');
        } else if (value is UpdatePJPStatusResponse) {
          UpdatePJPStatusResponse response = value;
          onResponse.onSuccess(response);
        } else {
          onResponse.onError('Unable to get Reports ');
        }
      }else{
        onResponse.onError('Unable to get Reports');
      }
    });
  }
}