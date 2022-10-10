
class CheckInModel {
  int id;
  String cvfId;
  String body;
  String state;
  bool isSync;


  CheckInModel(
      {
        required this.id,
        required this.cvfId,
        required this.body,
        required this.state,
        required this.isSync,


      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'cvfId': cvfId,
      'body': body,
      'state': state,
      'isSync': isSync,
    };

    return map;
  }
}