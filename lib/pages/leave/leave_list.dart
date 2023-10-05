import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/leave_balance_req.dart';
import 'package:intranet/api/request/leave_request.dart';
import 'package:intranet/api/response/LeaveRequisitionResponse.dart';
import 'package:intranet/api/response/leave_response.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/leave/apply_leave.dart';

import '../../api/APIService.dart';
import '../firebase/anylatics.dart';
import '../helper/helpers.dart';
import '../utils/theme/colors/light_colors.dart';

class LeaveSummeryScreen extends StatefulWidget {
  String displayName;

  String _applied = '-';
  String _taken = '-';
  String _rejected = '-';
  String _totalCanceled = '-';
  String _avaliableForEncash = '-';
  String _totalLeaveBalance = '-';

  LeaveSummeryScreen({Key? key, required this.displayName}) : super(key: key);

  @override
  _LeaveSummeryScreenState createState() => _LeaveSummeryScreenState();
}

class _LeaveSummeryScreenState extends State<LeaveSummeryScreen>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int employeeId = 0;

  List<LeaveBalanceInfo> leaveBalanceList = [];
  List<LeaveRequisitionInfo> leaveRequisitionList = [];
  bool isLoading = true;
  var hiveBox;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('didChangeAppLifecycleState ${state} ');
    if (state == AppLifecycleState.resumed) {
      getUserInfo();
    }
  }

  Future<void> getUserInfo() async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);

    var leaveBalanceSummery = hiveBox.get(getId());
    var leaveRequsitionSummery = hiveBox.get('r'+getId());
    if(leaveBalanceSummery==null){
      loadSummery();
    }else {
      getLocalData(leaveBalanceSummery);
    }
    if(leaveRequsitionSummery==null){
      loadLeaveRequsition();
    }else {
      getLeaveRequisitionData(leaveRequsitionSummery);
    }
  }

  getLocalData(data) {
    bool isLoad = false;
    try {
      isLoading = false;
      debugPrint(data.toString());
      Map<String,dynamic> jsonObject  = json.decode(data.toString());
      debugPrint('json decode');
      LeaveBalanceResponse response = LeaveBalanceResponse.fromJson(
        json.decode(data!),
      );
      if (response != null && response.responseData != null){
        LeaveBalanceInfo info = response.responseData[0];
        widget._applied = info.leaveApplied.toInt().toString();
        widget._taken = info.leaveTaken.toInt().toString();
        widget._rejected = info.leaveRejected.toInt().toString();
        widget._totalCanceled = info.leaveCancelled.toInt().toString();
        widget._avaliableForEncash = info.leaveAvaEncash.toInt().toString();
        widget._totalLeaveBalance = info.leaveBalance.toInt().toString();
        setState(() {});
      }
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }
  getLeaveRequisitionData(data) {
    bool isLoad = false;
    try {
      isLoading = false;
      debugPrint(data.toString());
      leaveRequisitionList.clear();
      Map<String,dynamic> jsonObject  = json.decode(data.toString());
      debugPrint('json decode');
      LeaveRequisitionResponse response = LeaveRequisitionResponse.fromJson(
        json.decode(data!),
      );
      if (response != null && response.responseData != null){
        leaveRequisitionList.addAll(response.responseData);
        setState(() {});
      }
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  loadSummery() {
    isLoading = true;
    //Utility.showLoaderDialog(context);
    leaveBalanceList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 1, time.day);
    LeaveBalanceRequest request = LeaveBalanceRequest(
        Employee_Id: employeeId,
        FDay: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(selectedDate),
        TDay: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(time));
    //loginRequestModel.User_Name = 'F2354';
    //loginRequestModel.User_Password = 'Niharika#123';
    APIService apiService = APIService();
    apiService.LeaveBalance(request).then((value) {
      debugPrint(value.toString());
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is LeaveBalanceResponse) {
          LeaveBalanceResponse response = value;
          if (response != null &&
              response.responseData != null &&
              response.responseData[0] != null) {

            String json = jsonEncode(response);
            saveLeaveSummery(json);

            LeaveBalanceInfo info = response.responseData[0];
            widget._applied = info.leaveApplied.toInt().toString();
            widget._taken = info.leaveTaken.toInt().toString();
            widget._rejected = info.leaveRejected.toInt().toString();
            widget._totalCanceled = info.leaveCancelled.toInt().toString();
            widget._avaliableForEncash = info.leaveAvaEncash.toInt().toString();
            widget._totalLeaveBalance = info.leaveBalance.toInt().toString();
            setState(() {});
          }
          debugPrint('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      //Navigator.of(context).pop();
      setState(() {});
    });
  }

  String getId(){
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_LEAVE}';
  }

  saveLeaveSummery(String json) async{
    hiveBox.put(getId(), json);
  }
  saveLeaveRequsition(String json) async{
    hiveBox.put('r'+getId(), json);
  }

  loadLeaveRequsition() {
   // Utility.showLoaderDialog(context);
    isLoading = true;
    setState(() {

    });
    leaveRequisitionList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 5, time.day);
    DateTime upDate = new DateTime(time.year, time.month + 3, time.day);
    LeaveListRequest request = LeaveListRequest(
        Employee_ID: employeeId.toString(),
        Employee_Name: "",
        FromDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(selectedDate),
        Role: '',
        Status: "0",
        ToDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(upDate),
        device: "0");

    APIService apiService = APIService();
    apiService.LeaveRequisition(request).then((value) {
      //debugPrint(value.toString());
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is LeaveRequisitionResponse) {
          LeaveRequisitionResponse response = value;
          if (response != null && response.responseData != null) {
            String json = jsonEncode(response);
            saveLeaveRequsition(json);
            leaveRequisitionList.addAll(response.responseData);
            setState(() {});
          }
          debugPrint('leave list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      //Navigator.of(context).pop();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('LeaveRequisition');
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.white,
            backgroundColor: Colors.blue,
            strokeWidth: 4.0,
            onRefresh: () async {
              // Replace this delay with the code to be executed during refresh
              // and return a Future when code finishs execution.
              loadLeaveRequsition();
              loadSummery();
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                Container(
                  color: LightColors.kLightBlue,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Leave Management',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              loadLeaveRequsition();
                              loadSummery();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.refresh,
                                size: 30,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ApplyLeaveScreen(
                                        employeeId: employeeId,
                                        displayName: '',
                                        applied: widget._applied,
                                        taken: widget._taken,
                                        rejected: widget._rejected,
                                        totalCanceled: widget._totalCanceled,
                                        avaliableForEncash:
                                        widget._avaliableForEncash,
                                        totalLeaveBalance:
                                        widget._totalLeaveBalance)),
                              );
                              loadLeaveRequsition();

                              /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ApplyLeaveScreen(
                                          employeeId: employeeId,
                                          displayName: '',
                                          applied: widget._applied,
                                          taken: widget._taken,
                                          rejected: widget._rejected,
                                          totalCanceled: widget._totalCanceled,
                                          avaliableForEncash:
                                          widget._avaliableForEncash,
                                          totalLeaveBalance:
                                          widget._totalLeaveBalance)));*/
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add_box,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                getLeaveBalance(),
                const Text(
                  'Leave History',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                getLeaveListView(),
              ],
            ),
          ),
        ));
  }

  getLeaveListView() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (leaveRequisitionList == null || leaveRequisitionList.length <= 0) {
      debugPrint('data not found');
      return Utility.emptyDataSet(context,"Leave Requisition are not available");
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: leaveRequisitionList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return generateLeaveRow(leaveRequisitionList[index]);
        },
      ));
    }
  }

  generateLeaveRow(LeaveRequisitionInfo model) {
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
                      color: LightColors.kAbsent_BUTTON,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model.noOfDays.toInt().toString(),
                            style: TextStyle(
                              fontSize: 20.0,
                              letterSpacing: 0.53,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'days',
                            style: TextStyle(fontSize: 14, color: Colors.black, letterSpacing: 0.53),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ref No : ${model.requisitionId.toInt()}',
                            style: TextStyle(fontSize: 8, color: Colors.black, letterSpacing: 0.53),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            alignment: Alignment.center,
                            child: Text(
                              model.employeeName,
                              style: TextStyle(fontSize: 12, color: Colors.black, letterSpacing: 0.53),
                            ),
                          ),
                          Text(
                            'Manager : ${model.superiorName}',
                            style: TextStyle(fontSize: 11, color: Colors.black, letterSpacing: 0.53),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: LightColors.kDarkOrange, // Set border width
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Text(
                        model.status=='Manager Approved' ? 'Manager\nApproved' : model.status,
                        style: TextStyle(fontSize: 12, color: Colors.black, letterSpacing: 0.53),
                      ),
                    ),
                    SizedBox(height: 0,)
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
                    Text(
                      'Reasons : ${model.reason}',
                      style: TextStyle(fontSize: 11, color: Colors.black, letterSpacing: 0.53),
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
                      'Leave From : ${getParsedShortDate(model.fromDay)} to ${getParsedShortDate(model.toDay)} ',
                      style: TextStyle(fontSize: 11, color: Colors.black, letterSpacing: 0.53),
                    ),
                    Text(
                      'Type : ${model.leaveType}',
                      style: TextStyle(fontSize: 11, color: Colors.black, letterSpacing: 0.53),
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
                Text(widget._applied, style: TextStyle(fontSize: 20)),
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
                Text(widget._taken, style: TextStyle(fontSize: 20)),
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
                Text(widget._rejected, style: TextStyle(fontSize: 20)),
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
                Text(widget._totalCanceled, style: TextStyle(fontSize: 20)),
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
                Text(widget._avaliableForEncash,
                    style: TextStyle(fontSize: 20)),
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
                Text(widget._totalLeaveBalance, style: TextStyle(fontSize: 20)),
                Text('Total leave Balanced',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
