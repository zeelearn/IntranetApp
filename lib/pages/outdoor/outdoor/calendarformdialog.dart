import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class CalendarFormDialog extends StatefulWidget {
  CalendarFormDialog({
    required this.datetime,
    required this.calendarId,
    this.event,
    super.key,
  });
  DateTime datetime;
  String? calendarId;
  Event? event;

  @override
  State<CalendarFormDialog> createState() => _CalendarFormDialogState();
}

class _CalendarFormDialogState extends State<CalendarFormDialog> {
  final eventTextController = TextEditingController();

  final descriptionTextController = TextEditingController();

  final urlTextController = TextEditingController();

  final locationTextController = TextEditingController();

  String? locationValue;

  late DeviceCalendarPlugin _deviceCalendarPlugin;

  @override
  void initState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
    if (widget.event != null) {
      eventTextController.text = widget.event!.title ?? '';
      descriptionTextController.text = widget.event!.description ?? '';
      urlTextController.text = widget.event?.url?.data?.contentText ?? '';
      locationValue = widget.event!.location ?? '';
    }
    debugPrint(
        'calendar id is - ${widget.calendarId} and selected date is - ${widget.datetime}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        insetPadding: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: eventTextController,
              decoration: InputDecoration(hintText: 'Enter event Name'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: descriptionTextController,
              decoration: InputDecoration(hintText: 'Enter Description'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: urlTextController,
              decoration: InputDecoration(hintText: 'Enter Url'),
            ),
            SizedBox(
              height: 20,
            ),
            DropdownButton<String>(
              elevation: 0,
              underline: Container(color: Colors.grey.shade700, height: 1),
              isExpanded: true,
              hint: Text('Select Location'),
              value: locationValue,
              items: <String>['Mumbai', 'Noida', 'Gurgaon', 'keral']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                locationValue = value;
                setState(
                  () {},
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  String timezone = 'Asia/Kolkata';
                  try {
                    timezone = await FlutterNativeTimezone.getLocalTimezone();
                  } catch (e) {
                    debugPrint('Could not get the local timezone');
                  }
                  var currentLocation = timeZoneDatabase.locations[timezone];

                  debugPrint('Location of time zone is - ${currentLocation}');

                  if (widget.event != null) {
                    widget.event?.title = eventTextController.text;
                    widget.event?.description = descriptionTextController.text;
                    widget.event?.url =
                        Uri.dataFromString(urlTextController.text);
                    widget.event?.location = locationValue;
                    final createEventResult = await _deviceCalendarPlugin
                        .createOrUpdateEvent(widget.event);
                    if (createEventResult!.isSuccess) {
                      debugPrint(
                          'event inserted in calendar is - ${createEventResult.data}  ');
                    } else {
                      createEventResult.errors.forEach((element) {
                        debugPrint(
                            'event inserted error for loop is - ${element.errorMessage}');
                      });
                    }
                  } else {
                    var eventToCreate = Event(widget.calendarId,
                        title: eventTextController.text,
                        description: descriptionTextController.text,
                        url: Uri.dataFromString(urlTextController.text),
                        location: locationValue,
                        start: TZDateTime(
                            currentLocation!,
                            widget.datetime.year,
                            widget.datetime.month,
                            widget.datetime.day),
                        end: TZDateTime(currentLocation, widget.datetime.year,
                            widget.datetime.month, widget.datetime.day),
                        allDay: true);
                    final createEventResult = await _deviceCalendarPlugin
                        .createOrUpdateEvent(eventToCreate);
                    if (createEventResult!.isSuccess) {
                      debugPrint(
                          'event inserted in calendar is - ${createEventResult.data}  and date is - ${TZDateTime(currentLocation, widget.datetime.year, widget.datetime.month, widget.datetime.day)} and event is - ${eventTextController.text}');
                    } else {
                      createEventResult.errors.forEach((element) {
                        debugPrint(
                            'event inserted error for loop is - ${element.errorMessage}');
                      });
                    }
                  }
                },
                child: const Text('Add Event')),
            const SizedBox(
              height: 20,
            ),
          ]),
        ),
      ),
    );
  }
}
