import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/business_selector.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.businesses,
    required this.selectedBusinessId,
    required this.selectedBusinessLabel,
    required this.onBusinessChanged,
    this.onBackTap,
  });

  final String userName;
  final List<BusinessApplications> businesses;
  final int? selectedBusinessId;
  final String selectedBusinessLabel;
  final ValueChanged<int?> onBusinessChanged;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: 'Back',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.trim().isEmpty ? 'User' : userName.trim(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    selectedBusinessLabel.trim().isEmpty
                        ? 'All Business'
                        : selectedBusinessLabel.trim(),
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180, minWidth: 120),
              child: BusinessSelector(
                businesses: businesses,
                selectedBusinessId: selectedBusinessId,
                selectedLabel: selectedBusinessLabel,
                onChanged: onBusinessChanged,
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
