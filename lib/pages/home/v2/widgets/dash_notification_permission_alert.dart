import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tappable alert shown on the dashboard when notification permission is off.
/// Tap opens the platform notification / app settings.
class DashNotificationPermissionAlert extends StatelessWidget {
  const DashNotificationPermissionAlert({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showNotificationPermissionAlert.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.onNotificationPermissionAlertTap,
            borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
            child: Ink(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
                border: Border.all(color: DashV2Colors.amber.withValues(alpha: 0.45)),
                boxShadow: DashV2Colors.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DashV2Colors.amber.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(DashV2Colors.iconRadius),
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        color: DashV2Colors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications are disabled',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DashV2Colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to open settings and allow notifications.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: DashV2Colors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: DashV2Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
