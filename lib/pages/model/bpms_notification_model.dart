import 'package:Intranet/api/response/bpms/project_task.dart';

class BpmsNotificationModelList {
  List<BpmsNotificationModel>? data;

  BpmsNotificationModelList({this.data});

  BpmsNotificationModelList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <BpmsNotificationModel>[];
      json['data'].forEach((v) {
        data!.add(new BpmsNotificationModel.fromJson(v));
      });
    }
  }

  getBody(){
    String body = '<h4>Pending tasks are</h4></BR>';
    for(int index=0;index<data!.length;index++){
      body +='</BR> ${index+1}. ${data![index].title}\n';
    }
    return body;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BpmsNotificationModel {
  String? dId;
  String? dName;
  String? title;
  String? status;
  String? due;
  String? taskId;

  BpmsNotificationModel({this.dId, this.dName, this.title, this.status, this.due, this.taskId});

  BpmsNotificationModel.fromJson(Map<String, dynamic> json) {
    dId = json['dId'];
    dName = json['dName'];
    title = json['title'];
    status = json['status'];
    due = json['due'];
    taskId = json['taskId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dId'] = this.dId;
    data['dName'] = this.dName;
    data['title'] = this.title;
    data['status'] = this.status;
    data['due'] = this.due;
    data['taskId'] = this.taskId;
    return data;
  }

  getModel() {
    return ProjectTaskModel(projectId: this.dId!, title: title!, id: this.taskId!, note: '', img: '', priority: '', startDate: '', endDate: '', pStartDate: '', dueDate: '', responsiblePerson: '', status: 1, statusname: 'Pending', parentTaskId: '', dependentTaskId: 0, taskcount: '', isImageUpload: 0, done: false, mtaskId: taskId!, taskcreateduser: dName!, latestComment: '', files: '', manager: '', treeStatus: '', datumClass: '', parantDate: '', parantPlandate: '', path: '');
  }
}
