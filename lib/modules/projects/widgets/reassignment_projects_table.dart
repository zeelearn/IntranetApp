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
    this.emptyTitle = 'Select a source employee',
    this.emptySubtitle = 'Mapped projects will appear here',
    this.shrinkWrap = false,
  });

  final List<ReassignableProject> projects;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onSelectAllPressed;
  final String emptyTitle;
  final String emptySubtitle;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final allSelected = projects.isNotEmpty &&
        projects.every((p) => selectedIds.contains(p.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Mapped projects',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textDark,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: projects.isEmpty ? null : onSelectAllPressed,
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
                        onChanged: projects.isEmpty
                            ? null
                            : (_) => onSelectAllPressed(),
                        activeColor: DashboardColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Select All (${projects.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: projects.isEmpty
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
        const SizedBox(height: 8),
        if (projects.isEmpty)
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
              return _ProjectRow(
                project: project,
                selected: selectedIds.contains(project.id),
                onToggle: () => onToggle(project.id),
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
                return _ProjectRow(
                  project: project,
                  selected: selectedIds.contains(project.id),
                  onToggle: () => onToggle(project.id),
                );
              },
            ),
          ),
      ],
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
    required this.onToggle,
  });

  final ReassignableProject project;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                value: selected,
                onChanged: (_) => onToggle(),
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
                        _StatusChip(status: project.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final label in project.teamLabels)
                          _TeamChip(label: label),
                        if (project.ownerName.trim().isNotEmpty)
                          Text(
                            'Owner: ${project.ownerName}',
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
        status,
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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashboardColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}
