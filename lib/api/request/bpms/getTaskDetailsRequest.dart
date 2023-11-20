import 'dart:convert';

class GetTaskDetailsRequest {
  GetTaskDetailsRequest({
    required this.projectID,
    required this.UserId,
  });
  late final String projectID;
  late final String UserId;

  GetTaskDetailsRequest.fromJson(Map<String, dynamic> json){
    projectID = json['projectID'];
    UserId = json['UserId'];
  }

  toJson() {
    return jsonEncode({
      'projectID': this.projectID,
      'UserId': this.UserId
    });
  }
  
}