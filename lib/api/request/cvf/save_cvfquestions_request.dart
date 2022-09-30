import 'dart:convert';
import 'dart:io';

class SaveCVFAnswers {
  int PJPCVF_Id;
  String DocXml;
  int UserId=1;

  SaveCVFAnswers(
      {required this.PJPCVF_Id,required this.DocXml,required this.UserId
      });

  getJson(){
    return jsonEncode( {
      'PJPCVF_Id': PJPCVF_Id,
      'DocXml': DocXml,
      'UserId': UserId,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJPCVF_Id': PJPCVF_Id,
      'DocXml': DocXml,
      'UserId': UserId,
    };
    return map;
  }
}