import 'package:flutter/material.dart';

import 'utils/screen_sizes.dart';

class DayNumber extends StatelessWidget {
  const DayNumber({
    required this.day,
    this.color,
  });

  final int day;
  final Color? color;

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
              color: day < 1 ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(size / 2),
            )
          : null,
      child: Text(
        day < 1 ? '' : day.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color != null ? Colors.black : Colors.black87,
          fontSize: screenSize(context) == ScreenSizes.small ? 8.0 : 10.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
