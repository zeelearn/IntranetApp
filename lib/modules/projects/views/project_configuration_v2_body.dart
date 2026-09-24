import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/models/reassignment_pair.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_employee_picker.dart';

/// New Project Reassignment layout aligned to Figma.
class ProjectConfigurationV2Body extends StatefulWidget {
  const ProjectConfigurationV2Body({
    super.key,
    required this.controller,
    required this.onSaveDraft,
    required this.onOpenDrafts,
    required this.onTransfer,
    required this.onCancel,
  });

  final ProjectConfigurationController controller;
  final VoidCallback onSaveDraft;
  final VoidCallback onOpenDrafts;
  final VoidCallback onTransfer;
  final VoidCallback onCancel;

  @override
  State<ProjectConfigurationV2Body> createState() =>
      _ProjectConfigurationV2BodyState();
}

class _ProjectConfigurationV2BodyState
    extends State<ProjectConfigurationV2Body> {
  static const double _wideBreakpoint = 1100;
  static const double _mediumBreakpoint = 840;
  static const double _compactBreakpoint = 600;
  static const int _pageSize = 10;

  late final Worker _sourceWorker;
  late final Worker _queryWorker;
  int _page = 0;

  ProjectConfigurationController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _sourceWorker = ever<EmployeeInfo?>(_c.sourceEmployee, (_) {
      if (!mounted) return;
      setState(() => _page = 0);
    });
    _queryWorker = ever<String>(_c.projectQuery, (_) {
      if (!mounted) return;
      setState(() => _page = 0);
    });
  }

  @override
  void dispose() {
    _sourceWorker.dispose();
    _queryWorker.dispose();
    super.dispose();
  }

  void _goToPage(int page, int pageCount) {
    final next = page.clamp(0, pageCount == 0 ? 0 : pageCount - 1);
    if (next == _page) return;
    setState(() => _page = next);
  }

  static String _projectIdOf(ReassignableProject project) {
    final id = project.projectId.trim().isNotEmpty
        ? project.projectId.trim()
        : project.id.trim();
    return id.isEmpty ? '—' : id;
  }

  static String _franchiseeCodeOf(ReassignableProject project) {
    final code = project.franchiseeCode.trim();
    if (code.isNotEmpty) return code;
    if (project.teamLabels.isNotEmpty) {
      final first = project.teamLabels.first.trim();
      if (first.isNotEmpty) return first;
    }
    return '—';
  }

  static String _franchiseeNameOf(ReassignableProject project) {
    final catchment = project.catchmentArea.trim();
    if (catchment.isNotEmpty) return catchment;
    final name = project.name.trim();
    return name.isEmpty ? '—' : name;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final source = _c.sourceEmployee.value;
      final target = _c.targetEmployee.value;
      final projects = _c.filteredSourceProjects;
      final selectedIds = _c.selectedProjectIds.toSet();
      final queuedIds = _c.queuedProjectIds;
      final totalLoaded = _c.sourceProjects.length;
      final selectedCount = selectedIds.length;
      final queuedCount = _c.queuedPairs.length;
      final pageCount =
          projects.isEmpty ? 1 : ((projects.length - 1) ~/ _pageSize) + 1;
      final safePage = _page.clamp(0, pageCount - 1);
      final start = safePage * _pageSize;
      final pageItems = projects.isEmpty
          ? const <ReassignableProject>[]
          : projects.sublist(
              start,
              (start + _pageSize).clamp(0, projects.length),
            );

      if (safePage != _page) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _page != safePage) {
            setState(() => _page = safePage);
          }
        });
      }

      return ColoredBox(
        color: DashboardColors.scaffold,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _wideBreakpoint;
                  final medium = constraints.maxWidth >= _mediumBreakpoint;
                  final compact = constraints.maxWidth < _compactBreakpoint;
                  final edge = compact ? 10.0 : 16.0;

                  final employeesBlock = _EmployeesSection(
                    controller: _c,
                    source: source,
                    target: target,
                    totalLoaded: totalLoaded,
                    compact: compact,
                  );

                  final projectsBlock = _MappedProjectsCard(
                    controller: _c,
                    source: source,
                    projects: projects,
                    pageItems: pageItems,
                    selectedIds: selectedIds,
                    queuedIds: queuedIds,
                    totalLoaded: totalLoaded,
                    selectedCount: selectedCount,
                    page: safePage,
                    pageCount: pageCount,
                    pageSize: _pageSize,
                    compact: compact,
                    useCardList: constraints.maxWidth < 720,
                    onPageChanged: (page) => _goToPage(page, pageCount),
                  );

                  final summary = _TransferSummaryCard(
                    controller: _c,
                    source: source,
                    target: target,
                    selectedCount: selectedCount,
                    totalLoaded: totalLoaded,
                    compact: compact,
                    onOpenDrafts: widget.onOpenDrafts,
                  );

                  if (wide) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(edge, 12, edge, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                employeesBlock,
                                const SizedBox(height: 12),
                                Expanded(child: projectsBlock),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(width: 300, child: summary),
                        ],
                      ),
                    );
                  }

                  if (medium) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(edge, 12, edge, 8),
                      child: Column(
                        children: [
                          employeesBlock,
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: projectsBlock),
                                const SizedBox(width: 12),
                                SizedBox(width: 280, child: summary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Phone: employees + summary take natural height;
                  // mapped projects fill the remaining viewport.
                  return Padding(
                    padding: EdgeInsets.fromLTRB(edge, 12, edge, 8),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.36,
                          ),
                          child: SingleChildScrollView(
                            child: employeesBlock,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: projectsBlock),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: (constraints.maxHeight * 0.28)
                                .clamp(160.0, 240.0),
                          ),
                          child: summary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _FooterBar(
              controller: _c,
              selectedCount: selectedCount,
              queuedCount: queuedCount,
              canSubmit: _c.canSubmit,
              isSubmitting: _c.isSubmitting.value,
              hint: !_c.canSubmit
                  ? (_c.submitValidationError ?? _c.queueValidationError)
                  : null,
              onAddConfiguration: widget.onSaveDraft,
              onTransfer: widget.onTransfer,
            ),
          ],
        ),
      );
    });
  }
}

