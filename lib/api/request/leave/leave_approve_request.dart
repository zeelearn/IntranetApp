class ApproveLeaveRequestManager {
  late String xml;
  late String userId;
  late String actionType;
  int? index;

  ApproveLeaveRequestManager({required this.xml,required this.userId,required this.actionType, required this.index});

  ApproveLeaveRequestManager.fromJson(Map<String, dynamic> json) {
    xml = json['xml'];
    userId = json['User_Id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['xml'] = this.xml;
    data['User_Id'] = this.userId;
    return data;
  }
}
