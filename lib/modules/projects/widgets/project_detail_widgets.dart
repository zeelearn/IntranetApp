import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/task_hierarchy_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_detail_controller.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_detail.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/views/task_hierarchy_screen.dart';
import 'package:Intranet/modules/projects/widgets/project_email_viewer.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';
import 'package:Intranet/modules/projects/widgets/task_tree_node.dart';
import 'package:get/get.dart';

class ProjectDetailHeaderCard extends StatelessWidget {
  const ProjectDetailHeaderCard({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fran = controller.detail.value?.franDetails;
      final expanded = controller.franchiseeExpanded.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Prospect Name',
            //   style: GoogleFonts.poppins(
            //     fontSize: 11,
            //     color: DashboardColors.textMuted,
            //   ),
            // ),
            // const SizedBox(height: 4),
            // Text(
            //   controller.projectTitleLine,
            //   style: GoogleFonts.poppins(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w700,
            //     color: DashboardColors.textDark,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Text(
            //       'Status',
            //       style: GoogleFonts.poppins(
            //         fontSize: 14,
            //         color: DashboardColors.textMuted,
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Container(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: controller.operatingStatusColor.withValues(alpha: 0.12),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       child: Text(
            //         controller.operatingStatusLabel,
            //         style: GoogleFonts.poppins(
            //           fontSize: 11,
            //           fontWeight: FontWeight.w600,
            //           color: controller.operatingStatusColor,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 10),
            Row(
                  children: [
                    const Icon(
                      Icons.contact_mail_outlined,
                      size: 18,
                      color: DashboardColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Franchisee Details',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.primary,
                        ),
                      ),
                    ),
                    Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.operatingStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.operatingStatusLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: controller.operatingStatusColor,
                    ),
                  ),
                )
                  ],
                ),
            //const SizedBox(height: 14),
            InkWell(
              onTap: controller.toggleFranchiseeExpanded,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        
                        title: Text(
                          controller.projectTitleLine,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: DashboardColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          fran?.attendee ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: DashboardColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // Expanded(
                    //   child: Text(
                    //     'Franchisee Details',
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w700,
                    //       color: DashboardColors.primary,
                    //     ),
                    //   ),
                    // ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: DashboardColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Divider(color: Colors.grey.shade300, height: 2, thickness: 1),
              SizedBox(height: 10),
              // _detailRow(Icons.storefront_outlined, 'Franchisee Name',
              //     fran?.franchiseeName ?? controller.project.franchiseeName),
              // _detailRow(Icons.person_outline, 'Contact Person',
              //     fran?.attendee ?? ''),
              _detailRow(Icons.phone_outlined, 'Mobile', fran?.mobileNo ?? ''),
              _detailRow(Icons.email_outlined, 'Email', fran?.emailId ?? ''),
              _detailRow(Icons.map_outlined, 'State', fran?.stateName ?? ''),
              _detailRow(
                  Icons.location_city_outlined, 'City', fran?.cityName ?? ''),
              _detailRow(Icons.home_outlined, 'Address 1', fran?.address1 ?? ''),
              _detailRow(Icons.home_work_outlined, 'Address 2',
                  fran?.address2 ?? ''),
              _detailRow(Icons.place_outlined, 'Place', fran?.place ?? ''),
              _detailRow(
                  Icons.pin_drop_outlined, 'Pin Code', fran?.pinCode ?? ''),
              _detailRow(Icons.layers_outlined, 'Tier',
                  fran?.tierName ?? controller.project.tierName),
              _detailRow(Icons.payments_outlined, 'Fee Type',
                  fran?.feeType ?? controller.project.feeType),
              _detailRow(Icons.apartment_outlined, 'Location Type',
                  fran?.locationType ?? ''),
            ],
          ],
        ),
      );
    });
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: DashboardColors.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
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
              value.trim().isEmpty ? '—' : value.trim(),
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

