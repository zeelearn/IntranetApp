import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashWelcomeBanner extends StatelessWidget {
  const DashWelcomeBanner({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashV2Colors.bannerStart, DashV2Colors.bannerEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -36,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DashV2Colors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 36,
            bottom: -28,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DashV2Colors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 110, 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashV2Greeting.forDateTime(
                        DateTime.now(),
                        controller.firstName.value.isEmpty
                            ? 'there'
                            : controller.firstName.value,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DashV2Text.greeting,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DashV2Greeting.subtitle,
                      maxLines: 2,
                      style: DashV2Text.subtitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            right: 14,
            bottom: 14,
            child: _WelcomeIllustration(),
          ),
        ],
      ),
    );
  }
}

/// Soft 3D-style clipboard + chart illustration matching Figma.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 8,
            child: Container(
              width: 54,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0056B3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              child: Column(
                children: [
                  _bar(0.55),
                  const SizedBox(height: 5),
                  _bar(0.8),
                  const SizedBox(height: 5),
                  _bar(0.4),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 4,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DashV2Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330056B3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: DashV2Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double widthFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: DashV2Colors.blue.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
