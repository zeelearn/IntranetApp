import 'package:get/get.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/repositories/project_reassignment_repository.dart';

/// Task status choice under Assign to (not used to filter the project list).
/// API `task_status`: 0 = all, 1 = Pending, 2 = In Progress.
enum TaskStatusFilter {
  all,
  pending,
  inProgress,
}

extension TaskStatusFilterLabel on TaskStatusFilter {
  String get label {
    switch (this) {
      case TaskStatusFilter.all:
        return 'All';
      case TaskStatusFilter.pending:
        return 'Pending';
      case TaskStatusFilter.inProgress:
        return 'In Progress';
    }
  }

  /// Value sent as UpdateTaskUser `task_status`.
  int get apiValue {
    switch (this) {
      case TaskStatusFilter.all:
        return 0;
      case TaskStatusFilter.pending:
        return 1;
      case TaskStatusFilter.inProgress:
        return 2;
    }
  }
}

class ProjectConfigurationController extends GetxController {
  ProjectConfigurationController({
    required ProjectReassignmentRepository repository,
  }) : _repository = repository;

  static const sameEmployeeMessage =
      'Current and new employee cannot be the same.';
  static const selectSourceMessage = 'Choose the current employee first.';
  static const selectTargetMessage = 'Choose the new employee.';
  static const selectProjectsMessage =
      'Select at least one project to move.';
  static const noEmployeesMessage =
      'No team members are available right now.';
  static const noActiveTargetsMessage =
      'No active employees are available to assign to.';
  static const noProjectsMessage =
      'This employee has no projects to move.';
  static const duplicateQueuedMessage =
      'One or more selected projects are already in another draft.';
  static const loadFailedMessage =
      'Unable to load team members. Please try again.';
  static const inactiveTargetMessage =
      'The new employee must be active.';

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
  final RxString projectQuery = ''.obs;
  final Rx<TaskStatusFilter> taskStatusFilter = TaskStatusFilter.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString loadError = RxnString();
  final RxnString actionError = RxnString();

  /// Business_UserID used by GetMyTask / UpdateTaskUser.
  String businessUserId(EmployeeInfo employee) {
    final id = employee.employeeId.trim();
    if (id.isNotEmpty) return id;
    return employee.employeeCode.trim();
  }

  /// Stable identity for same-employee checks.
  String employeeKey(EmployeeInfo employee) => businessUserId(employee);

