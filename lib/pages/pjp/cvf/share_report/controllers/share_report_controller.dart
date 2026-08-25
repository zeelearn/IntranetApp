import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_args.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_email_data.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/teacher_observation_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/training_support_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/urgent_attention_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/working_well_item.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/repositories/share_report_repository.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/services/share_report_email_service.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:Intranet/pages/widget/report.dart';
import 'package:flutter/foundation.dart';
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
  final attachmentUrl = ''.obs;

  /// True when CVF already has a submitted share-report email.
  final isAlreadySubmitted = false.obs;

  /// Read-only UI when email was previously submitted.
  final isReadOnly = false.obs;

  /// Forces preview rebuild when lists / text change.
  final previewTick = 0.obs;

  /// Static To / CC — not user-editable.
  final toEmails = <String>[].obs;
  final ccEmails = <String>[].obs;

  /// Logged-in user — shown in AppBar (dashboard style).
  final userDisplayName = ''.obs;
  final userDesignation = ''.obs;

  int _empId = 0;

  String get centreName => args.centreName;
  String get bpName => args.bpName;
  String get bpCode => args.bpCode;
  String get visitDateDisplay =>
      _emailService.formatVisitDate(args.visitDateRaw);
  String get facilitatorName => args.facilitatorName;
  String get pjpId => args.pjpId;
  String get cvfId => args.cvfId;
  String get pdfFileName => args.pdfFileName;

  /// True when [attachmentUrl] can be opened in a WebView.
  bool get canOpenAttachment => attachmentUrl.value.trim().isNotEmpty;

  /// Primary To address for UI chip (first recipient).
  String get toEmail => toEmails.isEmpty ? 'xxx.@xxx.com' : toEmails.first;

  bool get canSend =>
      !isReadOnly.value && !isAlreadySubmitted.value && !isSending.value;

  /// Opens [attachmentUrl] in a WebView when not blank (mail preview PDF tap).
  void openAttachmentPreview() {
    final url = attachmentUrl.value.trim();
    if (url.isEmpty) return;

    if (kIsWeb) {
      Get.to(
        () => MyWebsiteView(
          title: pdfFileName,
          url: url,
        ),
      );
      return;
    }

    Get.to(() => CVFReportWebView(url: url));
  }

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  void _bumpPreview() => previewTick.value++;

  void _loadUserProfile() {
    try {
      final box = Hive.box(LocalConstant.KidzeeDB);
      final first =
          (box.get(LocalConstant.KEY_FIRST_NAME) ?? '').toString().trim();
      final last =
          (box.get(LocalConstant.KEY_LAST_NAME) ?? '').toString().trim();
      var fullName = '$first $last'.trim();
      if (fullName.isEmpty) {
        fullName =
            (box.get(LocalConstant.KEY_USER_NAME) ?? '').toString().trim();
      }
      userDisplayName.value = fullName;
      userDesignation.value =
          (box.get(LocalConstant.KEY_DESIGNATION) ?? '').toString().trim();
      _empId = int.tryParse(
            (box.get(LocalConstant.KEY_EMPLOYEE_ID) ?? '').toString().trim(),
          ) ??
          0;
    } catch (_) {
      if (args.facilitatorName.trim().isNotEmpty) {
        userDisplayName.value = args.facilitatorName.trim();
      }
    }
  }

  Future<void> _bootstrap() async {
    isLoading.value = true;
    sectionError.value = '';
    try {
      _loadUserProfile();

      isAlreadySubmitted.value = args.cvf.isEmailSubmitted;
      isReadOnly.value = args.cvf.isEmailSubmitted;

      toEmails.assignAll(
        args.bpEmail.trim().isEmpty
            ? <String>[]
            : [args.bpEmail.trim().toLowerCase()],
      );
      ccEmails.assignAll(
        args.ccEmails
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      subject.value = _emailService.defaultSubject(
        centreName: centreName,
        visitDateRaw: args.visitDateRaw,
      );
      attachmentUrl.value = _defaultAttachmentUrl();

      workingWell.assignAll([WorkingWellItem()]);
      urgentAttention.assignAll([UrgentAttentionItem()]);
      teacherObservation.assignAll([TeacherObservationItem()]);
      trainingSupport.assignAll([TrainingSupportItem()]);

      pdfAvailable.value =
          args.isCheckedOut && cvfId.isNotEmpty && pjpId.isNotEmpty;

      if (args.cvf.isEmailSubmitted) {
        await _loadSubmittedReport();
      }

      _bumpPreview();
    } finally {
      isLoading.value = false;
    }
  }

  String _defaultAttachmentUrl() {
    if (cvfId.isEmpty) return '';
    return '${LocalStrings.CVF_REPORT_URL}$cvfId';
  }

  Future<void> _loadSubmittedReport() async {
    if (_empId <= 0) {
      sectionError.value =
          'Unable to load submitted report: employee ID is missing.';
      Get.snackbar(
        'Error',
        sectionError.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (pjpId.isEmpty || cvfId.isEmpty) {
      sectionError.value =
          'Unable to load submitted report: PJP/CVF ID is missing.';
      return;
    }

    final result = await _repository.getCvfReportApi(
      empId: _empId,
      pjpId: pjpId,
      cvfId: cvfId,
    );

    if (!result.success || result.data == null) {
      sectionError.value = result.message;
      Get.snackbar(
        'Unable to load report',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    _applyLoadedData(result.data!);
  }

  void _applyLoadedData(ShareReportEmailData data) {
    if (data.to.isNotEmpty) {
      toEmails.assignAll(data.to.map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    ccEmails.assignAll(data.cc.map((e) => e.trim()).where((e) => e.isNotEmpty));

    if (data.subject.trim().isNotEmpty) {
      subject.value = data.subject.trim();
    }
    if (data.attachmentUrl.trim().isNotEmpty) {
      attachmentUrl.value = data.attachmentUrl.trim();
      pdfAvailable.value = true;
    }

    workingWell.assignAll(
      data.workingWell.isEmpty ? [WorkingWellItem()] : data.workingWell,
    );
    urgentAttention.assignAll(
      data.urgentAttention.isEmpty
          ? [UrgentAttentionItem()]
          : data.urgentAttention,
    );
    teacherObservation.assignAll(
      data.teacherObservation.isEmpty
          ? [TeacherObservationItem()]
          : data.teacherObservation,
    );
    trainingSupport.assignAll(
      data.trainingSupport.isEmpty
          ? [TrainingSupportItem()]
          : data.trainingSupport,
    );

    isAlreadySubmitted.value = true;
    isReadOnly.value = true;
    sectionError.value = '';
    _bumpPreview();
  }

  // --- Dynamic rows ---

  void addWorkingWell() {
    if (isReadOnly.value) return;
    workingWell.add(WorkingWellItem());
    _bumpPreview();
  }

  Future<void> removeWorkingWell(int index) async {
    if (isReadOnly.value || !_canRemove(workingWell, index)) return;
    final item = workingWell[index];
    if (item.observation.trim().isNotEmpty && !await _confirmDelete()) {
      return;
    }
    workingWell.removeAt(index);
    _bumpPreview();
  }

  void addUrgentAttention() {
    if (isReadOnly.value) return;
    urgentAttention.add(UrgentAttentionItem());
    _bumpPreview();
  }

  Future<void> removeUrgentAttention(int index) async {
    if (isReadOnly.value || !_canRemove(urgentAttention, index)) return;
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
    if (isReadOnly.value) return;
    teacherObservation.add(TeacherObservationItem());
    _bumpPreview();
  }

  Future<void> removeTeacherObservation(int index) async {
    if (isReadOnly.value || !_canRemove(teacherObservation, index)) return;
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
    if (isReadOnly.value) return;
    trainingSupport.add(TrainingSupportItem());
    _bumpPreview();
  }

  Future<void> removeTrainingSupport(int index) async {
    if (isReadOnly.value || !_canRemove(trainingSupport, index)) return;
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
    if (isReadOnly.value) {
      Get.back(result: false);
      return;
    }
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

  void onRowEdited() {
    if (isReadOnly.value) return;
    _bumpPreview();
  }

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

  ShareReportEmailData buildSendPayload() {
    
    return ShareReportEmailData(
      pjpId: pjpId,
      cvfId: cvfId,
      to: toEmails.toList(),
      cc: ccEmails.toList(),
      subject: subject.value.trim(),
      body: generateEmailBody(),
      isHtml: true,
      contentType: 'text/html',
      attachmentUrl: attachmentUrl.value.trim().isEmpty
          ? _defaultAttachmentUrl()
          : attachmentUrl.value.trim(),
      workingWell: _emailService.filledWorkingWell(workingWell.toList()),
      urgentAttention: _emailService.filledUrgent(urgentAttention.toList()),
      teacherObservation:
          _emailService.filledTeachers(teacherObservation.toList()),
      trainingSupport: _emailService.filledTraining(trainingSupport.toList()),
    );
  }

  // --- Validation ---

  bool _isValidEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return false;
    // Masked emails from list APIs (e.g. ki*********@******.com).
    if (value.contains('*') && value.contains('@')) {
      return RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(value);
    }
    final regex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@'
      r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]'
      r'(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    return regex.hasMatch(value);
  }

  String? validateAllSections() {
    if (isAlreadySubmitted.value || isReadOnly.value) {
      return 'This Centre Visit Report has already been shared.';
    }
    if (pjpId.isEmpty) return 'PJP ID is missing.';
    if (cvfId.isEmpty) return 'CVF ID is missing.';
    if (!args.isCheckedOut) {
      return 'Share Report is available only after check-out.';
    }
    if (!pdfAvailable.value && attachmentUrl.value.trim().isEmpty) {
      return 'CVF report attachment is not available. Please try again.';
    }
    // if (toEmails.isEmpty) {
    //   return 'Recipient (To) email is not available for this centre.';
    // }
    for (final to in toEmails) {
      if (!_isValidEmail(to)) {
        return 'Invalid recipient (To) email: $to';
      }
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

  Future<bool> _confirmSendOnce() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Send report?'),
        content: const Text(
          'Once this Centre Visit Report is sent, it cannot be edited or '
          'sent again. You will only be able to view the email preview.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Send Report'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result == true;
  }

  Future<void> sendReport() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isSending.value) return;

    if (isAlreadySubmitted.value || isReadOnly.value) {
      Get.snackbar(
        'Already Sent',
        'This report has already been shared. You can only view the preview.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

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

    final confirmed = await _confirmSendOnce();
    if (!confirmed) return;

    isSending.value = true;
    try {
      debugPrint(generateEmailBody());
      final response = await _repository.sendReportApi(
        data: buildSendPayload(),
      );

      if (!response.success) {
        Get.snackbar(
          'Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // One-time send: lock form permanently for this visit.
      isAlreadySubmitted.value = true;
      isReadOnly.value = true;
      args.cvf.isEmailSubmitted = true;

      await Get.dialog(
        AlertDialog(
          title: const Text('Report Sent Successfully'),
          content: Text(
            (response.message.isEmpty
                    ? 'The Centre Visit Report has been sent successfully.'
                    : response.message) +
                '\n\nThis report can no longer be edited or sent again. '
                    'You can continue viewing the email preview.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Get.back(),
              child: const Text('View Preview'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      // Stay on page in read-only preview mode (no regenerate / resend).
      _bumpPreview();
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
