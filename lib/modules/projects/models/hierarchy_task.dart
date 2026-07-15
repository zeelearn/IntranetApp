import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/task_summary.dart';

class HierarchyTask extends Equatable {
  const HierarchyTask({
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
    required this.latestComment,
    required this.files,
    required this.mtaskId,
    this.img = '',
    this.manager = '',
    this.taskCreatedUser = '',
    this.parentDate = '',
    this.parentPlanDate = '',
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
  final String latestComment;
  final String files;
  final String mtaskId;
  final String img;
  final String manager;

  /// Creator user id from API `taskcreateduser` (compared to logged-in [userId]).
  final String taskCreatedUser;

  /// Actual dates for root/main tasks — API `parant_date` (`start,end`).
  final String parentDate;

  /// Plan dates for root/main tasks — API `parant_plandate` (`start,end`).
  final String parentPlanDate;

  TaskSummary get summary => TaskSummary.parse(taskcount);

  bool get isRoot =>
      parentTaskId.isEmpty || parentTaskId == '0' || parentTaskId == 'null';

  /// Parsed attachment paths/URLs from comma-separated [files] API field.
  List<String> get attachmentList {
    final raw = files.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null' || raw == '-') {
      return const [];
    }
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList(growable: false);
  }

  int get totalTaskCount {
    final s = summary;
    return s.completed + s.inProgress + s.pending + s.bpCompleted;
  }

  /// Plan start for display — prefers `parant_plandate` for root tasks.
  String get displayPlanStart {
    if (isRoot) {
      final fromParent = _pairStart(parentPlanDate);
      if (fromParent.isNotEmpty) return fromParent;
    }
    return planStartDate;
  }

  /// Plan end for display — prefers `parant_plandate` for root tasks.
  String get displayPlanEnd {
    if (isRoot) {
      final fromParent = _pairEnd(parentPlanDate);
      if (fromParent.isNotEmpty) return fromParent;
    }
    return dueDate;
  }

  /// Actual start for display — prefers `parant_date` for root tasks.
  String get displayActualStart {
    if (isRoot) {
      final fromParent = _pairStart(parentDate);
      if (fromParent.isNotEmpty) return fromParent;
    }
    return startDate;
  }

  /// Actual end for display — prefers `parant_date` for root tasks.
  String get displayActualEnd {
    if (isRoot) {
      final fromParent = _pairEnd(parentDate);
      if (fromParent.isNotEmpty) return fromParent;
    }
    return endDate;
  }

  factory HierarchyTask.fromJson(Map<String, dynamic> json) {
    return HierarchyTask(
      id: _str(json['id']),
      projectId: _str(json['project_id']),
      title: _str(json['title']),
      note: _str(json['note']),
      priority: _str(json['priority']),
      startDate: _str(json['Start_date']),
      endDate: _str(json['End_date']),
      planStartDate: _str(json['p_start_date']),
      dueDate: _str(json['due_date']),
      responsiblePerson: _str(json['Responsible_person']),
      status: _int(json['status']),
      statusName: _str(json['statusname']),
      parentTaskId: _str(json['parent_task_id']),
      taskcount: _str(json['taskcount']),
      latestComment: _str(json['latest_comment']),
      files: _str(json['files']),
      mtaskId: _str(json['mtask_id']),
      img: _str(json['img']),
      manager: _str(json['manager']),
      taskCreatedUser: _str(json['taskcreateduser']),
      parentDate: _str(json['parant_date'] ?? json['parent_date']),
      parentPlanDate: _str(json['parant_plandate'] ?? json['parent_plandate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'title': title,
        'note': note,
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
        'latest_comment': latestComment,
        'files': files,
        'mtask_id': mtaskId,
        'img': img,
        'manager': manager,
        'taskcreateduser': taskCreatedUser,
        'parant_date': parentDate,
        'parant_plandate': parentPlanDate,
      };

  HierarchyTask copyWith({
    String? title,
    String? note,
    String? priority,
    int? status,
    String? statusName,
    String? latestComment,
    String? taskCreatedUser,
  }) {
    return HierarchyTask(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      startDate: startDate,
      endDate: endDate,
      planStartDate: planStartDate,
      dueDate: dueDate,
      responsiblePerson: responsiblePerson,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      parentTaskId: parentTaskId,
      taskcount: taskcount,
      latestComment: latestComment ?? this.latestComment,
      files: files,
      mtaskId: mtaskId,
      img: img,
      manager: manager,
      taskCreatedUser: taskCreatedUser ?? this.taskCreatedUser,
      parentDate: parentDate,
      parentPlanDate: parentPlanDate,
    );
  }

  Color get statusColor {
    final s = statusName.toLowerCase();
    if (s.contains('complete') || status == 1) return DashboardColors.success;
    if (s.contains('progress') || status == 2) return DashboardColors.purple;
    if (s.contains('reject') || s.contains('cancel')) {
      return DashboardColors.error;
    }
    return DashboardColors.warning;
  }

  /// Soft pastel card background by status (Figma main-task cards).
  Color get pastelBackground {
    switch (statusChip) {
      case 'IP':
        return const Color(0xFFF3E5F5);
      case 'C':
        return const Color(0xFFE8F5E9);
      case 'BPC':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String get statusChip {
    final s = statusName.toLowerCase();
    if (s.contains('complete') && s.contains('bp')) return 'BPC';
    if (s.contains('complete')) return 'C';
    if (s.contains('progress')) return 'IP';
    if (s.contains('bp')) return 'BPC';
    return 'P';
  }

  Color get priorityColor {
    final p = priority.toLowerCase();
    if (p.contains('high')) return DashboardColors.error;
    if (p.contains('medium')) return DashboardColors.warning;
    if (p.contains('low')) return DashboardColors.success;
    return DashboardColors.textMuted;
  }

  static String _pairStart(String raw) {
    final parts = _splitPair(raw);
    return parts.isEmpty ? '' : parts.first;
  }

  static String _pairEnd(String raw) {
    final parts = _splitPair(raw);
    if (parts.length < 2) return '';
    return parts[1];
  }

  static List<String> _splitPair(String raw) {
    final v = raw.trim();
    if (v.isEmpty || v.toLowerCase() == 'null' || v == '-') {
      return const [];
    }
    return v
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList(growable: false);
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [id, projectId, parentTaskId, title, status];
}

class HierarchyTaskResponse extends Equatable {
  const HierarchyTaskResponse({
    required this.success,
    required this.tasks,
  });

  final int success;
  final List<HierarchyTask> tasks;

  /// Flattens API shapes: `data: [[{...},...]]` or `data: [{...},...]`.
  factory HierarchyTaskResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <HierarchyTask>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is List) {
          for (final inner in item) {
            if (inner is Map) {
              list.add(
                HierarchyTask.fromJson(Map<String, dynamic>.from(inner)),
              );
            }
          }
        } else if (item is Map) {
          list.add(HierarchyTask.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return HierarchyTaskResponse(
      success: HierarchyTask._int(json['success']),
      tasks: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': tasks.map((e) => e.toJson()).toList(growable: false),
      };

  @override
  List<Object?> get props => [success, tasks];
}
