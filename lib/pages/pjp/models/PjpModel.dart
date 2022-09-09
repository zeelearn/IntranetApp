import 'PJPCenterDetails.dart';

class PJPModel {
  int pjpId;
  DateTime dateTime;
  DateTime fromDate;
  DateTime toDate;
  bool isSync;
  String employeeId;
  String remark;
  bool isDelete;
  bool isActive;
  bool isEdit;
  bool isCheckIn;
  bool isCheckOut;
  bool isCVFCompleted;
  DateTime createdDate;
  DateTime modifiedDate;
  List<PJPCentersInfo> centerList;

  PJPModel(
      {required this.pjpId,
        required this.dateTime,
        required this.fromDate,
        required this.toDate,
        required this.remark,
        required this.isSync,
        required this.employeeId,
        required this.centerList,
        required this.isDelete,
        required this.isActive,
        required this.isCheckIn,
        required this.isCheckOut,
        required this.isCVFCompleted,
        required this.isEdit,
        required this.createdDate,
        required this.modifiedDate,

      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'pjpId': pjpId,
      'dateTime': dateTime,
      'fromDate': fromDate,
      'toDate': toDate,
      'remark': remark,
      'isSync': isSync,
      'employeeId': employeeId.trim(),
      'centerList': centerList,
      'isDelete': isDelete,
      'isActive': isActive,
      'isCheckIn': isCheckIn,
      'isCheckOut': isCheckOut,
      'isCVFCompleted': isCVFCompleted,
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
    };

    return map;
  }
}