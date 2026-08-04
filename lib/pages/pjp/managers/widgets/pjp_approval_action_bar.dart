import 'package:Intranet/pages/pjp/managers/pjp_approval_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PjpApprovalActionBar extends StatelessWidget {
  const PjpApprovalActionBar({super.key, required this.controller});

  final PjpApprovalController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.selectedCount;
      if (count == 0) return const SizedBox.shrink();

      return Material(
        elevation: 12,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: controller.toggleSelectAllPending,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            controller.allPendingSelected
                                ? 'Clear selection'
                                : 'Select All (Pending)',
                            style: const TextStyle(
                              color: Color(0xFF0277BD),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.confirmAndUpdateStatus(
                            context: context,
                            approve: false,
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.confirmAndUpdateStatus(
                            context: context,
                            approve: true,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
