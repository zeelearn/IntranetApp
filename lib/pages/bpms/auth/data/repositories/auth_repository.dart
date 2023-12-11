
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../api/APIService.dart';
import '../../../../../api/request/bpms/bpms_stats.dart';
import '../../../../../api/request/bpms/bpms_task.dart';
import '../../../../../api/request/bpms/franchisee_details_request.dart';
import '../../../../../api/request/bpms/getTaskDetailsRequest.dart';
import '../../../../../api/request/bpms/get_communication.dart';
import '../../../../../api/request/bpms/newtask.dart';
import '../../../../../api/request/bpms/projects.dart';
import '../../../../../api/request/bpms/send_cred.dart';
import '../../../../../api/response/bpms/bpms_stats.dart';
import '../../../../../api/response/bpms/bpms_status.dart';
import '../../../../../api/response/bpms/franchisee_details_response.dart';
import '../../../../../api/response/bpms/getTaskDetailsResponseModel.dart';
import '../../../../../api/response/bpms/get_communication_response.dart';
import '../../../../../api/response/bpms/newtask.dart';
import '../../../../../api/response/bpms/project_task.dart';
import '../../../../../api/response/bpms/send_cred.dart';
import '../exceptions/login_exception.dart';

abstract class AuthRepository {
  Future<String> login({
    required String email,
    required String password,
  });

  Future<GetFranchiseeDetailsResponse> getFranchiseeInfo({
    required String franchiseeId,
  });

  Future<ProjectStatsResponse> getProjectsCounts({
    required BpmsStatRequest request,
  });

  Future<ProjectResponse> getAllProject({
    required BpmsStatRequest request,
  });

  Future<ProjectResponse> getProjectByStatus({
    required BpmsStatRequest request,
  });


  Future<ProjectTaskResponse> getAllProjectTask({
    required BpmsTaskRequest request,
  });

  Future<GetCommunicationResponse> getCommunication({
    required int franchiseeId,
  });

  Future<GetTaskDetailsResponseModel> getTask({
    required String projectId,
    required String userId,
  });

  Future<ProjectStatusResponse> getStatus();

  Future<AddNewTaskResponse> addNewTask({required NewTaskRequest request});

}

class ApiAuthRepository implements AuthRepository {
  final Dio _dio;

  ApiAuthRepository(this._dio);



  @override
  Future<ProjectStatusResponse> getStatus() async {
    return await APIService().getBPMSStatus();
  }


  @override
  Future<ProjectStatsResponse> getProjectsCounts(
      {required BpmsStatRequest request}) async {
    try {
      return await APIService().getBpmsStats(request);
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to ProjectStatsResponse');
      //return null;
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
      //return null;
    }
  }

  @override
  Future<ProjectResponse> getAllProject(
      {required BpmsStatRequest request}) async {
    try {
      return await APIService().getAllProject(request);
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to ProjectStatsResponse');
      //return null;
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
      //return null;
    }
  }

  @override
  Future<ProjectResponse> getProjectByStatus(
      {required BpmsStatRequest request}) async {
    try {
      return await APIService().getProjectByStatus(request);
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to ProjectStatsResponse');
      //return null;
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
      //return null;
    }
  }

  @override
  Future<ProjectTaskResponse> getAllProjectTask(
      {required BpmsTaskRequest request}) async {
    try {
      return await APIService().getAllProjectTask(request);
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to ProjectStatsResponse');
      //return null;
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
      //return null;
    }
  }

  @override
  Future<GetCommunicationResponse> getCommunication(
      {required int franchiseeId}) async {
    try {
      return await APIService().getCommunication(GetCommunicationRequest(BusinessId: /*AppFlavor == 'mlzs' ? 2 :*/ 1, FranchiseeId: franchiseeId));
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to login');
      //return null;
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
      //return null;
    }
  }
  @override
  Future<GetTaskDetailsResponseModel> getTask(
      {required String projectId,required String userId}) async {
    try {
      return await APIService().getBPMSTaskDetails(GetTaskDetailsRequest(projectID: projectId,UserId: userId));
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to login');
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
    }
  }

  @override
  Future<GetFranchiseeDetailsResponse> getFranchiseeInfo(
      {required String franchiseeId}) async {
    try {
      print('getFranchiseeInfo 74');
      GetFranchiseeDetailsRequest request = GetFranchiseeDetailsRequest(franchiseeId: franchiseeId);
      GetFranchiseeDetailsResponse response = await APIService().getFranDetailInfo(request);
      return response;
    } on DioException catch (e) {
      print(e.message);
      throw LoginException(message: 'Unable to login');
    } catch (e) {
      print(e.toString());
      throw Exception('Unable to login');
    }
  }

  @override
  Future<String> login(
      {required String email, required String password}) async {
    const url = 'https://reqres.in/api/login';

    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _dio.post(url, data: data);

      final token = response.data['token'] as String;
      return token;
    } on DioException catch (e) {
      throw LoginException(message: 'Unable to login');
    } catch (e) {
      throw Exception('Unable to login');
    }
  }

  @override
  Future<AddNewTaskResponse> addNewTask({required NewTaskRequest request}) async {
    return await APIService().addNewTask(request);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(Dio());
});
