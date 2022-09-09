import 'dart:convert';

class AddPJPRequest {
  final int PJP_Id=0;
  final int Business_Id=1;
  final String Visit_Type='';
  String remarks='';
  String FromDate;
  String ToDate;
  String ByEmployee_Id;
  int Is_Submit=1;

  AddPJPRequest(
      {required this.FromDate,required this.ToDate,required this.ByEmployee_Id,required this.remarks
      });

  getJson(){
    return jsonEncode( {
      'PJP_Id': PJP_Id,
      'Business_Id': Business_Id,
      'Visit_Type': Visit_Type,
      'remarks': remarks,
      'FromDate': FromDate,
      'ToDate': ToDate,
      'ByEmployee_Id': ByEmployee_Id,
      'Is_Submit': Is_Submit,
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'PJP_Id': PJP_Id,
      'Business_Id': Business_Id,
      'Is_Submit': Is_Submit,
      'ByEmployee_Id': ByEmployee_Id,
      'Visit_Type': Visit_Type.trim(),
      'remarks': remarks.trim(),
      'FromDate': FromDate.trim(),
      'ToDate': ToDate.trim(),
    };
    return map;
  }
}