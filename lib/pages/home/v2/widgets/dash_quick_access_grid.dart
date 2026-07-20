import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashQuickAccessGrid extends StatelessWidget {
  const DashQuickAccessGrid({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= DashboardScreenV2Controller.kWideBreakpoint
            ? 4
            : width >= 600
                ? 3
                : 2;
        final aspectRatio = columnCount == 2 ? 1.35 : 1.65;

        return Obx(() {
          final items = controller.quickAccessItems;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return DashQuickAccessCard(
                item: item,
                onTap: () => controller.onQuickAccessTap(item.key),
              );
            },
          );
        });
      },
    );
  }
}
