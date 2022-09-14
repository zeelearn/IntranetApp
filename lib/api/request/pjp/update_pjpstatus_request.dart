import 'dart:convert';

class UpdatePJPStatusRequest {
  late int PJP_id;
  late int Is_Approved;
  String Workflow_user='';

  UpdatePJPStatusRequest(
      {required this.PJP_id,required this.Is_Approved,required this.Workflow_user
      });

  getJson(){
    return jsonEncode( {
      'PJP_id': PJP_id,
      'Is_Approved': Is_Approved,
      'Workflow_user': Workflow_user,

    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJP_id': PJP_id,
      'Is_Approved': Is_Approved,
      'Workflow_user': Workflow_user,
    };
    return map;
  }
}