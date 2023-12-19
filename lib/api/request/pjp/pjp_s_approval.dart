class PjpApproval {
  Root? root;

  PjpApproval({this.root});

  PjpApproval.fromJson(Map<String, dynamic> json) {
    root = json['root'] != null ? new Root.fromJson(json['root']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.root != null) {
      data['root'] = this.root!.toJson();
    }
    return data;
  }
}

class Root {
  List<Subroot>? subroot;

  Root({this.subroot});

  Root.fromJson(Map<String, dynamic> json) {
    if (json['subroot'] != null) {
      subroot = <Subroot>[];
      json['subroot'].forEach((v) {
        subroot!.add(new Subroot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.subroot != null) {
      data['subroot'] = this.subroot!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subroot {
  late int pJPId;
  late int pJPCVFId;
  late int isApproved;

  Subroot( {required this.pJPId,required  this.pJPCVFId,required  this.isApproved});

  Subroot.fromJson(Map<String, dynamic> json) {
    pJPId = json['PJP_Id'];
    pJPCVFId = json['PJPCVF_Id'];
    isApproved = json['Is_Approved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PJP_Id'] = this.pJPId;
    data['PJPCVF_Id'] = this.pJPCVFId;
    data['Is_Approved'] = this.isApproved;
    return data;
  }
}
