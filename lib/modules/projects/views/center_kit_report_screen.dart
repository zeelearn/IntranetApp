import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/center_kit_report_binding.dart';
import 'package:Intranet/modules/projects/controllers/center_kit_report_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/center_kit_card.dart';
import 'package:Intranet/modules/projects/widgets/center_kit_filter_sheet.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/project_search_bar.dart';

/// Center Kit Report — GetIllumeDetails API.
class CenterKitReportScreen extends StatelessWidget {
  const CenterKitReportScreen({
    super.key,
    this.businessId,
  });

  /// Null sends `{ "business_id": null }` (all businesses).
  final int? businessId;

  static Future<T?>? open<T>({int? businessId}) {
    return Get.to<T>(
      () => CenterKitReportScreen(businessId: businessId),
      binding: CenterKitReportBinding(businessId: businessId),
    );
  }

  String get _tag => CenterKitReportBinding.makeTag(businessId);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CenterKitReportController>(tag: _tag)) {
      CenterKitReportBinding(businessId: businessId).dependencies();
    }

    final controller = Get.find<CenterKitReportController>(tag: _tag);

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
                  : controller.refreshReport,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached report.'
                  : 'Showing cached data. Pull to refresh.',
            );
          }),
          ProjectSearchBar(
            hint: 'Search franchisee, PM, agreement, indent ID...',
            onChanged: controller.onSearchChanged,
            onFilterTap: () async {
              final result = await showCenterKitFilterSheet(
                context: context,
                current: controller.filter.value,
                indentStatuses: controller.indentStatusOptions,
                paymentStatuses: controller.paymentStatusOptions,
                zones: controller.zoneOptions,
                states: controller.stateOptions,
                projectManagers: controller.projectManagerOptions,
              );
              if (result != null) {
                controller.applyFilter(result);
              }
            },
          ),
          Obx(() {
            final f = controller.filter.value;
            if (!f.hasActiveFilters) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${f.activeCount} filter${f.activeCount == 1 ? '' : 's'} active',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: DashboardColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.visibleItems.isEmpty) {
                return const ProjectShimmer();
              }
              if (controller.errorMessage.value != null &&
                  controller.visibleItems.isEmpty) {
                return ProjectErrorWidget(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refreshReport,
                );
              }
              if (controller.visibleItems.isEmpty) {
                return ProjectEmptyWidget(
                  title: 'No Center Kit Records',
                  subtitle: 'Try adjusting search or filters',
                  onRetry: controller.refreshReport,
                );
              }

              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshReport,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 1024
                        ? 3
                        : width >= 600
                            ? 2
                            : 1;

                    if (columns == 1) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: controller.visibleItems.length,
                        itemBuilder: (context, index) {
                          return CenterKitCard(
                            item: controller.visibleItems[index],
                            index: index,
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
                        mainAxisSpacing: 8,
                        mainAxisExtent: columns >= 3 ? 290 : 310,
                      ),
                      itemCount: controller.visibleItems.length,
                      itemBuilder: (context, index) {
                        return CenterKitCard(
                          item: controller.visibleItems[index],
                          index: index,
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

  final CenterKitReportController controller;

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
                      'Center Kit Report',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${controller.visibleItems.length} of ${controller.allItems.length} records',
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
              onPressed: controller.refreshReport,
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
