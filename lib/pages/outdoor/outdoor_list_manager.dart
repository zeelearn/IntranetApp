import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/ApproveAttendanceMarking.dart';
import 'package:intranet/api/request/leavelist_request_man.dart';
import 'package:intranet/pages/widget/MyWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/APIService.dart';
import '../../api/request/approve_leave_request.dart';
import '../../api/response/apply_leave_response.dart';
import '../../api/response/approve_attendance_response.dart';
import '../../api/response/attendance_marking_man.dart';
import '../../api/response/leave_list_manager.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';
import '../utils/theme/colors/light_colors.dart';

class OutdoorManagerScreen extends StatefulWidget {
  int employeeId;

  OutdoorManagerScreen({Key? key, required this.employeeId})
      : super(key: key);

  @override
  _OutdoorManagerScreen createState() => _OutdoorManagerScreen();
}

class _OutdoorManagerScreen extends State<OutdoorManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<bool> _isChecked = [];
  bool _isSelectAll = false;
  final _selectedColor = LightColors.kLavender;
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [Tab(text: 'Pending Approvals'), Tab(text: 'All Approvals')];

  final _iconTabs = [
    Tab(icon: Icon(Icons.line_style)),
    Tab(icon: Icon(Icons.approval)),
  ];

  List<LeaveInfoMan> requisitionList = [];

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
      print('my index is' + _tabController.index.toString());
      setState(() {
        loadAcquisition();
      });
    });
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    widget.employeeId = int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);

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
            padding: EdgeInsets.only(top: 60),
            child: getAttendanceListView(),
          ),
        ],
      ),
    );
  }

  approveAcquisitinoSingle() {
    late LeaveInfoMan model;
    if (_isChecked != null && _isChecked.length > 0) {
      for (int index = 0; index < _isChecked.length; index++) {
        if (_isChecked[index]) {
          model = requisitionList[index];
          break;
        }
      }
      if (model != null) {
        _showDialog(model);
      }
    }
  }

  singleSelection(int position) {
    late AttendanceReqManModel model;
    if (_isChecked != null && _isChecked.length > 0) {
      for (int index = 0; index < _isChecked.length; index++) {
        if (position == index) {
          _isChecked[index] = true;
        } else {
          _isChecked[index] = false;
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
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Select and approve the acquisition',
              style: TextStyle(fontSize: 12),
            ),
          ),
          /*Row(
                children: [
                  Checkbox(
                    checkColor: Colors.black,
                    activeColor: LightColors.kLavender,
                    value: _isSelectAll,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSelectAll = value!;
                        updateListView();
                      });
                    },
                  ),
                  Text(
                    'Select All',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),*/
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

  getAttendanceListView() {
    if (requisitionList == null || requisitionList.length <= 0) {
      print('data not found');
      return Utility.emptyDataSet(context);
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
    Utility.showLoaderDialog(context);
    DateTime selectedDate = DateTime.now();
    DateTime _from = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
    DateTime _to = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
    requisitionList.clear();
    ApplyLeaveManRequest request = ApplyLeaveManRequest(device: 0,
        LeaveType: 'Outdoor', Employee_Id: widget.employeeId.toString(),
        Role: 'Man',
        FromDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(_from),
        ToDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(_to));
    APIService apiService = APIService();
    apiService.leaveRequisitionManager(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is LeaveListManagerResponse) {
          LeaveListManagerResponse response = value;
          if (response != null && response.responseData != null) {
            requisitionList.clear();
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
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  void _showDialog(LeaveInfoMan model) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Attendance Marking Approval"),
          content: new Text(
              'Are you sure to approve attendance request for ${model.employeeName}'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              onPressed: () {
                approveAcquisition(model, 'MANAP');
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kRed)),
              child: const Text('Rejected'),
            ),
            ElevatedButton(
              onPressed: () {
                approveAcquisition(model, 'REJ');
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child: const Text('Approved'),
            ),
          ],
        );
      },
    );
  }

  approveAcquisition(LeaveInfoMan model, String status) {
    Utility.showLoaderDialog(context);
    DateTime selectedDate = DateTime.now();
    ApproveLeaveRequest request= ApproveLeaveRequest(RequisitionTypeCode: model.requisitionTypeCode,
        User_Id: widget.employeeId.toInt().toString(),
        Requisition_Id: model.requisitionId.toInt().toString(),
        WorkflowTypeCode: model.workflowTypeCode,
        Requistion_Status_Code: status,
        Is_Approved: false,
        Workflow_UserType: '',
        Workflow_Remark: '');
    APIService apiService = APIService();
    apiService.approveLeave(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          if (response != null) {
            Utility.showMessage(context, response.responseMessage);
            Navigator.of(context).pop();
            loadAcquisition();
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  generateRow(int position, LeaveInfoMan model, int action) {
    double width = MediaQuery.of(context).size.width;

    return Expanded(
        flex: 1,
        child: Column(
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
                            getParsedShortDate(model.fromDay),
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
                            'Manager : ${model.managerName}',
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
                                ? SizedBox(
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
                                  singleSelection(position);
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
                      'Leave for : ${getParsedShortDate(model.fromDay)} to ${getParsedShortDate(model.toDay)} ',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                )),
          ],
        ));
  }

  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-ddTmm:hh:ss').parse(value);
      print('asasdi   ' + dt.day.toString());
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
