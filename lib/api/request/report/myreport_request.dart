import 'dart:convert';
import 'dart:io';

class MyReportRequest {
  String Usertype;


  MyReportRequest(
      {required this.Usertype,

      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Usertype': Usertype.trim(),
    };

    return map;
  }

  getJson(){
    return jsonEncode( {
      'Usertype': Usertype,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

}