import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DashKpiVariant { mobile, web }

class DashKpiRow extends StatelessWidget {
  const DashKpiRow({
    this.variant = DashKpiVariant.mobile,
    super.key,
  });

  final DashKpiVariant variant;

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.kpiStats.toList(growable: false);
      if (stats.isEmpty) return const SizedBox.shrink();

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < stats.length; index++) ...[
            if (index > 0)
              SizedBox(width: variant == DashKpiVariant.web ? 16 : 8),
            Expanded(
              child: variant == DashKpiVariant.web
                  ? _WebKpiCard(stat: stats[index])
                  : _MobileKpiItem(stat: stats[index]),
            ),
          ],
        ],
      );
    });
  }
}

/// Figma mobile KPI: solid circular icon (white glyph) + value + label + underline.
class _MobileKpiItem extends StatelessWidget {
  const _MobileKpiItem({required this.stat});

  final DashKpiStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: stat.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: stat.color.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(stat.icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(stat.value, style: DashV2Text.kpiValue),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            stat.label,
            maxLines: 1,
            style: DashV2Text.kpiLabel,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3.5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: stat.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _WebKpiCard extends StatelessWidget {
  const _WebKpiCard({required this.stat});

  final DashKpiStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DashV2Colors.tint(stat.color),
                  borderRadius: BorderRadius.circular(DashV2Colors.iconRadius),
                ),
                child: Icon(stat.icon, color: stat.color, size: 21),
              ),
              const Spacer(),
              Text(stat.value, style: DashV2Text.kpiValue),
            ],
          ),
          const SizedBox(height: 16),
          Text(stat.label, style: DashV2Text.cardTitle),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stat.progress.clamp(0, 1),
              minHeight: 6,
              color: stat.color,
              backgroundColor: DashV2Colors.tint(stat.color),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${(stat.progress * 100).round()}% complete',
            style: DashV2Text.caption,
          ),
        ],
      ),
    );
  }
}
