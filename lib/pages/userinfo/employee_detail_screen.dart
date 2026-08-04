import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:Intranet/pages/userinfo/employee_search_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key, required this.employee});

  final EmployeeInfo employee;

  @override
  Widget build(BuildContext context) {
    final name =
        EmployeeSearchUtils.displayOrDash(employee.employeeFullName);
    final email =
        EmployeeSearchUtils.displayOrDash(employee.employeeEmailId);
    final phone = employee.employeeContactNumber.trim();

    return Scaffold(
      backgroundColor: DashV2Colors.scaffold,
      appBar: AppBar(
        backgroundColor: DashV2Colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Employee Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DashV2Colors.card,
              borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
              boxShadow: DashV2Colors.cardShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: DashV2Colors.tint(DashV2Colors.primary),
                  child: Text(
                    _initials(name),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: DashV2Colors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: DashV2Colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: DashV2Colors.textMuted,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _call(context, phone),
                          style: TextButton.styleFrom(
                            foregroundColor: DashV2Colors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: Text(phone),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: DashV2Colors.card,
              borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
              boxShadow: DashV2Colors.cardShadow,
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Name',
                  value: employee.employeeFullName,
                ),
                _DetailRow(
                  label: 'Contact Number',
                  value: employee.employeeContactNumber,
                ),
                _DetailRow(
                  label: 'Email',
                  value: employee.employeeEmailId,
                ),
                _DetailRow(
                  label: 'Employee Code',
                  value: employee.employeeCode,
                ),
                _DetailRow(
                  label: 'Designation',
                  value: employee.employeeDesignation,
                ),
                _DetailRow(
                  label: 'App Status',
                  value: employee.empAppStatus,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
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

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      Utility.showMessages(context, 'Unable to place call');
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: DashV2Colors.border),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DashV2Colors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            EmployeeSearchUtils.displayOrDash(value),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DashV2Colors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
