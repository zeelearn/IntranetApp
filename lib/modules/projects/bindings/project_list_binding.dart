import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/controllers/project_list_controller.dart';
import 'package:Intranet/modules/projects/repositories/project_repository.dart';
import 'package:Intranet/modules/projects/services/project_local_service.dart';
import 'package:Intranet/modules/projects/services/project_remote_service.dart';

class ProjectListBinding extends Bindings {
  ProjectListBinding({
    required this.userId,
    required this.projectTeamStatus,
    required this.statusName,
    required this.statusColor,
    required this.businesses,
    this.businessId,
    this.currentUserName = '',
  });

  final int userId;
  final int? businessId;
  final int projectTeamStatus;
  final String statusName;
  final Color statusColor;
  final List<BusinessApplications> businesses;
  final String currentUserName;

  @override
  void dependencies() {
    final tag = _tag(userId, projectTeamStatus, businessId);

    if (!Get.isRegistered<ProjectRemoteService>(tag: tag)) {
      Get.put<ProjectRemoteService>(ProjectRemoteService(), tag: tag);
    }
    if (!Get.isRegistered<ProjectLocalService>(tag: tag)) {
      Get.put<ProjectLocalService>(ProjectLocalService(), tag: tag);
    }
    if (!Get.isRegistered<ProjectRepository>(tag: tag)) {
      Get.put<ProjectRepository>(
        ProjectRepository(
          remoteService: Get.find<ProjectRemoteService>(tag: tag),
          localService: Get.find<ProjectLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }

    Get.put<ProjectListController>(
      ProjectListController(
        userId: userId,
        businessId: businessId,
        projectTeamStatus: projectTeamStatus,
        statusName: statusName,
        statusColor: statusColor,
        businesses: businesses,
        currentUserName: currentUserName,
        repository: Get.find<ProjectRepository>(tag: tag),
      ),
      tag: tag,
    );
  }

  static String tag(int userId, int status, int? businessId) =>
      _tag(userId, status, businessId);

  static String _tag(int userId, int status, int? businessId) =>
      'project_list_${userId}_${status}_${businessId ?? 'all'}';
}
