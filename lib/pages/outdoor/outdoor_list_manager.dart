/*
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/request/leavelist_request_man.dart';
import 'package:Intranet/pages/widget/MyWidget.dart';
import '../../api/APIService.dart';
import '../../api/request/leave/leave_approve_request.dart';
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
  bool isLoading=true;
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
      debugPrint('my index is' + _tabController.index.toString());
      setState(() {
        loadAcquisition();
      });
    });
  }

  Future<void> getUserInfo() async {
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    widget.employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);

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
                Text(
                  'Outdoor Duty Approval',
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

  getSelectedModels(String status) {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue="[";
    if (_isChecked != null && _isChecked.length > 0) {
      String token="";
      debugPrint(status);
      for (int index = 0; index < _isChecked.length; index++) {
        if(_isChecked[index]) {
          String data = "{'Requisition_Id': ${requisitionList[index]
              .requisitionId.toInt()
              .toString()},'WorkflowTypeCode': 'LV2','RequisitionTypeCode': '${requisitionList[index]
              .requisitionTypeCode}','Requistion_Status_Code': '${status}','Is_Approved': ${status ==
              'REJ'
              ? "0"
              : "1"},'Workflow_UserType': 'MAN','Workflow_Remark': '${status ==
              'REJ'
              ? 'Rejected by Intranet App'
              : 'Approved from Intranet app'}'}";
          jsonValue = jsonValue + token + ' ' + data;
          //list.add(request);
          token = ",";
        }

      }
    }
    jsonValue = jsonValue+"]";
    return jsonValue;
  }

  approveAcquisition(LeaveInfoMan model, String status) {
    Utility.showLoaderDialog(context);
    var list = getSelectedModels(status);
    //String xml ="{'root': {'subroot': [{'Requisition_Id': 1102411,'WorkflowTypeCode': 'LV1','RequisitionTypeCode': 'LVREQ','Requistion_Status_Code': '','Is_Approved': 1,'Workflow_UserType': 'MAN','Workflow_Remark': 'approved'}]}}";
    //debugPrint(xml);
    String xml ="{'root': {'subroot': ${list}}";
    ApproveLeaveRequestManager request = ApproveLeaveRequestManager(xml: xml, userId: widget.employeeId.toString(), index: 0, actionType: '',);
    debugPrint('request'+request.toJson().toString());
    */
/*APIService apiService = APIService();
    apiService.approveLeaveManager(request).then((value) {
      debugPrint(value.toString());
      Navigator.of(context).pop();
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is ApplyLeaveResponse) {
          ApplyLeaveResponse response = value;
          if (response != null) {
            debugPrint(response.responseMessage);
            Utility.showMessageSingleButton(context, response.responseMessage,this);
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }

      setState(() {});
    });*//*

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
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Select and approve the acquisition',
              style: TextStyle(fontSize: 12),
            ),
          ),
          */
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
              ),*//*

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
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (requisitionList == null || requisitionList.length <= 0) {
      String message = _tabController.index==0 ? "No pending Outdoor Duty Requisition Approvals" : "Outdoor Duty Requisition requests are not available";
      return Utility.emptyDataSet(context,message);
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
    //Utility.showLoaderDialog(context);
    isLoading = true;
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
      isLoading=false;
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
      //Navigator.of(context).pop();
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
          title: new Text("Outdoor Marking Approval"),
          content: new Text(
              'Are you sure to Outdoor attendance request'),
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


*/
/*
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
      debugPrint(value.toString());
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
  }*//*


  generateRow(int position, LeaveInfoMan model, int action) {
    double width = MediaQuery.of(context).size.width;

    return Column(
          children: [
            Container(
              color: LightColors.kAbsent,
              margin:
              const EdgeInsets.only(left: 5, right: 5, bottom: 0, top: 0),
              padding: const EdgeInsets.all(0.0),
              */
/*decoration: BoxDecoration(border: Border.all(color: LightColors.kBlue)),*//*

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
                      */
/*decoration:  BoxDecoration(
                        color: model.status=='Pending' ? LightColors.kLightOrange : LightColors.kLightBlue, // Set border width
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),*//*

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
                      'Leave for : ${getParsedShortDate(model.fromDay)} to ${getParsedShortDate(model.toDay)} ',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                )),
          ],
        );
  }

  DateTime parseDate(String value) {
    DateTime dt = DateTime.now();
    //2022-07-18T00:00:00
    try {
      dt = new DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').parse(value);
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
}
*/
