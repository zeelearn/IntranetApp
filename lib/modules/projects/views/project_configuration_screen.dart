import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/project_configuration_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/projects_entry_args.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/utils/projects_sidebar_roles.dart';
import 'package:Intranet/modules/projects/views/project_configuration_v2_body.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

class ProjectConfigurationScreen extends StatefulWidget {
  const ProjectConfigurationScreen({
    super.key,
    required this.userId,
    required this.managerCode,
  });

  /// BPMS business user id for UpdateTaskUser.
  final int userId;

  /// Logged-in employee code for GetMyTeamForProjects.
  final String managerCode;

  static Future<T?>? open<T>({
    required int userId,
    required String managerCode,
  }) {
    final tag = ProjectConfigurationBinding.makeTag(userId);
    if (Get.isRegistered<ProjectConfigurationController>(tag: tag)) {
      ProjectConfigurationBinding.deleteIfRegistered(userId);
    }
    return Get.to<T>(
      () => ProjectConfigurationScreen(
        userId: userId,
        managerCode: managerCode,
      ),
      binding: ProjectConfigurationBinding(
        userId: userId,
        managerCode: managerCode,
      ),
      preventDuplicates: false,
    );
  }

  /// Loads manager code + BPMS user id from Hive, then opens the screen.
  static Future<T?>? openFromHive<T>() async {
    final box = await Utility.openBox();
    final userType =
        (box.get(LocalConstant.KEY_EMP_TYPE)?.toString() ?? '').trim();
    final managerCode =
        (box.get(LocalConstant.KEY_EMPLOYEE_CODE)?.toString() ?? '').trim();
    final args = await ProjectsEntryArgs.fromHive();
    final userId = args.userId;

    if (!ProjectsSidebarRoles.canShowConfiguration(userType)) {
      Get.snackbar(
        'Transfer projects',
        'Transfer projects is available only for Business Head.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return null;
    }

    if (managerCode.isEmpty) {
      Get.snackbar(
        'Transfer projects',
        'Employee code is missing. Please sign in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return null;
    }

    if (userId <= 0) {
      Get.snackbar(
        'Transfer projects',
        'Business user id is missing. Please sign in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.error.withValues(alpha: 0.12),
        colorText: DashboardColors.textDark,
      );
      return null;
    }

    return open<T>(userId: userId, managerCode: managerCode);
  }

  @override
  State<ProjectConfigurationScreen> createState() =>
      _ProjectConfigurationScreenState();
}

class _ProjectConfigurationScreenState
    extends State<ProjectConfigurationScreen> {
  late final String _tag;
  late final ProjectConfigurationController _controller;

  @override
  void initState() {
    super.initState();
    _tag = ProjectConfigurationBinding.makeTag(widget.userId);
    if (!Get.isRegistered<ProjectConfigurationController>(tag: _tag)) {
      ProjectConfigurationBinding(
        userId: widget.userId,
        managerCode: widget.managerCode,
      ).dependencies();
    }
    _controller = Get.find<ProjectConfigurationController>(tag: _tag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.load();
    });
  }

  @override
  void dispose() {
    // Do not delete GetX deps here. Get.to(binding:) owns lifecycle.
    super.dispose();
  }

  void _queuePair() {
    final queued = _controller.queueCurrentPair();
    if (!queued) {
      final message = _controller.actionError.value ??
          _controller.queueValidationError ??
          'Unable to save this transfer.';
      Get.snackbar(
        'Please check',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.errorLight,
        colorText: DashboardColors.textDark,
      );
      return;
    }
    Get.snackbar(
      'Saved as draft',
      'Tap Draft to review your transfers.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DashboardColors.successLight,
      colorText: DashboardColors.textDark,
    );
  }

  Future<void> _openQueuedPairsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _QueuedPairsSheet(controller: _controller);
      },
    );
  }

  Future<void> _submit() async {
    if (_controller.isSubmitting.value) return;
    final validation = _controller.submitValidationError;
    if (validation != null) {
      _controller.actionError.value = validation;
      Get.snackbar(
        'Please check',
        validation,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.errorLight,
        colorText: DashboardColors.textDark,
      );
      return;
    }

    final pairs = _controller.pairsForSubmit;
    if (pairs.isEmpty) {
      Get.snackbar(
        'Please check',
        ProjectConfigurationController.selectProjectsMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DashboardColors.errorLight,
        colorText: DashboardColors.textDark,
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ConfirmReassignmentSheet(
          pairs: pairs,
          isSubmitting: () => _controller.isSubmitting.value,
        );
      },
    );
    if (confirmed != true) return;

    try {
      final success = await _controller.submit();
      if (!mounted) return;
      if (success) {
        Get.snackbar(
          'Transfer complete',
          'Projects were moved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DashboardColors.successLight,
          colorText: DashboardColors.textDark,
        );
      } else {
        _showSubmitFailure(
          _controller.actionError.value ??
              'Unable to complete the transfer. Please check and try again.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showSubmitFailure(
        'Unable to complete the transfer. Please check and try again.',
      );
    }
  }

  void _showSubmitFailure([String? message]) {
    Get.snackbar(
      'Transfer failed',
      message ??
          'Unable to complete the transfer. Please check and try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DashboardColors.errorLight,
      colorText: DashboardColors.textDark,
    );
  }

  Future<void> _handleBack() async {
    final shouldLeave = await _confirmLeaveIfNeeded();
    if (!shouldLeave || !mounted) return;
    Navigator.of(context).pop();
  }

  /// Returns true when navigation away is allowed.
  Future<bool> _confirmLeaveIfNeeded() async {
    if (_controller.queuedPairs.isEmpty) return true;

    final goBack = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Go back?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DashboardColors.textDark,
            ),
          ),
          content: Text(
            'You have transfers saved as draft. Do you want to go back?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: DashboardColors.textMuted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: DashboardColors.primaryFilledButton(),
              child: Text(
                'Go back',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    return goBack == true;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canPop = _controller.queuedPairs.isEmpty;
      return PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack();
        },
        child: Scaffold(
          backgroundColor: DashboardColors.scaffold,
          appBar: AppBar(
            backgroundColor: DashboardColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: _handleBack,
            ),
            centerTitle: false,
            title: Text(
              'Project Reassignment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          body: _controller.isLoading.value && _controller.employees.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: DashboardColors.primary,
                  ),
                )
              : _buildV2Body(),
        ),
      );
    });
  }

  Widget _buildV2Body() {
    final loadError = _controller.loadError.value;
    final body = ProjectConfigurationV2Body(
      controller: _controller,
      onSaveDraft: _queuePair,
      onOpenDrafts: _openQueuedPairsSheet,
      onTransfer: _submit,
      onCancel: _handleBack,
    );
    if (loadError == null) return body;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: _InlineBanner(
            message: loadError,
            onRetry: _controller.load,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueuedPairsSheet extends StatelessWidget {
  const _QueuedPairsSheet({required this.controller});

  final ProjectConfigurationController controller;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.62;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Draft transfers',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DashboardColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              final pairs = controller.queuedPairs.toList(growable: false);
              if (pairs.isEmpty) {
                return Center(
                  child: Text(
                    'No drafts yet.\nChoose the current employee, projects, and new employee, then tap “Save as draft”.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: DashboardColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: pairs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final pair = pairs[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
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
                                '${pair.source.employeeFullName} → ${pair.target.employeeFullName}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: DashboardColors.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () =>
                                  controller.removeQueuedPair(index),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: DashboardColors.error,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        Text(
                          '${pair.projects.length} project${pair.projects.length == 1 ? '' : 's'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: DashboardColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final project in pair.projects.take(6))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${project.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: DashboardColors.textDark,
                              ),
                            ),
                          ),
                        if (pair.projects.length > 6)
                          Text(
                            '+${pair.projects.length - 6} more',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: DashboardColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConfirmReassignmentSheet extends StatelessWidget {
  const _ConfirmReassignmentSheet({
    required this.pairs,
    required this.isSubmitting,
  });

  final List<ReassignmentPair> pairs;
  final bool Function() isSubmitting;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;
    final projectCount =
        pairs.fold<int>(0, (sum, pair) => sum + pair.projects.length);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm transfer',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$projectCount project${projectCount == 1 ? '' : 's'} across ${pairs.length} transfer${pairs.length == 1 ? '' : 's'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: DashboardColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: pairs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pair = pairs[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    color: DashboardColors.scaffold,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transfer ${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pair.source.employeeFullName} → ${pair.target.employeeFullName}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final project in pair.projects)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: DashboardColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: DashboardColors.textDark,
                                      ),
                                    ),
                                    if (project.franchiseeCode.trim().isNotEmpty)
                                      Text(
                                        project.franchiseeCode,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: DashboardColors.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                project.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: DashboardColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: isSubmitting()
                          ? null
                          : () => Navigator.of(context).maybePop(true),
                      style: DashboardColors.primaryFilledButton(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm transfer',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
