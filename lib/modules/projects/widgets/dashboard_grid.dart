import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';
import 'package:Intranet/modules/projects/widgets/dashboard_card.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.expandToFit = false,
  });

  final List<DashboardCardModel> cards;
  final ValueChanged<DashboardCardModel> onCardTap;

  /// When true and height is bounded, aspect ratio is derived so all cards
  /// fit the available height without scrolling.
  final bool expandToFit;

  /// Caps stretched card height on web to avoid large empty white space.
  static const double webMaxCellHeight = 150;

  static int crossAxisCountFor(double width) {
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double childAspectRatioFor(int crossAxisCount) {
    switch (crossAxisCount) {
      case 4:
        return 1.15;
      case 3:
        return 1.05;
      default:
        return 0.95;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = crossAxisCountFor(constraints.maxWidth);
        const spacing = 10.0;
        final itemCount = cards.length;
        final rowCount = (itemCount / crossAxisCount).ceil().clamp(1, itemCount);

        double aspectRatio;
        var useScroll = false;

        if (expandToFit &&
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight > 0) {
          final totalSpacingH = spacing * (crossAxisCount - 1);
          final totalSpacingV = spacing * (rowCount - 1);
          final cellWidth =
              (constraints.maxWidth - totalSpacingH) / crossAxisCount;
          var cellHeight =
              (constraints.maxHeight - totalSpacingV) / rowCount;

          // On web, stretched cards leave large empty white areas — cap height.
          if (kIsWeb && cellHeight > webMaxCellHeight) {
            cellHeight = webMaxCellHeight;
            useScroll = true;
          }

          aspectRatio = cellHeight > 0
              ? cellWidth / cellHeight
              : childAspectRatioFor(crossAxisCount);
        } else {
          aspectRatio = childAspectRatioFor(crossAxisCount);
        }

        final grid = GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: !expandToFit || useScroll,
          physics: (expandToFit && !useScroll)
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return DashboardCard(
              model: card,
              index: index,
              onTap: () => onCardTap(card),
              compact: expandToFit,
            );
          },
        );

        if (useScroll &&
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite) {
          return SizedBox(
            height: constraints.maxHeight,
            child: grid,
          );
        }
        return grid;
      },
    );
  }
}
