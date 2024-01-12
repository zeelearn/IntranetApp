import 'package:Intranet/api/response/cvf/centers_respinse.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../utils/toastmsg.dart';
import '../cubit/getplandetailscubit/getplandetails_cubit.dart';
import '../model/createemplyeeplanrequestmodel.dart';

class CalendarFormDialog extends StatefulWidget {
  CalendarFormDialog({
    required this.datetime,
    required this.calendarId,
    required this.centerResponse,
    this.event,
    super.key,
  });
  DateTime datetime;
  String? calendarId;
  Event? event;
  CentersResponse? centerResponse;

  @override
  State<CalendarFormDialog> createState() => _CalendarFormDialogState();
}

class _CalendarFormDialogState extends State<CalendarFormDialog> {
  final eventTextController = TextEditingController();

  final descriptionTextController = TextEditingController();

  final urlTextController = TextEditingController();

  final locationTextController = TextEditingController();

  List<FranchiseeInfo> franchiseeInfo = [];

  late DeviceCalendarPlugin _deviceCalendarPlugin;

  List<XMLRequest> xmlRequest = [];

  String timezone = 'Asia/Kolkata';
  Location? currentLocation;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    getCurrentTimeZone();

    if (widget.event != null) {
      eventTextController.text = widget.event!.title ?? '';
      descriptionTextController.text = widget.event!.description ?? '';
      urlTextController.text = widget.event?.url?.data?.contentText ?? '';
      // locationValue = widget.event!.location ?? '';
    }
    debugPrint(
        'calendar id is - ${widget.calendarId} and selected date is - ${widget.datetime}');
    super.initState();
  }

  getCurrentTimeZone() async {
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('Could not get the local timezone');
    }

    currentLocation = timeZoneDatabase.locations[timezone];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetplandetailsCubit, GetplandetailsState>(
      listener: (context, state) {
        if (state is CreateEmplyeePlanSuccessState) {
          Navigator.pop(context, state.listofGetplanDate);
        } else if (state is GetplandetailsErrorState) {
          Fluttertoast.showToast(msg: state.error, backgroundColor: Colors.red);
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: eventTextController,
                decoration: const InputDecoration(hintText: 'Enter event Name'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: descriptionTextController,
                decoration:
                    const InputDecoration(hintText: 'Enter Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: urlTextController,
                decoration: const InputDecoration(hintText: 'Enter Url'),
              ),
              const SizedBox(
                height: 20,
              ),
              widget.centerResponse != null
                  ? DropdownSearch<FranchiseeInfo>.multiSelection(
                      items: widget.centerResponse!.responseData,
                      popupProps: PopupPropsMultiSelection.menu(
                        showSelectedItems: true,
                        // disabledItemFn: (String s) => s.startsWith('I'),
                        showSearchBox: true,
                        itemBuilder: (context, item, isSelected) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: !isSelected
                                ? null
                                : BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                  ),
                            child: ListTile(
                              selected: isSelected,
                              title: Text(item.franchiseeName),
                              subtitle: Text(item.franchiseeCode.toString()),
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        debugPrint('onChanged value is - $value');
                        franchiseeInfo = value;
                      },
                      selectedItems: const [],
                      filterFn: (item, filter) {
                        if (filter.isNotEmpty) {
                          return item.franchiseeName
                              .toLowerCase()
                              .contains(filter);
                        } else {
                          return true;
                        }
                      },
                      compareFn: (item, sItem) {
                        return item.franchiseeId == sItem.franchiseeId;
                      },
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          // labelText: "Menu mode",
                          hintText: "Select Center Location",
                        ),
                      ),
                      dropdownBuilder: (context, selectedItems) {
                        if (selectedItems.isEmpty) {
                          return const Text("No Center selected");
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedItems.map((e) {
                            return Text(e.franchiseeName);
                          }).toList(),
                        );
                      },
                    )
                  : const SizedBox.square(),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    debugPrint(
                        'Location of time zone is - $currentLocation and location date is - ${DateFormat('yyyy-MM-dd').format(TZDateTime(currentLocation!, widget.datetime.year, widget.datetime.month, widget.datetime.day))}');
                    xmlRequest.clear();
                    if (franchiseeInfo.isNotEmpty) {
                      for (var franchiseeData in franchiseeInfo) {
                        xmlRequest.add(XMLRequest(
                            centerId: franchiseeData.franchiseeId.toInt(),
                            fromDate: DateFormat('yyyy-MM-dd').format(
                                TZDateTime(
                                    currentLocation!,
                                    widget.datetime.year,
                                    widget.datetime.month,
                                    widget.datetime.day)),
                            toDate: DateFormat('yyyy-MM-dd').format(TZDateTime(
                                currentLocation!,
                                widget.datetime.year,
                                widget.datetime.month,
                                widget.datetime.day)),
                            remark: descriptionTextController.text,
                            eventName: eventTextController.text,
                            url: urlTextController.text,
                            id: 0));
                      }
                      if (xmlRequest.isNotEmpty) {
                        BlocProvider.of<GetplandetailsCubit>(context)
                            .createEmployeePlan(
                                date: DateFormat('yyyy-MM-dd').format(
                                    TZDateTime(
                                        currentLocation!,
                                        widget.datetime.year,
                                        widget.datetime.month,
                                        widget.datetime.day)),
                                xmlRequest: xmlRequest);

                        for (var request in xmlRequest) {
                          var eventToCreate = Event(widget.calendarId,
                              title: eventTextController.text,
                              description: descriptionTextController.text,
                              url: Uri.dataFromString(urlTextController.text),
                              location: request.centerId.toString(),
                              start: TZDateTime(
                                  currentLocation!,
                                  widget.datetime.year,
                                  widget.datetime.month,
                                  widget.datetime.day),
                              end: TZDateTime(
                                  currentLocation!,
                                  widget.datetime.year,
                                  widget.datetime.month,
                                  widget.datetime.day),
                              allDay: true);
                          final createEventResult = await _deviceCalendarPlugin
                              .createOrUpdateEvent(eventToCreate);
                          if (createEventResult!.isSuccess) {
                            debugPrint(
                                'event inserted in calendar is - ${createEventResult.data}  and date is - ${TZDateTime(currentLocation!, widget.datetime.year, widget.datetime.month, widget.datetime.day)} and event is - ${eventTextController.text}');
                          } else {
                            for (var element in createEventResult.errors) {
                              debugPrint(
                                  'event inserted error for loop is - ${element.errorMessage}');
                            }
                          }
                        }
                      } else {
                        ToastMessage()
                            .showErrorToast('Please select center to visit.');
                      }
                    } else {
                      ToastMessage()
                          .showErrorToast('Please select center to visit.');
                    }

                    // if (widget.event != null) {
                    //   widget.event?.title = eventTextController.text;
                    //   widget.event?.description = descriptionTextController.text;
                    //   widget.event?.url =
                    //       Uri.dataFromString(urlTextController.text);
                    //   widget.event?.location = franchiseeInfo!.franchiseeCity;
                    //   final createEventResult = await _deviceCalendarPlugin
                    //       .createOrUpdateEvent(widget.event);
                    //   if (createEventResult!.isSuccess) {
                    //     debugPrint(
                    //         'event inserted in calendar is - ${createEventResult.data}  ');
                    //   } else {
                    //     for (var element in createEventResult.errors) {
                    //       debugPrint(
                    //           'event inserted error for loop is - ${element.errorMessage}');
                    //     }
                    //   }
                    // } else {
                    //   for (var request in xmlRequest) {
                    //     var eventToCreate = Event(widget.calendarId,
                    //         title: eventTextController.text,
                    //         description: descriptionTextController.text,
                    //         url: Uri.dataFromString(urlTextController.text),
                    //         location: request.centerId.toString(),
                    //         start: TZDateTime(
                    //             currentLocation!,
                    //             widget.datetime.year,
                    //             widget.datetime.month,
                    //             widget.datetime.day),
                    //         end: TZDateTime(
                    //             currentLocation!,
                    //             widget.datetime.year,
                    //             widget.datetime.month,
                    //             widget.datetime.day),
                    //         allDay: true);
                    //     final createEventResult = await _deviceCalendarPlugin
                    //         .createOrUpdateEvent(eventToCreate);
                    //     if (createEventResult!.isSuccess) {
                    //       debugPrint(
                    //           'event inserted in calendar is - ${createEventResult.data}  and date is - ${TZDateTime(currentLocation!, widget.datetime.year, widget.datetime.month, widget.datetime.day)} and event is - ${eventTextController.text}');
                    //     } else {
                    //       for (var element in createEventResult.errors) {
                    //         debugPrint(
                    //             'event inserted error for loop is - ${element.errorMessage}');
                    //       }
                    //     }
                    //   }
                    // }
                  },
                  child: const Text('Add Event')),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
