import 'package:equatable/equatable.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';

/// Delivery indicators matching Figma (Sending → Sent → Delivered → Read).
enum CommentDeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum CommentAttachmentType {
  pdf,
  image,
  video,
  document,
  other,
}

class TaskCommentAttachment extends Equatable {
  const TaskCommentAttachment({
    required this.id,
    required this.fileName,
    required this.sizeLabel,
    required this.type,
    this.url = '',
    this.localPath = '',
    this.thumbnailUrl = '',
    this.bytes,
  });

  final String id;
  final String fileName;
  final String sizeLabel;
  final CommentAttachmentType type;

  /// Remote URL (`file_path`) for in-app / external open.
  final String url;
  final String localPath;
  final String thumbnailUrl;

  /// In-memory bytes for web / cross-platform upload + retry.
  final List<int>? bytes;

  String get openUrl {
    final u = url.trim();
    if (u.isNotEmpty) return u;
    return localPath.trim();
  }

  bool get hasUploadSource =>
      (bytes != null && bytes!.isNotEmpty) || localPath.trim().isNotEmpty;

  @override
  List<Object?> get props => [id, fileName, type, url, localPath, bytes?.length];
}

class TaskComment extends Equatable {
  const TaskComment({
    required this.id,
    required this.senderName,
    required this.message,
    required this.sentAt,
    required this.isMine,
    this.avatarInitials = '',
    this.deliveryStatus = CommentDeliveryStatus.sent,
    this.attachments = const [],
    this.reactionEmoji = '',
    this.reactionCount = 0,
    this.createdBy = '',
  });

  final String id;
  final String senderName;
  final String message;
  final DateTime sentAt;
  final bool isMine;
  final String avatarInitials;
  final CommentDeliveryStatus deliveryStatus;
  final List<TaskCommentAttachment> attachments;
  final String reactionEmoji;
  final int reactionCount;

  /// API `CreatedBy` user id string.
  final String createdBy;

  String get initials {
    if (avatarInitials.trim().isNotEmpty) return avatarInitials.trim();
    final parts = senderName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.isEmpty ? '?' : p.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  TaskComment copyWith({
    String? message,
    CommentDeliveryStatus? deliveryStatus,
    List<TaskCommentAttachment>? attachments,
    String? reactionEmoji,
    int? reactionCount,
    String? createdBy,
  }) {
    return TaskComment(
      id: id,
      senderName: senderName,
      message: message ?? this.message,
      sentAt: sentAt,
      isMine: isMine,
      avatarInitials: avatarInitials,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      attachments: attachments ?? this.attachments,
      reactionEmoji: reactionEmoji ?? this.reactionEmoji,
      reactionCount: reactionCount ?? this.reactionCount,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props =>
      [id, senderName, message, sentAt, isMine, createdBy];
}

/// Online member chip for the header / members sheet.
class TaskCommentMember extends Equatable {
  const TaskCommentMember({
    required this.name,
    this.isOnline = false,
  });

  final String name;
  final bool isOnline;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.isEmpty ? '?' : p.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [name, isOnline];
}

/// Args to open Task Comments / Communication screen.
class TaskCommentsArgs extends Equatable {
  const TaskCommentsArgs({
    required this.task,
    required this.userId,
    required this.projectName,
    this.parentTaskTitle = '',
    this.currentUserName = '',
  });

  final HierarchyTask task;
  final int userId;
  final String projectName;
  final String parentTaskTitle;
  final String currentUserName;

  @override
  List<Object?> get props => [task.id, userId, projectName];
}
