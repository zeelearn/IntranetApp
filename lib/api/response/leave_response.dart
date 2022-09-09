class LeaveBalanceResponse {
  LeaveBalanceResponse({
    required this.responseMessage,
    required this.statusCode,
    required this.responseData,
  });
  late final String responseMessage;
  late final int statusCode;
  late final List<LeaveBalanceInfo> responseData;

  LeaveBalanceResponse.fromJson(Map<String, dynamic> json){
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = List.from(json['responseData']).map((e)=>LeaveBalanceInfo.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['responseMessage'] = responseMessage;
    _data['statusCode'] = statusCode;
    _data['responseData'] = responseData.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class LeaveBalanceInfo {
  LeaveBalanceInfo({
    required this.id,
    required this.leaveBalance,
    required this.leaveAvaEncash,
    required this.leaveTaken,
    required this.leaveApplied,
    required this.leaveRejected,
    required this.leaveCancelled,
    required this.leaveEncashed,
    required this.lwp,
  });
  late final int id;
  late final double leaveBalance;
  late final double leaveAvaEncash;
  late final double leaveTaken;
  late final double leaveApplied;
  late final double leaveRejected;
  late final double leaveCancelled;
  late final double leaveEncashed;
  late final double lwp;

  LeaveBalanceInfo.fromJson(Map<String, dynamic> json){
    id = json['id'];
    leaveBalance = json['leaveBalance'];
    leaveAvaEncash = json['leaveAvaEncash'];
    leaveTaken = json['leaveTaken'];
    leaveApplied = json['leaveApplied'];
    leaveRejected = json['leaveRejected'];
    leaveCancelled = json['leaveCancelled'];
    leaveEncashed = json['leaveEncashed'];
    lwp = json['lwp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['leaveBalance'] = leaveBalance;
    _data['leaveAvaEncash'] = leaveAvaEncash;
    _data['leaveTaken'] = leaveTaken;
    _data['leaveApplied'] = leaveApplied;
    _data['leaveRejected'] = leaveRejected;
    _data['leaveCancelled'] = leaveCancelled;
    _data['leaveEncashed'] = leaveEncashed;
    _data['lwp'] = lwp;
    return _data;
  }
}