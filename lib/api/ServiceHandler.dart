import 'package:intranet/api/request/pjp/get_pjp_list_request.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';

import '../pages/iface/onResponse.dart';
import 'APIService.dart';

class IntranetServiceHandler{

  static loadPjpSummery(int employeeId,int pjpId,onResponse onResponse) {
    List<PJPInfo> pjpList = [];
    onResponse.onStart();
    PJPListRequest request = PJPListRequest(Employee_id: employeeId,PJP_id: pjpId);
    APIService apiService = APIService();
    apiService.getPJPList(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          onResponse.onError('PJP List not avaliable ');
        } else if (value is PjpListResponse) {
          PjpListResponse response = value;
          onResponse.onSuccess(response);
          /*if (response != null && response.responseData != null) {
            pjpList.addAll(response.responseData);
          }*/
        } else {
          onResponse.onError('PJP List not avaliable ');

        }
      }else{
        onResponse.onError('PJP List not avaliable ');
      }
    });
  }
}