import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/widget/MyWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/APIService.dart';
import '../../api/request/apply_leave_request.dart';
import '../../api/response/apply_leave_response.dart';
import '../helper/LightColor.dart';
import '../utils/theme/colors/light_colors.dart';

class ApplyOutDoorScreen extends StatefulWidget {
  String displayName;

  int employeeId = 0;

  ApplyOutDoorScreen(
      {Key? key,
        required this.employeeId,
        required this.displayName,
      })
      : super(key: key);

  @override
  _ApplyOutDoorScreen createState() => _ApplyOutDoorScreen();
}

class _ApplyOutDoorScreen extends State<ApplyOutDoorScreen> {
  List<LeaveRequisitionInfo> leaveRequisitionList = [];
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _fromTimeController = TextEditingController();
  TextEditingController _toTimeController = TextEditingController();
  TextEditingController _jobDescController = TextEditingController();
  DateTime currentDate = DateTime.now();
  DateTime minDate = DateTime(DateTime.now().year, DateTime.now().month - 3, 1);
  DateTime maxDate = DateTime(DateTime.now().year, DateTime.now().month + 3, 1);
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
        backgroundColor: LightColors.kLightYellow,
        appBar: AppBar(title: Text('Outdoor duty application'),),
        body: SafeArea(
          child: Column(
            children: [

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
                    MyWidget().getDateTime(context, 'Outdoor Marking Date',
                        _startDateController, minDate, maxDate),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    getTime(context, 'In Time',
                        _fromTimeController, minDate, maxDate),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    getTime(context, 'Out Time',
                        _toTimeController, minDate, maxDate),

                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    MyWidget().normalTextAreaField(
                        context, 'Please enter purpose', _jobDescController),
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
                          'Submit',
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
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null && timeOfDay != selectedTime)
    {
      setState(() {
        controller.text = '${timeOfDay.hour}:${timeOfDay.minute}';
      });

    }

  }

  validate() {
    if (_startDateController.text == '' ) {
      Utility.showMessage(context, 'Please Select the Date ');
    }else if (_fromTimeController.text == ''  || _toTimeController.text == '' ) {
      Utility.showMessage(context, 'Please Select the Time  ');
    } else if (_jobDescController.text == '') {
      Utility.showMessage(context, 'Please Enter the purpose');
    } else {
      DateTime startDate = parseDateTime('${_startDateController.text} ${_fromTimeController.text}:00');
      DateTime endDate = parseDateTime('${_startDateController.text} ${_toTimeController.text}:00');
      if (startDate.isAfter(endDate)) {
        Utility.showMessage(context, 'Please Enter Valid Time');
      }else {
        DateTime startDate = parseDateTime('${_startDateController.text} ${_fromTimeController.text}:00');
        DateTime endDate = parseDateTime('${_startDateController.text} ${_toTimeController.text}:00');
        if (startDate.isAfter(endDate)) {
          Utility.showMessage(context, 'Please Enter Valid Time');
        }else {
          applyOutdoor();
        }
      }

    }
  }

  clearForm(){
    _startDateController.text = '';
    _fromTimeController.text = '';
    _toTimeController.text = '';
    _jobDescController.text = '';
  }

  applyOutdoor() {
    Utility.showLoaderDialog(context);
    ApplyLeaveRequest request = ApplyLeaveRequest(
        Requisition_Id: 0,
        Type: 'OutDoor',
        Employee_Id: widget.employeeId.toString(),
        Remarks: _jobDescController.text,
        Requisition_Date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        RequisitionTypeCode: 'LV2',
        Start_Date: '${_startDateController.text} ${_fromTimeController.text}:00',
        End_Date: '${_startDateController.text} ${_toTimeController.text}:00',
        NosDays: 0,
        IsMaternityLeave: false,
        noofChildren: "0",
        WorkLocation: "");

    APIService apiService = APIService();
    apiService.applyLeave(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Outdoor Request');
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          Utility.showMessage(context, response.responseMessage);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } else {
        Navigator.pop(context);
        Utility.showMessage(context, "Unable to Apply Outdoor Request");
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
      dt = new DateFormat('yyyy-MM-dd mm:hh:ss').parse(value);
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


}
