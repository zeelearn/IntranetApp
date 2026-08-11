import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_args.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/repositories/share_report_repository.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/services/share_report_email_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ShareReportController extends GetxController {
  ShareReportController({
    required this.args,
    ShareReportRepository? repository,
    ShareReportEmailService? emailService,
  })  : _repository = repository ?? ShareReportRepository(),
        _emailService = emailService ?? const ShareReportEmailService();

  final ShareReportArgs args;
  final ShareReportRepository _repository;
  final ShareReportEmailService _emailService;

  final formKey = GlobalKey<FormState>();

  final workingWell = <WorkingWellItem>[].obs;
  final urgentAttention = <UrgentAttentionItem>[].obs;
  final teacherObservation = <TeacherObservationItem>[].obs;
  final trainingSupport = <TrainingSupportItem>[].obs;

  final isSending = false.obs;
  final isLoading = false.obs;
  final sectionError = ''.obs;
  final pdfAvailable = false.obs;
  final subject = ''.obs;

  /// Forces preview rebuild when lists / text change.
  final previewTick = 0.obs;

  /// Static To / CC — not user-editable.
  late final String toEmail;
  late final List<String> ccEmails;

  /// Logged-in user — shown in AppBar (dashboard style).
  final userDisplayName = ''.obs;
  final userDesignation = ''.obs;

  String get centreName => args.centreName;
  String get bpName => args.bpName;
  String get bpCode => args.bpCode;
  String get visitDateDisplay =>
      _emailService.formatVisitDate(args.visitDateRaw);
  String get facilitatorName => args.facilitatorName;
  String get pjpId => args.pjpId;
  String get cvfId => args.cvfId;
  String get pdfFileName => args.pdfFileName;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  void _bumpPreview() => previewTick.value++;

  void _loadUserProfile() {
    try {
      final box = Hive.box(LocalConstant.KidzeeDB);
      final first = (box.get(LocalConstant.KEY_FIRST_NAME) ?? '').toString().trim();
      final last = (box.get(LocalConstant.KEY_LAST_NAME) ?? '').toString().trim();
      var fullName = '$first $last'.trim();
      if (fullName.isEmpty) {
        fullName = (box.get(LocalConstant.KEY_USER_NAME) ?? '').toString().trim();
      }
      userDisplayName.value = fullName;
      userDesignation.value =
          (box.get(LocalConstant.KEY_DESIGNATION) ?? '').toString().trim();
    } catch (_) {
      // Fall back to facilitator name from args when Hive is unavailable.
      if (args.facilitatorName.trim().isNotEmpty) {
        userDisplayName.value = args.facilitatorName.trim();
      }
    }
  }

  void _bootstrap() {
    isLoading.value = true;
    try {
      _loadUserProfile();

      toEmail = args.bpEmail.trim().toLowerCase();
      ccEmails = args.ccEmails
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      subject.value = _emailService.defaultSubject(
        centreName: centreName,
        visitDateRaw: args.visitDateRaw,
      );

      // Start with one empty row per section for faster entry.
      workingWell.assignAll([WorkingWellItem()]);
      urgentAttention.assignAll([UrgentAttentionItem()]);
      teacherObservation.assignAll([TeacherObservationItem()]);
      trainingSupport.assignAll([TrainingSupportItem()]);

      pdfAvailable.value =
          args.isCheckedOut && cvfId.isNotEmpty && pjpId.isNotEmpty;
      _bumpPreview();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Dynamic rows ---

  void addWorkingWell() {
    workingWell.add(WorkingWellItem());
    _bumpPreview();
  }

  Future<void> removeWorkingWell(int index) async {
    if (!_canRemove(workingWell, index)) return;
    final item = workingWell[index];
    if (item.observation.trim().isNotEmpty &&
        !await _confirmDelete()) {
      return;
    }
    workingWell.removeAt(index);
    _bumpPreview();
  }

  void addUrgentAttention() {
    urgentAttention.add(UrgentAttentionItem());
    _bumpPreview();
  }

  Future<void> removeUrgentAttention(int index) async {
    if (!_canRemove(urgentAttention, index)) return;
    final item = urgentAttention[index];
    if ((item.areaOfConcern.trim().isNotEmpty ||
            item.timeline.trim().isNotEmpty) &&
        !await _confirmDelete()) {
      return;
    }
    urgentAttention.removeAt(index);
    _bumpPreview();
  }

  void addTeacherObservation() {
    teacherObservation.add(TeacherObservationItem());
    _bumpPreview();
  }

  Future<void> removeTeacherObservation(int index) async {
    if (!_canRemove(teacherObservation, index)) return;
    final item = teacherObservation[index];
    if ((item.teacherName.trim().isNotEmpty ||
            item.className.trim().isNotEmpty ||
            item.appStatus.trim().isNotEmpty) &&
        !await _confirmDelete()) {
      return;
    }
    teacherObservation.removeAt(index);
    _bumpPreview();
  }

  void addTrainingSupport() {
    trainingSupport.add(TrainingSupportItem());
    _bumpPreview();
  }

  Future<void> removeTrainingSupport(int index) async {
    if (!_canRemove(trainingSupport, index)) return;
    final item = trainingSupport[index];
    if (item.details.trim().isNotEmpty && !await _confirmDelete()) {
      return;
    }
    trainingSupport.removeAt(index);
    _bumpPreview();
  }

  bool _canRemove(List list, int index) =>
      index >= 0 && index < list.length && list.length > 1;

  Future<bool> _confirmDelete() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('Are you sure you want to remove this entry?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> confirmDiscard() async {
    if (isSending.value) return;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text(
          'Are you sure you want to discard this report? '
          'Your entered observations will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (result == true) {
      Get.back(result: false);
    }
  }

  void onRowEdited() => _bumpPreview();

  // --- Email ---

  String generateEmailBody() {
    return _emailService.generateEmailBody(
      bpName: bpName,
      centreName: centreName,
      visitDateRaw: args.visitDateRaw,
      facilitatorName: facilitatorName,
      workingWell: workingWell.toList(),
      urgentAttention: urgentAttention.toList(),
      teacherObservation: teacherObservation.toList(),
      trainingSupport: trainingSupport.toList(),
    );
  }

  // --- Validation ---

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]'
      r'(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    return regex.hasMatch(email);
  }

  String? validateAllSections() {
    if (pjpId.isEmpty) return 'PJP ID is missing.';
    if (cvfId.isEmpty) return 'CVF ID is missing.';
    if (!args.isCheckedOut) {
      return 'Share Report is available only after check-out.';
    }
    if (!pdfAvailable.value) {
      return 'CVF report attachment is not available. Please try again.';
    }
    if (toEmail.isEmpty || !_isValidEmail(toEmail)) {
      return 'Recipient (To) email is not available for this centre.';
    }
    for (final cc in ccEmails) {
      if (!_isValidEmail(cc)) {
        return 'Invalid CC email configured: $cc';
      }
    }
    if (subject.value.trim().length < 5) {
      return 'Subject is invalid.';
    }

    for (var i = 0; i < workingWell.length; i++) {
      final t = workingWell[i].observation.trim();
      if (t.isEmpty) {
        return "What's Working Well #${i + 1}: Observation is required.";
      }
      if (t.length < 3) {
        return "What's Working Well #${i + 1}: Minimum 3 characters.";
      }
      if (t.length > 500) {
        return "What's Working Well #${i + 1}: Maximum 500 characters.";
      }
    }

    for (var i = 0; i < urgentAttention.length; i++) {
      final a = urgentAttention[i].areaOfConcern.trim();
      final t = urgentAttention[i].timeline.trim();
      if (a.isEmpty) {
        return 'Urgent Attention #${i + 1}: Area of Concern is required.';
      }
      if (a.length < 3) {
        return 'Urgent Attention #${i + 1}: Area minimum 3 characters.';
      }
      if (a.length > 500) {
        return 'Urgent Attention #${i + 1}: Area maximum 500 characters.';
      }
      if (t.isEmpty) {
        return 'Urgent Attention #${i + 1}: Timeline is required.';
      }
      if (t.length > 100) {
        return 'Urgent Attention #${i + 1}: Timeline maximum 100 characters.';
      }
    }

    for (var i = 0; i < teacherObservation.length; i++) {
      final n = teacherObservation[i].teacherName.trim();
      final c = teacherObservation[i].className.trim();
      final s = teacherObservation[i].appStatus.trim();
      if (n.isEmpty) {
        return 'Teacher Observation #${i + 1}: Teacher Name is required.';
      }
      if (n.length > 150) {
        return 'Teacher Observation #${i + 1}: Teacher Name max 150 characters.';
      }
      if (c.isEmpty) {
        return 'Teacher Observation #${i + 1}: Class is required.';
      }
      if (c.length > 100) {
        return 'Teacher Observation #${i + 1}: Class max 100 characters.';
      }
      if (s.isEmpty) {
        return 'Teacher Observation #${i + 1}: App Status is required.';
      }
    }

    for (var i = 0; i < trainingSupport.length; i++) {
      final d = trainingSupport[i].details.trim();
      if (d.isEmpty) {
        return 'Training & Support #${i + 1}: Details are required.';
      }
      if (d.length < 3) {
        return 'Training & Support #${i + 1}: Minimum 3 characters.';
      }
      if (d.length > 1000) {
        return 'Training & Support #${i + 1}: Maximum 1000 characters.';
      }
    }

    if (workingWell.isEmpty) {
      return "Add at least one What's Working Well entry.";
    }
    if (urgentAttention.isEmpty) {
      return 'Add at least one Urgent Attention entry.';
    }
    if (teacherObservation.isEmpty) {
      return 'Add at least one Teacher Observation entry.';
    }
    if (trainingSupport.isEmpty) {
      return 'Add at least one Training & Support entry.';
    }

    return null;
  }

  Future<void> sendReport() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isSending.value) return;

    final sectionMsg = validateAllSections();
    if (sectionMsg != null) {
      sectionError.value = sectionMsg;
      Get.snackbar(
        'Validation',
        sectionMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    sectionError.value = '';

    isSending.value = true;
    try {
      final response = await _repository.shareReport(
        pjpId: pjpId,
        cvfId: cvfId,
        to: toEmail,
        cc: ccEmails,
        subject: subject.value.trim(),
        body: generateEmailBody(),
        workingWell: workingWell.toList(),
        urgentAttention: urgentAttention.toList(),
        teacherObservation: teacherObservation.toList(),
        trainingSupport: trainingSupport.toList(),
      );

      if (!response.success) {
        Get.snackbar(
          'Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await Get.dialog(
        AlertDialog(
          title: const Text('Report Sent Successfully'),
          content: const Text(
            'The Centre Visit Report has been sent successfully.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Get.back(result: true);
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
