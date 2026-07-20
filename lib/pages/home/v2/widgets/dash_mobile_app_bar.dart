import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashMobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashMobileAppBar({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DashV2Colors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: 'Open navigation',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu_rounded, size: 26),
        ),
      ),
      titleSpacing: 0,
      title: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.userFullName.value.isEmpty
                  ? ' '
                  : controller.userFullName.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DashV2Text.appBarTitle,
            ),
            InkWell(
              onTap: () => controller.showBusinessPicker(fromDrawer: false),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.only(right: 4, top: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        controller.businessName.value.isEmpty ||
                                controller.businessName.value == 'null'
                            ? 'eKidzee'
                            : controller.businessName.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DashV2Text.appBarSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: controller.onSearchTap,
          icon: const Icon(Icons.search_rounded, size: 24),
        ),
        Obx(
          () => IconButton(
            tooltip: 'Notifications',
            onPressed: controller.onNotificationsTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 24),
                if (controller.notificationCount.value > 0)
                  Positioned(
                    right: -6,
                    top: -5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3.5),
                      decoration: const BoxDecoration(
                        color: DashV2Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        controller.notificationCount.value > 99
                            ? '99+'
                            : '${controller.notificationCount.value}',
                        style: DashV2Text.badge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
