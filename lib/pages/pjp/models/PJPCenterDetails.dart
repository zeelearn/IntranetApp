class PJPCentersInfo {
  int pjpId;
  DateTime dateTime;
  String? centerCode='';
  late bool isSync=false;
  late bool isNotify = false;
   String? centerName;
  String? purpose;
  late bool isDelete=false;
  late bool isActive = false;
  late bool isCheckIn = false;
  late bool isCheckOut = false;
  late bool isCompleted = false;
  late DateTime createdDate = DateTime.now();
  late DateTime modifiedDate = DateTime.now();


  PJPCentersInfo(
      {required this.pjpId,
        required this.dateTime,
        required this.centerCode,
        required this.centerName,
        required this.isActive,
        required this.isNotify,
        required this.purpose,
        required this.isCheckIn,
        required this.isCheckOut,
        required this.isSync,
        required this.isCompleted,
         required this.createdDate,
        required this.modifiedDate,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'pjpId': pjpId,
      'dateTime': dateTime,
      'centerCode': centerCode?.trim(),
      'isSync': isSync,
      'isNotify': isNotify,
      'centerName': centerName?.trim(),
      'purpose': purpose?.trim(),
      'isDelete': isDelete,
      'isActive': isActive,
      'isCheckIn': isCheckIn,
      'isCheckOut': isCheckOut,
      'isCompleted': isCompleted,
      'isSync': isSync,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
    };

    return map;
  }
}