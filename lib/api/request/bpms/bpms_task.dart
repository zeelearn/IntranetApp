import 'dart:convert';
import 'dart:io';

class BpmsTaskRequest {
  String userId;
  String projectID;

  BpmsTaskRequest(
      {
        required this.userId,
        required this.projectID,
      });


  toJson(){
    return jsonEncode( {
      'UserId': userId,
      'projectID': projectID
    });
  }

}