  bool isActiveEmployee(EmployeeInfo employee) {
    final status = employee.empAppStatus.trim().toLowerCase();
    return status == 'active' || status == 'true' || status == '1';
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

  Set<String> get queuedProjectIds {
    return {
      for (final pair in queuedPairs)
        for (final project in pair.projects) project.id,
    };
  }

  bool get hasDuplicateQueuedSelection {
    final queued = queuedProjectIds;
    return selectedProjectIds.any(queued.contains);
  }

  /// True when every loaded source task is selected (drives wildcard API row).
  bool get isAllSourceProjectsSelected {
    if (sourceProjects.isEmpty || selectedProjectIds.isEmpty) return false;
    final selected = selectedProjectIds.toSet();
    return sourceProjects.every((project) => selected.contains(project.id));
  }

  List<ReassignableProject> get selectedProjects {
    final ids = selectedProjectIds.toSet();
    return sourceProjects
        .where((project) => ids.contains(project.id))
        .toList(growable: false);
  }

  List<ReassignableProject> get filteredSourceProjects {
    final needle = projectQuery.value.trim().toLowerCase();
    if (needle.isEmpty) return List<ReassignableProject>.from(sourceProjects);
    return sourceProjects.where((project) {
      return project.name.toLowerCase().contains(needle) ||
          project.franchiseeCode.toLowerCase().contains(needle) ||
          project.catchmentArea.toLowerCase().contains(needle) ||
          project.status.toLowerCase().contains(needle) ||
          project.ownerName.toLowerCase().contains(needle) ||
          project.sopName.toLowerCase().contains(needle) ||
          project.taskCount.toLowerCase().contains(needle) ||
          project.projectId.toLowerCase().contains(needle) ||
          project.teamLabels.any((label) => label.toLowerCase().contains(needle));
    }).toList(growable: false);
  }

  void setTaskStatusFilter(TaskStatusFilter filter) {
    taskStatusFilter.value = filter;
  }

  /// Why the current pair cannot be queued (null when valid).
  String? get queueValidationError {
    if (employees.isEmpty) return noEmployeesMessage;
    if (sourceEmployee.value == null) return selectSourceMessage;
    if (sourceProjects.isEmpty) return noProjectsMessage;
    if (selectedProjectIds.isEmpty) return selectProjectsMessage;
    if (targetEmployee.value == null) return selectTargetMessage;
    if (!isActiveEmployee(targetEmployee.value!)) return inactiveTargetMessage;
    if (sameEmployeeError != null) return sameEmployeeError;
    if (hasDuplicateQueuedSelection) return duplicateQueuedMessage;
    return null;
  }

  /// Why submit is blocked (null when submit is allowed).
  String? get submitValidationError {
    if (isSubmitting.value) {
      return 'A transfer is already in progress.';
    }
    if (queuedPairs.isNotEmpty) return null;
    return queueValidationError;
  }

  bool get canQueueCurrentPair => queueValidationError == null;

  bool get canSubmit {
    if (isSubmitting.value) return false;
    if (queuedPairs.isNotEmpty) return true;
    return canQueueCurrentPair;
  }

  List<EmployeeInfo> get filteredSourceEmployees =>
      filterSourceEmployees(sourceQuery.value);

  List<EmployeeInfo> get filteredTargetEmployees =>
      filterTargetEmployees(targetQuery.value);

  List<EmployeeInfo> filterEmployees(String query) =>
      filterSourceEmployees(query);

  List<EmployeeInfo> filterSourceEmployees(String query) {
    return _filterEmployees(employees, query);
  }

  /// Target dropdown: active employees only.
  List<EmployeeInfo> filterTargetEmployees(String query) {
    final active = employees.where(isActiveEmployee).toList(growable: false);
    return _filterEmployees(active, query);
  }

  List<EmployeeInfo> _filterEmployees(
    List<EmployeeInfo> source,
    String query,
  ) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return List<EmployeeInfo>.from(source);
    return source.where((employee) {
      return employee.employeeFullName.toLowerCase().contains(needle) ||
          employee.employeeCode.toLowerCase().contains(needle) ||
          employee.employeeId.toLowerCase().contains(needle) ||
          employee.employeeDesignation.toLowerCase().contains(needle) ||
          employee.display.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    actionError.value = null;
    try {
      final list = await _repository.listEmployees();
      employees.assignAll(list);
      if (list.isEmpty) {
        loadError.value = noEmployeesMessage;
      } else if (list.every((e) => !isActiveEmployee(e))) {
        loadError.value = noActiveTargetsMessage;
      }
    } on DashboardFailure catch (e) {
      employees.clear();
      loadError.value = e.message;
    } catch (_) {
      employees.clear();
      loadError.value = loadFailedMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectsForSource() async {
    final source = sourceEmployee.value;
    selectedProjectIds.clear();
    projectQuery.value = '';
    actionError.value = null;
    if (source == null) {
      sourceProjects.clear();
      return;
    }
    isLoadingProjects.value = true;
    try {
      sourceProjects.assignAll(
        await _repository.listProjectsForEmployee(businessUserId(source)),
      );
      if (sourceProjects.isEmpty) {
        actionError.value = noProjectsMessage;
      }
    } on DashboardFailure catch (e) {
      sourceProjects.clear();
      actionError.value = e.message;
    } catch (_) {
      sourceProjects.clear();
      actionError.value = 'Unable to load projects for this employee.';
    } finally {
      isLoadingProjects.value = false;
    }
  }

  Future<void> selectSourceAndLoad(EmployeeInfo employee) async {
    selectSource(employee);
    await loadProjectsForSource();
  }

  void selectSource(EmployeeInfo employee) {
    sourceEmployee.value = employee;
    sourceProjects.clear();
    selectedProjectIds.clear();
    projectQuery.value = '';
    actionError.value = null;
  }

  void selectTarget(EmployeeInfo employee) {
    if (!isActiveEmployee(employee)) {
      actionError.value = inactiveTargetMessage;
      return;
    }
    targetEmployee.value = employee;
    actionError.value = null;
  }

  void clearSource() {
    sourceEmployee.value = null;
    sourceProjects.clear();
    selectedProjectIds.clear();
    sourceQuery.value = '';
    projectQuery.value = '';
    taskStatusFilter.value = TaskStatusFilter.all;
    actionError.value = null;
  }

  void clearTarget() {
    targetEmployee.value = null;
    targetQuery.value = '';
    actionError.value = null;
  }

  void toggleProject(String projectId) {
    if (queuedProjectIds.contains(projectId)) {
      actionError.value = duplicateQueuedMessage;
      return;
    }
    actionError.value = null;
    if (selectedProjectIds.contains(projectId)) {
      selectedProjectIds.remove(projectId);
    } else {
      selectedProjectIds.add(projectId);
    }
  }

  void selectAllProjects() {
    final visible = filteredSourceProjects;
    final queued = queuedProjectIds;
    selectedProjectIds.assignAll(
      visible
          .where((project) => !queued.contains(project.id))
          .map((project) => project.id),
    );
    if (visible.any((project) => queued.contains(project.id))) {
      actionError.value = duplicateQueuedMessage;
    } else {
      actionError.value = null;
    }
  }

  void toggleSelectAllProjects() {
    final visible = filteredSourceProjects;
    if (visible.isEmpty) return;
    final queued = queuedProjectIds;
    final selectable =
        visible.where((project) => !queued.contains(project.id)).toList();
    if (selectable.isEmpty) {
      actionError.value = duplicateQueuedMessage;
      return;
    }
    final allSelected = selectable.every(
      (project) => selectedProjectIds.contains(project.id),
    );
    if (allSelected) {
      for (final project in selectable) {
        selectedProjectIds.remove(project.id);
      }
      actionError.value = null;
    } else {
      selectAllProjects();
    }
  }

  bool queueCurrentPair() {
    final error = queueValidationError;
    if (error != null) {
      actionError.value = error;
      return false;
    }
    final pair = _buildCurrentPair();
    if (pair == null) {
      actionError.value = selectProjectsMessage;
      return false;
    }
    queuedPairs.add(pair);
    _clearCurrentSelection();
    actionError.value = null;
    return true;
  }

  void removeQueuedPair(int index) {
    if (index < 0 || index >= queuedPairs.length) return;
    queuedPairs.removeAt(index);
    actionError.value = null;
  }

  Future<bool> submit() async {
    final error = submitValidationError;
    if (error != null) {
      actionError.value = error;
      return false;
    }
    final pairs = _pairsToSubmit();
    if (pairs.isEmpty) {
      actionError.value = selectProjectsMessage;
      return false;
    }
    isSubmitting.value = true;
    actionError.value = null;
    try {
      await _repository.submitMassReassignment(pairs);
      queuedPairs.clear();
      _clearCurrentSelection();
      return true;
    } on DashboardFailure catch (e) {
      actionError.value = e.message;
      return false;
    } on Exception catch (e) {
      actionError.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } on Error catch (e) {
      actionError.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  int get submitProjectCount {
    return pairsForSubmit.fold<int>(0, (sum, pair) {
      if (pair.reassignAll) {
        // Unknown exact count once wildcard is used; fall back to listed size.
        return sum + (pair.projects.isEmpty ? 1 : pair.projects.length);
      }
      return sum + pair.projects.length;
    });
  }

  List<ReassignmentPair> get pairsForSubmit {
    final pairs = List<ReassignmentPair>.from(queuedPairs);
    final current = _buildCurrentPair();
    if (current != null) {
      pairs.add(current);
    }
    return pairs;
  }

  List<ReassignmentPair> _pairsToSubmit() => pairsForSubmit;

  ReassignmentPair? _buildCurrentPair() {
    if (queueValidationError != null) return null;
    final selected = selectedProjects;
    if (selected.isEmpty) return null;
    return ReassignmentPair(
      source: sourceEmployee.value!,
      target: targetEmployee.value!,
      projects: selected,
      reassignAll: isAllSourceProjectsSelected,
      taskStatus: taskStatusFilter.value.apiValue,
    );
  }

  void _clearCurrentSelection() {
    clearSource();
    clearTarget();
  }
}
