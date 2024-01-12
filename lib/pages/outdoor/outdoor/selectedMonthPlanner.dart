import 'package:Intranet/pages/outdoor/cubit/getplandetailscubit/getplandetails_cubit.dart';
import 'package:Intranet/pages/outdoor/model/createemplyeeplanrequestmodel.dart';
import 'package:Intranet/pages/outdoor/outdoor/calendarformupdateDialog.dart';
import 'package:Intranet/pages/utils/toastmsg.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../api/APIService.dart';
import '../../../api/request/cvf/centers_request.dart';
import '../../../api/response/cvf/centers_respinse.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/utils.dart';
import '../model/getplandetails.dart';
import 'calendar/utils/meetingDataSource.dart';
import 'calendarformdialog.dart';

class SelectedMonthPlanner extends StatefulWidget {
  int year, month;
  List<GetPlanData> highlightDate;
  SelectedMonthPlanner(
      {required this.month,
      required this.year,
      required this.highlightDate,
      super.key});

  @override
  State<SelectedMonthPlanner> createState() => _SelectedMonthPlannerState();
}

class _SelectedMonthPlannerState extends State<SelectedMonthPlanner> {
  late DeviceCalendarPlugin _deviceCalendarPlugin;
  String? calendarId;
  CentersResponse? centerResponse;
  final List<Event?> _multiDatePickerValueWithDefaultValue = [];
  final List<Meeting> allMeetings = <Meeting>[];
  final List<GetPlanData> meetings = <GetPlanData>[];

  final CalendarController calendarController = CalendarController();

  List<XMLRequest> updatedxmlrequestlist = [];

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    super.initState();
    getCVFCenters();
    _retrieveCalendars();
    _retrieveCalendarEvents();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadDataSource(DateTime(widget.year, widget.month), true);
      calendarController.view = CalendarView.month;
      // calendarController.forward = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _retrieveCalendarEvents() async {
    final startDate = DateTime(widget.year, widget.month);
    final endDate =
        DateTime(widget.year, widget.month).add(const Duration(days: 30));

