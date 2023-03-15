import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/attendance_summery_request.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/APIService.dart';
import '../../api/response/attendance_response.dart';
import '../firebase/anylatics.dart';
import '../utils/theme/colors/light_colors.dart';
import '../utils/widgets/top_container.dart';
import '../widget/TimeBoard.dart';
import '../widget/month_picker_dialog.dart';
import 'attendance_marking.dart';

class AttendanceSummeryScreen extends StatefulWidget {
  String displayName;

  AttendanceSummeryScreen({Key? key, required this.displayName})
      : super(key: key);

  @override
  _AttendanceSummeryState createState() => _AttendanceSummeryState();
}

class _AttendanceSummeryState extends State<AttendanceSummeryScreen> {
  String _currentMonth = DateFormat('MMM').format(DateTime.now());
  String _currentYear = DateFormat('yyyy').format(DateTime.now());
  late DateTime selectedDate = DateTime.now();
  final DateTime initialDate = DateTime.now();
  int employeeId = 0;

  List<AttendanceSummeryModel> summeryModleList = [];
  bool isLoading = true;

  late final prefs;
  bool isInternet=true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentMonth =
        '${DateFormat('MMM').format(selectedDate)}-${DateFormat('MMM').format(new DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day))}';
    if (selectedDate.day > 15) {
      selectedDate = new DateTime(
          selectedDate.year, selectedDate.month + 1, selectedDate.day);
    }

