import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/outdoor_request.dart';
import 'package:intranet/api/response/outdoor_response.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';

import '../../api/APIService.dart';
import '../utils/theme/colors/light_colors.dart';
import 'apply_outdoor.dart';

class OutdoorScreen extends StatefulWidget {
  String displayName;
  int businessId;


  OutdoorScreen({Key? key, required this.displayName,required this.businessId}) : super(key: key);

  @override
  _OutdoorScreen createState() => _OutdoorScreen();
}

class _OutdoorScreen extends State<OutdoorScreen>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int employeeId = 0;
  var hiveBox;

  List<OutdoorModel> outdoorRequisitionList = [];
  bool isLoading = true;

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
    print('didChangeAppLifecycleState ${state} ');
    if (state == AppLifecycleState.resumed) {
      loadOutdoorRequisition();
    }
  }

  Future<void> getUserInfo() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);

    var leaveODSummery = hiveBox.get('r'+getId());
    if(leaveODSummery==null){
      loadOutdoorRequisition();
    }else {
      getLeaveRequisitionData(leaveODSummery);
    }
  }

  getLeaveRequisitionData(data) {
    bool isLoad = false;
    try {
      isLoading = false;
      outdoorRequisitionList.clear();
      Map<String,dynamic> jsonObject  = json.decode(data.toString());
      OutdoorResponse response = OutdoorResponse.fromJson(
        json.decode(data!),
      );
      if (response != null && response.responseData != null){
        outdoorRequisitionList.addAll(response.responseData);
        setState(() {});
      }
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  saveODSummery(String json) async{
    hiveBox.put(getId(), json);
  }
  String getId(){
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_OUTDOOR}';
  }

  loadOutdoorRequisition() {
    //Utility.showLoaderDialog(context);
    isLoading=true;
    setState(() {

    });
    outdoorRequisitionList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 5, time.day);
    DateTime upDate = new DateTime(time.year, time.month + 3, time.day);
    OutdoorRequest request =  OutdoorRequest(Employee_Id: employeeId.toString(),
        LeaveType: '', device: '0', Role: '',
        FromDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(selectedDate),
        ToDate: DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(upDate));

    APIService apiService = APIService();
    apiService.outdoorRequisition(request).then((value) {
      print(value.toString());
      isLoading=false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is OutdoorResponse) {
          OutdoorResponse response = value;
          if (response != null && response.responseData != null) {
            String json = jsonEncode(response);
            saveODSummery(json);
            outdoorRequisitionList.addAll(response.responseData);
            setState(() {});
          }
          print('leave list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
     // Navigator.of(context).pop();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
              loadOutdoorRequisition();
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
                        'Outdoor Requisition',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          applyNewOutdoor();
                          /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ApplyOutDoorScreen(employeeId: employeeId,displayName: '',)));*/
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add_box,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Outdoor History',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                getOutdoorListView(),
              ],
            ),
          ),
        ));
  }

  void applyNewOutdoor() async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ApplyOutDoorScreen(employeeId: employeeId,displayName: '', businessId: widget.businessId,)),
    );
    print('Response Received');

    this.loadOutdoorRequisition();
  }

  getOutdoorListView() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (outdoorRequisitionList == null || outdoorRequisitionList.length <= 0) {
      print('data not found');
      return Utility.emptyDataSet(context,"Outdoor Requisition are not avaliable");
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: outdoorRequisitionList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return generateRow(outdoorRequisitionList[index]);
        },
      ));
    }
  }

  generateRow(OutdoorModel model) {
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
                            getDate(model.date),
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            getMonth(model.date),
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
                              style: TextStyle(color: Colors.black),
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
                      decoration:  BoxDecoration(
                        color: model.status=='Pending' ? LightColors.kLightOrange : LightColors.kLightBlue, // Set border width
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: SizedBox(
                        width: width / 5.5,
                        child: Center(
                          child: Text(
                            model.status,
                            style: TextStyle(color: model.status=='Pending' ? LightColors.kRed : LightColors.kDarkBlue),
                            textAlign: TextAlign.center,
                          ),
                        ) ,
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
                      width: width/1.2,
                      child: Center(
                        child: Text(
                            'Reasons : ${model.reason}',
                          style: TextStyle(color: model.status=='Pending' ? LightColors.kRed : LightColors.kDarkBlue),
                          textAlign: TextAlign.center,
                        ),
                      ) ,
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
                      'Outdoor Time : ${model.fromTime} to ${model.toTime} ',
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
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  String getDate(String value) {
    DateTime dt = parseDate(value);
    String date='';
    try {
      date = new DateFormat('dd').format(dt);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return date;
  }

  String getMonth(String value) {
    DateTime dt = parseDate(value);
    String date='';
    try {
      date = new DateFormat('MMM').format(dt);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return date;
  }

  String getParsedShortDate(String value) {
    DateTime dateTime = parseDate(value);
    return DateFormat("MMM-dd").format(dateTime);
  }


}
