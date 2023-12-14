import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/request/apply_leave_request.dart';
import 'package:Intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:Intranet/api/response/apply_leave_response.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/widget/MyWidget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../api/APIService.dart';
import '../helper/LightColor.dart';
import '../iface/onClick.dart';
import '../utils/theme/colors/light_colors.dart';

class ApplyLeaveScreen extends StatefulWidget {
  String displayName;

  String applied = '-';
  String taken = '-';
  String rejected = '-';
  String totalCanceled = '-';
  String avaliableForEncash = '-';
  String totalLeaveBalance = '-';
  int employeeId = 0;
  String gender="";


  ApplyLeaveScreen(
      {Key? key,
      required this.employeeId,
      required this.displayName,
      required this.applied,
      required this.taken,
      required this.rejected,
      required this.totalCanceled,
      required this.avaliableForEncash,
      required this.totalLeaveBalance})
      : super(key: key);

  @override
  _ApplyLeaveScreen createState() => _ApplyLeaveScreen();
}

class _ApplyLeaveScreen extends State<ApplyLeaveScreen> implements onClickListener{
  List<LeaveRequisitionInfo> leaveRequisitionList = [];
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _purposeController = TextEditingController();
  DateTime minDate = DateTime(DateTime.now().year, DateTime.now().month - 3, 1);
  DateTime maxDate = DateTime(DateTime.now().year, DateTime.now().month + 3, 1);
  bool isMaternaty = false;
  bool isHappinessLeave = false;
  bool isCompoff = false;
  bool isCompoffEligible = false;
  String appVersion='';
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
    widget.gender = hiveBox.get(LocalConstant.KEY_GENDER) as String;
    String grade = hiveBox.get(LocalConstant.KEY_GRADE) as String;
    if(grade.isNotEmpty && grade.contains('M1')){
      isCompoffEligible=true;
    }
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
    setState(() {

    });
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
int _HappinessLeave=1;
int _CompOff=2;
int _groupValue=0;
    selectHappinessLeave(int timeSelected) {
      setState(() {
        _HappinessLeave = timeSelected;
        _groupValue = _HappinessLeave;
        _CompOff = 0;
      });
    }
    selectCompoff(int timeSelected) {
      setState(() {
        _CompOff = timeSelected;
        _groupValue = _HappinessLeave;
        _HappinessLeave = 0;
      });
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Leave Application',
            style:
            TextStyle(fontSize: 17, color: Colors.black, letterSpacing: 0.53),
          ),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.blue.withOpacity(0.7), //You can make this transparent
            elevation: 0.0,

        ),
        body: SafeArea(
          child:  Column(
            children: [
              Container(
                color: LightColors.kLightBlue,
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Leave Balance',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
              ),
              getLeaveBalance(),
              SizedBox(
                height: size.height * 0.01,
              ),
              MyWidget().richText(12, 'Apply Leave Request'),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          MyWidget().getDateTime(context, 'Start Date',
                              _startDateController, minDate, maxDate),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          !isHappinessLeave ? MyWidget().getDateTime(context, 'End Date',
                              _endDateController, minDate, maxDate) : SizedBox(height: 0,),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          MyWidget().normalTextAreaField(
                              context, 'Purpose', _purposeController),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          widget.gender =='Female' ?
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Material(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(getColor),
                                  value: isMaternaty,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isMaternaty = value!;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'IsMaternityLeave',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ) : SizedBox(height: 0,),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Material(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(getColor),
                                  value: isHappinessLeave,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isCompoff = false;
                                      isHappinessLeave = value!;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Happiness Leave',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                          isCompoffEligible ?
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Material(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(getColor),
                                  value: isCompoff,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isHappinessLeave = false;
                                      isCompoff = value!;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Comp Off',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ) : SizedBox(height: 0,),
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
                                'Submit',style: LightColors.textHeaderStyle,)
                            ),
                          ),
                  ],
                ),
              )
                  ],
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: Utility.footer(appVersion),
    );
  }

  validate() async{
    bool isInternet = await Utility.isInternet();
    if(!isInternet) {
      Utility.noInternetConnection(context);
    }else if (isHappinessLeave ?  _startDateController.text == '' :  _startDateController.text == '' || _endDateController.text == '') {
      Utility.showMessage(context, 'Please Select the Date Range');
    } else if (_purposeController.text == '') {
      Utility.showMessage(context, 'Please Enter the purpose of leave');
    } else {
      DateTime start = parseDateTime(_startDateController.text);
      DateTime end = parseDateTime(_endDateController.text);
      if (start.isAfter(end)) {
        Utility.showMessage(context, 'Please Enter Valid Date Range');
      } else {
        applyLeave();
      }
    }
  }
  DateTime parseDateTime(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('dd-MMM-yyyy').parse(value);
      //debugPrint('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  applyLeave() {
    Utility.showLoaderDialog(context);

    ApplyLeaveRequest request = ApplyLeaveRequest(
        Requisition_Id: 0,
        Type: isHappinessLeave ? 'Happiness Leave' : 'leave',
        Employee_Id: widget.employeeId.toString(),
        Remarks: _purposeController.text,
        Requisition_Date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        RequisitionTypeCode: isCompoff ? 'LV4' : 'LV1',
        Start_Date: DateFormat('yyyy-MM-dd').format(parseDateTime(_startDateController.text)),
        End_Date: DateFormat('yyyy-MM-dd').format(parseDateTime(isHappinessLeave ? _startDateController.text : _endDateController.text)),
        NosDays: 0,
        IsMaternityLeave: isMaternaty,
        noofChildren: "0",
        AppType :Platform.isAndroid ? 'Android' : Platform.isIOS ? 'IOS' : 'unknown',
        WorkLocation: "",IsHappinessLeave: isHappinessLeave);
    debugPrint(request.toJson().toString());
    APIService apiService = APIService();
    apiService.applyLeave(request).then((value) {
      Navigator.of(context).pop();
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'Unable to Apply Leave Request');
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          Utility.showMessageSingleButton(context, response.responseMessage,this);

        }
      } else {
        Navigator.pop(context);
        Utility.showMessage(context, "Unable to Apply Leave Request");
        debugPrint("null value");
      }
    });
  }

  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd').parse(value);
      //debugPrint('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  String getParsedShortDate(String value) {
    DateTime dateTime = parseDate(value);
    return DateFormat("MMM-dd").format(dateTime);
  }

  getLeaveBalance() {
    return GridView.extent(
      primary: false,
      childAspectRatio: (1 / .6),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 5),
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
      maxCrossAxisExtent: 140.0,
      children: <Widget>[
        Container(
          color: LightColors.kLavender,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.applied, style: TextStyle(fontSize: 20)),
                Text('Applied', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        Container(
          color: LightColors.kLightYellow,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.taken, style: TextStyle(fontSize: 20)),
                Text('Taken', style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ),
        Container(
          color: LightColors.kLightRed,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.rejected, style: TextStyle(fontSize: 20)),
                Text('Rejected', style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ),
        Container(
          color: LightColors.kLightOrange,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.totalCanceled, style: TextStyle(fontSize: 20)),
                Center(
                    child: Text('Total Leave Canceled',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)))
              ],
            ),
          ),
        ),
        Container(
          color: LightColors.kLightBlue,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.avaliableForEncash, style: TextStyle(fontSize: 20)),
                Text('Available leave Encashed',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ),
        Container(
          color: LightColors.kLavender,
          height: 50,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.totalLeaveBalance, style: TextStyle(fontSize: 20)),
                Text('Total leave Balanced',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onClick(int action, value) {
    Navigator.pop(context, 'DONE');
  }
}
