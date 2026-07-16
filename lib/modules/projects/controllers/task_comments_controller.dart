import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';
import 'package:Intranet/modules/projects/models/task_comments_payload.dart';
import 'package:Intranet/modules/projects/repositories/task_comments_repository.dart';
import 'package:Intranet/modules/projects/services/task_attachment_upload_service.dart';
import 'package:Intranet/modules/projects/utils/projects_file_opener.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';

/// Task Comments / Communication — API + offline Hive cache.
class TaskCommentsController extends GetxController {
  TaskCommentsController({
    required this.args,
    required TaskCommentsRepository repository,
    TaskAttachmentUploadService? uploadService,
    ImagePicker? imagePicker,
    Connectivity? connectivity,
  })  : _repository = repository,
        _uploadService = uploadService ?? TaskAttachmentUploadService(),
        _imagePicker = imagePicker ?? ImagePicker(),
        _connectivity = connectivity ?? Connectivity();

  static const allowedExtensions = <String>{
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'm4v',
  };

  static const maxBytes = 50 * 1024 * 1024; // 50MB

  final TaskCommentsArgs args;
  final TaskCommentsRepository _repository;
  final TaskAttachmentUploadService _uploadService;
  final ImagePicker _imagePicker;
  final Connectivity _connectivity;

  final RxList<TaskComment> comments = <TaskComment>[].obs;
  final RxList<TaskCommentMember> members = <TaskCommentMember>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool servingFromCache = false.obs;
  final RxBool isPickingFile = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString typingUserName = RxnString();

  /// Local comment ids currently uploading (prevents double-retry).
  final Set<String> _uploadingIds = <String>{};

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get taskId => args.task.id;

  String get taskTitle =>
      args.task.title.isEmpty ? 'Untitled' : args.task.title;

  String get projectName =>
      args.projectName.isEmpty ? 'Project' : args.projectName;

  String get parentSubtitle =>
      args.parentTaskTitle.trim().isEmpty ? projectName : args.parentTaskTitle;

  String get currentUserName {
    final fromArg = args.currentUserName.trim();
    if (fromArg.isNotEmpty) return fromArg;
    return 'User';
  }

  int get onlineMemberCount => members.where((m) => m.isOnline).length;

