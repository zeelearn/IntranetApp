import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/task_comments_binding.dart';
import 'package:Intranet/modules/projects/controllers/task_comments_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/hierarchy_task.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

/// Figma Task Comments / Communication screen (API + offline).
class TaskCommentsScreen extends StatelessWidget {
  const TaskCommentsScreen({super.key, required this.args});

  final TaskCommentsArgs args;

  static Future<void> open(TaskCommentsArgs args) async {
    await Get.to(
      () => TaskCommentsScreen(args: args),
      binding: TaskCommentsBinding(args: args),
      arguments: args,
    );
  }

  String get _tag => TaskCommentsBinding.makeTag(args);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TaskCommentsController>(tag: _tag)) {
      TaskCommentsBinding(args: args).dependencies();
    }
    final controller = Get.find<TaskCommentsController>(tag: _tag);
    final task = args.task;

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          _Header(
            controller: controller,
            onBack: () => Get.back(),
            onRefresh: controller.refreshComments,
          ),
          Expanded(
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _TaskSummaryCard(task: task, controller: controller),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final loading = controller.isLoading.value;
                    final items = controller.comments.toList(growable: false);
                    final typing = controller.typingUserName.value;
                    final error = controller.errorMessage.value;
                    final fromCache = controller.servingFromCache.value ||
                        controller.isOffline.value;

                    if (loading && items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    Widget body;
                    if (error != null && items.isEmpty) {
                      body = ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    error,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: DashboardColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    style: DashboardColors.primaryFilledButton(),
                                    onPressed: controller.refreshComments,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (items.isEmpty) {
                      body = ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No comments or files yet',
                              style: GoogleFonts.poppins(
                                color: DashboardColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      body = Column(
                        children: [
                          if (fromCache)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                              child: Text(
                                controller.isOffline.value
                                    ? 'Offline — showing cached comments'
                                    : 'Showing cached comments',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: DashboardColors.textMuted,
                                ),
                              ),
                            ),
                          Expanded(
                            child: RefreshIndicator(
                              color: DashboardColors.primary,
                              onRefresh: controller.refreshComments,
                              child: _MessageThread(
                                comments: items,
                                typingUserName: typing,
                                onReact: controller.addReaction,
                                onOpenAttachment: controller.openAttachment,
                                onRetryUpload: controller.retryUpload,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (items.isEmpty) {
                      return RefreshIndicator(
                        color: DashboardColors.primary,
                        onRefresh: controller.refreshComments,
                        child: body,
                      );
                    }
                    return body;
                  }),
                ),
              ],
            ),
          ),
          _ComposerBar(controller: controller),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.onBack,
    required this.onRefresh,
  });

  final TaskCommentsController controller;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4, top + 6, 8, 28),
      decoration: const BoxDecoration(
        color: DashboardColors.primary,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Comments',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  controller.projectName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Obx(() {
            final online = controller.onlineMemberCount;
            return InkWell(
              onTap: () => _showMembers(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.groups_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$online',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final busy = controller.isRefreshing.value;
            return IconButton(
              tooltip: 'Refresh',
              onPressed: busy ? null : onRefresh,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
            );
          }),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (v) {
              if (v == 'refresh') onRefresh();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
    );
  }

  void _showMembers(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.onlineMemberCount} members online',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final m in controller.members)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: DashboardColors.primaryLight,
                        child: Text(
                          m.initials,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: DashboardColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (m.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: DashboardColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(m.name, style: GoogleFonts.poppins(fontSize: 13)),
                  subtitle: Text(
                    m.isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: DashboardColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({
    required this.task,
    required this.controller,
  });

  final HierarchyTask task;
  final TaskCommentsController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x1A000000),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: task.statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    task.statusChip,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.taskTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        controller.parentSubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: task.statusColor),
                  ),
                  child: Text(
                    task.statusName.isEmpty
                        ? _statusLabel(task.statusChip)
                        : task.statusName,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: task.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetaCol(
                    icon: Icons.calendar_today_outlined,
                    label: 'Plan End',
                    value: ProjectDateUtils.formatReadable(task.dueDate),
                  ),
                ),
                Expanded(
                  child: _MetaCol(
                    icon: Icons.person_outline_rounded,
                    label: 'Responsible',
                    value: task.responsiblePerson.trim().isEmpty
                        ? '—'
                        : task.responsiblePerson.trim(),
                  ),
                ),
                Expanded(
                  child: _MetaCol(
                    icon: Icons.flag_outlined,
                    label: 'Priority',
                    value: task.priority.trim().isEmpty
                        ? '—'
                        : task.priority.trim(),
                    valueColor: task.priorityColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String chip) {
    switch (chip.toUpperCase()) {
      case 'IP':
        return 'In Progress';
      case 'C':
        return 'Completed';
      case 'BPC':
        return 'BP Completed';
      default:
        return 'Pending';
    }
  }
}

