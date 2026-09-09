class ReassignableProject {
  const ReassignableProject({
    required this.id,
    required this.name,
    required this.status,
    required this.teamLabels,
    required this.ownerId,
    required this.ownerName,
    this.sopName = '',
    this.franchiseeCode = '',
    this.taskCount = '',
    this.catchmentArea = '',
    this.projectId = '',
    this.taskId = 0,
  });

  /// Unique row key for UI selection (usually [projectId]).
  final String id;
  final String name;
  /// Optional; GetMyTask project rows may leave this empty.
  final String status;
  final List<String> teamLabels;
  final String ownerId;
  final String ownerName;

  final String sopName;
  final String franchiseeCode;
  final String taskCount;
  final String catchmentArea;

  /// API `project_id` for UpdateTaskUser.
  final String projectId;

  /// API `task_id` for UpdateTaskUser.
  final int taskId;

  ReassignableProject copyWith({
    String? id,
    String? name,
    String? status,
    List<String>? teamLabels,
    String? ownerId,
    String? ownerName,
    String? sopName,
    String? franchiseeCode,
    String? taskCount,
    String? catchmentArea,
    String? projectId,
    int? taskId,
  }) {
    return ReassignableProject(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      teamLabels: teamLabels ?? this.teamLabels,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      sopName: sopName ?? this.sopName,
      franchiseeCode: franchiseeCode ?? this.franchiseeCode,
      taskCount: taskCount ?? this.taskCount,
      catchmentArea: catchmentArea ?? this.catchmentArea,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
    );
  }
}