class _EmployeesSection extends StatelessWidget {
  const _EmployeesSection({
    required this.controller,
    required this.source,
    required this.target,
    required this.totalLoaded,
    required this.compact,
  });

  final ProjectConfigurationController controller;
  final EmployeeInfo? source;
  final EmployeeInfo? target;
  final int totalLoaded;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final currentPicker = ReassignmentEmployeePicker(
      key: const ValueKey('source-employee-picker-v2'),
      label: 'Current employee',
      hint: 'Search employee by name or ID…',
      employees: List<EmployeeInfo>.from(controller.employees),
      selected: source,
      onQueryChanged: (query) => controller.sourceQuery.value = query,
      onSelected: controller.selectSourceAndLoad,
      onCleared: controller.clearSource,
      filterEmployees: controller.filterSourceEmployees,
    );

    final newPicker = ReassignmentEmployeePicker(
      key: const ValueKey('target-employee-picker-v2'),
      label: 'New employee',
      hint: 'Select new employee',
      employees: List<EmployeeInfo>.from(controller.employees),
      selected: target,
      onQueryChanged: (query) => controller.targetQuery.value = query,
      onSelected: controller.selectTarget,
      onCleared: controller.clearTarget,
      filterEmployees: controller.filterTargetEmployees,
      showAvailabilityBadge: true,
    );

    final profile = _CurrentEmployeeProfileCard(
      employee: source,
      totalMapped: totalLoaded,
    );

    if (compact) {
      return Column(
        children: [
          _WhiteCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                currentPicker,
                const SizedBox(height: 12),
                newPicker,
              ],
            ),
          ),
          if (source != null) ...[
            const SizedBox(height: 10),
            profile,
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _WhiteCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: currentPicker),
                  const SizedBox(width: 16),
                  Expanded(child: newPicker),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: profile,
          ),
        ],
      ),
    );
  }
}

class _CurrentEmployeeProfileCard extends StatelessWidget {
  const _CurrentEmployeeProfileCard({
    required this.employee,
    required this.totalMapped,
  });

