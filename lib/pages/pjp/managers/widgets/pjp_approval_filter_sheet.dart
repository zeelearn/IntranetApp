import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/pjp/managers/pjp_approval_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showPjpApprovalFilterSheet(
  BuildContext context,
  PjpApprovalController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PjpApprovalFilterSheet(controller: controller),
  );
}

class _PjpApprovalFilterSheet extends StatelessWidget {
  const _PjpApprovalFilterSheet({required this.controller});

  final PjpApprovalController controller;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                    },
                    child: const Text('Reset'),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  const _SectionTitle('Date Range'),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetChip(
                          label: 'Last Month',
                          selected:
                              controller.datePreset.value ==
                              PjpDatePreset.lastMonth,
                          onTap: () async {
                            await controller
                                .applyDatePreset(PjpDatePreset.lastMonth);
                          },
                        ),
                        _PresetChip(
                          label: 'Last 3 Months',
                          selected:
                              controller.datePreset.value ==
                              PjpDatePreset.last3Months,
                          onTap: () async {
                            await controller
                                .applyDatePreset(PjpDatePreset.last3Months);
                          },
                        ),
                        _PresetChip(
                          label: 'This Year',
                          selected:
                              controller.datePreset.value ==
                              PjpDatePreset.thisYear,
                          onTap: () async {
                            await controller
                                .applyDatePreset(PjpDatePreset.thisYear);
                          },
                        ),
                        _PresetChip(
                          label: 'Last Year',
                          selected:
                              controller.datePreset.value ==
                              PjpDatePreset.lastYear,
                          onTap: () async {
                            await controller
                                .applyDatePreset(PjpDatePreset.lastYear);
                          },
                        ),
                        _PresetChip(
                          label: 'Custom',
                          selected:
                              controller.datePreset.value ==
                              PjpDatePreset.custom,
                          onTap: () =>
                              controller.pickCustomDateRange(context),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      '${Utility.convertShortDate(controller.fromDate.value)} → ${Utility.convertShortDate(controller.toDate.value)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Status'),
                  const SizedBox(height: 8),
                  Obx(() {
                    final selected = controller.statusFilter.value;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetChip(
                          label: 'All (${controller.allPjps.length})',
                          selected: selected == PjpApprovalStatusFilter.all,
                          onTap: () => controller
                              .setStatusFilter(PjpApprovalStatusFilter.all),
                        ),
                        _PresetChip(
                          label: 'Pending (${controller.pendingCount})',
                          selected:
                              selected == PjpApprovalStatusFilter.pending,
                          color: const Color(0xFFEF6C00),
                          onTap: () => controller.setStatusFilter(
                            PjpApprovalStatusFilter.pending,
                          ),
                        ),
                        _PresetChip(
                          label: 'Approved (${controller.approvedCount})',
                          selected:
                              selected == PjpApprovalStatusFilter.approved,
                          color: const Color(0xFF2E7D32),
                          onTap: () => controller.setStatusFilter(
                            PjpApprovalStatusFilter.approved,
                          ),
                        ),
                        _PresetChip(
                          label: 'Rejected (${controller.rejectedCount})',
                          selected:
                              selected == PjpApprovalStatusFilter.rejected,
                          color: Colors.red.shade700,
                          onTap: () => controller.setStatusFilter(
                            PjpApprovalStatusFilter.rejected,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: _SectionTitle('Employee Name')),
                      Obx(() {
                        if (controller.selectedEmployees.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return TextButton(
                          onPressed: controller.clearEmployeeFilter,
                          child: const Text('Clear'),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.employeeNames.isEmpty) {
                      return Text(
                        'No employees in current date range',
                        style: TextStyle(color: Colors.grey.shade600),
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.employeeNames.map((name) {
                        final selected =
                            controller.selectedEmployees.contains(name);
                        return FilterChip(
                          selected: selected,
                          label: Text(name),
                          showCheckmark: false,
                          selectedColor:
                              kPrimaryLightColor.withValues(alpha: 0.18),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? kPrimaryLightColor
                                : const Color(0xFF455A64),
                          ),
                          side: BorderSide(
                            color: selected
                                ? kPrimaryLightColor
                                : Colors.grey.shade300,
                          ),
                          onSelected: (_) => controller.toggleEmployee(name),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 18),
                  const _SectionTitle('Sort By'),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Column(
                      children: [
                        _SortTile(
                          title: 'Status (Pending first)',
                          value: PjpApprovalSort.statusAsc,
                          groupValue: controller.sortBy.value,
                          onChanged: controller.setSort,
                        ),
                        _SortTile(
                          title: 'Status (Rejected first)',
                          value: PjpApprovalSort.statusDesc,
                          groupValue: controller.sortBy.value,
                          onChanged: controller.setSort,
                        ),
                        _SortTile(
                          title: 'Date (Newest)',
                          value: PjpApprovalSort.dateNewest,
                          groupValue: controller.sortBy.value,
                          onChanged: controller.setSort,
                        ),
                        _SortTile(
                          title: 'Date (Oldest)',
                          value: PjpApprovalSort.dateOldest,
                          groupValue: controller.sortBy.value,
                          onChanged: controller.setSort,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimaryLightColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF263238),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = kPrimaryLightColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : color,
      ),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.08),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      onSelected: (_) => onTap(),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final PjpApprovalSort value;
  final PjpApprovalSort groupValue;
  final ValueChanged<PjpApprovalSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PjpApprovalSort>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13)),
      value: value,
      groupValue: groupValue,
      activeColor: kPrimaryLightColor,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
