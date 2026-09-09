import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_employee_picker.dart';

class ReassignmentPreviewPanel extends StatelessWidget {
  const ReassignmentPreviewPanel({
    super.key,
    required this.controller,
    this.shrinkWrap = false,
  });

  final ProjectConfigurationController controller;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Obx(_buildContent);
  }

  Widget _buildContent() {
    final selectedIds = controller.selectedProjectIds.toList(growable: false);
    final _ = controller.sourceProjects.length;
    final selectedCount = selectedIds.length;
    final source = controller.sourceEmployee.value;
    final target = controller.targetEmployee.value;
    final error = controller.sameEmployeeError ?? controller.actionError.value;
    final queuedCount = controller.queuedPairs.length;

    final sourceName = source?.employeeFullName.trim() ?? '—';
    final targetName = target?.employeeFullName.trim() ?? '—';

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to',
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
        const SizedBox(height: 12),
        ReassignmentEmployeePicker(
          key: const ValueKey('target-employee-picker'),
          label: 'New employee',
          hint: 'Search by name, code, or designation',
          employees: List<EmployeeInfo>.from(controller.employees),
          selected: target,
          onQueryChanged: (query) => controller.targetQuery.value = query,
          onSelected: controller.selectTarget,
          onCleared: controller.clearTarget,
          filterEmployees: controller.filterTargetEmployees,
          showAvailabilityBadge: true,
          showSelectedCard: false,
        ),
        const SizedBox(height: 12),
        Text(
          'Task status',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        _TaskStatusDropdown(
          value: controller.taskStatusFilter.value,
          onChanged: controller.setTaskStatusFilter,
        ),
        if (error != null) ...[
          const SizedBox(height: 10),
          _ErrorBanner(message: error),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DashboardColors.scaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Current', value: sourceName),
              _SummaryRow(label: 'New', value: targetName),
              _SummaryRow(
                label: 'Projects',
                value: selectedCount == 0
                    ? 'None selected'
                    : '$selectedCount selected',
              ),
              _SummaryRow(
                label: 'Task status',
                value: controller.taskStatusFilter.value.label,
              ),
              _SummaryRow(
                label: 'Draft',
                value: '$queuedCount',
              ),
              if (selectedCount > 0 && target != null) ...[
                const SizedBox(height: 8),
                Text(
                  '$selectedCount project${selectedCount == 1 ? '' : 's'} will move from $sourceName to $targetName.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.35,
                    color: DashboardColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (shrinkWrap) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SingleChildScrollView(child: body)),
      ],
    );
  }
}

class _TaskStatusDropdown extends StatelessWidget {
  const _TaskStatusDropdown({
    required this.value,
    required this.onChanged,
  });

  final TaskStatusFilter value;
  final ValueChanged<TaskStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskStatusFilter>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DashboardColors.primary),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: DashboardColors.textDark,
      ),
      items: [
        for (final option in TaskStatusFilter.values)
          DropdownMenuItem(
            value: option,
            child: Text(option.label),
          ),
      ],
      onChanged: (selected) {
        if (selected == null) return;
        onChanged(selected);
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textDark,
              ),
            ),
          ),
        ],
      ),
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
