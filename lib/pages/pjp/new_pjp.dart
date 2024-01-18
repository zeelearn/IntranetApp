import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../api/APIService.dart';
import '../../api/request/cvf/add_cvf_request.dart';
import '../../api/request/cvf/category_request.dart';
import '../../api/request/cvf/centers_request.dart';
import '../../api/response/cvf/add_cvf_response.dart';
import '../../api/response/cvf/category_response.dart';
import '../../api/response/cvf/centers_respinse.dart';
import '../firebase/anylatics.dart';
import '../helper/DBConstant.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LightColor.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../home/IntranetHomePage.dart';
import '../utils/theme/colors/light_colors.dart';
import '../widget/MyWidget.dart';
import '../widget/check/checkbox.dart';
import '../widget/date_time/time_picker.dart';
import '../widget/options/dropdown.dart';
import 'PJPForm.dart';
import 'models/PJPCenterDetails.dart';
import 'models/PjpModel.dart';

class NewPJP extends StatefulWidget {
  PJPModel mPjpModel;

  NewPJP({Key? key, required this.mPjpModel}) : super(key: key);

  @override
  State<NewPJP> createState() => _PjpState();
}

class _PjpState extends State<NewPJP> {
  late final ValueNotifier<List<PJPCentersInfo>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime? _selectedDay;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date

  List<PJPCentersInfo> mCVFList = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime cvfDate = DateTime.now();
  late List<CategotyInfo> mCategoryList = [];
  List<FranchiseeInfo> mFrianchiseeList = [];
  TimeOfDay? vistitDateTime;
  late String _CenterName;
  late bool _isNotify = false;
  late String _purposeMultiSelect = 'Select';
  List<String> _selectedItems = [];
  bool isAddCVF = false;
  int employeeId = 0;
  int businessId = 0;
  String appVersion = '';
  var hiveBox;

