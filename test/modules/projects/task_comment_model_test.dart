import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';

void main() {
  group('TaskCommentAttachment', () {
    test('openUrl prefers remote url over localPath', () {
      const a = TaskCommentAttachment(
        id: '1',
        fileName: 'a.png',
        sizeLabel: '1 KB',
        type: CommentAttachmentType.image,
        url: 'https://cdn.example.com/a.png',
        localPath: '/tmp/a.png',
      );
      expect(a.openUrl, 'https://cdn.example.com/a.png');
    });

    test('openUrl falls back to localPath', () {
      const a = TaskCommentAttachment(
        id: '1',
        fileName: 'a.pdf',
        sizeLabel: '2 KB',
        type: CommentAttachmentType.pdf,
        localPath: '/tmp/a.pdf',
      );
      expect(a.openUrl, '/tmp/a.pdf');
    });

    test('hasUploadSource for bytes or localPath', () {
      const withPath = TaskCommentAttachment(
        id: '1',
        fileName: 'a.png',
        sizeLabel: '1 KB',
        type: CommentAttachmentType.image,
        localPath: '/tmp/a.png',
      );
      const withBytes = TaskCommentAttachment(
        id: '2',
        fileName: 'b.png',
        sizeLabel: '1 KB',
        type: CommentAttachmentType.image,
        bytes: [1, 2, 3],
      );
      const empty = TaskCommentAttachment(
        id: '3',
        fileName: 'c.png',
        sizeLabel: '0',
        type: CommentAttachmentType.image,
      );
      expect(withPath.hasUploadSource, isTrue);
      expect(withBytes.hasUploadSource, isTrue);
      expect(empty.hasUploadSource, isFalse);
    });
  });

  group('TaskComment', () {
    test('initials from senderName', () {
      final c = TaskComment(
        id: '1',
        senderName: 'Sudhir Patil',
        message: 'Hi',
        sentAt: DateTime(2026, 7, 20),
        isMine: true,
      );
      expect(c.initials, 'SP');
    });

    test('copyWith updates deliveryStatus', () {
      final c = TaskComment(
        id: 'local_1',
        senderName: 'Me',
        message: '',
        sentAt: DateTime(2026, 7, 20),
        isMine: true,
        deliveryStatus: CommentDeliveryStatus.sending,
      );
      final failed = c.copyWith(deliveryStatus: CommentDeliveryStatus.failed);
      expect(failed.deliveryStatus, CommentDeliveryStatus.failed);
      expect(failed.id, 'local_1');
    });
  });

  group('TaskCommentsArgs', () {
    test('props include task id and userId', () {
      final task = HierarchyTask.fromJson({
        'id': '42',
        'title': 'Task',
        'parent_task_id': '0',
      });
      final args = TaskCommentsArgs(
        task: task,
        userId: 100,
        projectName: 'Project',
      );
      expect(args.props, containsAll(['42', 100, 'Project']));
    });
  });
}