class ProjectDetailTabBar extends StatelessWidget {
  const ProjectDetailTabBar({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTab.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                children: [
                  _tab(
                    tab: ProjectDetailTab.communication,
                    label: 'Communication',
                    icon: Icons.mail_outline_rounded,
                    color: DashboardColors.primary,
                    selected: selected,
                  ),
                  _tab(
                    tab: ProjectDetailTab.indent,
                    label: 'Indent Details',
                    icon: Icons.shopping_cart,
                    color: DashboardColors.purple,
                    selected: selected,
                  ),
                  // _tab(
                  //   tab: ProjectDetailTab.tasks,
                  //   label: 'Tasks',
                  //   icon: Icons.checklist_rounded,
                  //   color: DashboardColors.success,
                  //   selected: selected,
                  // ),
                  _tab(
                    tab: ProjectDetailTab.documents,
                    label: 'Documents',
                    icon: Icons.folder_outlined,
                    color: const Color(0xFFE65100),
                    selected: selected,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _TabBody(controller: controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _tab({
    required ProjectDetailTab tab,
    required String label,
    required IconData icon,
    required Color color,
    required ProjectDetailTab selected,
  }) {
    final active = selected == tab;
    return Expanded(
      child: InkWell(
        onTap: () => controller.selectTab(tab),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              child: Column(
                children: [
                  Icon(icon, size: 20, color: active ? color : Colors.grey),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? DashboardColors.primary : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: active ? DashboardColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.selectedTab.value) {
      case ProjectDetailTab.communication:
        return ProjectCommunicationTab(controller: controller);
      case ProjectDetailTab.indent:
        return ProjectIndentTab(controller: controller);
      case ProjectDetailTab.tasks:
        return ProjectTasksTab(controller: controller);
      case ProjectDetailTab.documents:
        return ProjectDocumentsTab(controller: controller);
    }
  }
}

class ProjectCommunicationTab extends StatelessWidget {
  const ProjectCommunicationTab({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.detail.value?.communication ?? const [];
      if(items.isNotEmpty){
        items.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Email Communication',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                child: const Icon(Icons.filter_list_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No communication found',
                  style: GoogleFonts.poppins(
                    color: DashboardColors.textMuted,
                  ),
                ),
              ),
            )
          else
            for (final item in items) _CommunicationTile(item: item),
        ],
      );
    });
  }
}

class _CommunicationTile extends StatelessWidget {
  const _CommunicationTile({required this.item});

  final ProjectCommunicationItem item;

  @override
  Widget build(BuildContext context) {
    final when = ProjectDateUtils.formatReadableDateTime(
      item.createdDate,
      timeHint: item.createdTime,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.mail_outline, size: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sent an Email on ${item.toAddress.isEmpty ? '—' : item.toAddress}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DashboardColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  when,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: DashboardColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DashboardColors.primaryLight.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.emailSubject.isNotEmpty)
                        Text(
                          item.emailSubject,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        item.bodyPreview.isEmpty ? '—' : item.bodyPreview,
                        style: GoogleFonts.poppins(fontSize: 11, height: 1.35),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              showProjectEmailViewer(context, item),
                          child: Text(
                            'Read More',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DashboardColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class ProjectIndentTab extends StatelessWidget {
  const ProjectIndentTab({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.detail.value;
      final items = data?.indentDetails ?? const [];
      if(items.isNotEmpty){
        items.sort((a, b) => b.indentDate.compareTo(a.indentDate));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Indent Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _IndentSummary(
            total: data?.totalIndents ?? 0,
            amount: data?.totalIndentAmount ?? 0,
            due: data?.totalDueAmount ?? 0,
            paid: data?.totalPaidAmount ?? 0,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No indent details found',
                  style: GoogleFonts.poppins(color: DashboardColors.textMuted),
                ),
              ),
            )
          else
            for (final item in items) _IndentCard(item: item),
        ],
      );
    });
  }
}

class _IndentSummary extends StatelessWidget {
  const _IndentSummary({
    required this.total,
    required this.amount,
    required this.due,
    required this.paid,
  });

  final int total;
  final double amount;
  final double due;
  final double paid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _cell('Total Indents', '$total', DashboardColors.textDark),
        _cell(
          'Total Indent Amount',
          ProjectDateUtils.formatAmount(amount),
          DashboardColors.textDark,
        ),
        _cell(
          'Total Due Amount',
          ProjectDateUtils.formatAmount(due),
          const Color(0xFFEF6C00),
        ),
        _cell(
          'Total Paid Amount',
          ProjectDateUtils.formatAmount(paid),
          DashboardColors.success,
        ),
      ],
    );
  }

