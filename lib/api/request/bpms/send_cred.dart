import 'dart:convert';

class SendCredentialsRequest {
  SendCredentialsRequest({
    required this.crmId,

  });
  late final String crmId;


  SendCredentialsRequest.fromJson(Map<String, dynamic> json){
    crmId = json['crm_id'];

  }

  toJson() {
    return jsonEncode({
      'crm_id': this.crmId,
    });
  }

}