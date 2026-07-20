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
      height: 130,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F2FF), Color(0xFFF2F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: DashV2Colors.blue.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 118, 18),
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
                        controller.firstName.value,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DashV2Text.sectionTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 7),
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
            right: 18,
            bottom: 18,
            child: _WelcomeIllustration(),
          ),
        ],
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            shape: BoxShape.circle,
          ),
        ),
        const Icon(
          Icons.assignment_turned_in_outlined,
          color: DashV2Colors.primary,
          size: 48,
        ),
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: DashV2Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}
