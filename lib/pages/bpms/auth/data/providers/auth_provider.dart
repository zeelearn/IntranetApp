import 'dart:convert';

import 'package:Intranet/api/request/bpms/bpms_stats.dart';
import 'package:Intranet/api/request/bpms/projects.dart';
import 'package:Intranet/api/response/bpms/bpms_stats.dart';
import 'package:Intranet/pages/helper/web_helper.dart';
import 'package:Intranet/pages/login/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:expensestracker/app/hiveDatabase/hive_database.dart';
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_page_controller.dart';
import 'package:expensestracker/presentation/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../api/request/bpms/bpms_task.dart';
import '../../../../../api/request/bpms/newtask.dart';
import '../../../../../api/response/bpms/bpms_status.dart';
import '../../../../../api/response/bpms/franchisee_details_response.dart';
import '../../../../../api/response/bpms/getTaskDetailsResponseModel.dart';
import '../../../../../api/response/bpms/get_communication_response.dart';
import '../../../../../api/response/bpms/newtask.dart';
import '../../../../../api/response/bpms/project_task.dart';
import '../../../../helper/LocalConstant.dart';
import '../../../../helper/utils.dart';
import '../../../bpms_db.dart';
import '../enums/auth_status.dart';
import '../exceptions/login_exception.dart';
import '../models/auth_state.dart';
import '../repositories/auth_repository.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repo);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthStateNotifier(this._repo, [AuthState? state])
      : super(state ?? AuthState.initial()) {
    checkAuthStatus();
  }

  getFranchiseeInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return '1';
    prefs.getString(LocalConstant.KEY_FRANCHISEE_ID) as String;
  }

  Future<List<CommunicationModel>> getCommunication(int franchiseeId) async {
    List<CommunicationModel> communicationList =
        await BpmsDB.getCommunication();
    if (communicationList.isEmpty || await Utility.isInternet()) {
      final communicationResponse =
          await _repo.getCommunication(franchiseeId: franchiseeId);
      await BpmsDB.addCommunication(communicationResponse);
      return communicationResponse.data;
    } else {
      return communicationList;
    }
  }

  Future<ProjectStatsModel> getStats(String userId) async {
    state = state.copyWith(
        status: AuthStatus.loading,
        statsCounts: ProjectStatsModel(
            TotalProject: 0,
            pendingtask: 0,
            completedTask: 0,
            InprogressTask: 0,
            CancelledTask: 0));
    final list = await _repo.getProjectsCounts(
        request: BpmsStatRequest(userId: userId, status: 0));
    state = state.copyWith(
        status: AuthStatus.authenticated, statsCounts: list.data[0]);
    return list.data[0];
  }

  getAllProjects(String userId, String lastSync) async {
    try {
      state = state.copyWith(
        status: AuthStatus.loading,
      );
      List<ProjectModel> modelList = await BpmsDB.getAllProjects();
      bool isOfflineEligble = await Utility.isOfflineEligble(lastSync);
      if (isOfflineEligble && modelList.isNotEmpty) {
        try {
          modelList.sort((a, b) => b.approvedDate.compareTo(a.approvedDate));
          modelList = modelList.reversed.toList();
        } catch (_) {}
        state = state.copyWith(
            status: AuthStatus.authenticated, projectList: modelList);
      } else {
        final response = await _repo.getAllProject(
            request: BpmsStatRequest(userId: userId, status: 0));
        await BpmsDB.addAllProjects(response.data, 100);
        state = state.copyWith(
            status: AuthStatus.authenticated, projectList: response.data);
      }
    } catch (_) {}
  }

  getProjectByStatus(String userId, int status, String lastSync) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    List<ProjectModel> modelList = await BpmsDB.getAllProjectByStatus(status);
    bool isOfflineEligble = await Utility.isOfflineEligble(lastSync);
    if (isOfflineEligble && modelList.isNotEmpty) {
      try {
        modelList.sort((b, a) => a.approvedDate.compareTo(b.approvedDate));
        modelList = modelList.reversed.toList();
      } catch (_) {}
      state = state.copyWith(
          status: AuthStatus.authenticated, projectList: modelList);
    } else {
      final response = await _repo.getProjectByStatus(
          request: BpmsStatRequest(userId: userId, status: status));

      await BpmsDB.insertProjectByStatus(response.data, status);
      state = state.copyWith(
          status: AuthStatus.authenticated, projectList: response.data);
    }
  }

  refreshProjectList(String userId, int status) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    if (status == 0 || status == 100) {
      final response = await _repo.getAllProject(
          request: BpmsStatRequest(userId: userId, status: status));
      await BpmsDB.addAllProjects(response.data, status);
      state = state.copyWith(
          status: AuthStatus.authenticated, projectList: response.data);
    } else {
      final response = await _repo.getProjectByStatus(
          request: BpmsStatRequest(userId: userId, status: status));
      await BpmsDB.insertProjectByStatus(response.data, status);
      state = state.copyWith(
          status: AuthStatus.authenticated, projectList: response.data);
    }
  }

  refreshProjectTask(String userId, String projectId) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    ProjectTaskResponse response = await _repo.getAllProjectTask(
        request: BpmsTaskRequest(userId: userId, projectID: projectId));
    await BpmsDB.addProjectsTask(response.data[0]);
    state =
        state.copyWith(status: AuthStatus.authenticated, projectTask: response);
  }

  getAllTask(String userId, String projectId) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    List<ProjectTaskModel> modelList = await BpmsDB.getProjectsTask();
    if (false && modelList.isNotEmpty) {
      //await BpmsDB.addProjectsTask(modelList);
      state = state.copyWith(
          status: AuthStatus.authenticated,
          projectTask: ProjectTaskResponse(success: 200, data: [modelList]));
    } else {
      ProjectTaskResponse response = await _repo.getAllProjectTask(
          request: BpmsTaskRequest(userId: userId, projectID: projectId));
      await BpmsDB.addProjectsTask(response.data[0]);
      state = state.copyWith(
          status: AuthStatus.authenticated, projectTask: response);
    }
  }

  getStatus() async {
    /*state = state.copyWith(status: AuthStatus.loading,
    );*/
    ProjectStatusResponse taskResponse = await _repo.getStatus();
    state = state.copyWith(
        status: AuthStatus.authenticated, statusList: taskResponse.data[0]);
  }

  addNewTask(NewTaskRequest request) async {
    state = state.copyWith(
      status: AuthStatus.loading,
    );
    AddNewTaskResponse taskResponse = await _repo.addNewTask(request: request);

    state = state.copyWith(
      status: AuthStatus.authenticated,
    );
  }

  Future<List<ProjectTaskModel>> getTaskDetails(
      String projectId, String userId) async {
    List<ProjectTaskModel> taskList = await BpmsDB.getTaskList();
    if (taskList.isEmpty || await Utility.isInternet()) {
      final taskResponse =
          await _repo.getTask(projectId: projectId, userId: userId);
      await BpmsDB.addTaskList(taskResponse);
      return taskResponse.taskDetail;
    } else {
      return taskList;
    }
  }

  Future<List<FranchiseeIndentModel>> getIndentList(String franchiseeId) async {
    List<FranchiseeIndentModel> indentList = await BpmsDB.getIndentList();
    if (indentList.isEmpty) {
      return [];
    } else {
      return indentList;
    }
  }

  Future<void> refreshCommunication() async {
    List<CommunicationModel> communicationist =
        await getCommunication(state.user!.FranchiseeId);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      communicationList: communicationist,
    );
    return;
  }

  Future<void> refreshTask() async {
    FranchiseeInfoModel? franshiseeInfo = await BpmsDB.getFranchiseeInfo();
    if (franshiseeInfo != null) {
      state = state.copyWith(status: AuthStatus.loading, loading: true);
      final taskResponse = await _repo.getTask(
          projectId: franshiseeInfo.leadId,
          userId: franshiseeInfo.FranchiseeId.toString());
      await BpmsDB.addTaskList(taskResponse);
      state = state.copyWith(
          status: AuthStatus.authenticated,
          taskModelList: taskResponse.taskDetail,
          loading: false);
    } else {}
    return;
  }

  isLoading(AuthStatus isLoading) {
    state = state.copyWith(
      status: isLoading,
    );
  }

  Future<void> checkAuthStatus() async {
    // check storage for existing token/user
    /*String franchiseeId = await getFranchiseeInfo();
    FranchiseeInfoModel? franshiseeInfo = await BpmsDB.getFranchiseeInfo();
    if(await Utility.isInternet()){
      state = state.copyWith(
          status: AuthStatus.loading,
          user: null
      );
      getFranchiseeDetailInfo(franchiseeId: franchiseeId);
      return;
    }else if(franshiseeInfo!=null ){
      getFranchiseeDetailInfo(franchiseeId: franchiseeId);
      return;
    }else if(franshiseeInfo==null){
      state = state.copyWith(
        status: AuthStatus.loading,
        user: null
      );
      getFranchiseeDetailInfo(franchiseeId: franchiseeId);
      return;
    }
    state = state.copyWith(
      status: AuthStatus.unknown,
    );*/
    state = state.copyWith(
      status: AuthStatus.authenticated,
    );
  }

  Future<void> getFranchiseeDetailInfo({required String franchiseeId}) async {
    try {
      state = state.copyWith(
        loading: true,
        errorMessage: '',
      );
      final franchiseeResponse =
          await _repo.getFranchiseeInfo(franchiseeId: franchiseeId);
      List<CommunicationModel> communicationist = await getCommunication(
          franchiseeResponse.franchiseeInfoModel[0].FranchiseeId);
      GetFranchiseeDetailsResponse franchiseeResponseModel =
          GetFranchiseeDetailsResponse.fromJson(
              json.decode(franchiseeResponse.toJsonValue()));
      List<ProjectTaskModel> taskList = await getTaskDetails(
          franchiseeResponseModel.franchiseeInfoModel[0].leadId, '1');
      state = state.copyWith(
        loading: false,
        user: franchiseeResponseModel.franchiseeInfoModel[0],
        communicationList: communicationist,
        indentList: franchiseeResponseModel.indentList,
        taskModelList: taskList,
        status: AuthStatus.authenticated,
        errorMessage: '',
      );
      if (state.user != null) {
        await BpmsDB.addFranchiseeInfo(state.user!);
      }
      if (franchiseeResponse.indentList.isNotEmpty) {
        await BpmsDB.addIndent(franchiseeResponse.indentList);
      }
    } on DioException catch (e) {
      final exc = LoginException.fromDioError(e);
      state = state.copyWith(
        errorMessage: exc.message,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    } finally {
      state = state.copyWith(
        loading: false,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    state = state.copyWith(
      loading: true,
      errorMessage: '',
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // do some API stuff
    await Future.delayed(const Duration(milliseconds: 300));
    await Hive.openBox(LocalConstant.authStorageKey);
    final box = Hive.box(LocalConstant.authStorageKey);
    await box.delete('token');
    await box.delete('user');
    await HiveDatabase.clear();
    clearAllExpenseControllers();

    /*state = state.copyWith(
      user: null,
      status: AuthStatus.unauthenticated,
      loading: false,
    );*/

    if (mounted) {
      resetWebUrl();
      Get.offAll(() => const LoginScreen(), routeName: '/');
    }
    /*  if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    } else if (Platform.isIOS) {
      exit(0);
    } */
  }

  Future<void> changepage(int page) async {
    /*state = state.copyWith(
      action: page,
      loading: true
    );*/
    await Future.delayed(const Duration(milliseconds: 50));
    state = state.copyWith(
        user: null,
        status: AuthStatus.authenticated,
        loading: false,
        action: page);
  }

  Future<void> updateMessage(ProjectTaskModel taskModel, String comment) async {
    List<ProjectTaskModel> taskList = await BpmsDB.getTaskList();
    for (int index = 0; index < taskList.length; index++) {
      if (taskList[index].mtaskId == taskModel.mtaskId) {
        taskList[index].latestComment = comment;
      }
    }
    GetTaskDetailsResponseModel response =
        GetTaskDetailsResponseModel(success: 200, taskDetail: taskList);
    await BpmsDB.addTaskList(response);
  }
}
