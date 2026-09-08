import 'package:get/get.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';

class ProjectConfigurationController extends GetxController {
  ProjectConfigurationController({
    required ProjectReassignmentRepository repository,
  }) : _repository = repository;

  static const sameEmployeeMessage =
      'Source and target employee cannot be the same.';

  final ProjectReassignmentRepository _repository;

  final RxList<EmployeeInfo> employees = <EmployeeInfo>[].obs;
  final RxList<ReassignableProject> sourceProjects =
      <ReassignableProject>[].obs;
  final RxList<String> selectedProjectIds = <String>[].obs;
  final Rxn<EmployeeInfo> sourceEmployee = Rxn<EmployeeInfo>();
  final Rxn<EmployeeInfo> targetEmployee = Rxn<EmployeeInfo>();
  final RxList<ReassignmentPair> queuedPairs = <ReassignmentPair>[].obs;
  final RxString sourceQuery = ''.obs;
  final RxString targetQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  String employeeKey(EmployeeInfo employee) {
    final code = employee.employeeCode.trim();
    if (code.isNotEmpty) return code;
    return employee.employeeId.trim();
  }

  String? get sameEmployeeError {
    final source = sourceEmployee.value;
    final target = targetEmployee.value;
    if (source == null || target == null) return null;
    final sourceKey = employeeKey(source);
    final targetKey = employeeKey(target);
    if (sourceKey.isEmpty || targetKey.isEmpty) return null;
    if (sourceKey == targetKey) return sameEmployeeMessage;
    return null;
  }

  bool get canQueueCurrentPair {
    if (sourceEmployee.value == null || targetEmployee.value == null) {
      return false;
    }
    if (sameEmployeeError != null) return false;
    return sourceProjects.any(
      (project) => selectedProjectIds.contains(project.id),
    );
  }

  bool get canSubmit => queuedPairs.isNotEmpty || canQueueCurrentPair;

  List<EmployeeInfo> get filteredSourceEmployees =>
      filterEmployees(sourceQuery.value);

  List<EmployeeInfo> get filteredTargetEmployees =>
      filterEmployees(targetQuery.value);

  List<EmployeeInfo> filterEmployees(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return List<EmployeeInfo>.from(employees);
    return employees.where((employee) {
      return employee.employeeFullName.toLowerCase().contains(needle) ||
          employee.employeeCode.toLowerCase().contains(needle) ||
          employee.employeeId.toLowerCase().contains(needle) ||
          employee.employeeDesignation.toLowerCase().contains(needle) ||
          employee.display.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      employees.assignAll(await _repository.listEmployees());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectsForSource() async {
    final source = sourceEmployee.value;
    selectedProjectIds.clear();
    if (source == null) {
      sourceProjects.clear();
      return;
    }
    sourceProjects.assignAll(
      await _repository.listProjectsForEmployee(employeeKey(source)),
    );
  }

  void selectSource(EmployeeInfo employee) {
    sourceEmployee.value = employee;
    sourceProjects.clear();
    selectedProjectIds.clear();
  }

  void selectTarget(EmployeeInfo employee) {
    targetEmployee.value = employee;
  }

  void clearSource() {
    sourceEmployee.value = null;
    sourceProjects.clear();
    selectedProjectIds.clear();
    sourceQuery.value = '';
  }

  void clearTarget() {
    targetEmployee.value = null;
    targetQuery.value = '';
  }

  void toggleProject(String projectId) {
    if (selectedProjectIds.contains(projectId)) {
      selectedProjectIds.remove(projectId);
    } else {
      selectedProjectIds.add(projectId);
    }
  }

  void selectAllProjects() {
    selectedProjectIds.assignAll(
      sourceProjects.map((project) => project.id),
    );
  }

  void toggleSelectAllProjects() {
    if (sourceProjects.isEmpty) return;
    final allSelected = sourceProjects.every(
      (project) => selectedProjectIds.contains(project.id),
    );
    if (allSelected) {
      selectedProjectIds.clear();
    } else {
      selectAllProjects();
    }
  }

  void queueCurrentPair() {
    final pair = _buildCurrentPair();
    if (pair == null) return;
    queuedPairs.add(pair);
    _clearCurrentSelection();
  }

  Future<bool> submit() async {
    if (!canSubmit) return false;
    final pairs = _pairsToSubmit();
    if (pairs.isEmpty) return false;
    isSubmitting.value = true;
    try {
      await _repository.submitMassReassignment(pairs);
      queuedPairs.clear();
      _clearCurrentSelection();
      return true;
    } on Exception {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  List<ReassignmentPair> _pairsToSubmit() {
    final pairs = List<ReassignmentPair>.from(queuedPairs);
    final current = _buildCurrentPair();
    if (current != null) {
      pairs.add(current);
    }
    return pairs;
  }

  ReassignmentPair? _buildCurrentPair() {
    if (!canQueueCurrentPair) return null;
    final selected = sourceProjects
        .where((project) => selectedProjectIds.contains(project.id))
        .toList(growable: false);
    if (selected.isEmpty) return null;
    return ReassignmentPair(
      source: sourceEmployee.value!,
      target: targetEmployee.value!,
      projects: selected,
    );
  }

  void _clearCurrentSelection() {
    clearSource();
    clearTarget();
  }
}
