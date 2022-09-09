import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/leave/leave_list.dart';
import 'package:intranet/pages/outdoor/outdoor_list.dart';
import 'package:intranet/pages/pjp/PJPForm.dart';
import 'package:intranet/pages/pjp/models/PjpModel.dart';
import 'package:intranet/pages/pjp/mypjp.dart';
import 'package:intranet/pages/userinfo/employee_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../attendance/attendance_list.dart';
import '../attendance/manager_screen.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/constants.dart';
import '../leave/leave_list_manager.dart';
import '../model/filter.dart';
import '../outdoor/outdoor_list_manager.dart';
import '../pjp/IntranetEvents.dart';
import '../pjp/cvf/mycvf.dart';
import '../utils/theme/colors/light_colors.dart';
import 'home_page_menus.dart';


class IntranetHomePage extends StatefulWidget {
  String userId;
  FilterSelection mPjpFilters = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  int _selectedDestination = 1;


  IntranetHomePage({Key? key,required this.userId}) : super(key: key);

  @override
  _IntranetHomePageState createState() => _IntranetHomePageState();
}

class _IntranetHomePageState extends State<IntranetHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  static const int MENU_HOME= 1;
  static const int MENU_ATTENDANCE= 2;
  static const int MENU_OUTDOOR=3;
  static const int MENU_LEAVE= 4;
  static const int MENU_LEAVE_APPROVAL= 5;
  static const int MENU_ATTENDANCE_MARKING_APPROVAL= 6;
  static const int MENU_OUTDOOR_APPROVAL= 7;
  static const int MENU_PROFILE= 8;
  static const int MENU_PJP= 9;


  late final ValueNotifier<List<PJPModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Map<DateTime, List<PJPModel>> attendanceEvent = Map();
  int employeeId=0;
  String mDesignation='';
  String _profileImage='https://cdn-icons-png.flaticon.com/128/4333/4333609.png';
  List<PJPModel> mPjpList=[];
  late String mTitle = "";

  @override
  void initState() {
    super.initState();
    print('initstate');
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    //addEvent();
    getUserInfo();


  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    employeeId = int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
    mDesignation = prefs.getString(LocalConstant.KEY_DESIGNATION) as String;
    mTitle = prefs.getString(LocalConstant.KEY_FIRST_NAME).toString() +" "+ prefs.getString(LocalConstant.KEY_LAST_NAME).toString();
    _profileImage = 'https://cdn-icons-png.flaticon.com/128/4333/4333609.png';
    /*String sex = prefs.getString(LocalConstant.KEY_GENDER) as String;
    if(sex == 'male'){
      _profileImage = 'https://cdn-icons-png.flaticon.com/128/4333/4333609.png';
    }else{
      _profileImage='https://cdn-icons.flaticon.com/png/128/4140/premium/4140047.png';
    }*/
    setState(() {});

  }

  getCurrentEvents(DateTime date,List<PJPModel> pjpListModels){
    List<PJPModel> list = [];
    print('getEvent----${pjpListModels.length}');
    for(int index=0;index<pjpListModels.length;index++){
      print('${Utility.shortDate(date)}  -- ${Utility.shortDate(pjpListModels[index].fromDate)}');
      if(Utility.shortDate(date) == Utility.shortDate(pjpListModels[index].fromDate)){
        list.add(pjpListModels[index]);
      }
    }
    return list;
  }

  syncPjpList() async{
    DBHelper helper = DBHelper();
    DateTime today = DateTime.now();
    List<PJPModel> pjpListModels = await helper.getPjpList() ;
    DateTime start = DateTime(1,today.month-1,today.year);
    DateTime end = DateTime(today.day,today.month+1,today.year);
    kEvents.clear();
    mPjpList.clear();
    mPjpList.addAll(pjpListModels);
    print('data inserted');
    /*if(pjpListModels!=null){
      Map<DateTime,List<PJPModel>> data = {};
      if(start.isBefore(end)) {
        try {
          data.putIfAbsent(pjpListModels[0].fromDate, () =>
              getCurrentEvents(start, pjpListModels));
          // data.putIfAbsent(pjpListModels[0].fromDate, getCurrentEvents(start,pjpListModels));
          start.add(Duration(days: 1, hours: 23));
        }catch(e){}
      }
      kEvents.addAll(data);
    }*/
  }

  void addEvent(){
    print('add event');
    //kEvents.addAll(_kEventSource);
    syncPjpList();
    print('addEvent ');
    setState(() {});
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<PJPModel> _getEventsForDay(DateTime day) {
    // Implementation example
    print('add _getEventsForDay');
    if(mPjpList==null || mPjpList.length==0){
      syncPjpList();
    }
    print('day is '+day.day.toString());
    return getCurrentEvents(day,mPjpList);//kEvents[day] ?? [];
  }

  BoxDecoration _getEventDecoration(DateTime day) {
    // Implementation example
    //return kEvents[day] ?? [];
    BoxDecoration decoration = BoxDecoration(
      color: Colors.indigo,
      shape: BoxShape.circle,
    );
    String todaysDate = new DateFormat('dd MMM yyyy').format(day);
    /*if(attendanceEvent.containsKey(todaysDate)){
      var list = attendanceEvent[todaysDate]?.toList();
      if(list?[0].title=='Present'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }else if(list?[0].title=='Holiday'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }
    }*/
    return decoration;
  }

  List<PJPModel> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);
