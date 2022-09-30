import 'dart:convert';
import 'dart:io';

class AddCVFRequest {
  int PJP_Id;
  String DocXml;
  int UserId=1;

  AddCVFRequest(
      {required this.PJP_Id,required this.DocXml,required this.UserId
      });

  getJson(){
    return jsonEncode( {
      'PJP_Id': PJP_Id,
      'DocXml': DocXml,
      'UserId': UserId,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJP_Id': PJP_Id,
      'DocXml': DocXml,
      'UserId': UserId,
    };
    return map;
  }
}