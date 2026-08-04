import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:Intranet/pages/userinfo/employee_detail_screen.dart';
import 'package:Intranet/pages/userinfo/employee_search_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard search → employee autocomplete using [APIService.getEmployeeList].
class EmployeeSearchDelegate extends SearchDelegate<EmployeeInfo?> {
  EmployeeSearchDelegate({
    APIService? apiService,
    List<EmployeeInfo>? initialEmployees,
  })  : _api = apiService ?? APIService(),
        _employees = initialEmployees;

  final APIService _api;
  List<EmployeeInfo>? _employees;
  Future<List<EmployeeInfo>>? _loadFuture;
  String? _error;

  @override
  String get searchFieldLabel => 'Search employees…';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: DashV2Colors.primary,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white24,
        selectionHandleColor: Colors.white,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    _loadFuture ??= _ensureLoaded();
    return FutureBuilder<List<EmployeeInfo>>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null || snapshot.hasError) {
          return _MessageState(
            icon: Icons.wifi_off_rounded,
            title: 'Unable to load employees',
            subtitle: _error ?? snapshot.error?.toString() ?? 'Please try again.',
            actionLabel: 'Retry',
            onAction: () {
              _employees = null;
              _error = null;
              _loadFuture = _ensureLoaded();
              showSuggestions(context);
            },
          );
        }

        final all = snapshot.data ?? const <EmployeeInfo>[];
        if (all.isEmpty) {
          return const _MessageState(
            icon: Icons.people_outline,
            title: 'No employees found',
            subtitle: 'Employee directory is empty.',
          );
        }

        final filtered = EmployeeSearchUtils.filter(all, query);
        if (filtered.isEmpty) {
          return _MessageState(
            icon: Icons.search_off_rounded,
            title: 'No matches',
            subtitle: 'No employees match “$query”.',
          );
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final employee = filtered[index];
            return _EmployeeSuggestionTile(
              employee: employee,
              onTap: () => _openDetail(context, employee),
            );
          },
        );
      },
    );
  }

  Future<List<EmployeeInfo>> _ensureLoaded() async {
    if (_employees != null) return _employees!;
    try {
      final value = await _api.getEmployeeList();
      if (value is EmployeeListResponse) {
        _employees = List<EmployeeInfo>.from(value.responseData);
        _error = null;
        return _employees!;
      }
      _error = 'Employee data not available.';
      _employees = const [];
      return _employees!;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> _openDetail(
    BuildContext context,
    EmployeeInfo employee,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }
}

class _EmployeeSuggestionTile extends StatelessWidget {
  const _EmployeeSuggestionTile({
    required this.employee,
    required this.onTap,
  });

  final EmployeeInfo employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name =
        EmployeeSearchUtils.displayOrDash(employee.employeeFullName);
    final designation =
        EmployeeSearchUtils.displayOrDash(employee.employeeDesignation);
    final code =
        EmployeeSearchUtils.displayOrDash(employee.employeeCode);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: DashV2Colors.tint(DashV2Colors.primary),
        child: Text(
          _initials(name),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: DashV2Colors.primary,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: DashV2Colors.textDark,
        ),
      ),
      subtitle: Text(
        '$designation · $code',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: DashV2Colors.textMuted,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty && p != '—')
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DashV2Colors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: DashV2Colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: DashV2Colors.primary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
