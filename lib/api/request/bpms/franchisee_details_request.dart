import 'dart:convert';

class GetFranchiseeDetailsRequest {
  GetFranchiseeDetailsRequest({
    required this.franchiseeId,
  });
  late final String franchiseeId;

  GetFranchiseeDetailsRequest.fromJson(Map<String, dynamic> json){
    franchiseeId = json['Franchisee_ID'];
  }

  toJson() {
    return jsonEncode({
      'Franchisee_ID': this.franchiseeId,
    });
  }
}