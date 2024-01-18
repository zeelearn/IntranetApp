import 'package:Intranet/pages/outdoor/cubit/getplandetailscubit/getplandetails_cubit.dart';
import 'package:Intranet/pages/outdoor/model/createemplyeeplanrequestmodel.dart';
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
import 'calendarformupdateDialog.dart';

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
  final List meetinginmap = [];

  final CalendarController calendarController = CalendarController();

  List<XMLRequest> updatedxmlrequestlist = [];

  var groupbypriority;

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
      return const Color(0xFFFFBF00);
    } else if (type == 'Pending') {
      return const Color(0xFFF08080);
    } else if (type == 'Completed') {
      return const Color(0xFF2ECC71);
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetplandetailsCubit, GetplandetailsState>(
      listener: (context, state) {
        if (state is DeleteEmplyeePlanSuccessState) {
          widget.highlightDate.removeWhere((element) {
            debugPrint(
                'highlight date id is - ${element.id} and - deleted id is - ${state.id}');
            return element.id == int.parse(state.id);
          });

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

                            for (GetPlanData newData in listofgetplandate) {
                              bool isAlreadyPresent = widget.highlightDate
                                  .any((item1) => item1.id == newData.id);

                              if (!isAlreadyPresent) {
                                widget.highlightDate.add(newData);
                              }
                            }

                            loadDataSource(selectedDate, false);

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
                const SizedBox(
                  height: 20,
                ),
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

                    loadDataSource(selectedDate, false);

                    setState(() {});
                  },
                  resourceViewHeaderBuilder: (context, details) {
                    return const Text('resourceHeader');
                  },
                  // loadMoreWidgetBuilder: (context, loadMoreAppointments) {
                  //   return const Text('loadmoreHeader');
                  // },
                  scheduleViewMonthHeaderBuilder: (context, details) {
                    return const Text('monthHeader');
                  },
                  // headerStyle:
                  //     const CalendarHeaderStyle(backgroundColor: Colors.black),
                  headerHeight: 0,
                  dataSource: MeetingDataSource(allMeetings),
                  monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.indicator,
                      appointmentDisplayCount: allMeetings.length),
                  onSelectionChanged: (calendarSelectionDetails) {
                    debugPrint('Is this getting clicked');
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: BlocBuilder<GetplandetailsCubit, GetplandetailsState>(
                    builder: (context, getplanbuilderstate) =>
                        getplanbuilderstate is GetplandetailsLoadingState
                            ? const Center(child: CircularProgressIndicator())
                            : meetings.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      bool isSamePriority = true;
                                      final String priority =
                                          meetings[index].priority!;

                                      if (index == 0) {
                                        isSamePriority = false;
                                      } else {
                                        final String prevPriority =
                                            meetings[index - 1].priority!;

                                        isSamePriority =
                                            priority == prevPriority;
                                      }
                                      if (index == 0 || !(isSamePriority)) {
                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4),
                                                child: Text(
                                                  priority == 'H'
                                                      ? 'CVF'
                                                      : 'Plan',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                              ),
                                              listWidget(index, context)
                                            ]);
                                      } else {
                                        return listWidget(index, context);
                                      }
                                    },
                                    itemCount: meetings.length,
                                  )
                                : const Center(
                                    child: Text('No Plan available.')),
                  ),
                ),
              ]))),
    );
  }

  Container listWidget(int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        color: getColor(meetings[index].status),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                meetings[index].eventName == null ||
                        meetings[index].eventName!.isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        '${meetings[index].eventName} - ${meetings[index].franchiseeName}',
                        overflow: TextOverflow.fade,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.white, fontSize: 18),
                      ),
                meetings[index].remarks == null ||
                        meetings[index].remarks!.isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        'Remarks - ${meetings[index].remarks}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.white, fontSize: 18),
                      ),
                meetings[index].visitDate != null
                    ? Text(
                        'Schedule Date - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(meetings[index].visitDate!))}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.white, fontSize: 14),
                      )
                    : const SizedBox.shrink(),
                meetings[index].priority == 'H'
                    ? Column(
                        children: [
                          meetings[index].checkIn != null
                              ? Text(
                                  'Check In ${DateFormat('yyyy-MM-dd, hh:mm:ss').format(DateTime.parse(meetings[index].checkIn!))}',
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          color: Colors.white, fontSize: 14),
                                )
                              : const SizedBox.shrink(),
                          meetings[index].checkOut != null
                              ? Text(
                                  'Check Out ${DateFormat('yyyy-MM-dd,hh:mm:ss').format(DateTime.parse(meetings[index].checkOut!))}',
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          color: Colors.white, fontSize: 14),
                                )
                              : const SizedBox.shrink(),
                        ],
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
          meetings[index].priority != null && meetings[index].priority == 'L'
              ? Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        debugPrint(
                            'Getplandata in month planner update button is - ${meetings[index].toJson()}');

                        showDialog(
                          context: context,
                          builder: (context) => CalendarFormUpdateDialog(
                              getPlandata: meetings[index],
                              calendarId: calendarId,
                              centerResponse: centerResponse),
                        ).then((value) async {
                          if (value != null) {
                            var listofgetplandate = value as List<GetPlanData>;

                            widget.highlightDate[widget.highlightDate
                                    .indexWhere((element) =>
                                        element.id ==
                                        listofgetplandate[0].id)] =
                                listofgetplandate[0];

                            loadDataSource(selectedDate, false);

                            setState(() {});
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Warning"),
                              content: const Text(
                                  'Do you want to delete this plan.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<GetplandetailsCubit>(
                                            context)
                                        .deleteEmployeePlan(
                                            id: meetings[index].id.toString());
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("YES"),
                                ),
                                TextButton(
                                  child: const Text("NO"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
