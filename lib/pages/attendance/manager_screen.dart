import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/attendance_marking_man_request.dart';
import 'package:intranet/pages/widget/MyWidget.dart';

import '../../api/APIService.dart';
import '../../api/response/attendance_marking_man.dart';
import '../../main.dart';
import '../firebase/notification_service.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';
import '../iface/onClick.dart';
import '../utils/theme/colors/light_colors.dart';

class AttendanceManagerScreen extends StatefulWidget {
  int employeeId;

  AttendanceManagerScreen({Key? key, required this.employeeId,
  required this.listener})
      : super(key: key);

  @override
  _AttendanceManagerScreen createState() => _AttendanceManagerScreen();
}

class _AttendanceManagerScreen extends State<AttendanceManagerScreen>
    with SingleTickerProviderStateMixin implements onClickListener {
  late TabController _tabController;
  List<bool> _isChecked = [];
  bool _isSelectAll = false;
  final _selectedColor = LightColors.kLavender;
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [Tab(text: 'Pending Approvals'), Tab(text: 'All Approvals')];

  bool isLoading=true;

  List<AttendanceReqManModel> requisitionList = [];

  updateListView() {
    if (requisitionList != null) {
      for (int index = 0; index < _isChecked.length; index++) {
        _isChecked[index] = _isSelectAll;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    getUserInfo();
    _tabController.addListener(() {
      //print('my index is' + _tabController.index.toString());
      setState(() {
        loadAcquisition();
      });
    });
  }

  Future<void> getUserInfo() async {
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    widget.employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);

    loadAcquisition();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                const Text(
                  'Attendance Marking Approval',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                /// Custom Tabbar with solid selected bg and transparent tabbar bg
                Container(
                  height: kToolbarHeight - 8.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: _selectedColor),
                    labelColor: LightColors.kGreen,
                    unselectedLabelColor: Colors.grey,
                    tabs: _tabs,
                  ),
                ),
              ]
                  .map((item) => Column(
                        /// Added a divider after each item to let the tabbars have room to breathe
                        children: [
                          item,
                          Divider(
                            color: Colors.transparent,
                          )
                        ],
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 90),
            child: getAttendanceListView(),
          ),
        ],
      ),
    );
  }

  approveAcquisitinoSingle() {
    late AttendanceReqManModel model;
    if (_isChecked != null && _isChecked.length > 0) {
      for (int index = 0; index < _isChecked.length; index++) {
        if (_isChecked[index]) {
          model = requisitionList[index];
          break;
        }
      }
      if (model != null) {
        _showDialog(model.requisitionId.toInt(), model.employeeName);
      }
    }
  }

  singleSelection(int position,bool value) {
    late AttendanceReqManModel model;
    if (_isChecked != null && _isChecked.length > 0) {
      for (int index = 0; index < _isChecked.length; index++) {
        if (position == index) {
          _isChecked[index] = value;
        }
      }
    }
  }

  getHeader(){
    if( _tabController.index == 0){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Checkbox(
                  checkColor: Colors.black,
                  activeColor: LightColors.kLavender,
                  value: _isSelectAll,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSelectAll = value!;
                      updateSelection();
                    });
                  },
                ),
                Text(
                  'Select All',
                  style: TextStyle(fontSize: 12),
                ),
              ],

            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: MyWidget().MyButtonPadding(),
                child: ElevatedButton(
                  onPressed: () {
                    approveAcquisitinoSingle();
                  },
                  // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                  style: ElevatedButton.styleFrom(
                      elevation: 12.0,
                      textStyle:
                      const TextStyle(color: LightColors.kLightGreen)),
                  child: const Text('Submit'),
                ),
              ),
            ),
          ),
        ],
      );
    }else{
      return Text('');
    }
  }

  updateSelection() {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue="[";
    if (_isChecked != null && _isChecked.length > 0) {

      for (int index = 0; index < _isChecked.length; index++) {
        _isChecked[index] = _isSelectAll;
      }
    }
  }

  getAttendanceListView() {
    print('getAttenadnceView');
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (requisitionList == null || requisitionList.length <= 0) {
      print('data not found');
      return Utility.emptyDataSet(context,"Attendance Requisition request are not available");
    } else {
      return Column(
        children: [
          getHeader(),
          Flexible(
              child: ListView.builder(
            controller: ScrollController(),
            itemCount: requisitionList.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return generateRow(
                  index, requisitionList[index], _tabController.index);
            },
          ))
        ],
      );
    }
  }

  loadAcquisition() {
    isLoading =true;
    //Utility.showLoaderDialog(context);
    DateTime selectedDate = DateTime.now();
    DateTime prevDate =
        DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
    DateTime nextDate =
        DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
    requisitionList.clear();
    AttendanceMarkingManRequest request = AttendanceMarkingManRequest(
        Role: 'MAN',
        Status: "0",
        Employee_Id: widget.employeeId.toString(),
        ToDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(nextDate),
        FromDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(prevDate),
        Type: 'AT');
    APIService apiService = APIService();
    apiService.getAttendanceRequisitionMan(request).then((value) {
      isLoading=false;
      if (value != null) {
        requisitionList.clear();
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is AttendanceMarkingManResponse) {
          AttendanceMarkingManResponse response = value;
          if (response != null && response.responseData != null) {
            for(int index=0;index<response.responseData.length;index++){
              if(_tabController.index==0){
                //pending
                if(response.responseData[index].status=='Pending'){
                  requisitionList.add(response.responseData[index]);
                }
              }else{
                //approve
                if(response.responseData[index].status!='Pending'){
                  requisitionList.add(response.responseData[index]);
                }
              }
            }
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      _isChecked = List<bool>.filled(requisitionList.length, false);
      //Navigator.of(context).pop();
      setState(() {});
    });
  }

  getSelectedModels(int isApprove,int start) {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue="[";
    if (_isChecked != null && _isChecked.length > 0) {
      String token="";
      print(isApprove);
      for (int index = start; index < _isChecked.length; index++) {
        if(_isChecked[index]) {
          String data = "{'Requisition_Id': ${requisitionList[index]
              .requisitionId.toInt()
              .toString()},'Is_Approved': ${isApprove}}";
          jsonValue = jsonValue + token + ' ' + data;
          //list.add(request);
          token = ",";
        }

      }
    }
    jsonValue = jsonValue+"]";
    return jsonValue;
  }

  void _showDialog(int reqid, String name) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Attendance Marking Approval"),
          content: new Text(
              'Are you sure to approve attendance request'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                approveAcquisition(reqid, 0);
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kRed)),
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                approveAcquisition(reqid, 1);
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  approveAcquisition(int reqid, int isApprove) {

    DBHelper dbHelper = DBHelper();
    for(int index=0;index<_isChecked.length;index++) {
      print('Data isnerting ${index}');
      var list = getSelectedModels(isApprove, (index * 50));
      if(list!=null && list.toString().trim().isNotEmpty && list.toString()!='[]') {
        String xml = "{'root': {'subroot': ${list}}";
        dbHelper.insertSyncData(xml, 'ATTENDANCE_MAN', widget.employeeId);
      }
    }

    Utility.showMessageSingleButton(context, 'Thanks you, We receive your request, we will process it in background, once complete the service we wll update you',this);
    NotificationService notificationService = NotificationService();
    notificationService.showNotification(12, 'Attandance Request Received', 'We are processing your service', 'We are processing your service');
    initializeService();

    /*
    Utility.showLoaderDialog(context);
    var list = getSelectedModels(isApprove);

    String xml ="{'root': {'subroot': ${list}}";
    ApproveLeaveRequestManager request = ApproveLeaveRequestManager(xml: xml, userId: widget.employeeId.toString(), index: 0, actionType: 'ATTAN_MAN',);
    print('request'+request.toJson().toString());

    *//*ApproveAttendanceMarking request = new ApproveAttendanceMarking(
        Requisition_Id: reqid.toString(),
        Modified_By: widget.employeeId.toString(),
        Is_Approved: isApprove.toString());*//*
    APIService apiService = APIService();
    apiService.approveAttendance(request).then((value) {
      //print(value.toString());
      Navigator.of(context).pop();
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is ApproveAttendanceResponse) {
          ApproveAttendanceResponse response = value;
          if (response != null) {
            //Navigator.of(context).pop();
            Utility.showMessage(context, response.responseMessage);
            this.loadAcquisition();
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }

      setState(() {});
    });*/
  }

  generateRow(int position, AttendanceReqManModel model, int action) {
    double width = MediaQuery.of(context).size.width;

    return Column(
          children: [
            Container(
              color: LightColors.kAbsent,
              margin:
                  const EdgeInsets.only(left: 5, right: 5, bottom: 0, top: 0),
              padding: const EdgeInsets.all(0.0),
              /*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*/
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width / 5.5,
                      color: LightColors.kLavender,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getParsedShortDate(model.date),
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ref No : ${model.requisitionId.toInt()}',
                            style: TextStyle(color: Colors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            alignment: Alignment.center,
                            child: Text(
                              model.employeeName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            'Manager : ${model.superiorName}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      /*decoration:  BoxDecoration(
                        color: model.status=='Pending' ? LightColors.kLightOrange : LightColors.kLightBlue, // Set border width
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),*/
                      child: SizedBox(
                        child: Center(
                            child: action == 1
                                ? model.status=='Rejected' ? SizedBox(
                              width: width / 5.5,
                              child: Center(
                                child: Image.asset('assets/icons/ic_cross.png',width: 20,),
                              ) ,
                            ) : SizedBox(
                              width: width / 5.5,
                              child: Center(
                                child: Image.asset('assets/icons/ic_check_mark.png',width: 20,),
                              ) ,
                            )
                                : Checkbox(
                                    checkColor: Colors.black,
                                    activeColor: LightColors.kLavender,
                                    value: _isChecked[position],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isChecked[position] = value!;
                                        singleSelection(position,value!);
                                      });
                                    },
                                  )),
                      ),
                    ),
                    Text(''),
                  ],
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: LightColors.kLightRed, // Set border width
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width / 1.2,
                      child: Center(
                        child: Text(
                          'Reasons : ${model.reason}',
                          style: TextStyle(
                              color: model.status == 'Pending'
                                  ? LightColors.kRed
                                  : LightColors.kDarkBlue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )),
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
                      'Attendance Time : ${model.inTime} to ${model.outTime} ',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                )),
          ],
        );
  }

  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();

    try {
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
      //print('${value}   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  String getParsedShortDate(String value) {
    DateTime dateTime = parseDate(value);
    //print(value);
    String parsedDate =  DateFormat("MMM-dd").format(dateTime);
    //print('Original ${value} parsed ${parsedDate}');
    return parsedDate;
  }

  @override
  void onClick(int action, value) {
    //Navigator.of(context).pop();
    widget.listener.onClick(LocalConstant.ACTION_BACK, 'back');
  }
}
