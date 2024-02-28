class AttendanceSummeryResponse {
  AttendanceSummeryResponse({
    required this.responseMessage,
    required this.statusCode,
    required this.responseData,
  });
  late final String responseMessage;
  late final int statusCode;
  late final List<AttendanceSummeryModel> responseData;

  AttendanceSummeryResponse.fromJson(Map<String, dynamic> json){
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = json['responseData'] !=null ? List.from(json['responseData']).map((e)=>AttendanceSummeryModel.fromJson(e)).toList() : [];
    if(responseData==null){
      responseData=[];
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['responseMessage'] = responseMessage;
    _data['statusCode'] = statusCode;
    _data['responseData'] = responseData.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class AttendanceSummeryModel {
  AttendanceSummeryModel({
    required this.employeeId,
    required this.day,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.odFrom,
    required this.odTo,
    required this.leave,
    required this.status,
    required this.totWorkingTime,
    required this.isHoliday,
    required this.isVacation,
    required this.isCompOff,
    required this.reqDateAtn,
    required this.reqDateAtnApp,
    required this.reqDateOut,
    required this.reqDateOutApp,
    required this.lateMark,
  });
  late final double employeeId;
  late final String day;
  late final String date;
  late final String? inTime;
  late final String? outTime;
  late final String odFrom;
  late final String odTo;
  late final String leave;
  late final String status;
  late final int totWorkingTime;
  late final bool isHoliday;
  late final bool isVacation;
  late final String isCompOff;
  late final String? reqDateAtn;
  late final String? reqDateAtnApp;
  late final String reqDateOut;
  late final String reqDateOutApp;
  late  String lateMark;

  AttendanceSummeryModel.fromJson(Map<String, dynamic> json){
    print('in nFrom Json');
    employeeId = json['employee_Id'];
    day = json['day'] != null ? json['day'] : "";
    date = json['date'] != null ? json['date'] : "";
    inTime = json['inTime'] != null ? json['inTime'] : "";
    outTime = json['outTime'] != null ? json['outTime'] : "";
    odFrom = json['odFrom'] != null ? json['odFrom'] : "";
    odTo = json['odTo'] != null ? json['odTo'] : "";
    leave = json['leave'] != null ? json['leave'] : "";
    status = json['status'] != null ? json['status'] : "";
    print('in nStatus');
    totWorkingTime =  json['totWorkingTime'] != null ? json['totWorkingTime'] : "";
    isHoliday = json['isHoliday'] != null ? json['isHoliday'] : "";
    isVacation = json['isVacation'] != null ? json['isVacation'] : "";
    isCompOff = json['isCompOff'] != null ? json['isCompOff'] : "";
    reqDateAtn = json['reqDateAtn'] != null ? json['reqDateAtn'] : "";
    reqDateAtnApp = json['reqDateAtnApp'] != null ? json['reqDateAtnApp'] : "";
    reqDateOut = json['reqDateOut'] != null ? json['reqDateOut'] : "";
    reqDateOutApp =  json['reqDateOutApp'] != null ? json['reqDateOutApp'] : "";
    lateMark = json['lateMark'] != null ? json['lateMark'] : "";
    print('in nLate Mark');
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['employee_Id'] = employeeId;
    _data['day'] = day;
    _data['date'] = date;
    _data['inTime'] = inTime;
    _data['outTime'] = outTime;
    _data['odFrom'] = odFrom;
    _data['odTo'] = odTo;
    _data['leave'] = leave;
    _data['status'] = status;
    _data['totWorkingTime'] = totWorkingTime;
    _data['isHoliday'] = isHoliday;
    _data['isVacation'] = isVacation;
    _data['isCompOff'] = isCompOff;
    _data['reqDateAtn'] = reqDateAtn;
    _data['reqDateAtnApp'] = reqDateAtnApp;
    _data['reqDateOut'] = reqDateOut;
    _data['reqDateOutApp'] = reqDateOutApp;
    _data['lateMark'] = lateMark;
    return _data;
  }
}