import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/add_task_binding.dart';
import 'package:Intranet/modules/projects/controllers/add_task_controller.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/add_task_form_widgets.dart';

/// Create / Edit Task screen (Material 3, Figma-aligned).
class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key, required this.args});

  final AddTaskArgs args;

  static Future<AddTaskResult?> open(AddTaskArgs args) async {
    return Get.to<AddTaskResult>(
      () => AddTaskScreen(args: args),
      binding: AddTaskBinding(args: args),
      arguments: args,
    );
  }

  String get _tag => AddTaskBinding.makeTag(args);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AddTaskController>(tag: _tag)) {
      AddTaskBinding(args: args).dependencies();
    }
    final controller = Get.find<AddTaskController>(tag: _tag);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          _Header(
            title: controller.screenTitle,
            busy: false,
            onClose: () => Get.back(result: null),
            onSave: () => _save(controller),
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 32 : 16,
                    16,
                    wide ? 32 : 16,
                    24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Obx(() {
                        // Subscribe to reactive field errors / selections.
                        final status = controller.statusId.value;
                        final priority = controller.priority.value;
                        final parentName = controller.parentTaskName.value;
                        final person = controller.responsiblePerson.value;
                        final plans = controller.planStart.value;
                        final plane = controller.planEnd.value;
                        final acts = controller.actualStart.value;
                        final acte = controller.actualEnd.value;
                        final titleErr = controller.titleError.value;
                        final noteErr = controller.noteError.value;
                        final dateErr = controller.dateError.value;
                        final formErr = controller.formError.value;
                        final isEdit = controller.isEditMode;

                        final dateRow = wide
                            ? _DateGridWide(
                                controller: controller,
                                isEditMode: isEdit,
                                planStart: plans,
                                planEnd: plane,
                                actualStart: acts,
                                actualEnd: acte,
                              )
                            : _DateGridMobile(
                                controller: controller,
                                isEditMode: isEdit,
                                planStart: plans,
                                planEnd: plane,
                                actualStart: acts,
                                actualEnd: acte,
                              );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TaskSelectorCard(
                              label: 'Parent Task',
                              value: parentName,
                              placeholder: 'Select a parent task',
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: DashboardColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  parentName.isEmpty
                                      ? Icons.folder_outlined
                                      : Icons.account_tree_outlined,
                                  color: DashboardColors.primary,
                                ),
                              ),
                              onTap: () => _pickParent(context, controller),
                            ),
                            const SizedBox(height: 16),
                            const TaskSectionLabel('Task Title', required: true),
                            TaskTextField(
                              controller: controller.titleController,
                              hint: 'Enter task title',
                              errorText: titleErr,
                              enabled: !isEdit,
                              readOnly: isEdit,
                              suffix: const Icon(
                                Icons.bookmark_border_rounded,
                                color: DashboardColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const TaskSectionLabel('Status', required: true),
                            TaskStatusChips(
                              selectedId: status,
                              onSelected: controller.selectStatus,
                            ),
                            const SizedBox(height: 16),
                            dateRow,
                            if (dateErr != null) ValidationMessage(dateErr),
                            if (!isEdit) ...[
                              const SizedBox(height: 16),
                              const TaskSectionLabel(
                                'Responsible Person',
                                required: true,
                              ),
                              TaskSelectorCard(
                                label: 'Assignee',
                                value: person,
                                placeholder: 'Select person',
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DashboardColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: DashboardColors.primary,
                                  ),
                                ),
                                onTap: () =>
                                    _pickAssignee(context, controller),
                              ),
                              const SizedBox(height: 16),
                              const TaskSectionLabel('Priority'),
                              TaskPriorityChips(
                                selected: priority,
                                onSelected: controller.selectPriority,
                              ),
                            ],
                            const SizedBox(height: 16),
                            const TaskSectionLabel(
                              'Description',
                              required: true,
                            ),
                            TaskTextField(
                              controller: controller.noteController,
                              hint: 'Enter description (optional)',
                              maxLines: 4,
                              maxLength: 500,
                              errorText: noteErr,
                            ),
                            //const SizedBox(height: 16),
                            //const TaskSectionLabel('Attachments'),
                            // TaskAttachmentBox(
                            //   files: files,
                            //   busy: picking,
                            //   errorText: attachErr,
                            //   onBrowse: () =>
                            //       _showAttachmentSheet(context, controller),
                            //   onRemove: controller.removeAttachment,
                            // ),
                            if (formErr != null) ...[
                              const SizedBox(height: 12),
                              ValidationMessage(formErr),
                            ],
                            const SizedBox(height: 24),
                            Text(
                              'Project: ${args.projectName}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: DashboardColors.textMuted,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Obx(() {
                  if (!controller.isSaving.value) {
                    return const SizedBox.shrink();
                  }
                  return const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: DashboardColors.primary,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(
            () => TaskBottomActionBar(
              primaryLabel: controller.isEditMode ? 'Update Task' : 'Save Task',
              busy: controller.isSaving.value,
              onPrimary: () => _save(controller),
              onCancel: () => Get.back(result: null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(AddTaskController controller) async {
    final result = await controller.saveTask();
    if (result != null && result.success) {
      Get.back(result: result);
    }
  }

  Future<void> _showAttachmentSheet(
    BuildContext context,
    AddTaskController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Attachment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined,
                      color: DashboardColors.primary),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: DashboardColors.primary),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose images'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file_rounded,
                      color: DashboardColors.primary),
                  title: const Text('Files'),
                  subtitle: const Text('PDF, DOC, DOCX, JPG, PNG'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controller.pickFromFiles();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickParent(
    BuildContext context,
    AddTaskController controller,
  ) async {
    final options = args.parentOptions;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.55,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Parent Task',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all_rounded),
                  title: const Text('Root task (no parent)'),
                  onTap: () {
                    controller.selectParent(null);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final t = options[i];
                      return ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(t.title.isEmpty ? 'Untitled' : t.title),
                        subtitle: Text('ID: ${t.id}'),
                        onTap: () {
                          controller.selectParent(t);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAssignee(
    BuildContext context,
    AddTaskController controller,
  ) async {
    final people = args.assigneeOptions;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        if (people.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No assignees found in this project',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      controller.selectResponsible(v.trim());
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Responsible Person',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final p in people)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(p),
                  onTap: () {
                    controller.selectResponsible(p);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onClose,
    required this.onSave,
    required this.busy,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onSave;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: busy ? null : onSave,
              icon: const Icon(Icons.save_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateGridMobile extends StatelessWidget {
  const _DateGridMobile({
    required this.controller,
    required this.isEditMode,
    required this.planStart,
    required this.planEnd,
    required this.actualStart,
    required this.actualEnd,
  });

  final AddTaskController controller;
  final bool isEditMode;
  final DateTime? planStart;
  final DateTime? planEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isEditMode) ...[
          Row(
            children: [
              Expanded(
                child: TaskDateField(
                  label: 'Plan Start Date',
                  value: planStart,
                  enabled: controller.planDatesEnabled,
                  onTap: () => controller.pickDate(
                    context: context,
                    target: controller.planStart,
                    enabled: controller.planDatesEnabled,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TaskDateField(
                  label: 'Plan End Date',
                  value: planEnd,
                  enabled: controller.planDatesEnabled,
                  onTap: () => controller.pickDate(
                    context: context,
                    target: controller.planEnd,
                    enabled: controller.planDatesEnabled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TaskDateField(
                label: 'Actual Start Date',
                value: actualStart,
                enabled: controller.actualDatesEnabled,
                onTap: () => controller.pickDate(
                  context: context,
                  target: controller.actualStart,
                  enabled: controller.actualDatesEnabled,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TaskDateField(
                label: 'Actual End Date',
                value: actualEnd,
                enabled: controller.actualDatesEnabled,
                onTap: () => controller.pickDate(
                  context: context,
                  target: controller.actualEnd,
                  enabled: controller.actualDatesEnabled,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateGridWide extends StatelessWidget {
  const _DateGridWide({
    required this.controller,
    required this.isEditMode,
    required this.planStart,
    required this.planEnd,
    required this.actualStart,
    required this.actualEnd,
  });

  final AddTaskController controller;
  final bool isEditMode;
  final DateTime? planStart;
  final DateTime? planEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditMode) ...[
          Expanded(
            child: TaskDateField(
              label: 'Plan Start Date',
              value: planStart,
              enabled: controller.planDatesEnabled,
              onTap: () => controller.pickDate(
                context: context,
                target: controller.planStart,
                enabled: controller.planDatesEnabled,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TaskDateField(
              label: 'Plan End Date',
              value: planEnd,
              enabled: controller.planDatesEnabled,
              onTap: () => controller.pickDate(
                context: context,
                target: controller.planEnd,
                enabled: controller.planDatesEnabled,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: TaskDateField(
            label: 'Actual Start Date',
            value: actualStart,
            enabled: controller.actualDatesEnabled,
            onTap: () => controller.pickDate(
              context: context,
              target: controller.actualStart,
              enabled: controller.actualDatesEnabled,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TaskDateField(
            label: 'Actual End Date',
            value: actualEnd,
            enabled: controller.actualDatesEnabled,
            onTap: () => controller.pickDate(
              context: context,
              target: controller.actualEnd,
              enabled: controller.actualDatesEnabled,
            ),
          ),
        ),
      ],
    );
  }
}