  Future<void> getUserInfo() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID);
    getCvfList();
    fetchCategory();
    getFrichinseeList();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
  }

  fetchCategory() {
    Utility.showLoaderDialog(context);
    mCategoryList.clear();
    debugPrint('categoty');
    CVFCategoryRequest request =
        CVFCategoryRequest(Category_Id: "0", Business_id: businessId);
    APIService apiService = APIService();
    apiService.getCVFCategoties(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFCategoryResponse) {
          CVFCategoryResponse response = value;
          if (response != null) {
            mCategoryList.addAll(response.responseData);
          }
          setState(() {});
          debugPrint('category list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  getFrichinseeList() async {
    DBHelper helper = DBHelper();

    List<FranchiseeInfo> franchiseeList =
        await helper.getFranchiseeList(businessId);

    if (franchiseeList == null || franchiseeList.length == 0) {
      debugPrint('data load ssss');
      loadCenterList();
    } else {
      mFrianchiseeList.addAll(franchiseeList);
      debugPrint('data ssss');
    }
  }

  loadCenterList() {
    Utility.showLoaderDialog(context);
    mFrianchiseeList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 1, time.day);
    CentersRequestModel requestModel =
        CentersRequestModel(EmployeeId: employeeId, Brand: businessId);
    APIService apiService = APIService();
    apiService.getCVFCenters(requestModel).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CentersResponse) {
          CentersResponse response = value;
          if (response != null && response.responseData != null) {
            mFrianchiseeList.addAll(response.responseData);
            addCentersinDB(businessId);
            setState(() {});
          }
          debugPrint('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  addCentersinDB(businessId) async {
    DBHelper dbHelper = DBHelper();
    dbHelper.deleteData(LocalConstant.TABLE_CVF_FRANCHISEE);
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      Map<String, Object> data = {
        DBConstant.FRANCHISEE_ID: mFrianchiseeList[index].franchiseeId,
        DBConstant.FRANCHISEE_NAME: mFrianchiseeList[index].franchiseeName,
        DBConstant.FRANCHISEE_CODE: mFrianchiseeList[index].franchiseeCode,
        DBConstant.ZONE: mFrianchiseeList[index].franchiseeZone,
        DBConstant.STATE: mFrianchiseeList[index].franchiseeState,
        DBConstant.CITY: mFrianchiseeList[index].franchiseeCity,
        DBConstant.BUSINESS_ID: businessId
      };
      dbHelper.insert(LocalConstant.TABLE_CVF_FRANCHISEE, data);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('cvf list ');
    Future.delayed(Duration.zero, () {
      this.loadUserData();
    });
  }

  loadUserData() {
    getUserInfo();
  }

  addPJPCentersinDB() async {
    DateTime time = DateTime(cvfDate.year, cvfDate.month, cvfDate.day,
        vistitDateTime?.hour as int, vistitDateTime?.minute as int);
    DBHelper dbHelper = DBHelper();
    Map<String, Object> data = {
      DBConstant.PJP_ID: widget.mPjpModel.pjpId,
      DBConstant.CENTRE_CODE: getCenterCode(_CenterName),
      DBConstant.CENTRE_NAME: _CenterName,
      DBConstant.PURPOSE: _purposeMultiSelect,
      DBConstant.DATE: Utility.parseDate(time),
      DBConstant.IS_ACTIVE: 1,
      DBConstant.IS_NOTIFY: _isNotify == true ? 1 : 0,
      /*DBConstant.IS_SYNC: 0,*/
      DBConstant.IS_CHECK_IN: 0,
      DBConstant.IS_CHECK_OUT: 0,
      DBConstant.IS_CVF_COMPLETED: 0,
      DBConstant.IS_NOTIFY: 1,
      DBConstant.MODIFIED_DATE: Utility.parseDate(DateTime.now()),
      DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
    };
    dbHelper.insert(LocalConstant.TABLE_PJP_CENTERS_DETAILS, data);
    //getPjpList();
    isAddCVF = false;
    getCvfList();

    setState(() {});
  }

  List<PJPCentersInfo> _getEventsForDay(DateTime day) {
    // Implementation example
    debugPrint('day is ' + day.day.toString());
    return getCurrentEvents(day); //kEvents[day] ?? [];
  }

  getCurrentEvents(DateTime date) {
    List<PJPCentersInfo> list = [];
    debugPrint('getEvent----${mCVFList.length}');
    for (int index = 0; index < mCVFList.length; index++) {
      debugPrint(
          '${Utility.shortDate(date)}  -- ${Utility.shortDate(mCVFList[index].dateTime as DateTime)}');
      if (Utility.shortDate(date) ==
          Utility.shortDate(mCVFList[index].dateTime as DateTime)) {
        list.add(mCVFList[index]);
      }
    }
    return list;
  }

  void getCvfList() async {
    mCVFList.clear();
    /*DBHelper helper = DBHelper();
    List<PJPCentersInfo> cvfList = await helper.getCVFList();
    if (cvfList != null) {
      for(int index=0;index<cvfList.length;index++){
        if(widget.mPjpModel.pjpId==cvfList[index].pjpId){
          mCVFList.add(cvfList[index]);
        }
        */ /*if(Utility.shortDate(cvfList[index].dateTime)==Utility.shortDate(widget.mPjpModel.fromDate) || Utility.shortDate(cvfList[index].dateTime)==Utility.shortDate(widget.mPjpModel.toDate) || (cvfList[index].dateTime.isAfter(widget.mPjpModel.fromDate) && cvfList[index].dateTime.isBefore(widget.mPjpModel.toDate))){
          mCVFList.add(cvfList[index]);
        }*/ /*
      }
      //mCVFList.addAll(cvfList);
    }
    debugPrint('length of CVF List is ${mCVFList.length}');
    setState(() {
      mCVFList = mCVFList;
    });*/
  }

  getCenterForm() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      String value = _showMultiSelect(context);
                      Utility.showMessage(context, value);
                      setState() {
                        _purposeMultiSelect = value;
                      }

                      ;
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: LightColors.kLightGray1)),
                      child: Text(
                        maxLines: 4,
                        _purposeMultiSelect == ''
                            ? 'Select Category'
                            : _purposeMultiSelect,
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  datePicker(context),
                  SizedBox(
                    height: 10,
                  ),
                  FastTimePicker(
                    name: 'Time',
                    onChanged: (value) {
                      vistitDateTime = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _purposeMultiSelect == 'Activity'
                      ? getActivity(size)
                      : getCenter(size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getFrichanseeId() {
    int code = 0;
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length < 25) {
        if (_CenterName == mFrianchiseeList[index].franchiseeName) {
          code = mFrianchiseeList[index].franchiseeId.toInt();
        }
      } else if (_CenterName ==
          mFrianchiseeList[index].franchiseeName.substring(0, 25)) {
        code = mFrianchiseeList[index].franchiseeId.toInt();
      }
    }
    return code;
  }

  addNewCVF() async {
    if (!await Utility.isInternet()) {
      //Navigator.of(context).pop();
      Utility.noInternetConnection(context);
    } else {
      Utility.showLoaderDialog(context);
      mCategoryList.clear();
      debugPrint('categoty');
      String xml =
          '<root><tblPJPCVF><Business_Id>${businessId}</Business_Id><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility.convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime?.hour}:${vistitDateTime?.minute}</Visit_Time><Category_Id>1</Category_Id></tblPJPCVF></root>';
      AddCVFRequest request = AddCVFRequest(
          PJP_Id: widget.mPjpModel.pjpId, DocXml: xml, UserId: employeeId);
      debugPrint(request.toJson().toString());
      APIService apiService = APIService();
      apiService.saveCVF(request).then((value) {
        debugPrint(value.toString());
        if (value != null) {
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'data not found');
          } else if (value is NewCVFResponse) {
            NewCVFResponse response = value;
            debugPrint(response.toString());
            if (response != null) {
              //mPjpModel.pjpId=response.responseData;
            }

            Utility.showMessage(context, 'CVF Saved in server');
            setState(() {});
            //debugPrint('category list ${response.responseData.length}');
          } else {
            Utility.showMessage(context, 'data not found');
          }
        }
        Navigator.of(context).pop();
        setState(() {});
      });
    }
  }

  getCenter(Size size) {
    return Column(
      children: [
        FastDropdown(
          name: 'Select Center',
          hint: Text('Select Center'),
          onChanged: (value) {
            _CenterName = value as String;
            // Utility.showMessage(context, '${value}');
          },
          items: getList(mFrianchiseeList),
        ),
        SizedBox(
          height: 10,
        ),
        FastCheckbox(
          name: 'Is Notify to Business Partner',
          titleText: 'Is Notify to Business Partner',
          onChanged: (value) {
            _isNotify = value as bool;
            setState() {}
            ;
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            //formKey.currentState?.build(context);

            DateTime time = DateTime(cvfDate.year, cvfDate.month, cvfDate.day,
                vistitDateTime?.hour as int, vistitDateTime?.minute as int);
            /*mPjpModel.centerList.add(PJPCentersInfo(pjpId: mPjpModel.pjpId, dateTime: time, centerCode: getCenterCode(_CenterName),
                centerName: _CenterName, isActive: true, isNotify: true, purpose: _purposeMultiSelect, isCheckIn: false, isCheckOut: false,
                isSync: false, isCompleted: false, createdDate: DateTime.now(), modifiedDate: DateTime.now()));*/
            //addPJPCentersinDB();
            addNewCVF();
            //setState(() {});
          },
          child: Container(
            alignment: Alignment.center,
            height: size.height / 20,
            width: size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: LightColor.brighter,
              boxShadow: [
                BoxShadow(
                  color: LightColors.kLightRed,
                  offset: const Offset(0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'Add Franchisee list',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget datePicker(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: LightColors.kLightGray1)),
        height: 60,
        child: Center(
            child: TextField(
          //editing controller of this TextField
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
              ),
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.mPjpModel.fromDate,
                firstDate: widget.mPjpModel.fromDate,
                //DateTime.now() - not to allow to choose before today.
                lastDate: widget.mPjpModel.toDate);

            if (pickedDate != null) {
              cvfDate = pickedDate;
              String formattedDate =
                  DateFormat('dd-MMM-yyyy').format(pickedDate);
              debugPrint(
                  formattedDate); //formatted date output using intl package =>  2021-03-16
            } else {}
          },
        )));
  }

  getActivity(Size size) {
    TextEditingController _activityNameController = TextEditingController();
    return Column(
      children: [
        MyWidget().normalTextField(
            context, 'Enter Activity Name', _activityNameController),
        SizedBox(
          height: 10,
        ),
        MyWidget().normalTextAreaField(
            context, 'Enter Activity Location', _activityNameController),
        GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: Container(
            alignment: Alignment.center,
            height: size.height / 20,
            width: size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: LightColor.brighter,
              boxShadow: [
                BoxShadow(
                  color: LightColors.kLightRed,
                  offset: const Offset(0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'Add Activity',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  _showMultiSelect(BuildContext context) async {
    if (mCategoryList == null || mCategoryList.length == 0) {
      fetchCategory();
    } else {
      debugPrint('category length ${mCategoryList.length}');
    }

    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final _items = getPurposeList();

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _purposeMultiSelect = '';
        _selectedItems = results;
        if (results.contains('Activity') && results.length > 1) {
          Utility.showMessage(
              context, 'Activity is not comes with another option');
        } else {
          String token = '';
          for (int index = 00; index < _selectedItems.length; index++) {
            _purposeMultiSelect += token + _selectedItems[index];
            token = ' , ';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('New PJP');

    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.light;
    return Scaffold(
      appBar: getAppbar(),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            TableCalendar<PJPCentersInfo>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: widget.mPjpModel.fromDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: widget.mPjpModel.fromDate,
              rangeEndDay: widget.mPjpModel.fromDate,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
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
              calendarStyle: CalendarStyle(
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
                markerDecoration: _getEventDecoration(_focusedDay),
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
                debugPrint('page changes');
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    isAddCVF = true;
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height / 30,
                    width: size.width / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: LightColor.brighter,
                      boxShadow: [
                        BoxShadow(
                          color: LightColors.kLightRed,
                          offset: const Offset(0, 5.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Add CVF',
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height / 30,
                    width: size.width / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: LightColor.brighter,
                      boxShadow: [
                        BoxShadow(
                          color: LightColors.kLightRed,
                          offset: const Offset(0, 5.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Add Activity',
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            isAddCVF == true ? getCenterForm() : loadCVFList(),
          ],
        ),
      ),
      bottomNavigationBar: Utility.footer(appVersion),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IntranetHomePage(userId: '')));
        },
        label: const Text('Add New'),
        icon: const Icon(Icons.thumb_up),
        backgroundColor: Colors.pink,
      ),
    );
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

  loadCVFList() {
    double width = MediaQuery.of(context).size.width;
    if (mCVFList == null || mCVFList.length <= 0) {
      debugPrint('CVF LIST not added ');
      return Text('');
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: mCVFList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return cvfView(mCVFList[index], width);
        },
      ));
    }
  }

  cvfView(PJPCentersInfo model, double width) {
    return GestureDetector(
      onTap: () {
        /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionListScreen()),
        );*/
      },
      child: Padding(
          padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            padding: EdgeInsets.all(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width * 0.10,
                    decoration: BoxDecoration(
                      color: LightColors.kLightGray1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Utility.shortTime(model.dateTime as DateTime),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          Utility.shortTimeAMPM(model.dateTime as DateTime),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(color: LightColors.kLightGray),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.centerName as String,
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            model.purpose as String,
                            style: TextStyle(color: Colors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              'Code  : ${model.centerCode}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  List<PJPCentersInfo> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    start = widget.mPjpModel.fromDate;
    end = widget.mPjpModel.toDate;
    final days = daysInRange(start, end);
    debugPrint('_getEventsForRange');
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
      debugPrint('_onDaySelected');
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    start = widget.mPjpModel.fromDate;
    end = widget.mPjpModel.toDate;
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    debugPrint('_onRangeSelected');
    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  AppBar getAppbar() {
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: true,
      title: Text(
        'Permanent Planner',
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
    );
  }

  getList(List<FranchiseeInfo> mFrianchiseeList) {
    List<String> data = ['Select'];
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length > 25) {
        data.add(mFrianchiseeList[index].franchiseeName.substring(0, 25));
      } else
        data.add(mFrianchiseeList[index].franchiseeName);
    }
    return data;
  }

  getPurposeList() {
    List<String> list = [];
    for (int index = 0; index < mCategoryList.length; index++) {
      if (mCategoryList[index].categoryName.length > 25) {
        list.add(mCategoryList[index].categoryName.substring(0, 25));
      } else
        list.add(mCategoryList[index].categoryName);
    }
    return list;
  }

  getCategoryId() {
    int id = 0;
    for (int index = 0; index < mCategoryList.length; index++) {
      if (_purposeMultiSelect == mCategoryList[index].categoryName) {
        id = mCategoryList[index].categoryId;
      }
    }
    return id;
  }

  getCenterCode(String centerName) {
    String code = '';
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName == centerName) {
        code = mFrianchiseeList[index].franchiseeCode;
      }
    }
    return code;
  }
}
