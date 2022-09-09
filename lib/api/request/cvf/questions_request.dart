import 'dart:convert';

class QuestionsRequest {
  late String Category_Id;
  late String Business_id;
  late String PJPCVF_Id;

  QuestionsRequest(
      {required this.Category_Id,
      required this.Business_id,
      required this.PJPCVF_Id,
      });

  getJson(){
    return jsonEncode( {
      'Category_Id': Category_Id,
      'Business_id': Business_id,
      'PJPCVF_Id': PJPCVF_Id,
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Category_Id': Category_Id.trim(),
      'Business_id': Business_id.trim(),
      'PJPCVF_Id': PJPCVF_Id.trim(),
    };
    return map;
  }
}