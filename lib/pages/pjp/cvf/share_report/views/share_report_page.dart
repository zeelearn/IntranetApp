import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_args.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/cvf_info_card.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/email_preview.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/teacher_observation_section.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/training_support_section.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/urgent_attention_section.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/working_well_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareReportPage extends StatelessWidget {
  const ShareReportPage({super.key, required this.args});

  final ShareReportArgs args;

  static const _wideBreakpoint = 980.0;

  static Future<T?>? open<T>(ShareReportArgs args) {
    return Get.to<T>(
      () => ShareReportPage(args: args),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<ShareReportController>()) {
          Get.delete<ShareReportController>(force: true);
        }
        Get.put(ShareReportController(args: args));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShareReportController>()) {
      Get.put(ShareReportController(args: args));
    }
    final controller = Get.find<ShareReportController>();

    return Scaffold(
      backgroundColor: ShareReportTheme.scaffold,
      appBar: AppBar(
        backgroundColor: ShareReportTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Centre Visit Report',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              'PJP: ${args.pjpDateRange}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Obx(() {
                final name = controller.userDisplayName.value.trim();
                final designation = controller.userDesignation.value.trim();
                if (name.isEmpty && designation.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (name.isNotEmpty)
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      if (designation.isNotEmpty)
                        Text(
                          designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= _wideBreakpoint;
              if (isWide) {
                return _WideLayout(controller: controller);
              }
              return _NarrowLayout(controller: controller);
            },
          ),
        );
      }),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.controller});

  final ShareReportController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _FormPane(controller: controller),
        ),
        const VerticalDivider(width: 1, color: ShareReportTheme.border),
        const Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: EmailComposePanel(showSendInPanel: true),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.controller});

  final ShareReportController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _FormPane(controller: controller)),
        const Divider(height: 1, color: ShareReportTheme.border),
        SafeArea(
          top: false,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Obx(() {
              final sending = controller.isSending.value;
              final canSend = controller.canSend;
              final submitted = controller.isAlreadySubmitted.value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          sending ? null : controller.confirmDiscard,
                      child: Text(
                        controller.isReadOnly.value ? 'Close' : 'Discard',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: canSend ? controller.sendReport : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: ShareReportTheme.primary,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        sending
                            ? 'Sending…'
                            : submitted
                                ? 'Already Sent'
                                : 'Send Report',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({required this.controller});

  final ShareReportController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ShareReportTheme.scaffold,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Obx(() {
            if (!controller.isAlreadySubmitted.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read_outlined,
                        size: 18, color: Colors.green.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This Centre Visit Report has already been shared. '
                        'Details below are read-only.',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Text('Visit observations', style: ShareReportTheme.title),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.isReadOnly.value
                  ? 'Submitted report — preview only. Editing and resend are disabled.'
                  : 'Enter details below — the email preview updates as you type.',
              style: ShareReportTheme.label,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final readOnly = controller.isReadOnly.value;
            return AbsorbPointer(
              absorbing: readOnly,
              child: Opacity(
                opacity: readOnly ? 0.85 : 1,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CvfInfoCard(),
                    SizedBox(height: 16),
                    _SectionShell(
                      title: "What's Working Well",
                      child: WorkingWellSection(hideTitle: true),
                    ),
                    SizedBox(height: 12),
                    _SectionShell(
                      title: 'Urgent Attention',
                      child: UrgentAttentionSection(hideTitle: true),
                    ),
                    SizedBox(height: 12),
                    _SectionShell(
                      title: 'Teacher Observation',
                      child: TeacherObservationSection(hideTitle: true),
                    ),
                    SizedBox(height: 12),
                    _SectionShell(
                      title: 'Training & Support Provided',
                      child: TrainingSupportSection(hideTitle: true),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final err = controller.sectionError.value;
            if (err.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                err,
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          }),
          if (MediaQuery.sizeOf(context).width <
              ShareReportPage._wideBreakpoint) ...[
            const SizedBox(height: 16),
            Text('Email preview', style: ShareReportTheme.sectionTitle),
            const SizedBox(height: 8),
            const SizedBox(
              height: 480,
              child: EmailComposePanel(showSendInPanel: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ShareReportTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ShareReportTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ShareReportTheme.sectionTitle),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
