import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_grid.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({
    super.key,
    this.fillHeight = false,
  });

  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            DashboardGrid.crossAxisCountFor(constraints.maxWidth);
        const spacing = 10.0;
        const itemCount = 9;
        final rowCount = (itemCount / crossAxisCount).ceil();

        double aspectRatio;
        if (fillHeight &&
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0) {
          final totalSpacingH = spacing * (crossAxisCount - 1);
          final totalSpacingV = spacing * (rowCount - 1);
          final cellWidth =
              (constraints.maxWidth - totalSpacingH) / crossAxisCount;
          final cellHeight =
              (constraints.maxHeight - totalSpacingV) / rowCount;
          aspectRatio = cellHeight > 0
              ? cellWidth / cellHeight
              : DashboardGrid.childAspectRatioFor(crossAxisCount);
        } else {
          aspectRatio = DashboardGrid.childAspectRatioFor(crossAxisCount);
        }

        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: !fillHeight,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
