import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';

class ReassignmentPair {
  const ReassignmentPair({
    required this.source,
    required this.target,
    required this.projects,
  });

  final EmployeeInfo source;
  final EmployeeInfo target;
  final List<ReassignableProject> projects;
}
