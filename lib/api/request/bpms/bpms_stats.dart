import 'dart:convert';
import 'dart:io';

class BpmsStatRequest {
  String userId;
  int status;

  BpmsStatRequest(
      {
        required this.userId,
        required this.status,
      });


  toJson(){
    return jsonEncode( {
      'user_Id': userId
      /*'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'*/
    });
  }
  toStatusJson(){
    return jsonEncode( {
      'User_Id': userId,
      'Status': status
      /*'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'*/
    });
  }

  toJson1(){
    return jsonEncode( {
      'userID': userId
      /*'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'*/
    });
  }
}