print('_getEventsForRange');
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      print('_onDaySelected');
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    print('_onRangeSelected');
    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void onBackClickListener() {
    print(('back  ${widget._selectedDestination}'));
    if(widget._selectedDestination==0) {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: Text("Cancel"),
        onPressed: () {},
      );
      Widget continueButton = TextButton(
        child: Text("Exit"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("AlertDialog"),
        content: Text("Would you like to Exit?"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }else{
      setState(() {
        widget._selectedDestination = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EasyLoading.init();
    return  WillPopScope(
      onWillPop: () async{
        onBackClickListener();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(
        //   title: KidzeeWidget().getAppBarUI(context),
        // ),
        appBar: getAppbar(),
        drawer: getNavigationalDrawar(),
        body: getScreen(),
        /*floatingActionButton:_selectedDestination==MENU_HOME ? FloatingActionButton.extended(
          onPressed: () {
            // Add your onPressed code here!
           *//* Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AddNewPjp()));*//*
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddNewPjp()));

          },
          label: const Text('New PJP'),
          icon: const Icon(Icons.thumb_up),
          backgroundColor: Colors.pink,
        ) : null,*/
      ),
    );
  }

  AppBar getAppbar(){
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: true,
      title:  Text(
        mTitle,
        style:
        TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
      ),
      /*shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),*/
      /*leading: InkWell(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.subject,
          color: Colors.white,
        ),
      ),*/
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EmployeeListScreen(displayName: '')));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            /*Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserNotification()));*/
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.notifications,
              size: 20,
            ),
          ),
        ),
      ],
      /*bottom: PreferredSize(
          child: getAppBottomView(),
          preferredSize: Size.fromHeight(80.0)),*/
    );
  }

  Widget getScreen() {
    print('getscreen--------');
    switch (widget._selectedDestination) {
      case MENU_HOME:
        return HomePageMenu();
        break;
      case MENU_ATTENDANCE:
        return AttendanceSummeryScreen(displayName: mTitle,);
        break;
      case MENU_OUTDOOR:
        return OutdoorScreen(displayName: mTitle,);
        break;
      case MENU_LEAVE:
        return LeaveSummeryScreen(displayName: mTitle,);
        break;
      case MENU_ATTENDANCE_MARKING_APPROVAL:
        return AttendanceManagerScreen(employeeId: employeeId);
        break;
       case MENU_LEAVE_APPROVAL:
        return LeaveManagerScreen(employeeId: employeeId,);
        break;
      case MENU_OUTDOOR_APPROVAL:
        return OutdoorManagerScreen(employeeId: employeeId,);
        break;
      case MENU_PJP:
        return MyPjpListScreen(mFilterSelection: widget.mPjpFilters);
        break;
      default:
        return _homeScreen(context);
    }
  }

  Widget getHomeScreen() {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
              onTap: () => selectDestination(MENU_PJP),
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFF4B39EF),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Color(0x39000000),
                            offset: Offset(0, 1),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: Icon(
                              Icons.electric_car,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                            child: Text(
                              'My PJP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('CVF CLICKED');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyCVFListScreen()));
                },
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFF4B39EF),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 3,
                            color: Color(0x39000000),
                            offset: Offset(0, 1),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding:
                            EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                            child: Text(
                              'My CVF',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getNavigationalDrawar() {
    //print(_profileImage);
    return Drawer(
      child: getMenu(),
    );
  }

  getMenu(){
      return ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text(mTitle),
            accountName: Text(mDesignation),
            currentAccountPicture:  CircleAvatar(
              radius: 50.0,
              backgroundColor: Color(0xFF778899),
              backgroundImage: NetworkImage(
                  _profileImage),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'My Menu',
            ),
          ),
          Divider(),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_attendance.png')
            ),
            title: Text('Attendance'),
            selected: widget._selectedDestination == MENU_ATTENDANCE,
            onTap: () => selectDestination(MENU_ATTENDANCE),
          ),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_leave.png')
            ),
            title: Text('Leave'),
            selected: widget._selectedDestination == MENU_LEAVE,
            onTap: () => selectDestination(MENU_LEAVE),
          ),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_outdoor.png')
            ),
            title: Text('Outdoor'),
            selected: widget._selectedDestination == MENU_OUTDOOR,
            onTap: () => selectDestination(MENU_OUTDOOR),
          ),
          Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manager Access',
            ),
          ),
          Divider(),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_leave.png')
            ),
            title: Text('Leave Approval'),
            selected: widget._selectedDestination == MENU_LEAVE_APPROVAL,
            onTap: () => selectDestination(MENU_LEAVE_APPROVAL),
          ),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_attendance.png')
            ),
            title: Text('Apptendnce Marking Approval'),
            selected: widget._selectedDestination == MENU_ATTENDANCE_MARKING_APPROVAL,
            onTap: () => selectDestination(MENU_ATTENDANCE_MARKING_APPROVAL),
          ),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_outdoor.png')
            ),
            title: Text('Outdoor Duty Approval'),
            selected: widget._selectedDestination == MENU_OUTDOOR_APPROVAL,
            onTap: () => selectDestination(MENU_OUTDOOR_APPROVAL),
          ),
          Divider(),
          ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_logout.png')
            ),
            title: Text('Log Out'),
            selected: widget._selectedDestination == 0,
            onTap: () => signOut(),
          ),
        ],
      );
  }

  void selectDestination(int index) {
    Navigator.of(context).pop();
    if(false && index==10){

    }else {
      setState(() {
        widget._selectedDestination = index;
      });
    }
  }

  signOut() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await Future.delayed(Duration(seconds: 1));
    if(Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }else if (Platform.isIOS){
      exit(0);
    }
  }

  Widget _homeScreen(BuildContext context) {
    print('home screen');
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Column(
          children: <Widget>[
                TableCalendar<PJPModel>(
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    // Weekend days color (Sat,Sun)
                    weekendStyle: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                  // Calendar Dates styling
                  calendarStyle:  CalendarStyle(
                    // Weekend dates color (Sat & Sun Column)
                    weekendTextStyle: TextStyle(color: Colors.red),
                    // highlighted color for today
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.rectangle,
                    ),
                    // highlighted color for selected day
                    selectedDecoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.rectangle,
                    ),
                    markerDecoration:  _getEventDecoration(_focusedDay),

                  ),

                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    print('page changes');

                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ValueListenableBuilder<List<PJPModel>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),

                            child: IntranetEventContainer( event: value[index],),
                          );
                        },
                      );
                    },
                  ),
                ),

            ]
        )
      )
    );
  }
}


