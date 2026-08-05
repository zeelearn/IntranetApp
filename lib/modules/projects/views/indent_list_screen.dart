import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/indent_list_binding.dart';
import 'package:Intranet/modules/projects/controllers/indent_list_controller.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/widgets/indent_card.dart';
import 'package:Intranet/modules/projects/widgets/indent_filter_sheet.dart';
import 'package:Intranet/modules/projects/widgets/offline_banner.dart';
import 'package:Intranet/modules/projects/widgets/project_list_states.dart';
import 'package:Intranet/modules/projects/widgets/project_search_bar.dart';

/// All Indents list — Pentemind Illume Status API.
class IndentListScreen extends StatelessWidget {
  const IndentListScreen({
    super.key,
    required this.userId,
    required this.businessId,
  });

  final int userId;
  final String businessId;

  static Future<T?>? open<T>({
    required int userId,
    required String businessId,
  }) {
    return Get.to<T>(
      () => IndentListScreen(userId: userId, businessId: businessId),
      binding: IndentListBinding(userId: userId, businessId: businessId),
    );
  }

  String get _tag => IndentListBinding.makeTag(userId, businessId);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IndentListController>(tag: _tag)) {
      IndentListBinding(userId: userId, businessId: businessId).dependencies();
    }

    final controller = Get.find<IndentListController>(tag: _tag);

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
                  : controller.refreshIndents,
              message: controller.isOffline.value
                  ? 'You are offline. Showing cached indents.'
                  : 'Showing cached data. Pull to refresh.',
            );
          }),
          ProjectSearchBar(
            hint: 'Search franchisee, agreement, indent ID...',
            onChanged: controller.onSearchChanged,
            onFilterTap: () async {
              final result = await showIndentFilterSheet(
                context: context,
                current: controller.filter.value,
                indentStatuses: controller.indentStatusOptions,
                paymentStatuses: controller.paymentStatusOptions,
                projectStatuses: controller.projectStatusOptions,
                zones: controller.zoneOptions,
                states: controller.stateOptions,
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
                  controller.visibleIndents.isEmpty) {
                return const ProjectShimmer();
              }
              if (controller.errorMessage.value != null &&
                  controller.visibleIndents.isEmpty) {
                return ProjectErrorWidget(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refreshIndents,
                );
              }
              if (controller.visibleIndents.isEmpty) {
                return ProjectEmptyWidget(
                  title: 'No Indents Found',
                  subtitle: 'Try adjusting search or filters',
                  onRetry: controller.refreshIndents,
                );
              }

              return RefreshIndicator(
                color: DashboardColors.primary,
                onRefresh: controller.refreshIndents,
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
                        itemCount: controller.visibleIndents.length,
                        itemBuilder: (context, index) {
                          final item = controller.visibleIndents[index];
                          return Obx(() {
                            final generating =
                                controller.isGeneratingPaymentLink.value &&
                                    controller.generatingPaymentLinkIndentId
                                            .value ==
                                        item.indentId;
                            return IndentCard(
                              item: item,
                              index: index,
                              showPaymentLink:
                                  controller.showPaymentLinkFor(item),
                              isGeneratingPaymentLink: generating,
                              onGeneratePaymentLink: () => controller
                                  .confirmAndGeneratePaymentLink(
                                context,
                                item,
                              ),
                              onBrandingKit: () =>
                                  controller.onBrandingKitTap(context, item),
                            );
                          });
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
                        mainAxisExtent: columns >= 3 ? 350 : 370,
                      ),
                      itemCount: controller.visibleIndents.length,
                      itemBuilder: (context, index) {
                        final item = controller.visibleIndents[index];
                        return Obx(() {
                          final generating =
                              controller.isGeneratingPaymentLink.value &&
                                  controller.generatingPaymentLinkIndentId
                                          .value ==
                                      item.indentId;
                          return IndentCard(
                            item: item,
                            index: index,
                            showPaymentLink:
                                controller.showPaymentLinkFor(item),
                            isGeneratingPaymentLink: generating,
                            onGeneratePaymentLink: () => controller
                                .confirmAndGeneratePaymentLink(
                              context,
                              item,
                            ),
                            onBrandingKit: () =>
                                controller.onBrandingKitTap(context, item),
                          );
                        });
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

  final IndentListController controller;

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
                      'All Indents',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${controller.visibleIndents.length} of ${controller.allIndents.length} indents',
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
              onPressed: controller.refreshIndents,
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
