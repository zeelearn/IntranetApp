import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

/// Searchable employee picker with an overlay suggestion list that paints
/// above sibling content (e.g. the mapped projects table).
class ReassignmentEmployeePicker extends StatefulWidget {
  const ReassignmentEmployeePicker({
    super.key,
    required this.label,
    required this.hint,
    required this.employees,
    required this.selected,
    required this.onQueryChanged,
    required this.onSelected,
    this.onCleared,
    this.filterEmployees,
    this.showAvailabilityBadge = false,
    this.showSelectedCard = false,
  });

  final String label;
  final String hint;
  final List<EmployeeInfo> employees;
  final EmployeeInfo? selected;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<EmployeeInfo> onSelected;
  final VoidCallback? onCleared;
  final List<EmployeeInfo> Function(String query)? filterEmployees;
  final bool showAvailabilityBadge;
  final bool showSelectedCard;

  @override
  State<ReassignmentEmployeePicker> createState() =>
      _ReassignmentEmployeePickerState();
}

class _ReassignmentEmployeePickerState
    extends State<ReassignmentEmployeePicker> {
  static const double _suggestionMaxHeight = 280;

  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();
  final GlobalKey _fieldKey = GlobalKey();

  bool _showSuggestions = false;
  bool _pointerInSuggestions = false;
  bool _forceSearch = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: _displayLabel(widget.selected),
    );
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant ReassignmentEmployeePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKey = _employeeKey(oldWidget.selected);
    final newKey = _employeeKey(widget.selected);
    if (newKey != oldKey && !_focusNode.hasFocus) {
      final label = _displayLabel(widget.selected);
      _textController.value = TextEditingValue(
        text: label,
        selection: TextSelection.collapsed(offset: label.length),
      );
      _forceSearch = false;
    }
  }

  @override
  void dispose() {
    _hideSuggestions(notify: false);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool get _hasSelection => widget.selected != null;

  /// Collapsed selected card replaces the field until the user chooses Change.
  bool get _showCollapsedSelection =>
      _hasSelection && !_forceSearch && !_focusNode.hasFocus;

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _openSuggestions();
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (!mounted || _focusNode.hasFocus || _pointerInSuggestions) return;
      _hideSuggestions();
      if (_hasSelection) {
        setState(() {
          _forceSearch = false;
          final label = _displayLabel(widget.selected);
          _textController.value = TextEditingValue(
            text: label,
            selection: TextSelection.collapsed(offset: label.length),
          );
        });
      }
    });
  }

  void _openSuggestions() {
    if (!mounted) return;
    setState(() => _showSuggestions = true);
    if (!_portalController.isShowing) {
      _portalController.show();
    }
  }

  void _hideSuggestions({bool notify = true}) {
    if (_portalController.isShowing) {
      _portalController.hide();
    }
    if (!mounted) return;
    if (notify) {
      if (_showSuggestions) setState(() => _showSuggestions = false);
    } else {
      _showSuggestions = false;
    }
  }

  String _employeeKey(EmployeeInfo? employee) {
    if (employee == null) return '';
    final code = employee.employeeCode.trim();
    if (code.isNotEmpty) return code;
    return employee.employeeId.trim();
  }

  String _displayLabel(EmployeeInfo? employee) {
    if (employee == null) return '';
    final name = employee.employeeFullName.trim();
    if (name.isNotEmpty) return name;
    if (employee.display.trim().isNotEmpty) return employee.display.trim();
    return employee.employeeCode.trim();
  }

  List<EmployeeInfo> _matches() {
    final query = _textController.text;
    if (widget.filterEmployees != null) {
      return widget.filterEmployees!(query);
    }
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return List<EmployeeInfo>.from(widget.employees);
    return widget.employees.where((employee) {
      return employee.employeeFullName.toLowerCase().contains(needle) ||
          employee.employeeCode.toLowerCase().contains(needle) ||
          employee.employeeId.toLowerCase().contains(needle) ||
          employee.employeeDesignation.toLowerCase().contains(needle) ||
          employee.display.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  Size _fieldSize() {
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return const Size(280, 52);
    }
    return box.size;
  }

  void _select(EmployeeInfo employee) {
    _pointerInSuggestions = false;
    final label = _displayLabel(employee);
    _textController.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    widget.onQueryChanged(label);
    widget.onSelected(employee);
    _forceSearch = false;
    _focusNode.unfocus();
    _hideSuggestions();
    HapticFeedback.selectionClick();
  }

  void _clear() {
    _textController.clear();
    widget.onQueryChanged('');
    widget.onCleared?.call();
    _forceSearch = true;
    if (mounted) setState(() {});
    _focusNode.requestFocus();
    _openSuggestions();
  }

  void _beginChange() {
    setState(() {
      _forceSearch = true;
      _textController.clear();
    });
    widget.onQueryChanged('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _openSuggestions();
    });
  }

  Widget _buildOverlay(BuildContext context) {
    final fieldSize = _fieldSize();
    final matches = _matches();
    final query = _textController.text.trim();

    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 8),
        child: Listener(
          onPointerDown: (_) => _pointerInSuggestions = true,
          onPointerUp: (_) => _pointerInSuggestions = false,
          onPointerCancel: (_) => _pointerInSuggestions = false,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: SizedBox(
              width: fieldSize.width.clamp(240, 720),
              child: _SuggestionList(
                employees: matches,
                selectedKey: _employeeKey(widget.selected),
                onSelected: _select,
                maxHeight: _suggestionMaxHeight,
                query: query,
                showAvailabilityBadge: widget.showAvailabilityBadge,
                totalAvailable: widget.employees.length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final focused = _focusNode.hasFocus || _showSuggestions;

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildOverlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.textDark,
                  ),
                ),
              ),
              if (_hasSelection && !_showCollapsedSelection)
                Text(
                  '${widget.employees.length} in team',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _layerLink,
            child: SizedBox(
              key: _fieldKey,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _showCollapsedSelection
                    ? _SelectedEmployeeTile(
                        key: const ValueKey('collapsed-selection'),
                        employee: selected!,
                        showAvailabilityBadge: widget.showAvailabilityBadge,
                        onChange: _beginChange,
                        onClear: widget.onCleared == null ? null : _clear,
                      )
                    : _SearchFieldShell(
                        key: const ValueKey('search-field'),
                        focused: focused,
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          onTap: () {
                            _forceSearch = true;
                            _openSuggestions();
                          },
                          onChanged: (value) {
                            widget.onQueryChanged(value);
                            _openSuggestions();
                            setState(() {});
                          },
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DashboardColors.textDark,
                          ),
                          cursorColor: DashboardColors.primary,
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: DashboardColors.textMuted,
                            ),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 6),
                              child: Icon(
                                Icons.person_search_rounded,
                                size: 22,
                                color: focused
                                    ? DashboardColors.primary
                                    : DashboardColors.textMuted,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_textController.text.isNotEmpty)
                                  IconButton(
                                    tooltip: 'Clear',
                                    onPressed: _clear,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                  ),
                                IconButton(
                                  tooltip: _showSuggestions
                                      ? 'Hide employees'
                                      : 'Show employees',
                                  onPressed: () {
                                    if (_showSuggestions) {
                                      _focusNode.unfocus();
                                      _hideSuggestions();
                                    } else {
                                      _forceSearch = true;
                                      _focusNode.requestFocus();
                                      _openSuggestions();
                                    }
                                  },
                                  visualDensity: VisualDensity.compact,
                                  icon: AnimatedRotation(
                                    turns: _showSuggestions ? 0.5 : 0,
                                    duration:
                                        const Duration(milliseconds: 180),
                                    child: const Icon(
                                      Icons.expand_more_rounded,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                              ],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hoverColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (widget.showSelectedCard &&
              selected != null &&
              !_showCollapsedSelection) ...[
            const SizedBox(height: 12),
            ReassignmentEmployeeCard(
              employee: selected,
              showAvailabilityBadge: widget.showAvailabilityBadge,
              onClear: widget.onCleared == null ? null : _clear,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchFieldShell extends StatelessWidget {
  const _SearchFieldShell({
    super.key,
    required this.focused,
    required this.child,
  });

  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused
              ? DashboardColors.primary
              : Colors.grey.shade300,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: DashboardColors.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _SelectedEmployeeTile extends StatelessWidget {
  const _SelectedEmployeeTile({
    super.key,
    required this.employee,
    required this.onChange,
    this.onClear,
    this.showAvailabilityBadge = false,
  });

  final EmployeeInfo employee;
  final VoidCallback onChange;
  final VoidCallback? onClear;
  final bool showAvailabilityBadge;

  @override
  Widget build(BuildContext context) {
    final designation = employee.employeeDesignation.trim();
    final code = employee.employeeCode.trim();
    final subtitle = [
      if (code.isNotEmpty) code,
      if (designation.isNotEmpty) designation,
    ].join(' • ');
    final active = _isActiveEmployee(employee);

    return Material(
      color: DashboardColors.primaryLight.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onChange,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: DashboardColors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              ReassignmentEmployeeAvatar(name: employee.employeeFullName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.employeeFullName.trim().isEmpty
                          ? 'Selected employee'
                          : employee.employeeFullName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.textDark,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showAvailabilityBadge) ...[
                _StatusPill(active: active),
                const SizedBox(width: 4),
              ],
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  foregroundColor: DashboardColors.primary,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: 'Clear',
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReassignmentEmployeeCard extends StatelessWidget {
  const ReassignmentEmployeeCard({
    super.key,
    required this.employee,
    this.showAvailabilityBadge = false,
    this.onClear,
  });

  final EmployeeInfo employee;
  final bool showAvailabilityBadge;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final designation = employee.employeeDesignation.trim();
    final department = employee.employeeDepartmentName.trim();
    final meta = [
      if (designation.isNotEmpty) designation,
      if (department.isNotEmpty) department,
    ].join(' • ');
    final code = employee.employeeCode.trim();
    final active = _isActiveEmployee(employee);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashboardColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          ReassignmentEmployeeAvatar(name: employee.employeeFullName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.employeeFullName,
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
                if (code.isNotEmpty) ...[
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
              ],
            ),
          ),
          if (showAvailabilityBadge) ...[
            _StatusPill(active: active, availableLabel: true),
            const SizedBox(width: 4),
          ],
          if (onClear != null)
            IconButton(
              tooltip: 'Clear',
              onPressed: onClear,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

class ReassignmentEmployeeAvatar extends StatelessWidget {
  const ReassignmentEmployeeAvatar({
    super.key,
    required this.name,
    this.radius = 22,
  });

  final String name;
  final double radius;

  static const _palette = <Color>[
    Color(0xFF1565C0),
    Color(0xFF00897B),
    Color(0xFF5E35B1),
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFF4527A0),
    Color(0xFF00695C),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _colorFor(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: accent.withValues(alpha: 0.14),
      child: Text(
        initialsForName(name),
        style: GoogleFonts.poppins(
          fontSize: radius >= 20 ? 13 : 10,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }

  Color _colorFor(String value) {
    if (value.trim().isEmpty) return DashboardColors.primary;
    final hash = value.trim().codeUnits.fold<int>(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.active,
    this.availableLabel = false,
  });

  final bool active;
  final bool availableLabel;

  @override
  Widget build(BuildContext context) {
    final label = availableLabel
        ? (active ? 'Available' : 'Inactive')
        : (active ? 'Active' : 'Inactive');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? DashboardColors.successLight
            : DashboardColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: active ? DashboardColors.success : DashboardColors.warning,
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.employees,
    required this.selectedKey,
    required this.onSelected,
    required this.query,
    required this.totalAvailable,
    this.maxHeight = 280,
    this.showAvailabilityBadge = false,
  });

  final List<EmployeeInfo> employees;
  final String selectedKey;
  final ValueChanged<EmployeeInfo> onSelected;
  final String query;
  final int totalAvailable;
  final double maxHeight;
  final bool showAvailabilityBadge;

  String _key(EmployeeInfo employee) {
    final code = employee.employeeCode.trim();
    if (code.isNotEmpty) return code;
    return employee.employeeId.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SuggestionHeader(
                matchCount: employees.length,
                totalAvailable: totalAvailable,
                query: query,
              ),
              if (employees.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 28,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        query.isEmpty
                            ? 'No employees available'
                            : 'No matches for “$query”',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try another name, code, or designation',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                    itemCount: employees.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 54,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      final selected = _key(employee) == selectedKey &&
                          selectedKey.isNotEmpty;
                      return _SuggestionTile(
                        employee: employee,
                        selected: selected,
                        query: query,
                        showAvailabilityBadge: showAvailabilityBadge,
                        onTap: () => onSelected(employee),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionHeader extends StatelessWidget {
  const _SuggestionHeader({
    required this.matchCount,
    required this.totalAvailable,
    required this.query,
  });

  final int matchCount;
  final int totalAvailable;
  final String query;

  @override
  Widget build(BuildContext context) {
    final label = query.isEmpty
        ? (totalAvailable == 0
            ? 'No team members'
            : 'Team members ($matchCount)')
        : '$matchCount match${matchCount == 1 ? '' : 'es'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      color: const Color(0xFFF7F9FC),
      child: Row(
        children: [
          Icon(
            Icons.groups_outlined,
            size: 16,
            color: DashboardColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DashboardColors.textMuted,
              ),
            ),
          ),
          if (query.isNotEmpty)
            Text(
              'of $totalAvailable',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: DashboardColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.employee,
    required this.selected,
    required this.query,
    required this.onTap,
    this.showAvailabilityBadge = false,
  });

  final EmployeeInfo employee;
  final bool selected;
  final String query;
  final VoidCallback onTap;
  final bool showAvailabilityBadge;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (employee.employeeCode.trim().isNotEmpty)
        employee.employeeCode.trim(),
      if (employee.employeeDesignation.trim().isNotEmpty)
        employee.employeeDesignation.trim(),
    ].join(' • ');
    final active = _isActiveEmployee(employee);

    return Material(
      color: selected
          ? DashboardColors.primaryLight.withValues(alpha: 0.85)
          : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ReassignmentEmployeeAvatar(
                name: employee.employeeFullName,
                radius: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: employee.employeeFullName,
                      query: query,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.textDark,
                      ),
                      highlightStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.primary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _HighlightedText(
                        text: subtitle,
                        query: query,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: DashboardColors.textMuted,
                        ),
                        highlightStyle: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showAvailabilityBadge) ...[
                _StatusPill(active: active),
                const SizedBox(width: 6),
              ],
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: DashboardColors.primary,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim();
    if (needle.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lower = text.toLowerCase();
    final index = lower.indexOf(needle.toLowerCase());
    if (index < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final before = text.substring(0, index);
    final match = text.substring(index, index + needle.length);
    final after = text.substring(index + needle.length);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: before, style: style),
          TextSpan(text: match, style: highlightStyle),
          TextSpan(text: after, style: style),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

bool _isActiveEmployee(EmployeeInfo employee) {
  final status = employee.empAppStatus.trim().toLowerCase();
  if (status.isEmpty) return true;
  return status == 'active' || status == 'true' || status == '1';
}

String initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final value = parts.first;
    return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
