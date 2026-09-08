import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/project_configuration_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/utils/projects_sidebar_roles.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_employee_picker.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_preview_panel.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_projects_table.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

class ProjectConfigurationScreen extends StatefulWidget {
  const ProjectConfigurationScreen({
    super.key,
    required this.userId,
  });

  final int userId;

  static Future<T?>? open<T>({required int userId}) {
    return Get.to<T>(
      () => ProjectConfigurationScreen(userId: userId),
      binding: ProjectConfigurationBinding(userId: userId),
    );
  }

  /// Loads employee id + role from Hive, then opens the screen for BH users.
  static Future<T?>? openFromHive<T>() async {
    final box = await Utility.openBox();
    final userType =
        (box.get(LocalConstant.KEY_EMP_TYPE)?.toString() ?? '').trim();
    final userIdRaw = box.get(LocalConstant.KEY_EMPLOYEE_ID)?.toString() ?? '';
    final userId = int.tryParse(userIdRaw) ?? 0;

    if (!ProjectsSidebarRoles.canShowConfiguration(userType)) {
      Get.snackbar(
        'Configuration',
        'Mass Project Reassignment is available only for Business Head.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return null;
    }

    return open<T>(userId: userId);
  }

  @override
  State<ProjectConfigurationScreen> createState() =>
      _ProjectConfigurationScreenState();
}

class _ProjectConfigurationScreenState
    extends State<ProjectConfigurationScreen> {
  static const double _wideBreakpoint = 900;

  late final String _tag;
  late final ProjectConfigurationController _controller;

  @override
  void initState() {
    super.initState();
    _tag = ProjectConfigurationBinding.makeTag(widget.userId);
    if (!Get.isRegistered<ProjectConfigurationController>(tag: _tag)) {
      ProjectConfigurationBinding(userId: widget.userId).dependencies();
    }
    _controller = Get.find<ProjectConfigurationController>(tag: _tag);
    _controller.load();
  }

  @override
  void dispose() {
    ProjectConfigurationBinding.deleteIfRegistered(widget.userId);
    super.dispose();
  }

  void _queuePair() {
    if (!_controller.canQueueCurrentPair) return;
    _controller.queueCurrentPair();
    Get.snackbar(
      'Assignment queued',
      'Select another source and destination to add more pairs.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DashboardColors.successLight,
      colorText: DashboardColors.textDark,
    );
  }

  Future<void> _submit() async {
    if (!_controller.canSubmit || _controller.isSubmitting.value) return;
    await _controller.submit();
    Get.snackbar(
      'Mass Reassignment',
      'Projects reassigned successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DashboardColors.successLight,
      colorText: DashboardColors.textDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          const _AppBar(),
          _Stepper(controller: _controller),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value &&
                  _controller.employees.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: DashboardColors.primary,
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _wideBreakpoint;
                  if (wide) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _SourceCard(controller: _controller)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PanelCard(
                              fill: true,
                              child: ReassignmentPreviewPanel(
                                controller: _controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        _SourceCard(controller: _controller, stacked: true),
                        const SizedBox(height: 12),
                        _PanelCard(
                          child: ReassignmentPreviewPanel(
                            controller: _controller,
                            shrinkWrap: true,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() => _FooterBar(
                queuedCount: _controller.queuedPairs.length,
                canQueue: _controller.canQueueCurrentPair,
                canSubmit: _controller.canSubmit,
                isSubmitting: _controller.isSubmitting.value,
                onQueue: _queuePair,
                onSubmit: _submit,
              )),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mass Project Reassignment',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Move projects from one employee to another',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.controller});

  final ProjectConfigurationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(_buildContent);
  }

  Widget _buildContent() {
    final hasSource = controller.sourceEmployee.value != null;
    final hasProjects = controller.selectedProjectIds.isNotEmpty;
    final hasTarget = controller.targetEmployee.value != null &&
        controller.sameEmployeeError == null;
    final canFinish =
        controller.canQueueCurrentPair || controller.queuedPairs.isNotEmpty;

    final activeIndex = canFinish
        ? 2
        : hasTarget
            ? 1
            : 0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _Step(
            number: 1,
            label: 'Select Source & Projects',
            state: hasSource && hasProjects
                ? _StepState.complete
                : activeIndex == 0
                    ? _StepState.active
                    : _StepState.upcoming,
          ),
          const _StepConnector(),
          _Step(
            number: 2,
            label: 'Select Destination & Confirm',
            state: hasTarget && hasProjects
                ? _StepState.complete
                : activeIndex == 1
                    ? _StepState.active
                    : _StepState.upcoming,
          ),
          const _StepConnector(),
          _Step(
            number: 3,
            label: 'Review & Submit',
            state: activeIndex == 2 ? _StepState.active : _StepState.upcoming,
          ),
        ],
      ),
    );
  }
}