class _MetaCol extends StatelessWidget {
  const _MetaCol({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: DashboardColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '—' : value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? DashboardColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MessageThread extends StatefulWidget {
  const _MessageThread({
    required this.comments,
    required this.typingUserName,
    required this.onReact,
    required this.onOpenAttachment,
    required this.onRetryUpload,
  });

  final List<TaskComment> comments;
  final String? typingUserName;
  final void Function(String commentId) onReact;
  final void Function(TaskCommentAttachment attachment) onOpenAttachment;
  final void Function(String commentId) onRetryUpload;

  @override
  State<_MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<_MessageThread> {
  final ScrollController _scrollController = ScrollController();
  int _lastCommentCount = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant _MessageThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    final countChanged = widget.comments.length != _lastCommentCount;
    final typingChanged = widget.typingUserName != oldWidget.typingUserName;
    if (countChanged || typingChanged) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _lastCommentCount = widget.comments.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;
      _scrollController.jumpTo(max);
      // Second pass after layout settles (images / separators).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <_ThreadEntry>[];
    DateTime? lastDay;
    for (final c in widget.comments) {
      final day = DateTime(c.sentAt.year, c.sentAt.month, c.sentAt.day);
      if (lastDay == null || day != lastDay) {
        grouped.add(_ThreadEntry.date(day));
        lastDay = day;
      }
      grouped.add(_ThreadEntry.message(c));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: grouped.length + (widget.typingUserName != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == grouped.length && widget.typingUserName != null) {
          return _TypingIndicator(name: widget.typingUserName!);
        }
        final entry = grouped[index];
        if (entry.date != null) {
          return _DateSeparator(date: entry.date!);
        }
        final comment = entry.comment!;
        return _MessageBubble(
          comment: comment,
          onReact: () => widget.onReact(comment.id),
          onOpenAttachment: widget.onOpenAttachment,
          onRetryUpload: () => widget.onRetryUpload(comment.id),
        );
      },
    );
  }
}

class _ThreadEntry {
  _ThreadEntry.date(this.date) : comment = null;
  _ThreadEntry.message(this.comment) : date = null;

  final DateTime? date;
  final TaskComment? comment;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _formatDay(date),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DashboardColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.comment,
    required this.onReact,
    required this.onOpenAttachment,
    required this.onRetryUpload,
  });

  final TaskComment comment;
  final VoidCallback onReact;
  final void Function(TaskCommentAttachment attachment) onOpenAttachment;
  final VoidCallback onRetryUpload;

  @override
  Widget build(BuildContext context) {
    final mine = comment.isMine;
    final bubbleColor =
        mine ? DashboardColors.primaryLight : Colors.white;
    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            _Avatar(initials: comment.initials),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!mine)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      comment.senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
                Material(
                  color: bubbleColor,
                  elevation: mine ? 0 : 1,
                  shadowColor: const Color(0x14000000),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(mine ? 14 : 4),
                    bottomRight: Radius.circular(mine ? 4 : 14),
                  ),
                  child: InkWell(
                    onLongPress: onReact,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (comment.message.isNotEmpty)
                            Text(
                              comment.message,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: DashboardColors.textDark,
                                height: 1.35,
                              ),
                            ),
                          for (final file in comment.attachments) ...[
                            if (comment.message.isNotEmpty)
                              const SizedBox(height: 8),
                            _AttachmentTile(
                              attachment: file,
                              onTap: () => onOpenAttachment(file),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(comment.sentAt),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: DashboardColors.textMuted,
                                ),
                              ),
                              if (mine) ...[
                                const SizedBox(width: 4),
                                if (comment.deliveryStatus ==
                                    CommentDeliveryStatus.failed)
                                  InkWell(
                                    onTap: onRetryUpload,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 14,
                                            color: DashboardColors.error,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Retry',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: DashboardColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  _DeliveryIcon(
                                    status: comment.deliveryStatus,
                                  ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (comment.reactionCount > 0 &&
                    comment.reactionEmoji.isNotEmpty)
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '${comment.reactionEmoji} ${comment.reactionCount}',
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            _Avatar(initials: comment.initials),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: DashboardColors.primary.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: DashboardColors.primary,
        ),
      ),
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon({required this.status});

