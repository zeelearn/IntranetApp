import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/attendance_marking_request.dart';
import 'package:intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/iface/onClick.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:intranet/pages/widget/MyWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/APIService.dart';
import '../../api/response/attendance_marking_response.dart';
import '../helper/LightColor.dart';
import '../utils/theme/colors/light_colors.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  String displayName;

  int employeeId = 0;

  AttendanceMarkingScreen(
      {Key? key,
        required this.employeeId,
        required this.displayName,
       })
      : super(key: key);

  @override
  _AttendanceMarkingScreen createState() => _AttendanceMarkingScreen();
}

class _AttendanceMarkingScreen extends State<AttendanceMarkingScreen> implements onClickListener{
  List<LeaveRequisitionInfo> leaveRequisitionList = [];
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _fromTimeController = TextEditingController();
  TextEditingController _toTimeController = TextEditingController();
  TextEditingController _workLocationController = TextEditingController();
  TextEditingController _jobDescController = TextEditingController();
  DateTime currentDate = DateTime.now();
  DateTime minDate = DateTime(DateTime.now().year, DateTime.now().month - 3, 1);
  DateTime maxDate = DateTime.now();
  bool isWFH = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    widget.employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.black;
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: widget.displayName=='--' ? null : AppBar(title: Text('ATTENDANCE MARKING'),),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              widget.displayName=='--' ? MyWidget().richText(14, 'ATTENDANCE MARKING') : Text(''),
              /*SizedBox(
                height: size.height * 0.02,
              ),
              MyWidget().richText(14, 'MARKING ATTENDANCE - BASE LOCATION (HQ) WORKING'),*/
              SizedBox(
                height: size.height * 0.03,
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    MyWidget().getDateTime(context, 'Attendance Marking Date',
                        _startDateController, minDate, maxDate),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    getTime(context, 'From Time',
                        _fromTimeController, minDate, maxDate),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    getTime(context, 'To Time',
                        _toTimeController, minDate, maxDate),


                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Material(
                          child: Checkbox(
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: isWFH,
                            onChanged: (bool? value) {
                              setState(() {
                                isWFH = value!;
                              });
                            },
                          ),
                        ),
                        Text(
                          'IS WFH',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),

                    MyWidget().normalTextField(
                        context, 'Work Location', _workLocationController),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    MyWidget().normalTextAreaField(
                        context, 'Tasks Achieved for the day', _jobDescController),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    GestureDetector(
                      onTap: () {
                        validate();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: size.height / 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: LightColor.primary_color,
                          boxShadow: [
                            BoxShadow(
                              color: LightColor.seeBlue,
                              offset: const Offset(0, 5.0),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Approve/Reject',
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            color: LightColor.black,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  getTime(BuildContext context,String label, TextEditingController controller,
      DateTime minDate,DateTime maxDate) {
    return TextField(
        style: TextStyle(color: LightColor.titleTextColor),
        controller: controller, //editing controller of this TextField
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: LightColors.kLavender)),
            icon: Icon(Icons.timer), //icon of text field
            labelText: label //label text of field
        ),
        readOnly: true, //set it true, so that user will not able to edit text
        onTap: () async {
          _selectTime(context, controller);
        });
  }

  _selectTime(BuildContext context,TextEditingController controller) async {
    TimeOfDay selectedTime = TimeOfDay.now();

    TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), child: child!,
        );
      },
    );
    /*final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );*/
    if(timeOfDay != null)
    {
      setState(() {
        //controller.text = '${timeOfDay.hour}:${timeOfDay.minute}';
        final dt = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, timeOfDay.hour, timeOfDay.minute);
        controller.text =  DateFormat('hh:mm a').format(dt);
      });

    }

  }

  validate()async {
    bool isInternet = await Utility.isInternet();
    if(!isInternet) {
      Utility.noInternetConnection(context);
    }else if (_startDateController.text == '' ) {
      Utility.showMessage(context, 'Please Select the Date ');
    }else if (_fromTimeController.text == ''  || _toTimeController.text == '' ) {
      Utility.showMessage(context, 'Please Select the Time  ');
    } else if (_workLocationController.text == '') {
      Utility.showMessage(context, 'Please Enter the working location');
    }else if (_jobDescController.text == '') {
      Utility.showMessage(context, 'Please Enter the Tasks Achieved for the day');
    } else {
      DateTime startDate = parseDateTime('${_startDateController} ${_fromTimeController.text}:00');
      DateTime endDate = parseDateTime('${_startDateController} ${_toTimeController.text}:00');
      if (startDate.isAfter(endDate)) {
        Utility.showMessage(context, 'Please Enter Valid Time');
      }else {
        applyMarking();
      }
      /*DateTime start = parseDate(_startDateController.text);
      DateTime end = parseDate(_endDateController.text);
      if (start.isAfter(end)) {
        Utility.showMessage(context, 'Please Enter Valid Date Range');
      } else {
        applyLeave();
      }*/
    }
  }

  clearForm(){
    _startDateController.text = '';
    _fromTimeController.text = '';
    _toTimeController.text = '';
    _workLocationController.text = '';
    _jobDescController.text = '';
  }
  applyMarking() {
    Utility.showLoaderDialog(context);
    AttendanceMarkingRequest request = AttendanceMarkingRequest(Employee_Name: widget.displayName,
        Worklocation: _workLocationController.text,
        Employee_Id: widget.employeeId.toString(),
        Reason: _jobDescController.text,
        FromDT: DateFormat('yyyy-MM-ddTHH:mm:ss').format(parseDateTime('${_startDateController.text} ${_fromTimeController.text}')),
        ToDT: DateFormat('yyyy-MM-ddTHH:mm:ss').format(parseDateTime('${_startDateController.text} ${_toTimeController.text}')));

  print(request.getJson());
    APIService apiService = APIService();
    apiService.attendanceMarking(request).then((value) {
      Navigator.of(context).pop();
      print(value);
      if (value != null) {
        if (value == null ) {
          Utility.showMessage(context, 'Unable to Process your Request');
        } else if (value is AttendanceMarkingResponse) {
          AttendanceMarkingResponse response = value;
          Utility.showMessageSingleButton(context, response.responseMessage,this);
          if(response.responseMessage=='Attendance marked successfully') {

            clearForm();
          }

        }
      } else {
        Navigator.pop(context);
        Utility.showMessage(context, "Unable to Apply Attendance Request");
        print("null value");
      }
    });
  }


  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd').parse(value);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }
  DateTime parseDateTime(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('dd-MMM-yyyy hh:mm a').parse(value);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  String getParsedShortDate(String value) {
    DateTime dateTime = parseDate(value);
    return DateFormat("MMM-dd").format(dateTime);
  }

  @override
  void onClick(int action, value) {
    clearForm();
  }




}
