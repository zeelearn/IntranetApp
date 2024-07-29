class KPIInfo {
  List<KPIModel>? data;

  KPIInfo({this.data});

  KPIInfo.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <KPIModel>[];
      json['data'].forEach((v) {
        data!.add(new KPIModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class KPIModel {
  String? year;
  String? month;
  String? zone;
  String? zM;
  String? tM;
  String? franchiseCodeName;
  String? targetACK;
  String? aCKACT;
  String? targetEN;
  String? eNAct;

  KPIModel(
      {
      required this.year,
      required this.month,
      required this.zone,
      required this.zM,
      required this.tM,
      required this.franchiseCodeName,
      required this.targetACK,
      required this.aCKACT,
      required this.targetEN,
      required this.eNAct});

  KPIModel.fromJson(Map<String, dynamic> json) {
    year = json['Year'];
    month = json['Month'];
    zone = json['Zone'];
    zM = json['ZM'];
    tM = json['TM'];
    franchiseCodeName = json['Franchise_code_name'];
    targetACK = json['Target ACK'];
    aCKACT = json['ActualACK'];
    targetEN = json['Target EN'];
    eNAct = json['EN Act'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Year'] = this.year;
    data['Month'] = this.month;
    data['Zone'] = this.zone;
    data['ZM'] = this.zM;
    data['TM'] = this.tM;
    data['Franchise_code_name'] = this.franchiseCodeName;
    data['Target ACK'] = this.targetACK;
    data['ActualACK'] = this.aCKACT;
    data['Target EN'] = this.targetEN;
    data['EN Act'] = this.eNAct;
    return data;
  }
}
