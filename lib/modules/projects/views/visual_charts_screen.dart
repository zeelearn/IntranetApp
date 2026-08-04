import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/visual_charts_binding.dart';
import 'package:Intranet/modules/projects/controllers/visual_charts_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/project_search_bar.dart';
import 'package:Intranet/modules/projects/widgets/visual_chart_card.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';

/// Visual Charts listing — GetReportsForDashboard API.
class VisualChartsScreen extends StatelessWidget {
  const VisualChartsScreen({
    super.key,
    required this.userId,
    required this.userType,
  });

  final int userId;
  final String userType;

  static Future<T?>? open<T>({
    required int userId,
    required String userType,
  }) {
    return Get.to<T>(
      () => VisualChartsScreen(userId: userId, userType: userType),
      binding: VisualChartsBinding(userId: userId, userType: userType),
    );
  }

  /// Loads employee id + role from Hive, then opens the screen.
  static Future<T?> openFromHive<T>() async {
    final box = await Utility.openBox();
    final userType =
        (box.get(LocalConstant.KEY_EMP_TYPE)?.toString() ?? '').trim();
    final userIdRaw = box.get(LocalConstant.KEY_EMPLOYEE_ID)?.toString() ?? '';
    final userId = int.tryParse(userIdRaw) ?? 0;
    return open<T>(userId: userId, userType: userType);
  }

  String get _tag => VisualChartsBinding.makeTag(userId, userType);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<VisualChartsController>(tag: _tag)) {
      VisualChartsBinding(userId: userId, userType: userType).dependencies();
    }

    final controller = Get.find<VisualChartsController>(tag: _tag);

    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      body: Column(
        children: [
          _AppBar(controller: controller),
          Obx(() {
            final showOffline =
                controller.isOffline.value || controller.servingFromCache.value;
            return OfflineBanner(
              visible: showOffline,
              onRetry: controller.isOffline.value
                  ? null
                  : controller.refreshCharts,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached charts.'
                  : 'Showing cached data. Pull to refresh.',
            );
          }),
          ProjectSearchBar(
            hint: 'Search charts by name or description...',
            showFilter: false,
            onChanged: controller.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.visibleCharts.isEmpty) {
                return const ProjectShimmer();
              }
              if (controller.errorMessage.value != null &&
                  controller.visibleCharts.isEmpty) {
                return ProjectErrorWidget(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refreshCharts,
                );
              }
              if (controller.visibleCharts.isEmpty) {
                return ProjectEmptyWidget(
                  title: 'No Visual Charts',
                  subtitle: 'No dashboards available for your role',
                  onRetry: controller.refreshCharts,
                );
              }

              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshCharts,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 1024
                        ? 3
                        : width >= 700
                            ? 2
                            : 1;

                    if (columns == 1) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: controller.visibleCharts.length,
                        itemBuilder: (context, index) {
                          final chart = controller.visibleCharts[index];
                          return VisualChartCard(
                            item: chart,
                            index: index,
                            onTap: () => controller.openChart(chart),
                          );
                        },
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 4,
                        mainAxisExtent: 130,
                      ),
                      itemCount: controller.visibleCharts.length,
                      itemBuilder: (context, index) {
                        final chart = controller.visibleCharts[index];
                        return VisualChartCard(
                          item: chart,
                          index: index,
                          onTap: () => controller.openChart(chart),
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.controller});

  final VisualChartsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.primary,
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visual Charts',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${controller.visibleCharts.length} of ${controller.allCharts.length} dashboards',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: controller.refreshCharts,
              tooltip: 'Refresh',
              icon: Obx(
                () => controller.isRefreshing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
