import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/project_detail_controller.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/repositories/project_detail_repository.dart';
import 'package:Intranet/modules/projects/services/project_detail_local_service.dart';
import 'package:Intranet/modules/projects/services/project_detail_remote_service.dart';

class ProjectDetailBinding extends Bindings {
  ProjectDetailBinding({
    required this.project,
    required this.userId,
    required this.currentUserName,
    required this.statusName,
    required this.statusColor,
    this.initialTab = ProjectDetailTab.communication,
    this.contributionId = 0,
  });

  final ProjectItem project;
  final int userId;
  final String currentUserName;
  final String statusName;
  final Color statusColor;
  final ProjectDetailTab initialTab;
  final int contributionId;

  String get tag => makeTag(userId, project);

  @override
  void dependencies() {
    if (!Get.isRegistered<ProjectDetailRemoteService>(tag: tag)) {
      Get.put<ProjectDetailRemoteService>(
        ProjectDetailRemoteService(),
        tag: tag,
      );
    }
    if (!Get.isRegistered<ProjectDetailLocalService>(tag: tag)) {
      Get.put<ProjectDetailLocalService>(
        ProjectDetailLocalService(),
        tag: tag,
      );
    }
    if (!Get.isRegistered<ProjectDetailRepository>(tag: tag)) {
      Get.put<ProjectDetailRepository>(
        ProjectDetailRepository(
          remoteService: Get.find<ProjectDetailRemoteService>(tag: tag),
          localService: Get.find<ProjectDetailLocalService>(tag: tag),
        ),
        tag: tag,
      );
    }
    if (!Get.isRegistered<ProjectDetailController>(tag: tag)) {
      Get.put<ProjectDetailController>(
        ProjectDetailController(
          project: project,
          userId: userId,
          currentUserName: currentUserName,
          statusName: statusName,
          statusColor: statusColor,
          initialTab: initialTab,
          contributionId: contributionId,
          repository: Get.find<ProjectDetailRepository>(tag: tag),
        ),
        tag: tag,
      );
    }
  }

  static String makeTag(int userId, ProjectItem project) {
    final crm = project.crmId.isNotEmpty ? project.crmId : project.id;
    return 'project_detail_${userId}_${project.franchiseeId}_$crm';
  }
}