  final EmployeeInfo? employee;
  final int totalMapped;

  @override
  Widget build(BuildContext context) {
    if (employee == null) {
      return _WhiteCard(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                child:
                    Icon(Icons.person_outline, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select a current employee to see mapped projects',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: DashboardColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final designation = employee!.employeeDesignation.trim();
    final code = employee!.employeeCode.trim();
    final meta = [
      if (designation.isNotEmpty) designation,
      if (code.isNotEmpty) code,
    ].join(' • ');

    return _WhiteCard(
      padding: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            ReassignmentEmployeeAvatar(name: employee!.employeeFullName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee!.employeeFullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DashboardColors.textDark,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: DashboardColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total Mapped Projects: $totalMapped',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MappedProjectsCard extends StatelessWidget {
  const _MappedProjectsCard({
    required this.controller,
    required this.source,
    required this.projects,
    required this.pageItems,
    required this.selectedIds,
    required this.queuedIds,
    required this.totalLoaded,
    required this.selectedCount,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.compact,
    required this.useCardList,
    required this.onPageChanged,
  });

  final ProjectConfigurationController controller;
  final EmployeeInfo? source;
  final List<ReassignableProject> projects;
  final List<ReassignableProject> pageItems;
  final Set<String> selectedIds;
  final Set<String> queuedIds;
  final int totalLoaded;
  final int selectedCount;
  final int page;
  final int pageCount;
  final int pageSize;
  final bool compact;
  final bool useCardList;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final hasSource = source != null;
    final allSelected = hasSource &&
        projects.isNotEmpty &&
        projects.every(
          (p) => selectedIds.contains(p.id) || queuedIds.contains(p.id),
        );

    return _WhiteCard(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        compact ? 12 : 14,
        compact ? 12 : 16,
        compact ? 10 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text(
              'Mapped Projects ($totalLoaded)',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: DashboardColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            _ProjectSearchField(
              enabled: hasSource,
              query: controller.projectQuery.value,
              onChanged: hasSource
                  ? (query) => controller.projectQuery.value = query
                  : null,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mapped Projects ($totalLoaded)',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: DashboardColors.textDark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: _ProjectSearchField(
                    enabled: hasSource,
                    query: controller.projectQuery.value,
                    onChanged: hasSource
                        ? (query) => controller.projectQuery.value = query
                        : null,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          _SelectionBar(
            enabled: hasSource && projects.isNotEmpty,
            allSelected: allSelected,
            selectedCount: selectedCount,
            totalVisible: projects.length,
            onToggleAll: !hasSource || projects.isEmpty
                ? null
                : controller.toggleSelectAllProjects,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _ProjectsTable(
              hasSource: hasSource,
              isLoading: controller.isLoadingProjects.value,
              query: controller.projectQuery.value,
              pageItems: pageItems,
              selectedIds: selectedIds,
              queuedIds: queuedIds,
              onToggle: controller.toggleProject,
              useCardList: useCardList,
            ),
          ),
          const SizedBox(height: 8),
          _PaginationBar(
            page: page,
            pageCount: pageCount,
            pageSize: pageSize,
            total: projects.length,
            totalLoaded: totalLoaded,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}

class _ProjectSearchField extends StatefulWidget {
  const _ProjectSearchField({
    required this.enabled,
    required this.query,
    required this.onChanged,
  });

  final bool enabled;
  final String query;
  final ValueChanged<String>? onChanged;

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
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged ?? (_) {},
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Search project, franchisee, code…',
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DashboardColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.enabled,
    required this.allSelected,
    required this.selectedCount,
    required this.totalVisible,
    required this.onToggleAll,
  });

  final bool enabled;
  final bool allSelected;
  final int selectedCount;
  final int totalVisible;
  final VoidCallback? onToggleAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DashboardColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DashboardColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: enabled && allSelected,
            onChanged: onToggleAll == null ? null : (_) => onToggleAll!(),
            activeColor: DashboardColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            'Select All ($totalVisible)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Selected: $selectedCount',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selectedCount > 0
                    ? DashboardColors.primary
                    : DashboardColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsTable extends StatelessWidget {
  const _ProjectsTable({
    required this.hasSource,
    required this.isLoading,
    required this.query,
    required this.pageItems,
    required this.selectedIds,
    required this.queuedIds,
    required this.onToggle,
    required this.useCardList,
  });

  final bool hasSource;
  final bool isLoading;
  final String query;
  final List<ReassignableProject> pageItems;
  final Set<String> selectedIds;
  final Set<String> queuedIds;
  final ValueChanged<String> onToggle;
  final bool useCardList;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DashboardColors.primary),
      );
    }

    if (!hasSource || pageItems.isEmpty) {
      return _EmptyProjects(
        title: !hasSource
            ? 'Choose the current employee'
            : (query.trim().isNotEmpty
                ? 'No matching projects'
                : 'No projects found'),
        subtitle: !hasSource
            ? 'Their mapped projects will show up here'
            : (query.trim().isNotEmpty
                ? 'Try a different search'
                : 'This employee has no projects to move'),
      );
    }

    if (useCardList) {
      return ListView.separated(
        itemCount: pageItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final project = pageItems[index];
          final queued = queuedIds.contains(project.id);
          return _ProjectListCard(
            project: project,
            selected: selectedIds.contains(project.id),
            queued: queued,
            onToggle: queued ? null : () => onToggle(project.id),
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            const _TableHeader(),
            Expanded(
              child: ListView.separated(
                itemCount: pageItems.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final project = pageItems[index];
                  final queued = queuedIds.contains(project.id);
                  return _TableRow(
                    project: project,
                    selected: selectedIds.contains(project.id),
                    queued: queued,
                    onToggle: queued ? null : () => onToggle(project.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: DashboardColors.textMuted,
    );
    return Container(
      color: const Color(0xFFF7F9FC),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(flex: 3, child: Text('Project ID', style: style)),
          Expanded(flex: 2, child: Text('Franchisee Code', style: style)),
          Expanded(flex: 3, child: Text('Franchisee Name', style: style)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
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
    final projectId = _ProjectConfigurationV2BodyState._projectIdOf(project);
    final code = _ProjectConfigurationV2BodyState._franchiseeCodeOf(project);
    final name = _ProjectConfigurationV2BodyState._franchiseeNameOf(project);

    return Material(
      color: selected
          ? DashboardColors.primaryLight.withValues(alpha: 0.45)
          : Colors.white,
      child: InkWell(
        onTap: onToggle,
        child: Opacity(
          opacity: queued ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: selected || queued,
                    onChanged: onToggle == null ? null : (_) => onToggle!(),
                    activeColor: DashboardColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    projectId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: DashboardColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: DashboardColors.textDark,
                          ),
                        ),
                      ),
                      if (queued) ...[
                        const SizedBox(width: 6),
                        const _DraftChip(),
                      ],
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

class _ProjectListCard extends StatelessWidget {
  const _ProjectListCard({
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
    final projectId = _ProjectConfigurationV2BodyState._projectIdOf(project);
    final code = _ProjectConfigurationV2BodyState._franchiseeCodeOf(project);
    final name = _ProjectConfigurationV2BodyState._franchiseeNameOf(project);

    return Opacity(
      opacity: queued ? 0.55 : 1,
      child: Material(
        color: selected
            ? DashboardColors.primaryLight.withValues(alpha: 0.55)
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
                    ? DashboardColors.primary.withValues(alpha: 0.3)
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
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: DashboardColors.textDark,
                              ),
                            ),
                          ),
                          if (queued) const _DraftChip(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        projectId,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        code,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.primary,
                        ),
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

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.total,
    required this.totalLoaded,
    required this.onPageChanged,
  });

  final int page;
  final int pageCount;
  final int pageSize;
  final int total;
  final int totalLoaded;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final from = total == 0 ? 0 : page * pageSize + 1;
    final to = total == 0 ? 0 : ((page + 1) * pageSize).clamp(1, total);
    final label = total == 0
        ? (totalLoaded == 0 ? 'No projects' : '0 of $totalLoaded shown')
        : 'Showing $from–$to of $total';

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: DashboardColors.textMuted,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Previous page',
          onPressed: page <= 0 ? null : () => onPageChanged(page - 1),
          icon: const Icon(Icons.chevron_left_rounded),
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '${pageCount == 0 ? 0 : page + 1} / $pageCount',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed:
              page >= pageCount - 1 ? null : () => onPageChanged(page + 1),
          icon: const Icon(Icons.chevron_right_rounded),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _TransferSummaryCard extends StatelessWidget {
  const _TransferSummaryCard({
    required this.controller,
    required this.source,
    required this.target,
    required this.selectedCount,
    required this.totalLoaded,
    required this.compact,
    required this.onOpenDrafts,
  });

  final ProjectConfigurationController controller;
  final EmployeeInfo? source;
  final EmployeeInfo? target;
  final int selectedCount;
  final int totalLoaded;
  final bool compact;
  final VoidCallback onOpenDrafts;

  String _taskStatusLabel(int value) {
    switch (value) {
      case 1:
        return 'Pending';
      case 2:
        return 'In Progress';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = controller.sameEmployeeError ?? controller.actionError.value;
    final sourceName = source?.employeeFullName.trim().isNotEmpty == true
        ? source!.employeeFullName.trim()
        : 'Not selected';
    final targetName = target?.employeeFullName.trim().isNotEmpty == true
        ? target!.employeeFullName.trim()
        : 'Not selected';
    final drafts = controller.queuedPairs.toList(growable: false);

    return _WhiteCard(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Summary',
              style: GoogleFonts.poppins(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: DashboardColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(label: 'Current Employee', value: sourceName),
            _SummaryRow(label: 'New Employee', value: targetName),
            _SummaryRow(
              label: 'Selected Projects',
              value: '$selectedCount / $totalLoaded',
            ),
            _SummaryRow(
              label: 'Task Status',
              value: controller.taskStatusFilter.value.label,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _InfoBanner(
                message: error,
                tone: _BannerTone.error,
              ),
            ] else ...[
              const SizedBox(height: 12),
              _InfoBanner(
                message: drafts.isNotEmpty
                    ? '${drafts.length} draft${drafts.length == 1 ? '' : 's'} ready. You can submit now or keep adding.'
                    : target == null
                        ? 'Select a new employee to enable project reassignment and submission.'
                        : selectedCount == 0
                            ? 'Select at least one project to transfer.'
                            : 'Ready to transfer $selectedCount project'
                                '${selectedCount == 1 ? '' : 's'}.',
                tone: drafts.isNotEmpty ||
                        (target != null && selectedCount > 0)
                    ? _BannerTone.success
                    : _BannerTone.info,
              ),
            ],
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenDrafts,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Drafts',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: DashboardColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: drafts.isEmpty
                              ? Colors.grey.shade100
                              : DashboardColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${drafts.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: drafts.isEmpty
                                ? DashboardColors.textMuted
                                : DashboardColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 18,
                        color: DashboardColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (drafts.isEmpty)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenDrafts,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DashboardColors.scaffold,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'No drafts yet. Tap here to review drafts anytime.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        height: 1.35,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                  ),
                ),
              )
            else
              for (var i = 0; i < drafts.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _DraftSummaryTile(
                  index: i,
                  pair: drafts[i],
                  taskStatusLabel: _taskStatusLabel(drafts[i].taskStatus),
                  onOpen: onOpenDrafts,
                  onRemove: () => controller.removeQueuedPair(i),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _DraftSummaryTile extends StatelessWidget {
  const _DraftSummaryTile({
    required this.index,
    required this.pair,
    required this.taskStatusLabel,
    required this.onOpen,
    required this.onRemove,
  });

  final int index;
  final ReassignmentPair pair;
  final String taskStatusLabel;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sourceName = pair.source.employeeFullName.trim().isNotEmpty
        ? pair.source.employeeFullName.trim()
        : pair.source.employeeCode;
    final targetName = pair.target.employeeFullName.trim().isNotEmpty
        ? pair.target.employeeFullName.trim()
        : pair.target.employeeCode;
    final projectCount = pair.reassignAll
        ? (pair.projects.isEmpty ? 'All' : '${pair.projects.length}+')
        : '${pair.projects.length}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DashboardColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: DashboardColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$sourceName → $targetName',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DashboardColors.textDark,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _DraftMetaChip(
                              icon: Icons.folder_outlined,
                              label: pair.reassignAll
                                  ? 'All projects'
                                  : '$projectCount project${pair.projects.length == 1 ? '' : 's'}',
                            ),
                            _DraftMetaChip(
                              icon: Icons.flag_outlined,
                              label: taskStatusLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove draft',
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: DashboardColors.error,
                  ),
                ],
              ),
              if (pair.projects.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final project in pair.projects.take(3))
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 2),
                    child: Text(
                      '• ${project.name.trim().isEmpty ? project.projectId : project.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                  ),
                if (pair.projects.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 30, top: 2),
                    child: Text(
                      '+${pair.projects.length - 3} more',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftMetaChip extends StatelessWidget {
  const _DraftMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DashboardColors.scaffold,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: DashboardColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BannerTone { info, success, error }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, required this.tone});

  final String message;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    switch (tone) {
      case _BannerTone.success:
        bg = DashboardColors.successLight;
        fg = DashboardColors.success;
        icon = Icons.check_circle_outline_rounded;
      case _BannerTone.error:
        bg = DashboardColors.errorLight;
        fg = DashboardColors.error;
        icon = Icons.error_outline_rounded;
      case _BannerTone.info:
        bg = DashboardColors.primaryLight;
        fg = DashboardColors.primary;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.35,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.controller,
    required this.queuedCount,
    required this.selectedCount,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onAddConfiguration,
    required this.onTransfer,
    this.hint,
  });

  final ProjectConfigurationController controller;
  final int queuedCount;
  final int selectedCount;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onAddConfiguration;
  final VoidCallback onTransfer;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final taskStatus = SizedBox(
      width: 160,
      child: _FooterTaskStatusDropdown(
        value: controller.taskStatusFilter.value,
        onChanged: controller.setTaskStatusFilter,
      ),
    );

    final addConfig = OutlinedButton.icon(
      onPressed: onAddConfiguration,
      icon: const Icon(Icons.add_rounded, size: 16),
      label: Text(
        'Add Configuration',
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: DashboardColors.primary,
        side: BorderSide(
          color: DashboardColors.primary.withValues(alpha: 0.45),
        ),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final submitLabel = selectedCount > 0
        ? 'Submit ($selectedCount)'
        : (queuedCount > 0 ? 'Submit ($queuedCount)' : 'Submit');

    final transfer = FilledButton.icon(
      onPressed: canSubmit && !isSubmitting ? onTransfer : null,
      icon: isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send_rounded, size: 16),
      label: Text(
        isSubmitting ? 'Submitting…' : submitLabel,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: DashboardColors.primaryFilledButton(
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hint!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: DashboardColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 560;
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        taskStatus,
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: addConfig),
                            const SizedBox(width: 8),
                            Expanded(child: transfer),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      const Spacer(),
                      taskStatus,
                      const SizedBox(width: 8),
                      addConfig,
                      const SizedBox(width: 8),
                      transfer,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterTaskStatusDropdown extends StatelessWidget {
  const _FooterTaskStatusDropdown({
    required this.value,
    required this.onChanged,
  });

  final TaskStatusFilter value;
  final ValueChanged<TaskStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        labelText: 'Task status',
        labelStyle: GoogleFonts.poppins(
          fontSize: 11,
          color: DashboardColors.textMuted,
        ),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskStatusFilter>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
          items: [
            for (final option in TaskStatusFilter.values)
              DropdownMenuItem(
                value: option,
                child: Text(option.label),
              ),
          ],
          onChanged: (selected) {
            if (selected == null) return;
            onChanged(selected);
          },
        ),
      ),
    );
  }
}

class _DraftChip extends StatelessWidget {
  const _DraftChip();

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

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
