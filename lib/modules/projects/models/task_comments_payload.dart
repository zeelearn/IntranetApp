import 'package:equatable/equatable.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';

/// Raw comment row from GetTaskAttachmentsAndComments.
class TaskApiComment extends Equatable {
  const TaskApiComment({
    required this.comment,
    required this.createdBy,
    required this.createdDate,
    required this.createdUser,
    required this.createdTime,
  });

  final String comment;
  final String createdBy;
  final String createdDate;
  final String createdUser;
  final String createdTime;

  factory TaskApiComment.fromJson(Map<String, dynamic> json) {
    return TaskApiComment(
      comment: _str(json['comment']),
      createdBy: _str(json['CreatedBy']),
      createdDate: _str(json['CreatedDate']),
      createdUser: _str(json['createduser']),
      createdTime: _str(json['createdtime']),
    );
  }

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'CreatedBy': createdBy,
        'CreatedDate': createdDate,
        'createduser': createdUser,
        'createdtime': createdTime,
      };

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  @override
  List<Object?> get props => [comment, createdBy, createdDate];
}

/// Raw file row from GetTaskAttachmentsAndComments.
class TaskApiFile extends Equatable {
  const TaskApiFile({
    required this.fileName,
    required this.filePath,
    required this.remarks,
    required this.createdBy,
    required this.createdUser,
    required this.createdDate,
  });

  final String fileName;
  final String filePath;
  final String remarks;
  final String createdBy;
  final String createdUser;
  final String createdDate;

  factory TaskApiFile.fromJson(Map<String, dynamic> json) {
    return TaskApiFile(
      fileName: TaskApiComment._str(json['file_name']),
      filePath: TaskApiComment._str(json['file_path']),
      remarks: TaskApiComment._str(json['remarks']),
      createdBy: TaskApiComment._str(json['CreatedBy']),
      createdUser: TaskApiComment._str(json['createduser']),
      createdDate: TaskApiComment._str(json['CreatedDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'file_name': fileName,
        'file_path': filePath,
        'remarks': remarks,
        'CreatedBy': createdBy,
        'createduser': createdUser,
        'CreatedDate': createdDate,
      };

  @override
  List<Object?> get props => [filePath, createdBy, createdDate];
}

/// Parsed payload for a task's comments + files.
class TaskCommentsPayload extends Equatable {
  const TaskCommentsPayload({
    required this.comments,
    required this.files,
    this.syncedAt,
  });

  final List<TaskApiComment> comments;
  final List<TaskApiFile> files;
  final DateTime? syncedAt;

  factory TaskCommentsPayload.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) map,
    ) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => map(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    DateTime? synced;
    final syncedRaw = json['syncedAt']?.toString();
    if (syncedRaw != null && syncedRaw.isNotEmpty) {
      synced = DateTime.tryParse(syncedRaw);
    }

    return TaskCommentsPayload(
      comments: parseList(json['comments'], TaskApiComment.fromJson),
      files: parseList(
        json['Files'] ?? json['files'],
        TaskApiFile.fromJson,
      ),
      syncedAt: synced,
    );
  }

  /// Parses API envelope `data[0]`.
  factory TaskCommentsPayload.fromApiEnvelope(Map<String, dynamic> decoded) {
    final raw = decoded['data'];
    Map<String, dynamic>? first;
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      first = Map<String, dynamic>.from(raw.first as Map);
    } else if (raw is Map) {
      first = Map<String, dynamic>.from(raw);
    }
    if (first == null) {
      return TaskCommentsPayload(
        comments: const [],
        files: const [],
        syncedAt: DateTime.now(),
      );
    }
    return TaskCommentsPayload.fromJson(first)
        .copyWith(syncedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'comments': comments.map((e) => e.toJson()).toList(growable: false),
        'Files': files.map((e) => e.toJson()).toList(growable: false),
        if (syncedAt != null) 'syncedAt': syncedAt!.toIso8601String(),
      };

  TaskCommentsPayload copyWith({
    List<TaskApiComment>? comments,
    List<TaskApiFile>? files,
    DateTime? syncedAt,
  }) {
    return TaskCommentsPayload(
      comments: comments ?? this.comments,
      files: files ?? this.files,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  /// Merges comments + files into UI [TaskComment]s, oldest first (chat order).
  List<TaskComment> toTimeline({required int userId}) {
    final userKey = userId.toString().trim();
    final items = <TaskComment>[];

    for (var i = 0; i < comments.length; i++) {
      final c = comments[i];
      final at = _parseDate(c.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
      items.add(
        TaskComment(
          id: 'c_${c.createdDate}_$i',
          senderName: c.createdUser.isEmpty ? 'User' : c.createdUser,
          message: c.comment,
          sentAt: at,
          isMine: userKey.isNotEmpty && c.createdBy.trim() == userKey,
          deliveryStatus: CommentDeliveryStatus.read,
          createdBy: c.createdBy,
        ),
      );
    }

    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      if (f.filePath.trim().isEmpty) continue;
      final at =
          _parseDate(f.createdDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final name = f.fileName.trim().isEmpty
          ? TaskAttachmentList.fileName(f.filePath)
          : f.fileName.trim();
      final type = _typeFor(f.filePath, name);
      items.add(
        TaskComment(
          id: 'f_${f.createdDate}_$i',
          senderName: f.createdUser.isEmpty ? 'User' : f.createdUser,
          message: f.remarks,
          sentAt: at,
          isMine: userKey.isNotEmpty && f.createdBy.trim() == userKey,
          deliveryStatus: CommentDeliveryStatus.read,
          createdBy: f.createdBy,
          attachments: [
            TaskCommentAttachment(
              id: 'att_${f.createdDate}_$i',
              fileName: name,
              sizeLabel: type.name.toUpperCase(),
              type: type,
              url: f.filePath.trim(),
              thumbnailUrl: type == CommentAttachmentType.image
                  ? f.filePath.trim()
                  : '',
            ),
          ],
        ),
      );
    }

    items.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return items;
  }

  List<TaskCommentMember> toMembers() {
    final seen = <String>{};
    final out = <TaskCommentMember>[];
    void addName(String name) {
      final n = name.trim();
      if (n.isEmpty) return;
      final key = n.toLowerCase();
      if (seen.contains(key)) return;
      seen.add(key);
      out.add(TaskCommentMember(name: n, isOnline: false));
    }

    for (final c in comments) {
      addName(c.createdUser);
    }
    for (final f in files) {
      addName(f.createdUser);
    }
    return out;
  }

  static DateTime? _parseDate(String raw) => ProjectDateUtils.tryParse(raw);

  static CommentAttachmentType _typeFor(String path, String name) {
    final ext = TaskAttachmentList.extensionOf(
      name.isNotEmpty ? name : path,
    );
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
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
        return CommentAttachmentType.document;
      default:
        return CommentAttachmentType.other;
    }
  }

  @override
  List<Object?> get props => [comments, files, syncedAt];
}