  final CommentDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case CommentDeliveryStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.grey.shade500,
          ),
        );
      case CommentDeliveryStatus.sent:
        return Icon(Icons.done_rounded, size: 14, color: Colors.grey.shade500);
      case CommentDeliveryStatus.delivered:
        return Icon(Icons.done_all_rounded,
            size: 14, color: Colors.grey.shade500);
      case CommentDeliveryStatus.read:
        return const Icon(Icons.done_all_rounded,
            size: 14, color: DashboardColors.primary);
      case CommentDeliveryStatus.failed:
        return Icon(Icons.error_outline_rounded,
            size: 14, color: DashboardColors.error);
    }
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.onTap,
  });

  final TaskCommentAttachment attachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.type == CommentAttachmentType.image;
    final isPdf = attachment.type == CommentAttachmentType.pdf;
    final isVideo = attachment.type == CommentAttachmentType.video;
    final color = isPdf
        ? DashboardColors.error
        : isImage
            ? DashboardColors.success
            : isVideo
                ? const Color(0xFF5E35B1)
                : DashboardColors.primary;
    final icon = isPdf
        ? Icons.picture_as_pdf_rounded
        : isImage
            ? Icons.image_rounded
            : isVideo
                ? Icons.videocam_rounded
                : Icons.insert_drive_file_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isImage ? 0.7 : 1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImage && attachment.openUrl.isNotEmpty
                    ? Image.network(
                        attachment.openUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(icon, color: color, size: 20),
                      )
                    : Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment.fileName.isEmpty
                          ? 'Attachment'
                          : attachment.fileName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isPdf
                          ? 'Tap to open PDF'
                          : isImage
                              ? 'Tap to view image'
                              : attachment.sizeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  size: 18, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final first = name.split(' ').first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          const _Avatar(initials: 'DS'),
          const SizedBox(width: 8),
          Text(
            '$first is typing',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
          ),
          const SizedBox(width: 4),
          const _DotPulse(),
        ],
      ),
    );
  }
}

class _DotPulse extends StatefulWidget {
  const _DotPulse();

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (i) {
            final t = (_c.value + i * 0.2) % 1.0;
            final opacity = 0.3 + (0.7 * (1 - (t - 0.5).abs() * 2).clamp(0, 1));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Opacity(
                opacity: opacity.toDouble(),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: DashboardColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({required this.controller});

  final TaskCommentsController controller;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
        child: Obx(() {
          final busy = controller.isPickingFile.value;
          return Row(
            children: [
              Expanded(
                child: Text(
                  'Attach PDF, image, or video',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: DashboardColors.textMuted,
                  ),
                ),
              ),
              Material(
                color: busy
                    ? DashboardColors.primary.withValues(alpha: 0.45)
                    : DashboardColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: busy ? null : () => _openAttachSheet(context),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: busy
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.attach_file_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _openAttachSheet(BuildContext context) {
    const options = <(IconData, Color, String)>[
      (Icons.image_rounded, Color(0xFF43A047), 'Image'),
      (Icons.photo_camera_rounded, Color(0xFF5E35B1), 'Camera'),
      (Icons.videocam_rounded, Color(0xFF6A1B9A), 'Video'),
      (Icons.picture_as_pdf_rounded, Color(0xFFD32F2F), 'PDF'),
      (Icons.folder_rounded, Color(0xFF607D8B), 'Files'),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Attachment',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, images, and videos only',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: DashboardColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final o in options)
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.onAttachmentOptionSelected(o.$3);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72,
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: o.$2.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(o.$1, color: o.$2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              o.$3,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
