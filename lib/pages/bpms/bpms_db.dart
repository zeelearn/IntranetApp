import 'package:hive_flutter/adapters.dart';

import '../../api/request/bpms/projects.dart';
import '../../api/response/bpms/franchisee_details_response.dart';
import '../../api/response/bpms/getTaskDetailsResponseModel.dart';
import '../../api/response/bpms/get_communication_response.dart';
import '../../api/response/bpms/project_task.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';

class BpmsDB{

  static addFranchiseeInfo(FranchiseeInfoModel model) async {
    var box = await Hive.openBox(LocalConstant.authStorageKey); //open the hive box before writing
    var mapUserData = model.toMap(model);
    await box.add(mapUserData);
    box.close();
  }

  static addIndent(List<FranchiseeIndentModel> indentList) async {
    await clearAll(LocalConstant.indent);
    var box = await Hive.openBox(LocalConstant.indent); //open the hive box before writing
    for(int index=0;index<indentList.length;index++) {
      var indentData = indentList[index].toMap(indentList[index]);
      await box.add(indentData);
    }
    box.close();
  }

  //Reading all the users data only one data
  static Future<List<FranchiseeIndentModel>> getIndentList() async {
    var box = await Hive.openBox(LocalConstant.indent);
    List<FranchiseeIndentModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var indentMap = box.getAt(i);
      list.add(FranchiseeIndentModel.fromJson(Map.from(indentMap)));
    }
    return list;
  }

  static Future<List<ProjectModel>> getAllProjects() async {
    var box = await Hive.openBox(LocalConstant.projects);
    List<ProjectModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var projectMap = box.getAt(i);
      list.add(ProjectModel.fromJson(Map.from(projectMap)));
    }
    return list;
  }

  static addAllProjects(List<ProjectModel> taskResponse,int status) async {
    await clearAll(LocalConstant.projects+'${status}');

    var box = await Hive.openBox(LocalConstant.projects+'${status}'); //open the hive box before writing
    for(int index=0;index<taskResponse.length;index++) {
      var mapTaskData = taskResponse[index].toMap();
      await box.add(mapTaskData);
    }
    updateBox(status);
    //box.close();
  }

  static Future<List<ProjectModel>> getAllProjectByStatus(int status) async {
    var box = await Hive.openBox(LocalConstant.projectbystatus+'${status}');
    List<ProjectModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var projectMap = box.getAt(i);
      list.add(ProjectModel.fromJsonStatus(Map.from(projectMap)));
    }
    return list;
  }

  static updateBox(int status) async{
    var box = await Utility.openBox();
    box.put(LocalConstant.PROJ_LAST_SYNC+'${status}',Utility.formatDate());
  }

  static insertProjectByStatus(List<ProjectModel> taskResponse,int status) async {
    await clearAll(LocalConstant.projectbystatus+'${status}');
    var box = await Hive.openBox(LocalConstant.projectbystatus+'${status}'); //open the hive box before writing
    for(int index=0;index<taskResponse.length;index++) {
      var mapTaskData = taskResponse[index].toMap();
      await box.add(mapTaskData);
    }
    box.close();
    updateBox(status);
  }

  static Future<List<ProjectTaskModel>> getProjectsTask() async {
    var box = await Hive.openBox(LocalConstant.projecttask);
    List<ProjectTaskModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var projectMap = box.getAt(i);
      list.add(ProjectTaskModel.fromJson(Map.from(projectMap)));
    }
    return list;
  }
  static addProjectsTask(List<ProjectTaskModel> taskResponse) async {
    await clearAll(LocalConstant.projecttask);
    var box = await Hive.openBox(LocalConstant.projecttask); //open the hive box before writing
    for(int index=0;index<taskResponse.length;index++) {
      var mapTaskData = taskResponse[index].toMap();
      await box.add(mapTaskData);
    }
    box.close();
  }

  //Reading all the users data only one data
  static Future<FranchiseeInfoModel?> getFranchiseeInfo() async {
    var box = await Hive.openBox(LocalConstant.authStorageKey);
    FranchiseeInfoModel? model=null;
    for (int i = box.length - 1; i >= 0; i--) {
      var userMap = box.getAt(i);
      model = FranchiseeInfoModel.fromJson(Map.from(userMap));
    }
    return model;
  }

  //Reading all the users data only one data
  static Future<List<CommunicationModel>> getCommunication() async {
    var box = await Hive.openBox(LocalConstant.communicationKey);
    List<CommunicationModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var communicationMap = box.getAt(i);
      list.add(CommunicationModel.fromJson(Map.from(communicationMap)));
    }
    return list;
  }
  static Future<List<ProjectTaskModel>> getTaskList() async {
    var box = await Hive.openBox(LocalConstant.taskKey);
    List<ProjectTaskModel> list = [];
    for (int i = box.length - 1; i >= 0; i--) {
      var taskMap = box.getAt(i);
      list.add(ProjectTaskModel.fromJson(Map.from(taskMap)));
    }
    return list;
  }

  static addCommunication(GetCommunicationResponse communicationModel) async {
    await clearAll(LocalConstant.communicationKey);
    var box = await Hive.openBox(LocalConstant.communicationKey); //open the hive box before writing
    for(int index=0;index<communicationModel.data.length;index++) {
      var mapCommunicationData = communicationModel.data[index].toMap(communicationModel.data[index]);
      await box.add(mapCommunicationData);
    }
    box.close();
  }
  static addTaskList(GetTaskDetailsResponseModel taskResponse) async {
    await clearAll(LocalConstant.taskKey);
    var box = await Hive.openBox(LocalConstant.taskKey); //open the hive box before writing
    for(int index=0;index<taskResponse.taskDetail.length;index++) {
      var mapTaskData = taskResponse.taskDetail[index].toMap();
      await box.add(mapTaskData);
    }
    box.close();
  }



  static clearAll(String  key) async {
    var box = await Hive.openBox(key);
    for (int i = box.length - 1; i >= 0; i--) {
      await box.clear();
    }
  }
}