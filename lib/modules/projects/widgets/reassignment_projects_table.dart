import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';

class ReassignmentProjectsTable extends StatelessWidget {
  const ReassignmentProjectsTable({
    super.key,
    required this.projects,
    required this.selectedIds,
    required this.onToggle,
    required this.onSelectAllPressed,
    this.queuedIds = const {},
    this.searchQuery = '',
    this.onSearchChanged,
    this.isLoading = false,
    this.totalCount,
    this.emptyTitle = 'Choose the current employee',
    this.emptySubtitle = 'Their projects will show up here',
    this.shrinkWrap = false,
  });

  final List<ReassignableProject> projects;
  final Set<String> selectedIds;
  final Set<String> queuedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onSelectAllPressed;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final bool isLoading;
  final int? totalCount;
  final String emptyTitle;
  final String emptySubtitle;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final selectable = projects
        .where((project) => !queuedIds.contains(project.id))
        .toList(growable: false);
    final allSelected = selectable.isNotEmpty &&
        selectable.every((p) => selectedIds.contains(p.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                totalCount == null
                    ? 'Assigned projects'
                    : 'Assigned projects ($totalCount)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textDark,
                ),
              ),
            ),
            InkWell(
              onTap: selectable.isEmpty ? null : onSelectAllPressed,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: allSelected,
                        onChanged: selectable.isEmpty
                            ? null
                            : (_) => onSelectAllPressed(),
                        activeColor: DashboardColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Select all (${selectable.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectable.isEmpty
                            ? DashboardColors.textMuted
                            : DashboardColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (onSearchChanged != null) ...[
          const SizedBox(height: 8),
          _ProjectSearchField(
            query: searchQuery,
            onChanged: onSearchChanged!,
          ),
        ],
        const SizedBox(height: 8),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(color: DashboardColors.primary),
            ),
          )
        else if (projects.isEmpty)
          _EmptyProjects(
            title: emptyTitle,
            subtitle: emptySubtitle,
          )
        else if (shrinkWrap)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final project = projects[index];
              final queued = queuedIds.contains(project.id);
              return _ProjectRow(
                project: project,
                selected: selectedIds.contains(project.id),
                queued: queued,
                onToggle: queued ? null : () => onToggle(project.id),
              );
            },
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final project = projects[index];
                final queued = queuedIds.contains(project.id);
                return _ProjectRow(
                  project: project,
                  selected: selectedIds.contains(project.id),
                  queued: queued,
                  onToggle: queued ? null : () => onToggle(project.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ProjectSearchField extends StatefulWidget {
  const _ProjectSearchField({
    required this.query,
    required this.onChanged,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<_ProjectSearchField> createState() => _ProjectSearchFieldState();
}

class _ProjectSearchFieldState extends State<_ProjectSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant _ProjectSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search franchisee, code, catchment, status…',
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: DashboardColors.textMuted,
        ),
        prefixIcon: const Icon(Icons.search_rounded, size: 18),
        suffixIcon: widget.query.trim().isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DashboardColors.primary),
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 13),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined, color: Colors.grey.shade400, size: 36),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.selected,
    required this.queued,
    required this.onToggle,
  });

  final ReassignableProject project;
  final bool selected;
  final bool queued;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (project.franchiseeCode.trim().isNotEmpty) project.franchiseeCode.trim(),
      if (project.catchmentArea.trim().isNotEmpty) project.catchmentArea.trim(),
      if (project.taskCount.trim().isNotEmpty) project.taskCount.trim(),
    ];

    return Opacity(
      opacity: queued ? 0.55 : 1,
      child: Material(
        color: selected
            ? DashboardColors.primaryLight.withValues(alpha: 0.65)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? DashboardColors.primary.withValues(alpha: 0.28)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected || queued,
                  onChanged: onToggle == null ? null : (_) => onToggle!(),
                  activeColor: DashboardColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: DashboardColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (queued)
                            _QueuedChip()
                          else
                            _StatusChip(status: project.status),
                        ],
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' • '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: DashboardColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final label in project.teamLabels.take(4))
                            _TeamChip(label: label),
                          if (project.ownerName.trim().isNotEmpty)
                            Text(
                              'With: ${project.ownerName}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: DashboardColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueuedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DashboardColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Draft',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: DashboardColors.warning,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.trim().isEmpty ? '—' : status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.foreground,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _colorsFor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'active':
        return (
          background: DashboardColors.successLight,
          foreground: DashboardColors.success,
        );
      case 'in progress':
        return (
          background: DashboardColors.primaryLight,
          foreground: DashboardColors.primary,
        );
      case 'pending':
        return (
          background: DashboardColors.warningLight,
          foreground: DashboardColors.warning,
        );
      default:
        return (
          background: Colors.grey.shade200,
          foreground: DashboardColors.textMuted,
        );
    }
  }
}

class _TeamChip extends StatelessWidget {
  const _TeamChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final initials = label.trim().isEmpty
        ? '?'
        : label.trim().substring(0, 1).toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DashboardColors.tealLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: DashboardColors.teal.withValues(alpha: 0.18),
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: DashboardColors.teal,
              ),
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: DashboardColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
