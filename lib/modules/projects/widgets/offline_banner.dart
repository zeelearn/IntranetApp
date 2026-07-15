import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.visible,
    this.onRetry,
    this.message = 'You are offline. Showing cached data.',
  });

  final bool visible;
  final VoidCallback? onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline-banner'),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: DashboardColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DashboardColors.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: DashboardColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: DashboardColors.textDark,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