  @override
  void onInit() {
    super.onInit();
    observeConnectivity();
    loadComments();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  Future<void> observeConnectivity() async {
    await _updateConnectivityFlag();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((results) async {
      final offline = results.every((r) => r == ConnectivityResult.none);
      final wasOffline = isOffline.value;
      isOffline.value = offline;
      if (wasOffline && !offline) {
        await sync();
        await _retryPendingUploads();
      }
    });
  }

  Future<void> _updateConnectivityFlag() async {
    final results = await _connectivity.checkConnectivity();
    isOffline.value = results.every((r) => r == ConnectivityResult.none);
  }

  Future<void> loadComments() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await loadOffline();
      if (!isOffline.value) {
        await sync();
      } else if (comments.isEmpty) {
        errorMessage.value = 'No internet connection.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOffline() async {
    final cached = await _repository.loadOffline(taskId: taskId);
    if (cached != null) {
      _applyPayload(cached, fromCache: true);
    }
  }

  Future<void> sync() async {
    if (isOffline.value) {
      servingFromCache.value = comments.isNotEmpty;
      return;
    }
    try {
      final remote = await _repository.sync(taskId: taskId);
      _applyPayload(remote, fromCache: false);
      errorMessage.value = null;
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshComments() async {
    isRefreshing.value = true;
    errorMessage.value = null;
    try {
      await _updateConnectivityFlag();
      if (isOffline.value) {
        await loadOffline();
        if (comments.isEmpty) {
          errorMessage.value = 'No internet connection.';
        }
      } else {
        final remote = await _repository.refresh(taskId: taskId);
        _applyPayload(remote, fromCache: false);
      }
    } on DashboardFailure catch (e) {
      await _handleFailure(e);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> pickGalleryImage() => _pickImage(ImageSource.gallery);

  Future<void> pickCameraImage() => _pickImage(ImageSource.camera);

  Future<void> pickGalleryVideo() async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    try {
      final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      await _attachPickedXFile(file);
    } catch (e) {
      debugPrint('[TaskAttach] pickGalleryVideo error: $e');
      Get.snackbar(
        'Attachment',
        'Unable to pick video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPickingFile.value = false;
    }
  }

  Future<void> pickPdfOrFiles() async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions.toList(growable: false),
        allowMultiple: false,
        withData: true, // required for web; safe on mobile too
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final path = file.path ?? '';
      List<int>? bytes = file.bytes;
      if ((bytes == null || bytes.isEmpty) && path.isNotEmpty && !kIsWeb) {
        // Rare: path-only pick — try XFile read.
        try {
          bytes = await XFile(path).readAsBytes();
        } catch (e) {
          debugPrint('[TaskAttach] path bytes read failed: $e');
        }
      }
      if ((bytes == null || bytes.isEmpty) && path.isEmpty) {
        Get.snackbar(
          'Attachment',
          'Unable to read selected file.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await attachLocalFile(
        path: kIsWeb ? '' : path,
        name: file.name,
        sizeBytes: bytes?.length ?? file.size,
        bytes: bytes,
      );
    } catch (e) {
      debugPrint('[TaskAttach] pickPdfOrFiles error: $e');
      Get.snackbar(
        'Attachment',
        'Unable to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPickingFile.value = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isPickingFile.value) return;
    isPickingFile.value = true;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      await _attachPickedXFile(file);
    } catch (e) {
      debugPrint('[TaskAttach] pickImage error: $e');
      Get.snackbar(
        'Attachment',
        'Unable to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPickingFile.value = false;
    }
  }

  Future<void> _attachPickedXFile(XFile file) async {
    debugPrint(
      '[TaskAttach] picked name=${file.name} path=${file.path} '
      'platform=${kIsWeb ? 'web' : defaultTargetPlatform.name}',
    );
    final bytes = await file.readAsBytes();
    await attachLocalFile(
      path: kIsWeb ? '' : file.path,
      name: file.name,
      sizeBytes: bytes.length,
      bytes: bytes,
    );
  }

  /// Adds the file to the chat list immediately, then uploads + inserts.
  Future<void> attachLocalFile({
    required String name,
    required int sizeBytes,
    String path = '',
    List<int>? bytes,
  }) async {
    final ext = TaskAttachmentList.extensionOf(
      name.isNotEmpty ? name : path,
    );
    if (!allowedExtensions.contains(ext)) {
      Get.snackbar(
        'Attachment',
        'Only PDF, images, and videos are allowed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (sizeBytes > maxBytes) {
      Get.snackbar(
        'Attachment',
        'File exceeds the 50MB limit.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if ((bytes == null || bytes.isEmpty) && path.trim().isEmpty) {
      Get.snackbar(
        'Attachment',
        'Invalid file. Please select again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final type = _typeForExtension(ext);
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final fileName =
        name.isEmpty ? path.split(RegExp(r'[/\\]')).last : name;
    debugPrint(
      '[TaskAttach] queue localId=$localId fileName=$fileName '
      'type=$type size=$sizeBytes path=$path bytes=${bytes?.length ?? 0}',
    );
    final attachment = TaskCommentAttachment(
      id: '${localId}_file',
      fileName: fileName,
      sizeLabel: _formatSize(sizeBytes),
      type: type,
      localPath: path,
      bytes: bytes,
      thumbnailUrl: type == CommentAttachmentType.image
          ? (path.isNotEmpty ? path : '')
          : '',
    );
    final pending = TaskComment(
      id: localId,
      senderName: currentUserName,
      message: '',
      sentAt: DateTime.now(),
      isMine: true,
      deliveryStatus: CommentDeliveryStatus.sending,
      attachments: [attachment],
      createdBy: args.userId.toString(),
    );
    comments.add(pending);
    await _uploadPending(localId);
  }

  Future<void> retryUpload(String commentId) async {
    final i = comments.indexWhere((c) => c.id == commentId);
    if (i < 0) return;
    final c = comments[i];
    if (c.deliveryStatus != CommentDeliveryStatus.failed) return;
    if (c.attachments.isEmpty || !c.attachments.first.hasUploadSource) {
      Get.snackbar(
        'Retry',
        'Original file is no longer available. Please attach again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    debugPrint('[TaskAttach] retry commentId=$commentId');
    comments[i] = c.copyWith(deliveryStatus: CommentDeliveryStatus.sending);
    await _uploadPending(commentId);
  }

  Future<void> _retryPendingUploads() async {
    final failed = comments
        .where((c) =>
            c.id.startsWith('local_') &&
            c.deliveryStatus == CommentDeliveryStatus.failed)
        .map((c) => c.id)
        .toList(growable: false);
    for (final id in failed) {
      await retryUpload(id);
    }
  }

  Future<void> _uploadPending(String commentId) async {
    if (_uploadingIds.contains(commentId)) return;
    final i = comments.indexWhere((c) => c.id == commentId);
    if (i < 0) return;
    final comment = comments[i];
    if (comment.attachments.isEmpty) return;

    final attachment = comment.attachments.first;
    final localPath = attachment.localPath.trim();
    final fileName = attachment.fileName;
    final bytes = attachment.bytes;
    if (!attachment.hasUploadSource) {
      _markFailed(commentId, 'Original file data is missing.');
      return;
    }

    await _updateConnectivityFlag();
    if (isOffline.value) {
      _markFailed(commentId, 'No internet connection.');
      return;
    }

    _uploadingIds.add(commentId);
    try {
      final isVideo = attachment.type == CommentAttachmentType.video;
      final isImage = attachment.type == CommentAttachmentType.image;
      debugPrint(
        '[TaskAttach] _uploadPending commentId=$commentId '
        'fileName=$fileName path=$localPath bytes=${bytes?.length ?? 0}',
      );
      final uploaded = await _uploadService.uploadAndAttach(
        localPath: localPath,
        taskId: taskId,
        userId: args.userId,
        fileName: fileName,
        bytes: bytes,
        isVideoFile: isVideo,
        isImageFile: isImage,
      );

      final idx = comments.indexWhere((c) => c.id == commentId);
      if (idx < 0) return;
      final current = comments[idx];
      final prev = current.attachments.first;
      final updatedAttachment = TaskCommentAttachment(
        id: prev.id,
        fileName: uploaded.originalName.isNotEmpty
            ? uploaded.originalName
            : (fileName.isNotEmpty ? fileName : prev.fileName),
        sizeLabel: uploaded.sizeBytes > 0
            ? _formatSize(uploaded.sizeBytes)
            : prev.sizeLabel,
        type: prev.type,
        url: uploaded.location,
        localPath: prev.localPath,
        bytes: prev.bytes, // keep for retry if insert later fails
        thumbnailUrl: prev.type == CommentAttachmentType.image
            ? uploaded.location
            : prev.thumbnailUrl,
      );
      comments[idx] = current.copyWith(
        deliveryStatus: CommentDeliveryStatus.read,
        attachments: [updatedAttachment],
      );
      debugPrint(
        '[TaskAttach] SUCCESS commentId=$commentId url=${uploaded.location}',
      );

      // Refresh timeline so server-side attachment id/date align.
      unawaited(sync());
    } on DashboardFailure catch (e) {
      debugPrint('[TaskAttach] FAILED commentId=$commentId error=${e.message}');
      _markFailed(commentId, e.message);
    } catch (e) {
      debugPrint('[TaskAttach] FAILED commentId=$commentId error=$e');
      _markFailed(commentId, e.toString());
    } finally {
      _uploadingIds.remove(commentId);
    }
  }

  void _markFailed(String commentId, String message) {
    final i = comments.indexWhere((c) => c.id == commentId);
    if (i >= 0) {
      comments[i] =
          comments[i].copyWith(deliveryStatus: CommentDeliveryStatus.failed);
    }
    debugPrint('[TaskAttach] markFailed commentId=$commentId message=$message');
    Get.snackbar(
      'Upload failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void addReaction(String commentId, {String emoji = '👍'}) {
    final i = comments.indexWhere((c) => c.id == commentId);
    if (i < 0) return;
    final c = comments[i];
    if (c.reactionEmoji == emoji) {
      comments[i] = c.copyWith(reactionCount: c.reactionCount + 1);
    } else {
      comments[i] = c.copyWith(reactionEmoji: emoji, reactionCount: 1);
    }
  }

  Future<void> openAttachment(TaskCommentAttachment attachment) {
    return ProjectsFileOpener.openAttachment(attachment);
  }

  void onAttachmentOptionSelected(String label) {
    switch (label) {
      case 'Image':
        unawaited(pickGalleryImage());
        return;
      case 'Camera':
        unawaited(pickCameraImage());
        return;
      case 'Video':
        unawaited(pickGalleryVideo());
        return;
      case 'PDF':
      case 'Files':
      default:
        unawaited(pickPdfOrFiles());
    }
  }

  void _applyPayload(TaskCommentsPayload payload, {required bool fromCache}) {
    final localPending = comments
        .where((c) => c.id.startsWith('local_'))
        .toList(growable: false);

    final remote = payload.toTimeline(userId: args.userId);
    comments.assignAll(remote);

    // Keep local uploads at the bottom until the server timeline includes them.
    for (final local in localPending) {
      final localUrl = local.attachments.isEmpty
          ? ''
          : local.attachments.first.url.trim();
      final alreadyOnServer = localUrl.isNotEmpty &&
          remote.any(
            (r) => r.attachments.any((a) => a.url.trim() == localUrl),
          );
      final keepLocal = !alreadyOnServer &&
          (local.deliveryStatus == CommentDeliveryStatus.sending ||
              local.deliveryStatus == CommentDeliveryStatus.failed ||
              localUrl.isNotEmpty);
      if (keepLocal) {
        comments.add(local);
      }
    }
    comments.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    members.assignAll(payload.toMembers());
    servingFromCache.value = fromCache;
    typingUserName.value = null;
  }

  Future<void> _handleFailure(DashboardFailure e) async {
    if (comments.isNotEmpty) {
      servingFromCache.value = true;
      Get.snackbar(
        'Using cached comments',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      final cached = await _repository.loadOffline(taskId: taskId);
      if (cached != null) {
        _applyPayload(cached, fromCache: true);
      } else {
        errorMessage.value = e.message;
      }
    }
  }

  static CommentAttachmentType _typeForExtension(String ext) {
    switch (ext) {
      case 'pdf':
        return CommentAttachmentType.pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'bmp':
        return CommentAttachmentType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
      case 'm4v':
        return CommentAttachmentType.video;
      default:
        return CommentAttachmentType.other;
    }
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
