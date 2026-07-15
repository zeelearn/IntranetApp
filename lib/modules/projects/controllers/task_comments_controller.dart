import 'package:get/get.dart';
import 'package:Intranet/modules/projects/controllers/task_hierarchy_controller.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';

/// Task Comments / Communication — static data until API is wired.
class TaskCommentsController extends GetxController {
  TaskCommentsController({required this.args});

  final TaskCommentsArgs args;

  final RxList<TaskComment> comments = <TaskComment>[].obs;
  final RxList<TaskCommentMember> members = <TaskCommentMember>[].obs;
  final RxString draft = ''.obs;
  final RxBool isSending = false.obs;
  final RxnString typingUserName = RxnString();

  String get taskTitle =>
      args.task.title.isEmpty ? 'Untitled' : args.task.title;

  String get projectName =>
      args.projectName.isEmpty ? 'Project' : args.projectName;

  String get parentSubtitle =>
      args.parentTaskTitle.trim().isEmpty ? projectName : args.parentTaskTitle;

  String get currentUserName {
    final fromArg = args.currentUserName.trim();
    if (fromArg.isNotEmpty) return fromArg;
    return TaskHierarchyController.myTasksUserName;
  }

  int get onlineMemberCount => members.where((m) => m.isOnline).length;

  @override
  void onInit() {
    super.onInit();
    _loadStaticData();
  }

  void onDraftChanged(String value) => draft.value = value;

  Future<void> sendComment() async {
    final text = draft.value.trim();
    if (text.isEmpty || isSending.value) return;
    isSending.value = true;
    final pending = TaskComment(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      senderName: currentUserName,
      message: text,
      sentAt: DateTime.now(),
      isMine: true,
      deliveryStatus: CommentDeliveryStatus.sending,
    );
    comments.add(pending);
    draft.value = '';

    // Simulate send → read pipeline until API exists.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _updateStatus(pending.id, CommentDeliveryStatus.sent);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _updateStatus(pending.id, CommentDeliveryStatus.delivered);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _updateStatus(pending.id, CommentDeliveryStatus.read);
    isSending.value = false;
  }

  void addReaction(String commentId, {String emoji = '👍'}) {
    final i = comments.indexWhere((c) => c.id == commentId);
    if (i < 0) return;
    final c = comments[i];
    if (c.reactionEmoji == emoji) {
      comments[i] = c.copyWith(
        reactionCount: c.reactionCount + 1,
      );
    } else {
      comments[i] = c.copyWith(
        reactionEmoji: emoji,
        reactionCount: 1,
      );
    }
  }

  /// Stub for attachment picker — API / file pick later.
  void onAttachmentOptionSelected(String label) {
    Get.snackbar(
      'Attachments',
      '$label — coming soon',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateStatus(String id, CommentDeliveryStatus status) {
    final i = comments.indexWhere((c) => c.id == id);
    if (i < 0) return;
    comments[i] = comments[i].copyWith(deliveryStatus: status);
  }

  void _loadStaticData() {
    members.assignAll(const [
      TaskCommentMember(name: 'Deepak Sharma', isOnline: true),
      TaskCommentMember(name: 'Nikul Kumar', isOnline: true),
      TaskCommentMember(name: 'Priya Patel', isOnline: true),
      TaskCommentMember(name: 'Rahul Mehta', isOnline: true),
      TaskCommentMember(name: 'Anita Shah', isOnline: false),
    ]);

    final me = currentUserName;
    comments.assignAll([
      TaskComment(
        id: 'c1',
        senderName: 'Deepak Sharma',
        message:
            'Please review the signup flow wireframes and share feedback by EOD.',
        sentAt: DateTime(2023, 8, 22, 10, 15),
        isMine: false,
        deliveryStatus: CommentDeliveryStatus.read,
        reactionEmoji: '👍',
        reactionCount: 1,
      ),
      TaskComment(
        id: 'c2',
        senderName: me,
        message: 'Sure, I will take a look today afternoon.',
        sentAt: DateTime(2023, 8, 22, 10, 42),
        isMine: true,
        deliveryStatus: CommentDeliveryStatus.read,
      ),
      TaskComment(
        id: 'c3',
        senderName: 'Deepak Sharma',
        message: 'Requirements document attached for reference.',
        sentAt: DateTime(2023, 8, 22, 11, 5),
        isMine: false,
        deliveryStatus: CommentDeliveryStatus.read,
        attachments: const [
          TaskCommentAttachment(
            id: 'a1',
            fileName: 'Zoho_CW_Requirements.pdf',
            sizeLabel: '1.2 MB • PDF',
            type: CommentAttachmentType.pdf,
          ),
        ],
      ),
      TaskComment(
        id: 'c4',
        senderName: me,
        message: 'Reviewed. Adding wireframe assets for the center handover.',
        sentAt: DateTime(2023, 8, 22, 14, 20),
        isMine: true,
        deliveryStatus: CommentDeliveryStatus.read,
        attachments: const [
          TaskCommentAttachment(
            id: 'a2',
            fileName: 'Zoho_CW_Wireframes.png',
            sizeLabel: '860 KB • PNG',
            type: CommentAttachmentType.image,
          ),
        ],
      ),
      TaskComment(
        id: 'c5',
        senderName: 'Priya Patel',
        message: 'Looks good from product side. Please proceed.',
        sentAt: DateTime(2023, 8, 23, 9, 30),
        isMine: false,
        deliveryStatus: CommentDeliveryStatus.read,
      ),
    ]);

    typingUserName.value = 'Deepak Sharma';
  }
}