    getUserInfo();

  }

  Future<void> getUserInfo() async {
    prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);

    isInternet = await Utility.isInternet();

    var attendanceList = prefs.getString(getId());
    if(attendanceList==null){
      loadSummery(false);
    }else{
      try {
        isLoading = false;
        print(attendanceList.toString());
        Map<String,dynamic> jsonObject  = json.decode(attendanceList.toString());
        print('json decode');
        AttendanceSummeryResponse response = AttendanceSummeryResponse.fromJson(
          json.decode(attendanceList),
        );
        if (response != null && response.responseData != null)
          summeryModleList.addAll(response.responseData);
        setState(() {});
      }catch(e){
        loadSummery(false);
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = prefs.getString(getId());
      isLoading = false;
      print(attendanceList.toString());
      Map<String,dynamic> jsonObject  = json.decode(attendanceList.toString());
      print('json decode');
      AttendanceSummeryResponse response = AttendanceSummeryResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null)
        summeryModleList.addAll(response.responseData);
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  String getId(){
    int month = selectedDate.month - 1;
    return '${employeeId.toString()}_${month}_${LocalConstant.KEY_MY_ATTENDANCE}';
  }

  saveAttendanceLocally(String json) async{

    prefs.setString(getId(), json);
  }

  loadSummery(bool isLocalCheck)async {

    if(isLocalCheck==true && getLocalData()){

    }else {
      isLoading = true;
      _currentMonth =
      '${DateFormat('MMM').format(new DateTime(
          selectedDate.year, selectedDate.month - 1,
          selectedDate.day))}-${DateFormat('MMM').format(selectedDate)}';
      setState(() {});
      int _FromMonth = selectedDate.month - 1;
      int _fromYear = selectedDate.year;
      if (selectedDate.month == 1) {
        _FromMonth = 12;
        _fromYear = selectedDate.year - 1;
      }
      summeryModleList.clear();
      AttendanceSummeryRequestModel request = AttendanceSummeryRequestModel(
          Employee_Id: employeeId,
          PayrollFromMonth: _FromMonth,
          PayrollFromYear: _fromYear,
          PayrollToMonth: selectedDate.month,
          PayrollToYear: selectedDate.year);
      //loginRequestModel.User_Name = 'F2354';
      //loginRequestModel.User_Password = 'Niharika#123';
      APIService apiService = APIService();
      apiService.attendanceSummery(request).then((value) {
        isLoading = false;
        if (value != null) {
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'data not found');
          } else if (value is AttendanceSummeryResponse) {
            AttendanceSummeryResponse response = value;
            String json = jsonEncode(response);
            saveAttendanceLocally(json);
            if (response != null && response.responseData != null)
              summeryModleList.addAll(response.responseData);
            print('summery list ${response.responseData.length}');
          } else {
            Utility.showMessage(context, 'data not found');
          }
        }
        //Navigator.of(context).pop();
        setState(() {});
      });
    }
  }

  Future<void> _pullRefresh() async {
    loadSummery(false);
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('AttendanceRequisition');
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isLoading ? Colors.white : LightColors.kLightGray,
      body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SafeArea(
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: LightColors.kLightBlue,
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attendance Summary',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    loadSummery(false);
                                  },
                                  child: const Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.refresh,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AttendanceMarkingScreen(
                                                isManager: false,
                                                  employeeId: employeeId,
                                                  displayName: '')),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.add_box,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        color: LightColors.kLightYellow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectedDate = DateTime(selectedDate.year,
                                    selectedDate.month - 1, selectedDate.day);
                                setMonthValue();
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  'assets/icons/ic_prev.png',
                                  height: 50,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _onPressed(context: context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: '${_currentMonth}  ',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.lightBlue),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: _currentYear,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Colors.lightBlue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                selectedDate = new DateTime(selectedDate.year,
                                    selectedDate.month + 1, selectedDate.day);
                                setMonthValue();
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset('assets/icons/ic_next.png',
                                    height: 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      getAttendanceListView(),
                    ],
                  ),
                ),
                /*Container(
                padding: EdgeInsets.only(top: 40),
                child: Flexible(
                  child: getAttendanceListView(),
                ),
              ),*/
              ],
            ),
          )),
    );
  }

  getAttendanceListView() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    }else if(!isInternet && summeryModleList.isEmpty){
      return Utility.noInternetDataSet(context);
    } else if (summeryModleList == null || summeryModleList.length <= 0) {
      print('data not found');
      return Utility.emptyDataSet(context,
          "Attendence Requisition not avaliable, Please try again later");
    } else {
      return Flexible(
          child: ListView.builder(
        controller: ScrollController(),
        itemCount: summeryModleList.length,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return generateRow(summeryModleList[index]);
        },
      ));
    }
  }

  generateRow(AttendanceSummeryModel model) {
    if (model.isHoliday || model.isVacation || model.status == 'Weekend' || model.status=='Absent') {
      return getWeekendData(model);
    } else if (model.status == 'Absent' &&
        model.reqDateAtn != null &&
        model.reqDateAtn != '') {
      return getAbsentButRequestedInfo(model);
    } else if (model.status == 'Absent') {
      return getAbsentInfo(model);
    } else {
      return getFullDay1(model);
    }
  }

  getWeekend1(AttendanceSummeryModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(

          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                color: LightColors.kLightOrange,
                width: 70,
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      model.day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,

                      child: Text(
                        model.status,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  getFullDay1(AttendanceSummeryModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                color: LightColors.kFULLDAY_BUTTON,
                width: 70,
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      model.day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: generateAttendanceView(model),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LightColors.kLightGray,
                  // Set border width
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child:  Text(
                  model.status,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getWeekendData(AttendanceSummeryModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Container(
                color: model.status == 'Absent' ? LightColors.kLightRed : model.status == 'Weekend' ? LightColors.kLightOrange : LightColors.kFULLDAY_BUTTON,
                width: 70,
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      model.day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: generateAttendanceView(model),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LightColors.kLightGray,
                  // Set border width
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child:  Text(
                  model.status,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getFullDayInfo(AttendanceSummeryModel model) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: LightColors.kLightFULLDAY,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
      padding: const EdgeInsets.all(0.0),
      /*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*/
      child: IntrinsicHeight(
          child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: width / 5.5,
                color: LightColors.kFULLDAY_BUTTON,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      model.day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "  In Time  ",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        model.inTime as String,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: LightColors.kFULLDAY_BUTTON,
                      // Set border width
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const Text(
                      "Full Day",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Out Time ",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        model.outTime.toString(),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              model.lateMark != 'No'
                  ? Positioned(
                      top: 10,
                      right: 10,
                      child: Text(
                          'Mark\n ${model.lateMark}')) /*Image.asset('assets/icons/ic_late.png'))*/
                  : Text('')
            ],
          ),
          getOutdoorRequestedInfo(model),
        ],
      )),
    );

    /*if(model.status=='Weekend'){
      return getHoliday(model);
    }else{
      return getFullDay(model);
    }*/
  }

  getAbsentInfo(AttendanceSummeryModel model) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: LightColors.kAbsent,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
      padding: const EdgeInsets.all(0.0),
      /*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*/
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              width: width / 5.5,
              color: LightColors.kAbsent_BUTTON,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    model.day.substring(0, 3),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LightColors.kAbsent_BUTTON, // Set border width
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Text(
                    model.status,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getAbsentButRequestedInfo(AttendanceSummeryModel model) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          color: LightColors.kAbsent,
          margin: const EdgeInsets.only(left: 5, right: 5, bottom: 0, top: 0),
          padding: const EdgeInsets.all(0.0),
          /*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*/
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Container(
                  width: width / 5.5,
                  color: LightColors.kAbsent_BUTTON,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        model.day.substring(0, 3),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: LightColors.kAbsent_BUTTON,
                        // Set border width
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Text(
                        model.status,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LightColors.kAbsent_BUTTON, // Set border width
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Atten Req : ${model.reqDateAtn.toString()}',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
      ],
    );
  }

  getOutdoorRequestedInfo(AttendanceSummeryModel model) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LightColors.kLightGray, // Set border width
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: getAttendanceRequisition(
                  model), /*[
                model.reqDateOut.isNotEmpty ?
                Text(
                  'Outdoor Req : ${getOutdoorDate(model.reqDateOut.toString())}',
                  style: TextStyle(color: Colors.black),
                ) : Text(''),
                model.reqDateAtn!.isNotEmpty ?
                Text(
                  'Attendance Req : ${getOutdoorDate(model.reqDateAtn.toString())}',
                  style: TextStyle(color: Colors.black),
                ) : Text(''),
              ],*/
            )),
      ],
    );
  }

  getAttendanceRequisition(AttendanceSummeryModel model) {
    List<Widget> _rowWidget = [];
    if (model.reqDateAtn!.isNotEmpty) {
      _rowWidget.add(Text(
        'Attendance Req : ${getOutdoorDate(model.reqDateAtn.toString())}',
        style: TextStyle(color: Colors.black),
      ));
    } else if (model.reqDateOut.isNotEmpty) {
      _rowWidget.add(Text(
        'Outdoor Req : ${getOutdoorDate(model.reqDateOut.toString())}',
        style: TextStyle(color: Colors.black),
      ));
    }
    return _rowWidget;
  }

  generateAttendanceView(AttendanceSummeryModel model) {
    List<Widget> _rowWidget = [];
    if (model.inTime!.isNotEmpty) {
      _rowWidget.add(Text(
        'In: ${model.inTime as String} Out: ${model.outTime as String} ',
        style: GoogleFonts.inter(
          fontSize: 14.0,
          color: model.status == 'Absent' ? Colors.orangeAccent : model.status == 'Weekend' ? LightColors.kLightOrange :Colors.blue,
          fontWeight:  FontWeight.w600,
          height: 1.5,
        ),
      ),);
    }else{
      if(model.reqDateOut.isEmpty && model.reqDateOutApp.isEmpty && model.reqDateAtn!.isEmpty && model.reqDateAtnApp!.isEmpty) {
        _rowWidget.add(Text(
          model.status,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: model.status == 'Absent' ? Colors.orangeAccent : model
                .status == 'Weekend' ? LightColors.kLightOrange : Colors.blue,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),);
      }
    }
    if (model.lateMark.isNotEmpty && model.lateMark=='Yes') {
      _rowWidget.add(Text(
        'Mark : ${model.lateMark}',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.redAccent,
        ),
      ));
    }
    if (model.reqDateOut.isNotEmpty) {
      _rowWidget.add(Text(
        'Outdoor Req : ${getOutdoorDate(model.reqDateOut.toString())}',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black45,
        ),
      ));
    }
    if (model.reqDateOutApp.isNotEmpty) {
      _rowWidget.add(Text(
        'Outdoor Approve : ${getOutdoorDate(model.reqDateOutApp.toString())}',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black45,
        ),
      ));
    }
    if (model.reqDateAtn!.isNotEmpty) {
      _rowWidget.add(Text(
        'Atten Req : ${getOutdoorDate(model.reqDateAtn.toString())}',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black45,
        ),
      ));
    }
    if (model.reqDateAtnApp!.isNotEmpty) {
      _rowWidget.add(Text(
        'Atten Approve : ${getOutdoorDate(model.reqDateAtnApp.toString())}',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.black45,
        ),
      ));
    }
    return _rowWidget;
  }

  getWeekend(AttendanceSummeryModel model) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: 50,
      color: LightColors.kLightOrange,
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 0),
      padding: const EdgeInsets.all(0.0),
      /*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*/
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              width: width / 5.5,
              color: LightColors.kDarkOrange,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${parseDate(model.date).day.toString()} ${getShortMonth(model.date)}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    model.day.substring(0, 3),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LightColors.kDarkOrange, // Set border width
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Text(
                    model.status,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    /*if(model.status=='Weekend'){
      return getHoliday(model);
    }else{
      return getFullDay(model);
    }*/
  }

  getHoliday(AttendanceSummeryModel model) {
    return Container(
      decoration: BoxDecoration(
          color: LightColors.kLightYellow2,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: LightColors.kLavender,
            width: 4,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            model.status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          TextButton(
              child: Text("${model.status}".toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.black)),
              style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orangeAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ))),
              onPressed: () => null),
        ],
      ),
    );
  }

  getFullDay(AttendanceSummeryModel model) {
    return Container(
      decoration: BoxDecoration(
          color: LightColors.kLightBlue,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: LightColors.kLavender,
            width: 4,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimeBoard(
            page: TaskPageStatus.details,
            isCompleted: true,
            hour: parseDate(model.date).day.toString(),
            minute: model.day,
          ),
          Column(
            children: [
              RichText(
                text: TextSpan(
                  text: 'In Time',
                  style: TextStyle(fontSize: 15.0, color: Colors.lightBlue),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: model.inTime,
                  style: TextStyle(fontSize: 15.0, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          TextButton(
              child: Text("${model.status}".toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.white)),
              style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueGrey),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)))),
              onPressed: () => null),
          /*RichText(
            text: TextSpan(
              text: model.status,
              style: TextStyle(

                  fontSize: 15.0, color: Colors.lightBlue),
            ),
          ),*/
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              RichText(
                text: TextSpan(
                  text: model.outTime,
                  style: TextStyle(fontSize: 15.0, color: Colors.lightBlue),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: '9:30 AM',
                  style: TextStyle(fontSize: 15.0, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
          Text(''),
        ],
      ),
    );
  }

  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  String getShortMonth(String value) {
    String month = '';
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
      month = DateFormat("MMM").format(dt);
    } catch (e) {
      e.toString();
    }
    return month;
  }

  String getOutdoorDate(String value) {
    String date = '';
    DateTime dt = DateTime.now();
    //07/25/22  2:32:44 PM
    value = value.replaceAll("  ", " ");
    try {
      dt = new DateFormat('MM/dd/yy hh:mm:ss a').parse(value);
      date = DateFormat("dd MMM hh:mm a").format(dt);
    } catch (e) {
      e.toString();
    }
    return date;
  }

  void setMonthValue() {
    //_currentMonth = DateFormat('MMM').format(selectedDate);
    _currentMonth =
        '${DateFormat('MMM').format(selectedDate)}-${DateFormat('MMM').format(new DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day))}';
    _currentYear = DateFormat('yyyy').format(selectedDate);

    setState(() {
      summeryModleList.clear();
    });
    loadSummery(true);
  }

  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1, 5),
      lastDate: DateTime(DateTime.now().year + 1, 9),
      initialDate: selectedDate,
      locale: Locale("en"),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
          setMonthValue();
        });
      }
    });
  }
}
