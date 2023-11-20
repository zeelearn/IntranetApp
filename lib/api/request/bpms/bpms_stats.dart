import 'dart:convert';
import 'dart:io';

class BpmsStatRequest {
  String userId;

  BpmsStatRequest(
      {required this.userId,
      });


  toJson(){
    return jsonEncode( {
      'user_Id': userId
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