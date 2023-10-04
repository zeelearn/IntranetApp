import 'dart:convert';
import 'dart:io';

class UpdatePJPStatusListRequest {
  late String DocXML;
  String Workflow_user='';

  UpdatePJPStatusListRequest(
      {required this.DocXML,required this.Workflow_user
      });

  getJson(){
    return jsonEncode( {
      'DocXML': DocXML,
      'Workflow_user': Workflow_user,
      'AppType' :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown'
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'DocXML': DocXML,
      'Workflow_user': Workflow_user,
    };
    return map;
  }
}