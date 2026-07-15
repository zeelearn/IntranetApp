import 'package:equatable/equatable.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';

/// Navigation / binding args for [AddTaskScreen] (create or edit).
class AddTaskArgs extends Equatable {
  const AddTaskArgs({
    required this.projectId,
    required this.userId,
    required this.projectName,
    this.parentTaskId = '0',
    this.parentTaskName = '',
    this.contributionId = 0,
    this.taskId = 0,
    this.mtaskId = 0,
    this.seedTask,
    this.parentOptions = const [],
    this.assigneeOptions = const [],
    this.defaultAssignee = '',
  });

  final String projectId;
  final int userId;
  final String projectName;
  final String parentTaskId;
  final String parentTaskName;
  final int contributionId;

  /// `0` = create, `> 0` = edit (future).
  final int taskId;
  final int mtaskId;
  final HierarchyTask? seedTask;
  final List<HierarchyTask> parentOptions;
  final List<String> assigneeOptions;
  final String defaultAssignee;

  /// Create when [taskId] is 0 and no seed; Edit when seeded or taskId > 0.
  bool get isEditMode => taskId > 0 || seedTask != null;

  @override
  List<Object?> get props => [
        projectId,
        userId,
        parentTaskId,
        contributionId,
        taskId,
      ];
}

/// Payload for `POST /api/bp/AddNewTask`.
class AddTaskRequest extends Equatable {
  const AddTaskRequest({
    required this.taskId,
    required this.mtaskId,
    required this.projectId,
    required this.title,
    required this.note,
    required this.startDate,
    required this.endDate,
    required this.planStartDate,
    required this.planEndDate,
    required this.status,
    required this.parentTaskId,
    required this.userId,
    this.formUrl = '',
    this.dependentTaskId = 0,
    this.contributionId = 0,
  });

  final int taskId;
  final int mtaskId;
  final String projectId;
  final String title;
  final String note;
  final String startDate;
  final String endDate;
  final String planStartDate;
  final String planEndDate;
  final int status;
  final String formUrl;
  final String parentTaskId;
  final int dependentTaskId;
  final int contributionId;
  final int userId;

  Map<String, dynamic> toJson() => {
        'taskid': taskId,
        'mtask_id': mtaskId,
        'project_id': projectId,
        'title': title,
        'note': note,
        'start_date': startDate,
        'end_date': endDate,
        'p_start_date': planStartDate,
        'p_end_date': planEndDate,
        'status': status,
        'formurl': formUrl,
        'parent_task_id': parentTaskId,
        'dependent_task_id': dependentTaskId,
        'contribution_id': contributionId,
        'User_id': userId,
      };

  factory AddTaskRequest.fromJson(Map<String, dynamic> json) {
    return AddTaskRequest(
      taskId: _int(json['taskid']),
      mtaskId: _int(json['mtask_id']),
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      planStartDate: json['p_start_date']?.toString() ?? '',
      planEndDate: json['p_end_date']?.toString() ?? '',
      status: _int(json['status']),
      formUrl: json['formurl']?.toString() ?? '',
      parentTaskId: json['parent_task_id']?.toString() ?? '0',
      dependentTaskId: _int(json['dependent_task_id']),
      contributionId: _int(json['contribution_id']),
      userId: _int(json['User_id']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [taskId, projectId, title, parentTaskId, userId];
}

class AddTaskResult extends Equatable {
  const AddTaskResult({
    required this.success,
    required this.savedOffline,
    this.message = '',
  });

  final bool success;
  final bool savedOffline;
  final String message;

  @override
  List<Object?> get props => [success, savedOffline, message];
}

/// Status chip options shown on the form (API `status` int).
class TaskFormStatusOption {
  const TaskFormStatusOption({
    required this.id,
    required this.code,
    required this.label,
  });

  final int id;
  final String code;
  final String label;

  /// Matches existing payload samples: Pending default = 1.
  static const pending = TaskFormStatusOption(id: 1, code: 'P', label: 'Pending');
  static const inProgress =
      TaskFormStatusOption(id: 2, code: 'IP', label: 'In Progress');
  static const completed =
      TaskFormStatusOption(id: 3, code: 'C', label: 'Completed');
  static const bpCompleted =
      TaskFormStatusOption(id: 4, code: 'BPC', label: 'BP Completed');

  static const all = [pending, inProgress, completed, bpCompleted];
}

class TaskFormPriority {
  static const low = 'Low';
  static const medium = 'Medium';
  static const high = 'High';
  static const all = [low, medium, high];
}

/// Local attachment selected via camera / gallery / file picker.
class TaskAttachmentFile extends Equatable {
  const TaskAttachmentFile({
    required this.name,
    required this.sizeBytes,
    this.path = '',
    this.extension = '',
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String extension;

  static const maxBytes = 10 * 1024 * 1024; // 10MB
  static const allowedExtensions = {
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  };

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage {
    final e = extension.toLowerCase();
    return e == 'jpg' || e == 'jpeg' || e == 'png';
  }

  bool get isPdf => extension.toLowerCase() == 'pdf';

  @override
  List<Object?> get props => [name, path, sizeBytes];
}
