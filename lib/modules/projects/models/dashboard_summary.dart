import 'package:equatable/equatable.dart';

import 'project_status.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalProject,
    required this.pendingTask,
    required this.completedTask,
    required this.inProgressTask,
    required this.cancelledTask,
    required this.allProject,
    required this.completedProject,
    required this.notInterestedProject,
    required this.refundedProject,
    required this.rejectedProject,
    required this.pendingProject,
    required this.notStartedProject,
  });

  final int totalProject;
  final int pendingTask;
  final int completedTask;
  final int inProgressTask;
  final int cancelledTask;
  final List<ProjectStatus> allProject;
  final List<ProjectStatus> completedProject;
  final List<ProjectStatus> notInterestedProject;
  final List<ProjectStatus> refundedProject;
  final List<ProjectStatus> rejectedProject;
  final List<ProjectStatus> pendingProject;
  final List<ProjectStatus> notStartedProject;

  factory DashboardSummary.empty() => const DashboardSummary(
        totalProject: 0,
        pendingTask: 0,
        completedTask: 0,
        inProgressTask: 0,
        cancelledTask: 0,
        allProject: [],
        completedProject: [],
        notInterestedProject: [],
        refundedProject: [],
        rejectedProject: [],
        pendingProject: [],
        notStartedProject: [],
      );

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalProject: _asInt(json['TotalProject']),
      pendingTask: _asInt(json['pendingtask']),
      completedTask: _asInt(json['completedTask']),
      inProgressTask: _asInt(json['InprogressTask']),
      cancelledTask: _asInt(json['CancelledTask']),
      allProject: _statusList(json['AllProject']),
      completedProject: _statusList(json['CompletedProject']),
      notInterestedProject: _statusList(json['NotInterestedProject']),
      refundedProject: _statusList(json['RefundedProject']),
      rejectedProject: _statusList(json['RejectedProject']),
      pendingProject: _statusList(json['PendingProject']),
      notStartedProject: _statusList(json['NotStartedProject']),
    );
  }

  Map<String, dynamic> toJson() => {
        'TotalProject': totalProject,
        'pendingtask': pendingTask,
        'completedTask': completedTask,
        'InprogressTask': inProgressTask,
        'CancelledTask': cancelledTask,
        'AllProject':
            allProject.map((e) => e.toJson()).toList(growable: false),
        'CompletedProject':
            completedProject.map((e) => e.toJson()).toList(growable: false),
        'NotInterestedProject': notInterestedProject
            .map((e) => e.toJson())
            .toList(growable: false),
        'RefundedProject':
            refundedProject.map((e) => e.toJson()).toList(growable: false),
        'RejectedProject':
            rejectedProject.map((e) => e.toJson()).toList(growable: false),
        'PendingProject':
            pendingProject.map((e) => e.toJson()).toList(growable: false),
        'NotStartedProject':
            notStartedProject.map((e) => e.toJson()).toList(growable: false),
      };

  DashboardSummary copyWith({
    int? totalProject,
    int? pendingTask,
    int? completedTask,
    int? inProgressTask,
    int? cancelledTask,
    List<ProjectStatus>? allProject,
    List<ProjectStatus>? completedProject,
    List<ProjectStatus>? notInterestedProject,
    List<ProjectStatus>? refundedProject,
    List<ProjectStatus>? rejectedProject,
    List<ProjectStatus>? pendingProject,
    List<ProjectStatus>? notStartedProject,
  }) {
    return DashboardSummary(
      totalProject: totalProject ?? this.totalProject,
      pendingTask: pendingTask ?? this.pendingTask,
      completedTask: completedTask ?? this.completedTask,
      inProgressTask: inProgressTask ?? this.inProgressTask,
      cancelledTask: cancelledTask ?? this.cancelledTask,
      allProject: allProject ?? this.allProject,
      completedProject: completedProject ?? this.completedProject,
      notInterestedProject: notInterestedProject ?? this.notInterestedProject,
      refundedProject: refundedProject ?? this.refundedProject,
      rejectedProject: rejectedProject ?? this.rejectedProject,
      pendingProject: pendingProject ?? this.pendingProject,
      notStartedProject: notStartedProject ?? this.notStartedProject,
    );
  }

  int countFor(List<ProjectStatus> list) {
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (sum, item) => sum + item.count);
  }

  int statusIdFor(List<ProjectStatus> list, int fallback) {
    if (list.isEmpty) return fallback;
    return list.first.statusId;
  }

  /// Prefer AllProject list count; fall back to TotalProject.
  int get allProjectCount {
    final fromList = countFor(allProject);
    if (fromList > 0) return fromList;
    return totalProject;
  }

  int get totalTasks =>
      pendingTask + inProgressTask + completedTask + cancelledTask;

  static List<ProjectStatus> _statusList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => ProjectStatus.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [
        totalProject,
        pendingTask,
        completedTask,
        inProgressTask,
        cancelledTask,
        allProject,
        completedProject,
        notInterestedProject,
        refundedProject,
        rejectedProject,
        pendingProject,
        notStartedProject,
      ];
}
