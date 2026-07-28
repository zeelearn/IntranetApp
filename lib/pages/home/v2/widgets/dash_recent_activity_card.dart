import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashRecentActivityCard extends StatelessWidget {
  const DashRecentActivityCard({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Obx(() {
        final activities = controller.recentActivities.toList(growable: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardHeader(onViewAll: _showComingSoon),
            const SizedBox(height: 10),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('No recent activity', style: DashV2Text.subtitle),
              )
            else
              for (var index = 0; index < activities.length; index++) ...[
                _ActivityRow(item: activities[index]),
                if (index < activities.length - 1)
                  const Divider(height: 1, color: DashV2Colors.border),
              ],
          ],
        );
      }),
    );
  }

  void _showComingSoon() {
    Get.snackbar(
      'Coming soon',
      'Recent activity history will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text('Recent Activity', style: DashV2Text.sectionTitle)),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: DashV2Colors.blue),
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final DashActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: DashV2Colors.tint(item.color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashV2Text.cardTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashV2Text.cardSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.timeAgo, style: DashV2Text.caption),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: DashV2Colors.card,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: DashV2Colors.border),
  boxShadow: const [
    BoxShadow(
      color: Color(0x0D1F2A44),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ],
);
