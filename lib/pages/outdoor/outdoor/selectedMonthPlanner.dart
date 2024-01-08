import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar/utils/meetingDataSource.dart';
import 'calendarformdialog.dart';

class SelectedMonthPlanner extends StatefulWidget {
  int year, month;
  SelectedMonthPlanner({required this.month, required this.year, super.key});

  @override
  State<SelectedMonthPlanner> createState() => _SelectedMonthPlannerState();
}

class _SelectedMonthPlannerState extends State<SelectedMonthPlanner> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  String? calendarId;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    super.initState();

    _retrieveCalendars();
    _retrieveCalendarEvents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Event?> _multiDatePickerValueWithDefaultValue = [
    // DateTime(today.year, today.month, 1),
    // DateTime(today.year, today.month, 5),
    // DateTime(today.year, today.month, 14),
    // DateTime(today.year, today.month, 17),
    // DateTime(today.year, today.month, 25),
  ];

  List<DateTime?> _setDefaultEvent = [
    // DateTime.now(),
  ];

  Future _retrieveCalendarEvents() async {
    final startDate = DateTime(widget.year, widget.month);
    final endDate = DateTime(widget.year, widget.month).add(Duration(days: 30));

    var listofCalendar = await _deviceCalendarPlugin.retrieveCalendars();

    for (var element in listofCalendar.data!) {
      if (element.name == 'Intranet') {
        calendarId = element.id;
      }
    }

    if (calendarId == null) {
      var result = await _deviceCalendarPlugin.createCalendar(
        'Intranet',
        calendarColor: null,
        localAccountName: 'Local Intranet',
      );
      debugPrint('response from create calendar is - ${result.data}');
      if (result.isSuccess) {
        calendarId = result.data;
      }
    }

    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate));

    _multiDatePickerValueWithDefaultValue.clear();

    for (var element in calendarEventsResult.data!) {
      _multiDatePickerValueWithDefaultValue.add(element);
    }
    setState(() {});
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess &&
          (permissionsGranted.data == null ||
              permissionsGranted.data == false)) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess ||
            permissionsGranted.data == null ||
            permissionsGranted.data == false) {
          return;
        }
      }
    } on PlatformException catch (e, s) {
      debugPrint('RETRIEVE_CALENDARS: $e, $s');
    }
  }

  DateTime selectedDate = DateTime.now();

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0)
            .subtract(Duration(days: 1));
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                  'User Plan for ${DateFormat('MMM').format(DateTime(0, widget.month))}'),
              actions: [
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CalendarFormDialog(
                              datetime: selectedDate, calendarId: calendarId);
                        },
                      ).then((value) async => await loadSelectedDateData());
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ))
              ],
            ),
            body: Column(children: [
              SfCalendar(
                view: CalendarView.month,
                initialDisplayDate: DateTime(widget.year, widget.month),
                allowViewNavigation: false,
                // todayTextStyle: Theme.of(context)
                //     .textTheme
                //     .labelSmall!
                //     .copyWith(fontSize: 12),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      color: const Color.fromARGB(255, 68, 140, 255), width: 2),
                  // borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.circle,
                ),
                dragAndDropSettings: const DragAndDropSettings(
                  allowScroll: false,
                  allowNavigation: false,
                ),
                allowDragAndDrop: false,
                onTap: (CalendarTapDetails calendarTapDetails) async {
                  selectedDate = calendarTapDetails.date!;

                  await loadSelectedDateData();

                  setState(() {});
                },
                dataSource: MeetingDataSource(_getDataSource()),
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment,
                    monthCellStyle: MonthCellStyle(
                        leadingDatesTextStyle: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(fontSize: 12),
                        textStyle: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(fontSize: 12))),
                // monthCellBuilder: (context, details) {
                //   if (details.date ==
                //       DateTime.now().subtract(Duration(days: 3))) {
                //     return Container(
                //       child: Text(details.date.day.toString()),
                //       color: Colors.red,
                //     );
                //   } else {
                //     return Container(
                //       color: Colors.white,
                //       child: Text(details.date.day.toString()),
                //     );
                //   }
                // },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          // vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: Colors.cyanAccent.shade700,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_multiDatePickerValueWithDefaultValue[index]!.title}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  '${DateFormat('yyyy/MM/dd').format(_multiDatePickerValueWithDefaultValue[index]!.start as DateTime)} - ${DateFormat('yyyy/MM/dd').format(_multiDatePickerValueWithDefaultValue[index]!.end as DateTime)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => CalendarFormDialog(
                                          datetime:
                                              _multiDatePickerValueWithDefaultValue[
                                                      index]!
                                                  .start as DateTime,
                                          calendarId: calendarId,
                                          event:
                                              _multiDatePickerValueWithDefaultValue[
                                                  index]),
                                    ).then((value) async =>
                                        await loadSelectedDateData());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    _deviceCalendarPlugin
                                        .deleteEvent(
                                            calendarId,
                                            _multiDatePickerValueWithDefaultValue[
                                                    index]!
                                                .eventId)
                                        .then((value) async {
                                      if (value.isSuccess) {
                                        await loadSelectedDateData();
                                      }
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _multiDatePickerValueWithDefaultValue.length,
                ),
              )
            ])));
  }

  Future<void> loadSelectedDateData() async {
    final startDate = DateTime(widget.year, widget.month);
    final endDate =
        DateTime(widget.year, widget.month).add(const Duration(days: 30));
    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate));

    _multiDatePickerValueWithDefaultValue.clear();

    for (var element in calendarEventsResult.data!) {
      debugPrint(
          'List of available event is - ${element.start} and selectedDate is - $selectedDate');
      if (element.start.toString().split('+')[0] == selectedDate.toString()) {
        _multiDatePickerValueWithDefaultValue.add(element);
      }
    }
  }
}
