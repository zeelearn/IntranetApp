import 'package:flutter/material.dart';

import 'utils/dates.dart';
import 'utils/screen_sizes.dart';

class DayNumber extends StatelessWidget {
  const DayNumber(
      {super.key,
      required this.day,
      this.color,
      this.highlightedDates,
      required this.currentTime});

  final List<HighlightDateColorModel>? highlightedDates;
  final int day;
  final Color? color;
  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    final double size = getDayNumberSize(context);

    return Container(
      width: size,
      height: size,
      // padding: EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: color != null
          ? BoxDecoration(
              color: day < 1 ? Colors.transparent : Colors.transparent,
              borderRadius: BorderRadius.circular(size / 2),
            )
          : null,
      child: Column(
        children: [
          Text(
            day < 1 ? '' : day.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color != null ? Colors.black : Colors.black87,
              fontSize: screenSize(context) == ScreenSizes.small ? 8.0 : 10.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              if (highlightedDates != null) ...[
                for (int i = 0; i < highlightedDates!.length; i++) ...[
                  highlightedDates![i].dateTime == currentTime
                      ? Container(
                          width: 2,
                          height: 2,
                          // alignment: Alignment.bottomRight,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: highlightedDates![i].color),
                        )
                      : const SizedBox.shrink()
                ]
              ]
            ],
          ))
        ],
      ),
    );
  }
}
