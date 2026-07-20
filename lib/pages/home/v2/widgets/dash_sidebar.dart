import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashSidebar extends StatelessWidget {
  const DashSidebar({
    this.isDrawer = false,
    this.showHelpCard = false,
    super.key,
  });

  final bool isDrawer;
  final bool showHelpCard;

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isDrawer || controller.sidebarExpanded.value;
      final items = DashV2MenuCatalog.sidebarItems(
        isBpms: controller.isBpms.value,
      );
      final logout = items.firstWhere((item) => item.key == 'logout');
      final navigation =
          items.where((item) => item.key != 'logout').toList(growable: false);

      return ColoredBox(
        color: DashV2Colors.card,
        child: SafeArea(
          child: Column(
            children: [
              _SidebarHeader(
                expanded: expanded,
                isDrawer: isDrawer,
                onToggle: controller.toggleSidebar,
                businessName: controller.businessName.value,
                onBusinessTap: () =>
                    controller.showBusinessPicker(fromDrawer: isDrawer),
              ),
              const Divider(height: 1, color: DashV2Colors.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  children: _buildNavigation(
                    navigation,
                    expanded: expanded,
                    selectedKey: controller.selectedNav.value,
                  ),
                ),
              ),
              if (showHelpCard && expanded)
                _NeedHelpCard(onTap: controller.onContactSupportTap),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
                child: _NavTile(
                  item: logout,
                  expanded: expanded,
                  selected: false,
                  onTap: () => controller.onSidebarTap(logout.key),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildNavigation(
    List<DashNavItem> items, {
    required bool expanded,
    required String selectedKey,
  }) {
    final widgets = <Widget>[];
    String? currentSection;

    for (final item in items) {
      final section = item.section ?? 'Menu';
      if (section != currentSection) {
        currentSection = section;
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 14));
        if (expanded) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
              child: Text(
                section,
                style: DashV2Text.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }
      }
      widgets.add(
        _NavTile(
          item: item,
          expanded: expanded,
          selected: item.key == selectedKey,
          onTap: () => controller.onSidebarTap(item.key),
        ),
      );
      widgets.add(const SizedBox(height: 4));
    }
    return widgets;
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.expanded,
    required this.isDrawer,
    required this.onToggle,
    required this.businessName,
    required this.onBusinessTap,
  });

  final bool expanded;
  final bool isDrawer;
  final VoidCallback onToggle;
  final String businessName;
  final VoidCallback onBusinessTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isDrawer && expanded ? 92 : 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DashV2Colors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.dashboard_customize_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
            if (expanded) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Intranet', style: DashV2Text.sectionTitle),
                    if (isDrawer)
                      InkWell(
                        onTap: onBusinessTap,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DashV2Text.caption,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 15,
                              color: DashV2Colors.textMuted,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (!isDrawer)
              IconButton(
                tooltip: expanded ? 'Collapse sidebar' : 'Expand sidebar',
                onPressed: onToggle,
                icon: Icon(
                  expanded
                      ? Icons.keyboard_double_arrow_left_rounded
                      : Icons.keyboard_double_arrow_right_rounded,
                  color: DashV2Colors.textMuted,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });

  final DashNavItem item;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? DashV2Colors.primary : DashV2Colors.textMuted;
    return Tooltip(
      message: expanded ? '' : item.label,
      child: Material(
        color: selected
            ? DashV2Colors.tint(DashV2Colors.primary)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (expanded) const SizedBox(width: 13),
                Icon(item.icon, color: foreground, size: 21),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DashV2Text.cardTitle.copyWith(color: foreground),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedHelpCard extends StatelessWidget {
  const _NeedHelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashV2Colors.tint(DashV2Colors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need Help?', style: DashV2Text.cardTitle),
          const SizedBox(height: 3),
          Text('Contact our support team', style: DashV2Text.cardSubtitle),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: DashV2Colors.primary,
                side: const BorderSide(color: DashV2Colors.primary),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Contact Support'),
            ),
          ),
        ],
      ),
    );
  }
}
