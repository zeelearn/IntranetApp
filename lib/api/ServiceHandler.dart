import 'dart:convert';

import 'package:intranet/api/request/cvf/update_cvf_status_request.dart';
import 'package:intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:intranet/api/response/cvf/update_status_response.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';

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

  static updateCVFStatus(int employeeId,String cvfId,String date,String status,onResponse onResponse) {

    onResponse.onStart();
    UpdateCVFStatusRequest request = UpdateCVFStatusRequest(PJPCVF_id: cvfId, DateTime: date, Status: status, Employee_id: employeeId);
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
  }
}