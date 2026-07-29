import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/pjp/managers/pjp_approval_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Compact status chips + active filter summary under the AppBar.
class PjpApprovalFilterBar extends StatelessWidget {
  const PjpApprovalFilterBar({super.key, required this.controller});

  final PjpApprovalController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final selected = controller.statusFilter.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusChip(
                      label: 'All',
                      count: controller.allPjps.length,
                      selected: selected == PjpApprovalStatusFilter.all,
                      color: kPrimaryLightColor,
                      onTap: () => controller
                          .setStatusFilter(PjpApprovalStatusFilter.all),
                    ),
                    _StatusChip(
                      label: 'Pending',
                      count: controller.pendingCount,
                      selected: selected == PjpApprovalStatusFilter.pending,
                      color: const Color(0xFFEF6C00),
                      onTap: () => controller
                          .setStatusFilter(PjpApprovalStatusFilter.pending),
                    ),
                    _StatusChip(
                      label: 'Approved',
                      count: controller.approvedCount,
                      selected: selected == PjpApprovalStatusFilter.approved,
                      color: const Color(0xFF2E7D32),
                      onTap: () => controller
                          .setStatusFilter(PjpApprovalStatusFilter.approved),
                    ),
                    _StatusChip(
                      label: 'Rejected',
                      count: controller.rejectedCount,
                      selected: selected == PjpApprovalStatusFilter.rejected,
                      color: Colors.red.shade700,
                      onTap: () => controller
                          .setStatusFilter(PjpApprovalStatusFilter.rejected),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  Icon(Icons.calendar_month,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${controller.datePresetLabel} · ${Utility.convertShortDate(controller.fromDate.value)} → ${Utility.convertShortDate(controller.toDate.value)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (controller.selectedEmployees.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.selectedEmployees.length} emp',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryLightColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Obx(() {
              final pending = controller.selectableVisible.length;
              if (pending == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: controller.toggleSelectAllPending,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kPrimaryLightColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.allPendingSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: kPrimaryLightColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.allPendingSelected
                                ? 'Clear selection'
                                : 'Select All (Pending) — $pending',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryLightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        showCheckmark: false,
        label: Text('$label ($count)'),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : color,
        ),
        selectedColor: color,
        backgroundColor: color.withValues(alpha: 0.10),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
