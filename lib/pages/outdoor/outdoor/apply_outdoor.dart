import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/request/leave/php_checker.dart';
import 'package:Intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/widget/MyWidget.dart';
import '../../../api/APIService.dart';
import '../../../api/request/apply_leave_request.dart';
import '../../../api/request/leave/pjp_response.dart';
import '../../../api/response/apply_leave_response.dart';

import '../../helper/LightColor.dart';
import '../../pjp/add_new_pjp.dart';
import '../../utils/theme/colors/light_colors.dart';


class ApplyOutDoorScreen extends StatefulWidget {
  String displayName;

  int employeeId = 0;
  int businessId = 0;

  ApplyOutDoorScreen(
      {Key? key,
        required this.businessId,
        required this.employeeId,
        required this.displayName,
      })
      : super(key: key);

  @override
  _ApplyOutDoorScreen createState() => _ApplyOutDoorScreen();
}

class _ApplyOutDoorScreen extends State<ApplyOutDoorScreen> implements onClickListener{
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
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    widget.employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);

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
        backgroundColor: LightColors.kLightGray,
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
                          'Submit',style: LightColors.textHeaderStyle13Selected,
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
    TimeOfDay selectedTime = TimeOfDay(hour: 12, minute: 00);
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), child: child!,
        );
      },

    );
    if(timeOfDay != null )
    {
      setState(() {
        final dt = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, timeOfDay.hour, timeOfDay.minute);
        controller.text =  DateFormat('hh:mm a').format(dt);
        //controller.text = '${timeOfDay.hourOfPeriod}:${timeOfDay.minute}';
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
    } else if (_jobDescController.text == '') {
      Utility.showMessage(context, 'Please Enter the purpose');
    } else {
      DateTime startDate = parseDateTime('${_startDateController.text} ${_fromTimeController.text}');
      DateTime endDate = parseDateTime('${_startDateController.text} ${_toTimeController.text}');
      if (startDate.isAfter(endDate)) {
        Utility.showMessage(context, 'Please Enter Valid Time');
      }else {
        DateTime startDate = parseDateTime('${_startDateController.text} ${_fromTimeController.text}');
        DateTime endDate = parseDateTime('${_startDateController.text} ${_toTimeController.text}');
        if (startDate.isAfter(endDate)) {
          Utility.showMessage(context, 'Please Enter Valid Time');
        }else {
          //applyOutdoor();
          checkPJPStatus();
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

  checkPJPStatus() {
    Utility.showLoaderDialog(context);
    //2022-01-17T10:26:02
    CheckPhpRequest request = CheckPhpRequest(Employee_id: widget.employeeId.toString(),
        OnDate: DateFormat('yyyy-MM-dd').format(parseDateTime('${_startDateController.text} ${_fromTimeController.text}')));
    debugPrint(request.toJson());
    APIService apiService = APIService();
    apiService.getPhpByDate(request).then((value) {
      if (value != null) {
        Navigator.of(context).pop();
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Outdoor Request');
        } else if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Outdoor Request');
        } else if (value is PJPListResponse) {
          PJPListResponse response = value;
          if(response.responseMessage.isNotEmpty) {
            if(response.responseData[0].isMandatory){
              if(response.responseData[0].count>0){
                //allow to insert
                Utility.showWarning(context, response.responseData[0].msg, '','alert_animation','Apply', this);
              }else{
                //restrict
                Utility.getAlertDialog(context, response.responseData[0].msg, this);
              }
            }else{
              print(response.responseData);
              //warning and continue
              if(response.responseData[0].count>0) {
                Utility.showWarning(context, response.responseData[0].msg, '', 'alert_animation','Apply', this);
              }else{
                //Utility.showWarning(context, response.responseData[0].msg, '', 'warning','Apply Anyway', this);
                Utility.showWarning(context, 'Are you sure to Apply new Outdoor', '', 'alert_animation','Apply', this);
              }
            }
            /*Utility.showMessageSingleButton(
                context, "Outdoor Request successfully submitted", this);*/
          }else{
            Utility.showMessageSingleButton(context, response.responseMessage, this);
          }

        }
      } else {
        Navigator.pop(context);
        Utility.showMessages(context, "Unable to Apply Outdoor Request");
        debugPrint("null value");
      }
    });
  }

  applyOutdoor() {
    Utility.showLoaderDialog(context);
    //2022-01-17T10:26:02
    ApplyLeaveRequest request = ApplyLeaveRequest(
        Requisition_Id: 0,
        Type: 'OutDoor',
        Employee_Id: widget.employeeId.toString(),
        Remarks: _jobDescController.text,
        Requisition_Date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        RequisitionTypeCode: 'LV2',
        Start_Date: DateFormat('yyyy-MM-ddTHH:mm:ss').format(parseDateTime('${_startDateController.text} ${_fromTimeController.text}')),
        End_Date: DateFormat('yyyy-MM-ddTHH:mm:ss').format(parseDateTime('${_startDateController.text} ${_toTimeController.text}')),
        NosDays: 0,
        IsMaternityLeave: false,
        noofChildren: "0",
        AppType :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown',
        WorkLocation: "", IsHappinessLeave: false);
    debugPrint(request.toJson().toString());
    APIService apiService = APIService();
    apiService.applyLeave(request).then((value) {
      if (value != null) {
        Navigator.of(context).pop();
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Outdoor Request');
        } else if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Outdoor Request');
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          if(response.responseMessage.isEmpty) {
            Utility.showMessageSingleButton(
                context, "Outdoor Request successfully submitted", this);
          }else{
            Utility.showMessageSingleButton(context, response.responseMessage, this);
          }

        }
      } else {
        Navigator.pop(context);
        Utility.showMessages(context, "Unable to Apply Outdoor Request");
        debugPrint("null value");
      }
    });
  }


  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    debugPrint(value);
    try {
      dt = new DateFormat('yyyy-MM-dd').parse(value);
      //debugPrint('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    debugPrint('parsed date sss ${dt}');
    return dt;
  }
  DateTime parseDateTime(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('dd-MMM-yyyy hh:mm a').parse(value);
      //debugPrint('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }
  DateTime parseDateOnly(String value) {
    DateTime dt = DateTime.now();
    try {
      dt = new DateFormat('dd-MMM-yyyy').parse(value);
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
    if (action == Utility.ACTION_CONFIRM) {
      applyOutdoor();
    }else if (action == Utility.ACTION_ADDPJP) {
      Navigator.pop(context, 'DONE');
      Navigator.pop(context, 'DONE');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNewPJPScreen(employeeId: widget.employeeId, businessId: widget.businessId, currentDate: parseDateOnly(_startDateController.text.toString()),)),
      );
    }else if (action == Utility.ACTION_OK) {
      Navigator.pop(context, 'DONE');
    }else if (action == Utility.ACTION_CCNCEL) {
      Navigator.pop(context, 'DONE');
    }else
      Navigator.pop(context, 'DONE');
  }


}
