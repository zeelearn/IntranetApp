import 'package:flutter/material.dart';

/// Checks if the given date is equal to the current date.
bool isCurrentDate(DateTime date) {
  final DateTime now = DateTime.now();
  return date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
}

/// Checks if the given date is a highlighted date.
// bool isHighlightedDate(
//     DateTime date, List<HighlightDateColorModel> highlightedDates) {
//   return highlightedDates.any((HighlightDateColorModel highlightedDate) =>
//       date.isAtSameMomentAs(DateTime(highlightedDate.dateTime.year,
//           highlightedDate.dateTime.month, highlightedDate.dateTime.day)));
// }

Color? isHighlightedDate(
    DateTime date, List<HighlightDateColorModel> highlightedDates) {
  for (var element in highlightedDates) {
    if (date.isAtSameMomentAs(DateTime(
        element.dateTime.year, element.dateTime.month, element.dateTime.day))) {
      debugPrint('date is - $date and color is - ${element.color}');
      return element.color;
    } else {
      // return 1;
    }
  }
  return Colors.transparent;
}

/// Gets the number of days for the given month,
/// by taking the next month on day 0 and getting the number of days.
int getDaysInMonth(int year, int month) {
  return month < DateTime.monthsPerYear
      ? DateTime(year, month + 1, 0).day
      : DateTime(year + 1, 1, 0).day;
}

/// Gets the name of the given month by its number,
/// using either the supplied or default name.
String getMonthName(int month, {List<String>? monthNames}) {
  final List<String> names = monthNames ??
      <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
  return names[month - 1];
}

class HighlightDateColorModel {
  DateTime dateTime;
  Color color;

  HighlightDateColorModel({required this.dateTime, required this.color});
}
