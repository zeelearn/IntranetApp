import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/repositories/task_repository.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

class AddTaskController extends GetxController {
  AddTaskController({
    required this.args,
    required TaskRepository repository,
    ImagePicker? imagePicker,
  })  : _repository = repository,
        _imagePicker = imagePicker ?? ImagePicker();

  final AddTaskArgs args;
  final TaskRepository _repository;
  final ImagePicker _imagePicker;

  final titleController = TextEditingController();
  final noteController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxBool isPickingFile = false.obs;
  final RxnString formError = RxnString();
  final RxnString titleError = RxnString();
  final RxnString noteError = RxnString();
  final RxnString dateError = RxnString();
  final RxnString attachmentError = RxnString();

  final RxString parentTaskId = '0'.obs;
  final RxString parentTaskName = ''.obs;
  final RxInt statusId = TaskFormStatusOption.pending.id.obs;
  final RxString priority = TaskFormPriority.medium.obs;
  final RxString responsiblePerson = ''.obs;
  final RxInt subtaskCount = 0.obs;
  final RxInt dependentTaskId = 0.obs;

  final Rxn<DateTime> planStart = Rxn<DateTime>();
  final Rxn<DateTime> planEnd = Rxn<DateTime>();
  final Rxn<DateTime> actualStart = Rxn<DateTime>();
  final Rxn<DateTime> actualEnd = Rxn<DateTime>();

  final RxList<TaskAttachmentFile> attachments = <TaskAttachmentFile>[].obs;

  bool get isEditMode => args.isEditMode;

  /// Plan dates: hidden on create; visible but disabled on edit.
  bool get showPlanDates => isEditMode;
  bool get planDatesEnabled => false;

  /// Actual dates: enabled on create and edit (saved to API).
  bool get actualDatesEnabled => true;

  String get screenTitle => isEditMode ? 'Edit Task' : 'Add New Task';

  @override
  void onInit() {
    super.onInit();
    loadArguments();
  }

  @override
  void onClose() {
    titleController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void loadArguments() {
    parentTaskId.value =
        args.parentTaskId.isEmpty ? '0' : args.parentTaskId;
    parentTaskName.value = args.parentTaskName;
    if (args.defaultAssignee.trim().isNotEmpty) {
      responsiblePerson.value = args.defaultAssignee.trim();
    }
    final seed = args.seedTask;
    if (seed != null) {
      titleController.text = seed.title;
      noteController.text = seed.note;
      priority.value =
          seed.priority.isNotEmpty ? seed.priority : TaskFormPriority.medium;
      responsiblePerson.value = seed.responsiblePerson;
      statusId.value = seed.status == 0
          ? TaskFormStatusOption.pending.id
          : seed.status;
      planStart.value = ProjectDateUtils.tryParse(seed.planStartDate);
      planEnd.value = ProjectDateUtils.tryParse(seed.dueDate);
      actualStart.value = ProjectDateUtils.tryParse(seed.startDate);
      actualEnd.value = ProjectDateUtils.tryParse(seed.endDate);
      if (!seed.isRoot) {
        parentTaskId.value = seed.parentTaskId;
      }
    }
  }

  void selectParent(HierarchyTask? task) {
    if (task == null) {
      parentTaskId.value = '0';
      parentTaskName.value = '';
      return;
    }
    parentTaskId.value = task.id;
    parentTaskName.value = task.title;
  }

  void selectStatus(int id) => statusId.value = id;

  void selectPriority(String value) => priority.value = value;

  void selectResponsible(String name) => responsiblePerson.value = name;

  void incrementSubtasks() => subtaskCount.value++;

  void decrementSubtasks() {
    if (subtaskCount.value > 0) subtaskCount.value--;
  }

  Future<void> pickDate({
    required BuildContext context,
    required Rxn<DateTime> target,
    required bool enabled,
  }) async {
    if (!enabled) return;
    final now = DateTime.now();
    final initial = target.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      target.value = picked;
      dateError.value = null;
    }
  }