  Widget _cell(String label, String value, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: DashboardColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndentCard extends StatelessWidget {
  const _IndentCard({required this.item});

  final IndentDetailItem item;

  Color get _statusColor {
    final s = item.indentStatus.toLowerCase();
    if (s.contains('paid') || s.contains('delivered') || s.contains('cleared')) {
      return DashboardColors.success;
    }
    if (s.contains('partial') || s.contains('dispatch')) {
      return const Color(0xFFEF6C00);
    }
    if (s.contains('pending')) return DashboardColors.error;
    return DashboardColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.indentNo.isEmpty ? 'Indent #${item.indentId}' : item.indentNo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DashboardColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.indentStatus.isEmpty ? '—' : item.indentStatus,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _kv(
                  'Indent Date',
                  ProjectDateUtils.formatReadable(item.indentDate),
                ),
              ),
              Expanded(child: _kv('Indent Type', item.indentType)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _kv(
                  'Indent Amount',
                  ProjectDateUtils.formatAmount(item.indentAmount),
                ),
              ),
              Expanded(
                child: _kv(
                  'Approved Amount',
                  ProjectDateUtils.formatAmount(item.apprAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _kv(
                  'Due Amount',
                  ProjectDateUtils.formatAmount(item.dueAmount),
                  valueColor: item.dueAmount > 0
                      ? const Color(0xFFEF6C00)
                      : null,
                ),
              ),
              Expanded(
                child: _kv(
                  'Paid Amount',
                  ProjectDateUtils.formatAmount(item.paidAmount),
                  valueColor: DashboardColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: DashboardColors.textMuted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? DashboardColors.textDark,
          ),
        ),
      ],
    );
  }
}

class ProjectDocumentsTab extends StatelessWidget {
  const ProjectDocumentsTab({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = controller.detail.value?.documents ?? const [];
      final fallback = controller.project.docUrl.trim();
      final named = <NamedAttachment>[
        for (final d in docs)
          if (d.docUrl.trim().isNotEmpty)
            NamedAttachment(
              name: d.name.isEmpty ? 'Document' : d.name,
              url: d.docUrl.trim(),
            ),
      ];
      if (named.isEmpty && fallback.isNotEmpty) {
        named.add(NamedAttachment(name: 'Project Document', url: fallback));
      }
      if (named.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No documents found',
              style: GoogleFonts.poppins(color: DashboardColors.textMuted),
            ),
          ),
        );
      }
      return TaskAttachmentList.named(
        documents: named,
        title: 'Documents',
      );
    });
  }
}

/// Embedded project task list — reuses [TaskHierarchyController] tree.
class ProjectTasksTab extends StatelessWidget {
  const ProjectTasksTab({super.key, required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    final tag = TaskHierarchyBinding.makeTag(
      controller.userId,
      controller.project,
    );

    if (!Get.isRegistered<TaskHierarchyController>(tag: tag)) {
      TaskHierarchyBinding(
        project: controller.project,
        userId: controller.userId,
        currentUserName: controller.currentUserName,
        contributionId: controller.contributionId,
      ).dependencies();
    }

    if (!Get.isRegistered<TaskHierarchyController>(tag: tag)) {
      return _OpenFullTasksButton(onOpen: () => _openFull());
    }

    final tasks = Get.find<TaskHierarchyController>(tag: tag);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Project Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: _openFull,
              child: const Text('Open full view'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          // ignore: unused_local_variable
          final _ = tasks.treeRevision.value;
          final loading = tasks.isLoading.value;
          final roots = tasks.visibleRoots();
          if (loading && roots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (roots.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No tasks found',
                  style: GoogleFonts.poppins(color: DashboardColors.textMuted),
                ),
              ),
            );
          }
          return Column(
            children: [
              for (var i = 0; i < roots.length; i++)
                TaskTreeNode(
                  key: ValueKey('pd_root_${roots[i].id}'),
                  controller: tasks,
                  task: roots[i],
                  depth: 0,
                  isLast: i == roots.length - 1,
                  onView: (_) => _openFull(),
                  onMenuAction: (action, task) {
                    if (action == TaskActionType.createChild) {
                      tasks.openAddTask(parent: task);
                      return;
                    }
                    if (action == TaskActionType.edit ||
                        action == TaskActionType.updateStatus) {
                      tasks.openEditTask(task);
                      return;
                    }
                    if (action == TaskActionType.delete) {
                      tasks.deleteTask(task);
                      return;
                    }
                    if (action == TaskActionType.comments) {
                      tasks.openComments(task);
                      return;
                    }
                    _openFull();
                  },
                ),
            ],
          );
        }),
      ],
    );
  }

  void _openFull() {
    TaskHierarchyScreen.open(
      project: controller.project,
      userId: controller.userId,
      currentUserName: controller.currentUserName,
      contributionId: controller.contributionId,
    );
  }
}

class _OpenFullTasksButton extends StatelessWidget {
  const _OpenFullTasksButton({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Project Tasks',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: DashboardColors.primaryFilledButton(),
          onPressed: onOpen,
          icon: const Icon(Icons.account_tree_outlined),
          label: const Text('Open Task List'),
        ),
      ],
    );
  }
}
