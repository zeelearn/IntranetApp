import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';

/// Item from `POST /api/bp/GettaskbyUser` (status-filtered user tasks).
class UserTaskItem extends Equatable {
  const UserTaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.note,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.planStartDate,
    required this.dueDate,
    required this.responsiblePerson,
    required this.status,
    required this.statusName,
    required this.parentTaskId,
    required this.taskcount,
    required this.mtaskId,
    this.franchiseeName = '',
    this.franchiseeCode = '',
    this.files = '',
  });

  final String id;
  final String projectId;
  final String title;
  final String note;
  final String priority;
  final String startDate;
  final String endDate;
  final String planStartDate;
  final String dueDate;
  final String responsiblePerson;
  final int status;
  final String statusName;
  final String parentTaskId;
  final String taskcount;
  final String mtaskId;
  final String franchiseeName;
  final String franchiseeCode;
  final String files;

  factory UserTaskItem.fromJson(Map<String, dynamic> json) {
    return UserTaskItem(
      id: _str(json['id']),
      projectId: _str(json['project_id'] ?? json['CRM_id']),
      title: _str(json['title'] ?? json['Title']),
      note: _str(json['latest_comment'] ?? json['note'] ?? json['Remark']),
      priority: _str(json['priority']),
      startDate: _str(json['Start_date']),
      endDate: _str(json['End_date']),
      planStartDate: _str(json['p_start_date']),
      dueDate: _str(json['due_date'] ?? json['deadline']),
      responsiblePerson: _str(json['Responsible_person']),
      status: _int(json['status']),
      statusName: _str(json['statusname']),
      parentTaskId: _str(json['parent_task_id']),
      taskcount: _str(json['taskcount']),
      mtaskId: _str(json['mtask_id']),
      franchiseeName: _str(json['Franchisee_Name']),
      franchiseeCode: _str(json['Franchisee_Code']),
      files: _str(json['files']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'title': title,
        'latest_comment': note,
        'priority': priority,
        'Start_date': startDate,
        'End_date': endDate,
        'p_start_date': planStartDate,
        'due_date': dueDate,
        'Responsible_person': responsiblePerson,
        'status': status,
        'statusname': statusName,
        'parent_task_id': parentTaskId,
        'taskcount': taskcount,
        'mtask_id': mtaskId,
        'Franchisee_Name': franchiseeName,
        'Franchisee_Code': franchiseeCode,
        'files': files,
      };

  /// Opens Task Hierarchy for the parent project.
  ProjectItem toProjectItem() {
    return ProjectItem(
      crmId: projectId,
      id: projectId,
      docUrl: '',
      approvedDate: '',
      franchiseeCode: franchiseeCode,
      franchiseeName: franchiseeName.isNotEmpty ? franchiseeName : title,
      franchiseeId: 0,
      deadline: dueDate,
      createdBy: '',
      totalNoOfTask: 0,
      catchmentArea: '',
      taskcount: taskcount,
      tierName: '',
      feeType: '',
      title: title,
      responsiblePerson: responsiblePerson,
    );
  }

  String get statusChip {
    final s = statusName.toLowerCase();
    if (s.contains('complete') && s.contains('bp')) return 'BPC';
    if (s.contains('complete')) return 'C';
    if (s.contains('progress')) return 'IP';
    return 'P';
  }

  Color get statusColor {
    switch (statusChip) {
      case 'C':
      case 'BPC':
        return DashboardColors.success;
      case 'IP':
        return DashboardColors.purple;
      default:
        return DashboardColors.warning;
    }
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [id, projectId, title, status];
}

class UserTaskListResponse extends Equatable {
  const UserTaskListResponse({
    required this.success,
    required this.tasks,
  });

  final int success;
  final List<UserTaskItem> tasks;

  factory UserTaskListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <UserTaskItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(UserTaskItem.fromJson(Map<String, dynamic>.from(item)));
        } else if (item is List) {
          for (final inner in item) {
            if (inner is Map) {
              list.add(
                UserTaskItem.fromJson(Map<String, dynamic>.from(inner)),
              );
            }
          }
        }
      }
    }
    return UserTaskListResponse(
      success: UserTaskItem._int(json['success']),
      tasks: list,
    );
  }

  @override
  List<Object?> get props => [success, tasks];
}
