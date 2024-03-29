import 'package:flutter/material.dart';

import 'utils/screen_sizes.dart';

class YearTitle extends StatelessWidget {
  const YearTitle(
    this.year,
  );

  final int year;

  @override
  Widget build(BuildContext context) {
    return Text(
      year.toString(),
      style: TextStyle(
          fontSize: screenSize(context) == ScreenSizes.small ? 22.0 : 26.0,
          fontWeight: FontWeight.w600,
          color: Colors.black),
    );
  }
}
