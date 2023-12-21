import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager_exceptional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/main.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/widget/MyWidget.dart';

import '../../api/response/leave_list_manager.dart';
import '../../api/response/pjp/pjplistresponse.dart';
import '../firebase/notification_service.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../model/filter.dart';
import '../utils/theme/colors/light_colors.dart';
import 'filters.dart';
import 'mypjp_manager_a.dart';
import 'mypjp_manager_e.dart';
import 'mypjp_manager_p.dart';

class PJPManagerScreen extends StatefulWidget {
  int employeeId;

  PJPManagerScreen({Key? key, required this.employeeId})
      : super(key: key);

  @override
  _PJPManagerScreen createState() => _PJPManagerScreen();
}

class _PJPManagerScreen extends State<PJPManagerScreen>
    with SingleTickerProviderStateMixin implements onClickListener {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  List<bool> _isChecked = [];
  List<PJPInfo> mPjpList = [];
  int businessId=1;
  bool _isSelectAll = false;
  final _selectedColor = LightColors.kLavender;
  final _tabs = [Tab(text: 'Pending Approvals'), Tab(text: 'All Approvals')];
  FilterSelection mFilterSelection = FilterSelection(
    filters: [], type: FILTERStatus.NONE,);

  late MyPjpManPListScreen pendingApproval;

  final _iconTabs = [
    Tab(icon: Icon(Icons.line_style)),
    Tab(icon: Icon(Icons.approval)),
  ];

  List<LeaveInfoMan> requisitionList = [];
  bool isLoading = true;

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
    debugPrint('MyManager screen');
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    getUserInfo();
    updateFilter();
    _tabController.addListener(() {
      debugPrint('pjplist my index is' + _tabController.index.toString());
      setState(() {
        //IntranetServiceHandler.loadPjpSummery(widget.employeeId, 0,businessId, this);
      });
    });
  }

  updateFilter(){
    pendingApproval = MyPjpManPListScreen(
      mFilterSelection: mFilterSelection,
      mPjpList:[],
      isApproved : false);
  }

  Future<void> getUserInfo() async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    widget.employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    //loadAcquisition();

  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("My PJP",style: LightColors.textHeaderStyleWhite),
              Padding(
                padding: EdgeInsets.only(right: 3),
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: MyWidget().MyButtonPadding(),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PJPManagerExceptionalScreen()));
                      },
                      // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                      style: ElevatedButton.styleFrom(
                          elevation: 11.0,
                          backgroundColor: Colors.white70,
                          shadowColor: Colors.white,
                          textStyle:
                          const TextStyle(color: Colors.black)),
                      child:  Text('Exceptional PJP',style: LightColors.textStyle,),
                    ),
                  ),
                ),
              ),
            ],
          ) /*const Text("My PJP")*/,
          backgroundColor: kPrimaryLightColor,
          elevation: 50.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Menu Icon',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      body: SafeArea(
        child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: Colors.blue,
        strokeWidth: 4.0,
        onRefresh: () async {
          updateFilter();
          return Future<void>.delayed(const Duration(seconds: 3));
        },child: Stack(
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
              padding: EdgeInsets.only(top: 70),
              child: _tabController.index==0 ? pendingApproval : MyPjpManAListScreen(
                mFilterSelection: FilterSelection(
                  filters: [], type: FILTERStatus.NONE,),
                mPjpList:[],
                isApproved : _tabController.index==0 ? false : true,),
            ),
          ],
        ),
    )));
  }

  void openFilters() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FiltersScreen(
            employeeId: widget.employeeId,
          ),
        ));
    if (result is FilterSelection) {
      FilterSelection filter = result;
      mFilterSelection.type = filter.type;
      mFilterSelection.filters.clear();

      for(int index=0;index<filter.filters.length;index++){
        if(filter.filters[index].isSelected){
          mFilterSelection.filters.add(filter.filters[index]);
          debugPrint(filter.filters[index].name);
        }
      }
    }
    updateFilter();
    setState(() {
    });
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

  getSelectedModels(String status,int start) {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue="[";
    if (_isChecked != null && _isChecked.length > 0) {
      String token="";
      debugPrint(status);
      for (int index = start; index < _isChecked.length; index++) {
        if(_isChecked[index]) {
          String data = "{'Requisition_Id': ${requisitionList[index]
              .requisitionId.toInt()
              .toString()},'WorkflowTypeCode': '${requisitionList[index].workflowTypeCode}','RequisitionTypeCode': '${requisitionList[index]
              .requisitionTypeCode}','Requistion_Status_Code': '${status}','Is_Approved': ${status ==
              'REJ'
              ? "0"
              : "1"},'Workflow_UserType': 'MAN','Workflow_Remark': '${status ==
              'REJ'
              ? 'Rejected by Intranet App'
              : 'Approved from Intranet app'}'}";
          /*ApproveLeaveRequest request= ApproveLeaveRequest(RequisitionTypeCode: requisitionList[index].requisitionTypeCode,
              User_Id: widget.employeeId.toInt().toString(),
              Requisition_Id: requisitionList[index].requisitionId.toInt().toString(),
              WorkflowTypeCode: requisitionList[index].workflowTypeCode,
              Requistion_Status_Code: status,
              Is_Approved: status=='REJ' ? false : true,
              Workflow_UserType: 'MAN',
              Workflow_Remark: 'approved from Intranet App');*/
          jsonValue = jsonValue + token + ' ' + data;
          //list.add(request);
          token = ",";
        }

      }
    }
    jsonValue = jsonValue+"]";
    return jsonValue;
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
            padding: EdgeInsets.only(right: 30),
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
                  child: Text('Submit',style: LightColors.textHeaderStyle13Selected,),
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
    debugPrint('getAttendanceListView');
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (requisitionList == null || requisitionList.length <= 0) {
      String message = _tabController.index==0 ? "No pending List Requisition Approvals" : "Requests are not available";
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

  /*loadAcquisition() {
    //Utility.showLoaderDialog(context);
    isLoading = true;
    setState(() {

    });
    debugPrint('loadAcquisition leave man');
    DateTime selectedDate = DateTime.now();
    DateTime _from = DateTime(selectedDate.year, selectedDate.month - 3, selectedDate.day);
    DateTime _to = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
    requisitionList.clear();
    ApplyLeaveManRequest request = ApplyLeaveManRequest(device: 0,
        LeaveType: 'Leave', Employee_Id: widget.employeeId.toString(),
        Role: 'Man',
        FromDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(_from),
        ToDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(_to));
    debugPrint('request ${request.toString()}');
    APIService apiService = APIService();
    apiService.leaveRequisitionManager(request).then((value) {
      isLoading=false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is LeaveListManagerResponse) {
          LeaveListManagerResponse response = value;
          requisitionList.clear();
          if (response != null && response.responseData != null) {
            for(int index=0;index<response.responseData.length;index++){
              if(_tabController.index==0){
                //pending
                if(response.responseData[index].status=='Pending'){
                    requisitionList.add(response.responseData[index]);
                }else{
                  debugPrint(response.responseData[index].employeeName);
                  debugPrint(response.responseData[index].leaveType);
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
*/
  void _showDialog(LeaveInfoMan model) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Leave  Approval"),
          content: new Text(
              'Are you sure to approve the ${model.leaveType} request'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                approveAcquisition(model, 'REJ');
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
                approveAcquisition(model, 'MANAP');
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

  approveAcquisition(LeaveInfoMan model, String status) {
    //Utility.showLoaderDialog(context);
    DBHelper dbHelper = DBHelper();
    for(int index=0;index<_isChecked.length;index++) {
      //debugPrint('Data isnerting ${index}');
      var list = getSelectedModels(status, (index * 50));
      if(list!=null && list.toString().trim().isNotEmpty && list.toString()!='[]') {
        String xml = "{'root': {'subroot': ${list}}";
        dbHelper.insertSyncData(xml, 'LEAVEMAN', widget.employeeId);
      }
    }
    //Navigator.of(context).pop();
    Utility.showMessageSingleButton(context, 'Thank You. We received your request. We will process it in background. Once  it is completed, we will update you.',this);
    NotificationService notificationService = NotificationService();
    notificationService.showNotification(12, '${model.leaveType} REQUEST Received', 'We are processing your service', 'We are processing your service');
    initializeService();
    //loadAcquisition();

    //var list = getSelectedModels(status);
    //String xml ="{'root': {'subroot': [{'Requisition_Id': 1102411,'WorkflowTypeCode': 'LV1','RequisitionTypeCode': 'LVREQ','Requistion_Status_Code': '','Is_Approved': 1,'Workflow_UserType': 'MAN','Workflow_Remark': 'approved'}]}}";
    //debugPrint(xml);

    //String xml ="{'root': {'subroot': ${list}}";
    /*ApproveLeaveRequestManager request = ApproveLeaveRequestManager(xml: xml, userId: widget.employeeId.toString(),);
    APIService apiService = APIService();
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
    });*/
  }

  generateRow(int position, LeaveInfoMan model, int action) {
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
                                child: model.status=='Manager Approved' ?  Image.asset(
                                  'assets/icons/ic_checked.png',
                                  height: 50,
                                ) : model.status=='Rejected' ?  Image.asset(
                                  'assets/icons/ic_cross.png',
                                  height: 50,
                                ) : Image.asset(
                                  'assets/icons/ic_pending.png',
                                  height: 50,
                                ),
                              ) ,
                            )
                                : Checkbox(
                              checkColor: Colors.black,
                              activeColor: LightColors.kLavender,
                              value: _isChecked[position],
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked[position] = value!;
                                  //singleSelection(position);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leave for : ${getParsedShortDate(model.fromDay)} to ${getParsedShortDate(model.toDay)} ',
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Type : ${model.leaveType}',
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

  @override
  void onClick(int action, value) {
    //this.loadAcquisition();
    //Navigator.of(context).pop();
  }

  @override
  void onError(value) {
    isLoading=false;
    print(value);
    setState(() {

    });
    //Navigator.of(context).pop();
  }

}