enum _StepState { upcoming, active, complete }

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.state,
  });

  final int number;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.upcoming;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: active
                ? DashboardColors.primary
                : Colors.grey.shade300,
            child: state == _StepState.complete
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    '$number',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : DashboardColors.textMuted,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? DashboardColors.textDark
                  : DashboardColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Container(
        width: 28,
        height: 2,
        color: Colors.grey.shade300,
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child, this.fill = false});

  final Widget child;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: fill ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.controller,
    this.stacked = false,
  });

  final ProjectConfigurationController controller;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Obx(_buildContent);
  }

  Widget _buildContent() {
    final hasSource = controller.sourceEmployee.value != null;
    final table = ReassignmentProjectsTable(
      projects: controller.sourceProjects,
      selectedIds: controller.selectedProjectIds,
      onToggle: controller.toggleProject,
      onSelectAllPressed: () {
        final projects = controller.sourceProjects;
        if (projects.isEmpty) return;
        final allSelected = projects.every(
          (project) => controller.selectedProjectIds.contains(project.id),
        );
        if (allSelected) {
          controller.selectedProjectIds.clear();
        } else {
          controller.selectAllProjects();
        }
      },
      emptyTitle: hasSource ? 'No projects found' : 'Select a source employee',
      emptySubtitle: hasSource
          ? 'This employee has no mapped projects'
          : 'Mapped projects will appear here',
      shrinkWrap: stacked,
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Source & Projects',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick the employee whose projects should move.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: DashboardColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ReassignmentEmployeePicker(
          label: 'Source employee',
          hint: 'Search by name, code, or designation',
          employees: controller.employees,
          selected: controller.sourceEmployee.value,
          onQueryChanged: (query) => controller.sourceQuery.value = query,
          onSelected: (employee) {
            controller.selectSource(employee);
            controller.loadProjectsForSource();
          },
          filterEmployees: controller.filterEmployees,
        ),
        const SizedBox(height: 16),
        if (stacked) table else Expanded(child: table),
      ],
    );

    return _PanelCard(fill: !stacked, child: body);
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.queuedCount,
    required this.canQueue,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onQueue,
    required this.onSubmit,
  });

  final int queuedCount;
  final bool canQueue;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onQueue;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 720;
              final countLabel = queuedCount == 1
                  ? '1 assignment pair queued'
                  : '$queuedCount assignment pairs queued';

              final queueButton = OutlinedButton(
                onPressed: canQueue ? onQueue : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashboardColors.primary,
                  side: BorderSide(
                    color: DashboardColors.primary.withValues(alpha: 0.45),
                  ),
                  minimumSize: Size(stacked ? double.infinity : 0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Another Assignment Pair',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );

              final submitButton = FilledButton(
                onPressed: canSubmit && !isSubmitting ? onSubmit : null,
                style: DashboardColors.primaryFilledButton(
                  minimumSize: Size(stacked ? double.infinity : 0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Perform Mass Reassignment',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      countLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    queueButton,
                    const SizedBox(height: 8),
                    submitButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      countLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.textDark,
                      ),
                    ),
                  ),
                  queueButton,
                  const SizedBox(width: 8),
                  submitButton,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
