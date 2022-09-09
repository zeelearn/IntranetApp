import 'dart:convert';

class ApproveAttendanceMarking {
  String Requisition_Id;
  String Modified_By;
  String Is_Approved;

  ApproveAttendanceMarking(
      {required this.Requisition_Id,
        required this.Modified_By,
        required this.Is_Approved,
      });

  getJson(){
    return jsonEncode( {
      'Requisition_Id': Requisition_Id,
      'Modified_By': Modified_By.trim(),
      'Is_Approved': Is_Approved.trim(),
    });
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Requisition_Id': Requisition_Id.trim(),
      'Modified_By': Modified_By.trim(),
      'Is_Approved': Is_Approved.trim(),

    };

    return map;
  }
}