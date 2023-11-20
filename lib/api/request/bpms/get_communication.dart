import 'dart:convert';

class GetCommunicationRequest {
  GetCommunicationRequest({
    required this.BusinessId,
    required this.FranchiseeId,
  });
  late final int BusinessId;
  late final int FranchiseeId;

  GetCommunicationRequest.fromJson(Map<String, dynamic> json){
    BusinessId = json['Business_id'];
    FranchiseeId = json['Franchisee_id'];
  }

  toJson() {
    return jsonEncode({
      'Business_id': this.BusinessId,
      'Franchisee_id': this.FranchiseeId
    });
  }
}