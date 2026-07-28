import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashUpcomingRemindersCard extends StatelessWidget {
  const DashUpcomingRemindersCard({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Obx(() {
        final reminders = controller.upcomingReminders.toList(growable: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upcoming Reminders',
                    style: DashV2Text.sectionTitle,
                  ),
                ),
                TextButton(
                  onPressed: _showComingSoon,
                  style:
                      TextButton.styleFrom(foregroundColor: DashV2Colors.blue),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child:
                    Text('No upcoming reminders', style: DashV2Text.subtitle),
              )
            else
              for (var index = 0; index < reminders.length; index++) ...[
                _ReminderRow(item: reminders[index]),
                if (index < reminders.length - 1)
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
      'Reminder history will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.item});

  final DashReminderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              color: DashV2Colors.tint(DashV2Colors.blue),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.month,
                  style: DashV2Text.caption.copyWith(
                    color: DashV2Colors.blue,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.day,
                  style: DashV2Text.cardTitle.copyWith(
                    color: DashV2Colors.blue,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: DashV2Colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.when,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DashV2Text.cardSubtitle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
