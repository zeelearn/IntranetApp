import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashProjectStatusCard extends StatelessWidget {
  const DashProjectStatusCard({super.key});

  DashboardScreenV2Controller get controller =>
      Get.find<DashboardScreenV2Controller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Obx(() {
        final segments =
            controller.projectStatusSegments.toList(growable: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Status Overview', style: DashV2Text.sectionTitle),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: segments.isEmpty
                      ? const Center(child: Text('No project status data'))
                      : PieChart(
                          PieChartData(
                            centerSpaceRadius: 48,
                            sectionsSpace: 3,
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sections: segments
                                .map(_sectionForSegment)
                                .toList(growable: false),
                          ),
                        ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    children: [
                      for (final segment in segments)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _LegendRow(segment: segment),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.openProjects,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All Projects'),
                style: TextButton.styleFrom(
                  foregroundColor: DashV2Colors.blue,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  PieChartSectionData _sectionForSegment(DashChartSegment segment) {
    return PieChartSectionData(
      value: segment.value,
      color: segment.color,
      radius: 24,
      showTitle: false,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment});

  final DashChartSegment segment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            segment.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashV2Text.cardSubtitle.copyWith(
              color: DashV2Colors.textDark,
            ),
          ),
        ),
        Text(
          '${segment.value.round()}%',
          style: DashV2Text.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
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
