import 'package:Intranet/api/response/cvf/centers_respinse.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';

import '../../utils/toastmsg.dart';
import '../cubit/getplandetailscubit/getplandetails_cubit.dart';
import '../model/createemplyeeplanrequestmodel.dart';
import '../model/getplandetails.dart';

class CalendarFormUpdateDialog extends StatefulWidget {
  CalendarFormUpdateDialog({
    // required this.datetime,
    required this.calendarId,
    required this.centerResponse,
    required this.getPlandata,
    super.key,
  });
  // DateTime datetime;
  String? calendarId;

  CentersResponse? centerResponse;
  GetPlanData getPlandata;

  @override
  State<CalendarFormUpdateDialog> createState() =>
      _CalendarFormUpdateDialogState();
}

class _CalendarFormUpdateDialogState extends State<CalendarFormUpdateDialog> {
  final eventTextController = TextEditingController();

  final descriptionTextController = TextEditingController();

  final urlTextController = TextEditingController();

  final locationTextController = TextEditingController();

  FranchiseeInfo? franchiseeInfo;

  late DeviceCalendarPlugin _deviceCalendarPlugin;

  List<XMLRequest> xmlRequest = [];

  String timezone = 'Asia/Kolkata';
  Location? currentLocation;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    getCurrentTimeZone();

    debugPrint(
        'getplandata in initstate  is - ${widget.getPlandata.centerId} ');

    eventTextController.text = widget.getPlandata.eventName ?? '';
    descriptionTextController.text = widget.getPlandata.remarks ?? '';
    urlTextController.text = widget.getPlandata.url ?? '';
    // locationValue = widget.event!.location ?? '';

    for (var element in widget.centerResponse!.responseData) {
      if (element.franchiseeId == widget.getPlandata.centerId) {
        franchiseeInfo = element;
      }
    }
    super.initState();
  }

  getCurrentTimeZone() async {
    /*try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      debugPrint('Could not get the local timezone');
    }*/

    currentLocation = timeZoneDatabase.locations[timezone];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetplandetailsCubit, GetplandetailsState>(
      listener: (context, state) {
        if (state is CreateEmplyeePlanSuccessState) {
          Navigator.pop(context, state.listofGetplanDate);
        } else if (state is GetplandetailsErrorState) {
          ToastMessage().showErrorToast(
            state.error,
          );
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
              /*  TextField(
                controller: urlTextController,
                decoration: const InputDecoration(hintText: 'Enter Url'),
              ),
              const SizedBox(
                height: 20,
              ), */
              widget.centerResponse != null
                  ? DropdownButton<FranchiseeInfo>(
                      elevation: 0,
                      underline:
                          Container(color: Colors.grey.shade700, height: 1),
                      isExpanded: true,
                      hint: const Text('Select Location'),
                      value: franchiseeInfo,
                      items: widget.centerResponse!.responseData
                          .map((FranchiseeInfo value) {
                        return DropdownMenuItem<FranchiseeInfo>(
                          value: value,
                          child: Text(value.franchiseeName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        franchiseeInfo = value;
                        setState(
                          () {},
                        );
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<GetplandetailsCubit, GetplandetailsState>(
                builder: (context, getplandetailstate) => ElevatedButton(
                    onPressed: getplandetailstate is GetplandetailsLoadingState
                        ? null
                        : () async {
                            xmlRequest.clear();
                            var selectedDateTime =
                                DateTime.parse(widget.getPlandata.visitDate!);

                            debugPrint(
                                'Location of time zone is - $currentLocation and location date is - ${DateFormat('yyyy-MM-dd').format(TZDateTime(currentLocation!, selectedDateTime.year, selectedDateTime.month, selectedDateTime.day))}');

                            debugPrint(
                                'getplandata is - ${widget.getPlandata.centerId} ');

                            xmlRequest.add(XMLRequest(
                                id: widget.getPlandata.id!,
                                centerId: franchiseeInfo!.franchiseeId.toInt(),
                                fromDate: '',
                                toDate: '',
                                remark: descriptionTextController.text,
                                eventName: eventTextController.text,
                                url: urlTextController.text));

                            BlocProvider.of<GetplandetailsCubit>(context)
                                .createEmployeePlan(
                                    date: DateFormat('yyyy-MM-dd').format(
                                        TZDateTime(
                                            currentLocation!,
                                            selectedDateTime.year,
                                            selectedDateTime.month,
                                            selectedDateTime.day)),
                                    xmlRequest: xmlRequest);
                          },
                    child: getplandetailstate is GetplandetailsLoadingState
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            height: 45,
                            child: const CircularProgressIndicator())
                        : const Text('update Event')),
              ),
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
