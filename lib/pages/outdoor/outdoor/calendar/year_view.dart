import 'package:flutter/material.dart';

import 'month_view.dart';
import 'utils/dates.dart';
import 'utils/screen_sizes.dart';

class YearView extends StatelessWidget {
  const YearView({
    super.key,
    required this.context,
    required this.year,
    required this.currentDateColor,
    this.highlightedDates,
    this.highlightedDateColor,
    this.monthNames,
    this.onMonthTap,
    this.monthTitleStyle,
  });

  final BuildContext context;
  final int year;
  final Color currentDateColor;
  final List<HighlightDateColorModel>? highlightedDates;
  final Color? highlightedDateColor;
  final List<String>? monthNames;
  final Function? onMonthTap;
  final TextStyle? monthTitleStyle;

  double get horizontalMargin => 16.0;
  double get monthViewPadding => 8.0;

  Widget buildYearMonths(BuildContext context) {
    final List<Row> monthRows = <Row>[];
    final List<MonthView> monthRowChildren = <MonthView>[];

    for (int month = 1; month <= DateTime.monthsPerYear; month++) {
      monthRowChildren.add(
        MonthView(
          context: context,
          year: year,
          month: month,
          padding: monthViewPadding,
          currentDateColor: currentDateColor,
          highlightedDates: highlightedDates,
          highlightedDateColor: highlightedDateColor,
          monthNames: monthNames,
          onTap: onMonthTap,
          titleStyle: monthTitleStyle,
        ),
      );

      if (month % 3 == 0) {
        monthRows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<MonthView>.from(monthRowChildren),
          ),
        );
        monthRowChildren.clear();
      }
    }

    return Column(
      children: List<Row>.from(monthRows),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getYearViewHeight(context),
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Container(
          //   margin: EdgeInsets.symmetric(
          //     horizontal: horizontalMargin,
          //     vertical: 0.0,
          //   ),
          //   child: YearTitle(year),
          // ),
          // Container(
          //   margin: EdgeInsets.only(
          //     left: horizontalMargin,
          //     right: horizontalMargin,
          //     top: 8.0,
          //   ),
          //   child: Divider(
          //     color: Colors.black26,
          //   ),
          // ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin - monthViewPadding,
              vertical: 0.0,
            ),
            child: buildYearMonths(context),
          ),
        ],
      ),
    );
  }
}
