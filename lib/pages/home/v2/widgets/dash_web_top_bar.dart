import 'dart:typed_data';

import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashWebTopBar extends StatelessWidget {
  const DashWebTopBar({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: DashV2Colors.card,
            border: Border(bottom: BorderSide(color: DashV2Colors.border)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Toggle sidebar',
                onPressed: controller.toggleSidebar,
                icon: const Icon(
                  Icons.menu_open_rounded,
                  color: DashV2Colors.textDark,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Tooltip(
                    message: 'Search',
                    child: TextField(
                      readOnly: true,
                      onTap: controller.onSearchTap,
                      decoration: InputDecoration(
                        hintText: 'Search here…',
                        hintStyle: DashV2Text.subtitle,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: DashV2Colors.textMuted,
                        ),
                        filled: true,
                        fillColor: DashV2Colors.scaffold,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Obx(
                () => IconButton(
                  tooltip: 'Notifications',
                  onPressed: controller.onNotificationsTap,
                  icon: Badge(
                    isLabelVisible: controller.notificationCount.value > 0,
                    label: Text(
                      controller.notificationCount.value > 99
                          ? '99+'
                          : '${controller.notificationCount.value}',
                    ),
                    backgroundColor: DashV2Colors.red,
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProfileAvatar(
                      bytes: controller.profileAvatarBytes.value,
                      imageUrl: controller.profileImageUrl.value,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userFullName.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DashV2Text.cardTitle,
                        ),
                        Text(
                          controller.designation.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DashV2Text.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DashWebHeaderActions(),
      ],
    );
  }
}

class DashWebHeaderActions extends StatelessWidget {
  const DashWebHeaderActions({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DashV2Greeting.forDateTime(
                      DateTime.now(),
                      controller.firstName.value,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DashV2Text.title,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DashV2Greeting.subtitle,
                    style: DashV2Text.subtitle,
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: DashV2Colors.card,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: DashV2Colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: DashV2Colors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.dateRangeLabel.value,
                    style: DashV2Text.cardSubtitle.copyWith(
                      color: DashV2Colors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: controller.openNewProject,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('+ New Project'),
            style: FilledButton.styleFrom(
              backgroundColor: DashV2Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.bytes, required this.imageUrl});

  final Uint8List? bytes;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? image;
    if (bytes != null) {
      image = MemoryImage(bytes!);
    } else if (imageUrl.isNotEmpty) {
      image = NetworkImage(imageUrl);
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: DashV2Colors.tint(DashV2Colors.blue),
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, __) {},
      child: const Icon(
        Icons.person_outline_rounded,
        color: DashV2Colors.blue,
      ),
    );
  }
}
