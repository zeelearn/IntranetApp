import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_employee_picker.dart';

class ReassignmentPreviewPanel extends StatelessWidget {
  const ReassignmentPreviewPanel({
    super.key,
    required this.controller,
    this.shrinkWrap = false,
  });

  final ProjectConfigurationController controller;
  final bool shrinkWrap;

  List<ReassignableProject> _selectedProjects() {
    final ids = controller.selectedProjectIds.toSet();
    return controller.sourceProjects
        .where((project) => ids.contains(project.id))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(_buildContent);
  }

  Widget _buildContent() {
    final selectedProjects = _selectedProjects();
    final source = controller.sourceEmployee.value;
    final target = controller.targetEmployee.value;
    final error = controller.sameEmployeeError;
    final queued = controller.queuedPairs;

    final sourceName = source?.employeeFullName.trim() ?? 'source';
    final targetName = target?.employeeFullName.trim() ?? 'destination';
    final summary = selectedProjects.isEmpty
        ? queued.isEmpty
            ? 'Select projects and a destination employee to preview assignments.'
            : '${queued.length} assignment pair${queued.length == 1 ? '' : 's'} queued.'
        : '${selectedProjects.length} project${selectedProjects.length == 1 ? '' : 's'} selected • Will be reassigned from $sourceName → $targetName.';

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Destination & Confirm',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose who should receive the selected projects.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: DashboardColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ReassignmentEmployeePicker(
          label: 'Target employee',
          hint: 'Search by name, code, or designation',
          employees: controller.employees,
          selected: target,
          onQueryChanged: (query) => controller.targetQuery.value = query,
          onSelected: controller.selectTarget,
          onCleared: controller.clearTarget,
          filterEmployees: controller.filterEmployees,
          showAvailabilityBadge: true,
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: error),
        ],
        const SizedBox(height: 16),
        Text(
          'Assignments to create',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        if (selectedProjects.isEmpty && queued.isEmpty)
          _PreviewEmpty()
        else ...[
          for (final project in selectedProjects)
            _AssignmentTile(
              title: project.name,
              subtitle: '$sourceName → $targetName',
            ),
          if (queued.isNotEmpty) ...[
            if (selectedProjects.isNotEmpty) const SizedBox(height: 8),
            Text(
              'Queued pairs',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final pair in queued)
              _AssignmentTile(
                title:
                    '${pair.source.employeeFullName} → ${pair.target.employeeFullName}',
                subtitle:
                    '${pair.projects.length} project${pair.projects.length == 1 ? '' : 's'}',
              ),
          ],
        ],
        const SizedBox(height: 16),
        Text(
          summary,
          style: GoogleFonts.poppins(
            fontSize: 12,
            height: 1.4,
            color: DashboardColors.textMuted,
          ),
        ),
      ],
    );

    if (shrinkWrap) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(child: body),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DashboardColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DashboardColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: DashboardColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        'No assignments yet. Select a source, projects, and a different target.',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: DashboardColors.textMuted,
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.swap_horiz_rounded,
            size: 18,
            color: DashboardColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: DashboardColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
