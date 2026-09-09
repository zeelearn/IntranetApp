import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';

class ReassignmentPair {
  const ReassignmentPair({
    required this.source,
    required this.target,
    required this.projects,
    this.reassignAll = false,
    this.taskStatus = 0,
  });

  final EmployeeInfo source;
  final EmployeeInfo target;
  final List<ReassignableProject> projects;

  /// When true, UpdateTaskUser sends a single wildcard row
  /// (`project_id: "0"`, `task_id: 0`) instead of every selected task.
  final bool reassignAll;

  /// UpdateTaskUser `task_status`: 0 = all, 1 = Pending, 2 = In Progress.
  final int taskStatus;
}