  bool validateForm() {
    titleError.value = null;
    noteError.value = null;
    dateError.value = null;
    formError.value = null;

    final title = titleController.text.trim();
    final note = noteController.text.trim();
    var ok = true;

    if (title.length < 3) {
      titleError.value = 'Title must be at least 3 characters';
      ok = false;
    }
    if (note.length < 5) {
      noteError.value = 'Description must be at least 5 characters';
      ok = false;
    }

    if (isEditMode) {
      // Plan dates are read-only on edit; actual dates are editable + sent to API.
      if (actualStart.value == null || actualEnd.value == null) {
        dateError.value = 'Actual start and end dates are required';
        ok = false;
      } else if (actualEnd.value!.isBefore(actualStart.value!)) {
        dateError.value = 'Actual end date must be on or after actual start';
        ok = false;
      }
    } else {
      if (actualStart.value == null || actualEnd.value == null) {
        dateError.value = 'Actual start and end dates are required';
        ok = false;
      } else if (actualEnd.value!.isBefore(actualStart.value!)) {
        dateError.value = 'Actual end date must be on or after actual start';
        ok = false;
      }
    }

    // if (!isEditMode && responsiblePerson.value.trim().isEmpty) {
    //   formError.value = 'Please select a responsible person';
    //   ok = false;
    // }
    return ok;
  }

  AddTaskRequest buildRequest() {
    final parent = parentTaskId.value.trim().isEmpty
        ? '0'
        : parentTaskId.value.trim();

    // Create: plan dates hidden → mirror actual dates for API.
    // Edit: plan dates locked (display); actual dates editable and sent.
    final actualStartDt = actualStart.value!;
    final actualEndDt = actualEnd.value!;
    final planStartDt = isEditMode
        ? (planStart.value ?? actualStartDt)
        : actualStartDt;
    final planEndDt =
        isEditMode ? (planEnd.value ?? actualEndDt) : actualEndDt;

    final parsedTaskId = args.taskId > 0
        ? args.taskId
        : (int.tryParse(args.seedTask?.id ?? '') ?? 0);
    final parsedMTaskId = args.mtaskId > 0
        ? args.mtaskId
        : (int.tryParse(args.seedTask?.mtaskId ?? '') ?? 0);

    return AddTaskRequest(
      taskId: parsedTaskId,
      mtaskId: parsedMTaskId,
      projectId: args.projectId,
      title: titleController.text.trim(),
      note: noteController.text.trim(),
      startDate: ProjectDateUtils.formatApi(actualStartDt),
      endDate: ProjectDateUtils.formatApi(actualEndDt),
      planStartDate: ProjectDateUtils.formatApi(planStartDt),
      planEndDate: ProjectDateUtils.formatApi(planEndDt),
      status: statusId.value,
      parentTaskId: parent,
      dependentTaskId: dependentTaskId.value,
      contributionId: 3,
      userId: args.userId,
    );
  }