/*class Event {

  final String title;
  dynamic mEvent;
  Event(this.title,this.mEvent);


 *//* final String title;
  final String subtitle;
  final String fromDate;
  final String toDate;


  const Event(this.title,this.subtitle,this.toDate,this.fromDate);

  @override
  String toString() => title;*//*
}*/

/*var pjpModel = PJPEventModel(title: 'Employee Training', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
    purposeOfVisit: 'Training',
    businessType: 'kidzee', fromDate: '15 Aug', toDate: '18 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/meeting.png',
    checkInTime: '10:00',isCheckin: true,ampm:'AM');*/
/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<PJPModel>>(
  equals: isSameDay,
  hashCode: getHashCode,
);
/*final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('',pjpModel)))
  ..addAll({
    kToday: [
      Event('',PJPEventModel(title: 'Kidzee Varsova', subtitle: 'Scheduled Center Visit at CWP-XXX', visitType: 'Center Visit',
          purposeOfVisit: 'Center Visit',
          businessType: 'kidzee', fromDate: '23 Aug', toDate: '25 Aug', boxColor: LightColors.kLightGreen,icons: 'assets/icons/visitor.png',
      checkInTime: '10:00',isCheckin: true,ampm:'AM')),
      Event('',PJPEventModel(title: 'Kidzee Banashankari', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
          purposeOfVisit: 'Training',
          businessType: 'kidzee', fromDate: '25 Aug', toDate: '28 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/training.png',
          checkInTime: '12:30',isCheckin: false,ampm:'PM')),
      Event('',PJPEventModel(title: 'Kidzee Chembur', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
          purposeOfVisit: 'Training',
          businessType: 'kidzee', fromDate: '25 Aug', toDate: '2  8 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/meeting.png',
          checkInTime: '04:00',isCheckin: true,ampm:'PM')),
    ],
  });*/

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month+2, kToday.day);