    var listofCalendar = await _deviceCalendarPlugin.retrieveCalendars();
    if (listofCalendar.data != null) {
      for (var element in listofCalendar.data!) {
        if (element.name == 'Intranet') {
          calendarId = element.id;
        }
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

  getCVFCenters() async {
    var hive = Hive.box(LocalConstant.KidzeeDB);
    var employeeID = hive.get(LocalConstant.KEY_EMPLOYEE_ID, defaultValue: 0);
    var businessID = hive.get(LocalConstant.KEY_BUSINESS_ID, defaultValue: 0);
    CentersRequestModel requestModel = CentersRequestModel(
        EmployeeId: int.parse(employeeID), Brand: businessID);
    await APIService().getCVFCenters(requestModel).then((value) {
      if (value != null) {
        if (value is CentersResponse) {
          debugPrint('Response from CVF api is - $value');
          centerResponse = value;

          setState(() {});
        } else {
          Utility.showMessage(context, 'No Franchisee data found');
        }
      }
    });
  }

  DateTime selectedDate = DateTime.now();

  loadDataSource(DateTime selectedDate, bool isMonth) {
    meetings.clear();
    allMeetings.clear();

    for (int i = 0; i < widget.highlightDate.length; i++) {
      widget.highlightDate[i].visitDate != null &&
              DateFormat('yyyy-MM-dd')
                      .parse(widget.highlightDate[i].visitDate!)
                      .month ==
                  selectedDate.month
          ? allMeetings.add(Meeting(
              widget.highlightDate[i].remarks ?? '',
              DateFormat('yyyy-MM-dd')
                  .parse(widget.highlightDate[i].visitDate!),
              DateFormat('yyyy-MM-dd')
                  .parse(widget.highlightDate[i].visitDate!),
              getColor(widget.highlightDate[i].status),
              true))
          : null;
      widget.highlightDate[i].visitDate != null &&
              (isMonth
                  ? DateFormat('yyyy-MM-dd')
                          .parse(widget.highlightDate[i].visitDate!)
                          .month ==
                      selectedDate.month
                  : DateFormat('yyyy-MM-dd')
                          .parse(widget.highlightDate[i].visitDate!) ==
                      selectedDate)
          ? meetings.add(widget.highlightDate[i])
          : null;
    }
    // setState(() {});
  }

  Color getColor(String? type) {
    debugPrint('type is - $type');
    if (type == "FILL CVF") {
      return Colors.yellowAccent.shade200;
    } else if (type == 'Pending') {
      return Colors.redAccent.shade200;
    } else if (type == 'Completed') {
      return Colors.greenAccent.shade200;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetplandetailsCubit, GetplandetailsState>(
      listener: (context, state) {
        if (state is DeleteEmplyeePlanSuccessState) {
          widget.highlightDate
              .removeWhere((element) => element.id == int.parse(state.id));

          loadDataSource(selectedDate, false);
          setState(() {});
        } else if (state is GetplandetailsErrorState) {
          ToastMessage().showErrorToast(state.error);
        }
      },
      child: SafeArea(
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
                              datetime: selectedDate,
                              calendarId: calendarId,
                              centerResponse: centerResponse,
                            );
                          },
                        ).then((value) async {
                          if (value != null) {
                            var listofgetplandate = value as List<GetPlanData>;

                            for (var element in listofgetplandate) {
                              debugPrint(
                                  'Response from insert api is - ${element.toJson()}');
                              if (!widget.highlightDate.contains(element)) {
                                widget.highlightDate.add(element);
                              }
                            }

                            loadDataSource(selectedDate, false);

                            // updatedxmlrequestlist.addAll(value);
                            setState(() {});
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ))
                ],
              ),
              body: Column(children: [
                SfCalendar(
                  view: CalendarView.month,
                  viewNavigationMode: ViewNavigationMode.none,
                  initialDisplayDate: DateTime(widget.year, widget.month),
                  allowViewNavigation: false,
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                        color: const Color.fromARGB(255, 68, 140, 255),
                        width: 2),
                    // borderRadius: const BorderRadius.all(Radius.circular(4)),
                    shape: BoxShape.circle,
                  ),
                  dragAndDropSettings: const DragAndDropSettings(
                    allowScroll: false,
                    allowNavigation: false,
                  ),
                  showNavigationArrow: false,
                  allowDragAndDrop: false,
                  controller: calendarController,
                  onTap: (CalendarTapDetails calendarTapDetails) async {
                    selectedDate = calendarTapDetails.date!;

                    // await loadSelectedDateData();
                    loadDataSource(selectedDate, false);

                    setState(() {});
                  },
                  dataSource: MeetingDataSource(allMeetings),
                  monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
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
                          color: getColor(meetings[index].status),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meetings[index].remarks ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  meetings[index].visitDate != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                          DateTime.parse(
                                              meetings[index].visitDate!))
                                      : '',
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
                                    debugPrint(
                                        'Getplandata in month planner update button is - ${meetings[index].toJson()}');

                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          CalendarFormUpdateDialog(
                                              getPlandata: meetings[index],
                                              calendarId: calendarId,
                                              centerResponse: centerResponse),
                                    ).then((value) async {
                                      if (value != null) {
                                        var listofgetplandate =
                                            value as List<GetPlanData>;

                                        // widget.highlightDate.firstWhere((element) => element.id == listofgetplandate[0].id) = listofgetplandate[0];

                                        widget.highlightDate[widget
                                                .highlightDate
                                                .indexWhere((element) =>
                                                    element.id ==
                                                    listofgetplandate[0].id)] =
                                            listofgetplandate[0];
                                        /*  for (var element in listofgetplandate) {
                                          if (!widget.highlightDate
                                              .contains(element)) {
                                            widget.highlightDate.add(element);
                                          }
                                        } */

                                        // for (int i = 0;
                                        //     i < widget.highlightDate.length;
                                        //     i++) {
                                        //   if (widget.highlightDate[i].id ==
                                        //       listofgetplandate[0].id) continue;
                                        //   widget.highlightDate[i] =
                                        //       listofgetplandate[0];
                                        //   break;
                                        // }

                                        loadDataSource(selectedDate, false);

                                        // updatedxmlrequestlist.addAll(value);
                                        setState(() {});
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () {
                                    BlocProvider.of<GetplandetailsCubit>(
                                            context)
                                        .deleteEmployeePlan(
                                            id: meetings[index].id.toString());
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    itemCount: meetings.length,
                  ),
                )
              ]))),
    );
  }

  Future<void> loadSelectedDateData() async {
    final startDate = DateTime(widget.year, widget.month);
    final endDate =
        DateTime(widget.year, widget.month).add(const Duration(days: 30));
    var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate));

    _multiDatePickerValueWithDefaultValue.clear();
    if (calendarEventsResult.data != null) {
      for (var element in calendarEventsResult.data!) {
        debugPrint(
            'List of available event is - ${element.start} and selectedDate is - $selectedDate');
        if (element.start.toString().split('+')[0] == selectedDate.toString()) {
          _multiDatePickerValueWithDefaultValue.add(element);
        }
      }
    }
  }
}
