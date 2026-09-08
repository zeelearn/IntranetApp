import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

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

  @override
  State<ReassignmentEmployeePicker> createState() =>
      _ReassignmentEmployeePickerState();
}

class _ReassignmentEmployeePickerState
    extends State<ReassignmentEmployeePicker> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _showSuggestions = false;

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
      _textController.text = _displayLabel(widget.selected);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _showSuggestions = _focusNode.hasFocus);
  }

  String _employeeKey(EmployeeInfo? employee) {
    if (employee == null) return '';
    final code = employee.employeeCode.trim();
    if (code.isNotEmpty) return code;
    return employee.employeeId.trim();
  }

  String _displayLabel(EmployeeInfo? employee) {
    if (employee == null) return '';
    if (employee.display.trim().isNotEmpty) return employee.display.trim();
    return employee.employeeFullName.trim();
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

  void _select(EmployeeInfo employee) {
    widget.onSelected(employee);
    _textController.text = _displayLabel(employee);
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final matches = _showSuggestions ? _matches() : const <EmployeeInfo>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          onChanged: (value) {
            widget.onQueryChanged(value);
            setState(() {});
          },
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: DashboardColors.primary,
            ),
            suffixIcon: _textController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () {
                      _textController.clear();
                      widget.onQueryChanged('');
                      widget.onCleared?.call();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
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
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: 6),
          _SuggestionList(
            employees: matches,
            selectedKey: _employeeKey(selected),
            onSelected: _select,
          ),
        ],
        if (selected != null && !_showSuggestions) ...[
          const SizedBox(height: 12),
          ReassignmentEmployeeCard(
            employee: selected,
            showAvailabilityBadge: widget.showAvailabilityBadge,
          ),
        ],
      ],
    );
  }
}

class ReassignmentEmployeeCard extends StatelessWidget {
  const ReassignmentEmployeeCard({
    super.key,
    required this.employee,
    this.showAvailabilityBadge = false,
  });

  final EmployeeInfo employee;
  final bool showAvailabilityBadge;

  @override
  Widget build(BuildContext context) {
    final designation = employee.employeeDesignation.trim();
    final department = employee.employeeDepartmentName.trim();
    final meta = [
      if (designation.isNotEmpty) designation,
      if (department.isNotEmpty) department,
    ].join(' • ');
    final code = employee.employeeCode.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
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
          if (showAvailabilityBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DashboardColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Available',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.success,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: DashboardColors.primary.withValues(alpha: 0.15),
      child: Text(
        initialsForName(name),
        style: GoogleFonts.poppins(
          fontSize: radius >= 20 ? 13 : 10,
          fontWeight: FontWeight.w700,
          color: DashboardColors.primary,
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
  });

  final List<EmployeeInfo> employees;
  final String selectedKey;
  final ValueChanged<EmployeeInfo> onSelected;

  String _key(EmployeeInfo employee) {
    final code = employee.employeeCode.trim();
    if (code.isNotEmpty) return code;
    return employee.employeeId.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          'No matching employees',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: DashboardColors.textMuted,
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: employees.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            final employee = employees[index];
            final selected = _key(employee) == selectedKey && selectedKey.isNotEmpty;
            final subtitle = [
              if (employee.employeeCode.trim().isNotEmpty)
                employee.employeeCode.trim(),
              if (employee.employeeDesignation.trim().isNotEmpty)
                employee.employeeDesignation.trim(),
            ].join(' • ');
            return ListTile(
              dense: true,
              selected: selected,
              selectedTileColor: DashboardColors.primaryLight,
              leading: ReassignmentEmployeeAvatar(
                name: employee.employeeFullName,
                radius: 16,
              ),
              title: Text(
                employee.employeeFullName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textDark,
                ),
              ),
              subtitle: subtitle.isEmpty
                  ? null
                  : Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: DashboardColors.textMuted,
                      ),
                    ),
              onTap: () => onSelected(employee),
            );
          },
        ),
      ),
    );
  }
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
