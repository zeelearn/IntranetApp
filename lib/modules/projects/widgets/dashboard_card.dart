import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_card_model.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.model,
    required this.index,
    this.onTap,
    this.compact = false,
  });

  final DashboardCardModel model;
  final int index;
  final VoidCallback? onTap;

  /// Tighter spacing/typography when cards fill the screen height.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 16 : 20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 16 : 20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  model.backgroundColor.withValues(alpha: 0.65),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final tight = compact || h < 140;
                final veryTight = h < 120;

                final pad = veryTight ? 6.0 : (tight ? 8.0 : 14.0);
                final iconSize = veryTight ? 24.0 : (tight ? 28.0 : 36.0);
                final countSize = veryTight ? 16.0 : (tight ? 20.0 : 26.0);
                final titleSize = veryTight ? 9.5 : (tight ? 10.5 : 12.0);
                final captionSize = veryTight ? 9.0 : (tight ? 10.0 : 11.0);
                final gapAfterHeader = veryTight ? 2.0 : (tight ? 3.0 : 10.0);
                final gapAfterTitle = veryTight ? 1.0 : (tight ? 2.0 : 4.0);
                final gapBeforeCaption = veryTight ? 2.0 : (tight ? 3.0 : 6.0);
                final progressHeight = tight ? 3.5 : 6.0;

                return Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: model.backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              model.icon,
                              color: model.color,
                              size: iconSize * 0.55,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: tight ? 5 : 8,
                              vertical: tight ? 1 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: model.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              model.chipLabel,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: tight ? 8.5 : 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gapAfterHeader),
                      Text(
                        model.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF546E7A),
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: gapAfterTitle),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${model.count}',
                              style: GoogleFonts.poppins(
                                fontSize: countSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A237E),
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (model.percent / 100).clamp(0.0, 1.0),
                          minHeight: progressHeight,
                          backgroundColor: model.backgroundColor,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(model.color),
                        ),
                      ),
                      SizedBox(height: gapBeforeCaption),
                      Text(
                        model.percentLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: captionSize,
                          color: const Color(0xFF78909C),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
