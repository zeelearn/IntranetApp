import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/pjp/managers/pjp_approval_controller.dart';
import 'package:Intranet/pages/pjp/managers/widgets/pjp_approval_action_bar.dart';
import 'package:Intranet/pages/pjp/managers/widgets/pjp_approval_filter_bar.dart';
import 'package:Intranet/pages/pjp/managers/widgets/pjp_approval_filter_sheet.dart';
import 'package:Intranet/pages/pjp/managers/widgets/pjp_approval_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Manager screen to approve / reject team PJP requests (`isSelfPJP == 0`).
class PjpApprovalPage extends StatelessWidget {
  const PjpApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PjpApprovalController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final searching = controller.showSearch.value;
          return AppBar(
            backgroundColor: kPrimaryLightColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: searching
                ? TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText:
                          'Search employee, code, franchisee, activity, CVF id…',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  )
                : const Text(
                    'PJP Approvals',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
            actions: [
              IconButton(
                tooltip: searching ? 'Close search' : 'Search',
                onPressed: controller.toggleSearch,
                icon: Icon(searching ? Icons.close : Icons.search),
              ),
              IconButton(
                tooltip: 'Filters',
                onPressed: () =>
                    showPjpApprovalFilterSheet(context, controller),
                icon: Badge(
                  isLabelVisible: controller.activeFilterCount > 0,
                  label: Text('${controller.activeFilterCount}'),
                  child: const Icon(Icons.filter_list),
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => controller.refreshList(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              PjpApprovalFilterBar(controller: controller),
              Expanded(child: _PjpApprovalBody(controller: controller)),
              PjpApprovalActionBar(controller: controller),
            ],
          ),
          Obx(() {
            if (!controller.isSubmitting.value) {
              return const SizedBox.shrink();
            }
            return Container(
              color: Colors.black38,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Updating PJP status…'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PjpApprovalBody extends StatelessWidget {
  const _PjpApprovalBody({required this.controller});

  final PjpApprovalController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.errorMessage.value;
      if (error != null && controller.allPjps.isEmpty) {
        return _EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Unable to load',
          subtitle: error,
          actionLabel: 'Retry',
          onAction: () => controller.loadPjps(),
        );
      }

      if (controller.visiblePjps.isEmpty) {
        return _EmptyState(
          icon: Icons.assignment_outlined,
          title: 'No team PJPs found',
          subtitle: 'No PJPs match the selected filters and date range.',
          actionLabel: 'Refresh',
          onAction: () => controller.refreshList(),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshList,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: controller.visiblePjps.length,
          itemBuilder: (context, index) {
            final pjp = controller.visiblePjps[index];
            return Obx(
              () => PjpApprovalListItem(
                pjp: pjp,
                selected: controller.isSelected(pjp),
                selectable: controller.canSelect(pjp),
                onToggle: () => controller.toggleSelection(pjp),
                onOpen: () => controller.openCvfHistory(context, pjp),
              ),
            );
          },
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: kPrimaryLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
