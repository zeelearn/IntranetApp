import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';

abstract class ProjectReassignmentRepository {
  Future<List<EmployeeInfo>> listEmployees();

  Future<List<ReassignableProject>> listProjectsForEmployee(String employeeKey);

  Future<void> submitMassReassignment(List<ReassignmentPair> pairs);
}
