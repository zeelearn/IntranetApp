
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'dart:collection';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:device_calendar/device_calendar.dart';

import 'calendar/scrolling_years_calendar.dart';
import 'calendar/utils/dates.dart';
import 'selectedMonthPlanner.dart';

final today = DateUtils.dateOnly(DateTime.now());

class MyOutdoorPlanner extends StatefulWidget {
  const MyOutdoorPlanner({super.key});

  @override
  State<MyOutdoorPlanner> createState() => _MyOutdoorPlannerState();
}

class _MyOutdoorPlannerState extends State<MyOutdoorPlanner> {
  String? selectedYear = DateTime.now().year.toString();

  List<HighlightDateColorModel> getHighlightedDates() {
    return List<HighlightDateColorModel>.generate(
      10,
      (int index) => HighlightDateColorModel(
          dateTime: DateTime.now().add(Duration(days: 10 * (index + 1))),
          color: index % 2 == 0 ? 1 : 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Month'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          DropdownButton<String>(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            underline: const SizedBox.shrink(),
            isExpanded: false,
            hint: const Text('Select Year'),
            value: selectedYear,
            items: <String>[
              '2026',
              '2025',
              '2024',
              '2023',
              '2022',
              '2021',
              '2020'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              selectedYear = value;
              setState(
                () {},
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(
              color: Colors.black26,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          ScrollingYearsCalendar(
            context: context,
            initialDate:
                DateTime.now().copyWith(year: int.parse(selectedYear!)),
            firstDate: DateTime.now()
                .subtract(const Duration(days: 1))
                .copyWith(year: int.parse(selectedYear!)),
            lastDate: DateTime.now()
                .add(Duration(days: 1))
                .copyWith(year: int.parse(selectedYear!)),
            currentDateColor: Colors.white,
            highlightedDates: getHighlightedDates(),
            highlightedDateColor: Colors.deepOrange,
            monthNames: const <String>[
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
            ],
            onMonthTap: (int year, int month) {
              debugPrint('Tapped $month/$year');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedMonthPlanner(
                      year: year,
                      month: month,
                    ),
                  ));
            },
            monthTitleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