  Future<AddTaskResult?> saveTask() async {
    if (isSaving.value) return null;
    if (!validateForm()) return null;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isEditMode ? 'Update task?' : 'Add task?'),
        content: Text(
          isEditMode
              ? 'Are you sure you want to update this task?'
              : 'Are you sure you want to add this task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: DashboardColors.primaryFilledButton(),
            onPressed: () => Get.back(result: true),
            child: Text(isEditMode ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
    if (confirmed != true) return null;

    isSaving.value = true;
    formError.value = null;
    try {
      final AddTaskResult result;
      if (isEditMode) {
        result = await _repository.updateTaskStatus(
          request: buildUpdateRequest(),
          projectId: args.projectId,
        );
      } else {
        result = await _repository.addTask(buildRequest());
      }
      // Ensure creator is set on newly returned tasks for local edit/delete.
      final withCreator = result.task != null &&
              result.task!.taskCreatedUser.trim().isEmpty
          ? result.task!.copyWith(taskCreatedUser: args.userId.toString())
          : result.task;
      final finalResult = withCreator == result.task
          ? result
          : AddTaskResult(
              success: result.success,
              message: result.message,
              savedOffline: result.savedOffline,
              task: withCreator,
            );
      // Snackbar is shown on the listing after navigation — avoid Get.snackbar
      // here so Get.back is not consumed by the snackbar overlay.
      return finalResult;
    } on DashboardFailure catch (e) {
      formError.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFB71C1C),
        margin: const EdgeInsets.all(12),
      );
      return null;
    } catch (e) {
      formError.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFB71C1C),
        margin: const EdgeInsets.all(12),
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  UpdateTaskStatusRequest buildUpdateRequest() {
    final taskId = args.taskId > 0
        ? args.taskId.toString()
        : (args.seedTask?.id ?? '0');
    final start = actualStart.value;
    final end = actualEnd.value;
    if (start == null || end == null) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'Actual start and end dates are required.',
      );
    }
    return UpdateTaskStatusRequest(
      taskId: taskId,
      status: TaskFormStatusOption.labelForId(statusId.value),
      remark: noteController.text.trim(),
      startDate: ProjectDateUtils.formatApi(start),
      endDate: ProjectDateUtils.formatApi(end),
      userId: args.userId,
    );
  }

  void clearForm() {
    titleController.clear();
    noteController.clear();
    statusId.value = TaskFormStatusOption.pending.id;
    priority.value = TaskFormPriority.medium;
    responsiblePerson.value = '';
    subtaskCount.value = 0;
    dependentTaskId.value = 0;
    planStart.value = null;
    planEnd.value = null;
    actualStart.value = null;
    actualEnd.value = null;
    attachments.clear();
    titleError.value = null;
    noteError.value = null;
    dateError.value = null;
    formError.value = null;
    attachmentError.value = null;
    parentTaskId.value =
        args.parentTaskId.isEmpty ? '0' : args.parentTaskId;
    parentTaskName.value = args.parentTaskName;
  }

  void reset() => clearForm();

  void removeAttachment(int index) {
    if (index < 0 || index >= attachments.length) return;
    attachments.removeAt(index);
  }

  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> pickFromFiles() async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    attachmentError.value = null;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            TaskAttachmentFile.allowedExtensions.toList(growable: false),
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (result == null) return;
      for (final file in result.files) {
        await _addPickedFile(
          name: file.name,
          path: file.path ?? '',
          sizeBytes: file.size,
          extension: file.extension ?? _extFromName(file.name),
        );
      }
    } catch (e) {
      attachmentError.value = 'Unable to pick files: $e';
    } finally {
      isPickingFile.value = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    attachmentError.value = null;
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null) return;
      final name = picked.name.isNotEmpty
          ? picked.name
          : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await picked.readAsBytes();
      final size = bytes.length;
      await _addPickedFile(
        name: name,
        path: picked.path,
        sizeBytes: size,
        extension: _extFromName(name).isEmpty ? 'jpg' : _extFromName(name),
      );
    } catch (e) {
      attachmentError.value = source == ImageSource.camera
          ? 'Unable to open camera. Check permissions.'
          : 'Unable to open gallery. Check permissions.';
    } finally {
      isPickingFile.value = false;
    }
  }

  Future<void> _addPickedFile({
    required String name,
    required String path,
    required int sizeBytes,
    required String extension,
  }) async {
    final ext = extension.toLowerCase().replaceAll('.', '');
    if (!TaskAttachmentFile.allowedExtensions.contains(ext)) {
      attachmentError.value =
          'Unsupported file type.$name Use PDF, DOC, DOCX, JPG, or PNG.';
      return;
    }
    if (sizeBytes > TaskAttachmentFile.maxBytes) {
      attachmentError.value = '$name exceeds the 10MB limit.';
      return;
    }
    final already = attachments.any(
      (a) => a.name == name && a.sizeBytes == sizeBytes && a.path == path,
    );
    if (already) return;
    attachments.add(
      TaskAttachmentFile(
        name: name,
        path: path,
        sizeBytes: sizeBytes,
        extension: ext,
      ),
    );
    attachmentError.value = null;
  }

  String _extFromName(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0 || i == name.length - 1) return '';
    return name.substring(i + 1).toLowerCase();
  }
}
