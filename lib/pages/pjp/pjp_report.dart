import 'dart:convert';

import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/get_pjp_report_request.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../api/response/pjp/pjplistresponse.dart';
import '../../api/response/pjp/update_pjpstatus_response.dart';
import '../firebase/anylatics.dart';
import '../firebase/indicator.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../iface/onClick.dart';
import '../iface/onResponse.dart';
import '../model/filter.dart';
import '../utils/theme/colors/light_colors.dart';
import 'add_new_pjp.dart';
import 'cvf/cvf_questions.dart';
import 'cvf/pjpcvf.dart';
import 'filters.dart';

class MyPjpReportScreen extends StatefulWidget {
  FilterSelection mFilterSelection;

  MyPjpReportScreen({Key? key, required this.mFilterSelection})
      : super(key: key);

  @override
  _MyPjpReportListState createState() => _MyPjpReportListState();
}

class _MyPjpReportListState extends State<MyPjpReportScreen>
    implements onResponse, onClickListener {
  List<PJPInfo> mPjpList = [];
  int employeeId = 0;
  int businessId = 0;
  String employeeCode = '';
  var hiveBox;
  bool isLoading = true;
  //FilterSelection mFilterSelection = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isInternet = true;

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyPjp');
    Future.delayed(Duration.zero, () {
      this.getUserInfo();
    });
  }

  Widget datePicker(TextEditingController controller) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: LightColors.kLightGray1)),
        height: 45,
        child: Center(
            child: TextField(
          //editing controller of this TextField
          decoration: InputDecoration(
            icon: Icon(Icons.calendar_today), //icon of text field
            //label text of field
          ),
          controller: controller,
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            _showDatePicker(controller);
          },
        )));
  }

  final DateTime initialDate = DateTime.now();
  _showDatePicker(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(DateTime.now().year - 1, 5),
        lastDate: DateTime(DateTime.now().year + 1, 9));

    if (pickedDate != null) {
      setState(() {
        //debugPrint(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
        String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
        //debugPrint(formattedDate); //formatted date output using intl package =>  2021-03-16
        controller.text = formattedDate;
      });
    } else {}
  }

  loadPjpReport() async {
    PJPReportRequest request = PJPReportRequest(
        employeeCode: employeeCode,
        fromDate: Utility.convertShortDate(fromDate),
        toDate: Utility.convertShortDate(toDate));
    isInternet = await Utility.isInternet();
    if (isInternet) {
      IntranetServiceHandler.loadPjpReport(request, this);
    }
  }

  Future<void> getUserInfo() async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    employeeCode = hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;

    isInternet = await Utility.isInternet();
    if (isInternet) {
      loadPjpReport();
    } else {
      var pjpList = hiveBox.get(getId());
      try {
        isLoading = false;
        PjpListResponse response = PjpListResponse.fromJson(
          json.decode(pjpList),
        );
        if (response != null && response.responseData != null)
          mPjpList.addAll(response.responseData);
        setState(() {});
      } catch (e) {
        loadPjpReport();
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = hiveBox.get(getId());
      isLoading = false;
      //debugPrint(attendanceList.toString());
      PjpListResponse response = PjpListResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null) {
        mPjpList.addAll(response.responseData);
        mPjpList.sort((a, b) {
          //sorting in descending order
          return DateTime.parse(a.fromDate)
              .compareTo(DateTime.parse(b.fromDate));
        });
      }
      setState(() {});
      isLoad = true;
    } catch (e) {
      isLoad = false;
    }
    return isLoad;
  }

  openDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
    );
    if (picked != null && picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
//below have methods that runs once a date range is picked
        loadPjpReport();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("PJP Report"),
            actions: <Widget>[
              //IconButton
              IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: 'Date Range',
                onPressed: () {
                  openDateRange();
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onPressed: () {
                  openFilters();
                },
              ), //IconButton
            ],
            //<Widget>[]
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
                // Replace this delay with the code to be executed during refresh
                // and return a Future when code finishs execution.
                loadPjpReport();
                return Future<void>.delayed(const Duration(seconds: 3));
              },
              // Pull from top to show refresh indicator.
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      '${Utility.convertShortDate(fromDate)} to ${Utility.convertShortDate(toDate)}'),
                  SizedBox(
                    height: 10,
                  ),
                  getPjpListView(),
                ],
              ),
            ),
          )),
    );
  }

  void openNewPjp() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddNewPJPScreen(
                employeeId: employeeId,
                businessId: businessId,
                currentDate: DateTime.now(),
              )),
    );
    //debugPrint('Response Received');

    loadPjpReport();
  }

  void goToSecondScreen(BuildContext context) async {
    /*var result = await Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new FiltersScreen(),
      fullscreenDialog: true,)
    );*/
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FiltersScreen(
                employeeId: employeeId,
              )),
    );
    if (result is FilterSelection) {
      FilterSelection filter = result;
      widget.mFilterSelection.type = filter.type;
      widget.mFilterSelection.filters.clear();
      for (int index = 0; index < filter.filters.length; index++) {
        if (filter.filters[index].isSelected) {
          widget.mFilterSelection.filters.add(filter.filters[index]);
          //debugPrint('--${filter.filters[index].name}');
        }
      }
      //debugPrint(filter.filters.toList());
      loadPjpReport();
    }
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
  }

  getTimeLine(PJPInfo pjpInfo, List<GetDetailedPJP> cvfList) {
    List<Widget> list = [];
    for (int index = 0; index < cvfList.length; index++) {
      list.add(GestureDetector(
        onTap: () {
          if (pjpInfo.ApprovalStatus == 'Approved') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuestionListScreen(
                        cvfView: cvfList[index],
                        mCategory: 'All',
                        PJPCVF_Id: int.parse(cvfList[index].PJPCVF_Id),
                        employeeId: employeeId,
                        mCategoryId: cvfList[index].purpose![0].categoryId,
                        isViewOnly: true,
                      )),
            );
          }
        },
        child: _buildTimelineTile(
          indicator: const IconIndicator(
            iconData: Icons.location_pin,
            size: 18,
          ),
          pjp: pjpInfo,
          cvf: cvfList[index],
          hour: cvfList[index].visitTime,
          weather: cvfList[index].ActivityTitle == 'NA'
              ? cvfList[index].franchiseeName
              : cvfList[index].ActivityTitle,
          temperature: cvfList[index].ActivityTitle != 'NA'
              ? cvfList[index].Address
              : cvfList[index].franchiseeCode,
          phrase: cvfList[index].Status,
        ),
      ));
    }
    return list;
  }

  getPjpListView() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    } else if (mPjpList.isEmpty) {
      //debugPrint('PJP List not avaliable');
      return Utility.emptyDataSet(
          context, "your PJP list is Empty, Please plan your journey");
    } else if (mPjpList.isEmpty && isInternet) {
      return Utility.noInternetDataSet(context);
    } else {
      mPjpList = mPjpList.reversed.toList();
      return Flexible(
          child: ListView.builder(
        itemCount: mPjpList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return mPjpList[index].getDetailedPJP!.length == 0
              ? getView(mPjpList[index])
              : ExpansionTile(
                  leading: null,
                  trailing: null,
                  tilePadding: EdgeInsets.all(5),
                  title: getView(mPjpList[index]),
                  children: getTimeLine(
                      mPjpList[index], mPjpList[index].getDetailedPJP!),
                );
          /*return getView(mPjpList[index]);*/
        },
      ));
    }
  }

  getView(PJPInfo pjpInfo) {
    return GestureDetector(
      onTap: () {
        if (pjpInfo.ApprovalStatus == 'Approved') {
          pjpInfo.isSelfPJP = '0';
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CVFListScreen(
                        mPjpInfo: pjpInfo,
                        isView: false,
                      )));
        } else if (pjpInfo.isSelfPJP == '1' &&
            pjpInfo.ApprovalStatus == 'Rejected') {
          Utility.showMessageSingleButton(
              context, 'The PJP is Rejected by Manager', this);
        } else if (pjpInfo.isSelfPJP == '1') {
          Utility.showMessageSingleButton(
              context,
              'This pjp is not approved yet, Please connect with your manager',
              this);
        }
      },
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Color(0x430F1113),
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                minLeadingWidth: 0,
                title: Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 12, 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            child: Text(
                              'Created By : ${pjpInfo.displayName}',
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Color(0xFF4B39EF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                            child: Text(
                              'Ref Id : P-${pjpInfo.PJP_Id}',
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Color(0xFF4B39EF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Date : ${Utility.getShortDate(pjpInfo.fromDate)} to ${Utility.getShortDate(pjpInfo.toDate)}',
                        style: const TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xFF090F13),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: /*Expanded(
                  flex: 1,
                  child:*/
                    Text(
                  'Remark : ${pjpInfo.remarks}',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                //),
                trailing: pjpInfo.ApprovalStatus == 'Pending'
                    ? Text('')
                    : pjpInfo.isSelfPJP == '0' &&
                            pjpInfo.ApprovalStatus == 'Pending'
                        ? OutlinedButton(
                            onPressed: () {
                              if (pjpInfo.isSelfPJP == '0' ||
                                  widget.mFilterSelection.type ==
                                          FILTERStatus.MYSELF &&
                                      pjpInfo.ApprovalStatus == 'Approved') {
                                Utility.showMessageMultiButton(
                                    context,
                                    'Approve',
                                    'Reject',
                                    'PJP : ${pjpInfo.PJP_Id}',
                                    'Are you sure to approve the PJP, created by ${pjpInfo.displayName}',
                                    pjpInfo,
                                    this);
                              } else {
                                Utility.showMessages(context,
                                    'Please wait Your manager need to approve the PJP');
                              }
                            },
                            child: Text(
                              'Pending Approval',
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Color(0xFF4B39EF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : pjpInfo.ApprovalStatus == 'Approved'
                            ? Image.asset(
                                'assets/icons/ic_checked.png',
                                height: 30,
                              )
                            : Text(
                                pjpInfo.ApprovalStatus,
                                style: TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  color: LightColors.kRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                      child: Icon(
                        Icons.schedule,
                        color: Color(0xFF4B39EF),
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                      child: Text(
                        '${Utility.getDateDifference(Utility.convertDate(pjpInfo.fromDate), Utility.convertDate(pjpInfo.toDate))} Days',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xFF4B39EF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    pjpInfo.getDetailedPJP != null ||
                            pjpInfo.getDetailedPJP!.length > 0
                        ? Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(24, 0, 0, 4),
                                child: pjpInfo.getDetailedPJP == null ||
                                        pjpInfo.getDetailedPJP!.length == 0
                                    ? null
                                    : Icon(
                                        Icons.local_activity,
                                        color: Color(0xFF4B39EF),
                                        size: 20,
                                      ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                                child: Text(
                                  pjpInfo.getDetailedPJP == null ||
                                          pjpInfo.getDetailedPJP!.length == 0
                                      ? ''
                                      : '${pjpInfo.getDetailedPJP!.length} CVFs',
                                  style: TextStyle(
                                    fontFamily: 'Lexend Deca',
                                    color: Color(0xFF4B39EF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  generatePjpRow(PJPInfo pjpInfo) {
    return Align(
      alignment: AlignmentDirectional(0, 0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Color(0x230E151B),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: primaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                    child: Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/app_logo.png',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '${Utility.getShortDate(pjpInfo.fromDate)} to ${Utility.getShortDate(pjpInfo.toDate)}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      Text(
                        pjpInfo.remarks,
                        style: TextStyle(color: LightColors.kDarkBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openFilters() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FiltersScreen(
            employeeId: employeeId,
          ),
        ));
    if (result is FilterSelection) {
      FilterSelection filter = result;
      widget.mFilterSelection.type = filter.type;
      widget.mFilterSelection.filters.clear();

      for (int index = 0; index < filter.filters.length; index++) {
        if (filter.filters[index].isSelected) {
          widget.mFilterSelection.filters.add(filter.filters[index]);
          //debugPrint(filter.filters[index].name);
        }
      }
      //debugPrint(filter.filters.toList());
      loadPjpReport();
    } else {
      //debugPrint('Object not found ${result}');
    }
  }

  @override
  void onError(value) {
    isLoading = false;
    setState(() {});
    Navigator.of(context).pop();
  }

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  String getId() {
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_PJP}';
  }

  savePJPLocally(String json) async {
    if (hiveBox == null) {
      hiveBox = await Hive.openBox(LocalConstant.KidzeeDB);
    }
    hiveBox.put(getId(), json);
  }

  TimelineTile _buildTimelineTile({
    required IconIndicator indicator,
    required String hour,
    required String weather,
    required String temperature,
    required GetDetailedPJP cvf,
    required PJPInfo pjp,
    required String phrase,
    bool isLast = false,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.2,
      beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
      indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: 18,
        height: 18,
        indicator: indicator,
      ),
      isLast: isLast,
      startChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            hour,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      endChild: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              weather,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              temperature,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phrase,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'CVF ID ${cvf.PJPCVF_Id}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                cvf.Status == 'Completed'
                    ? Container(
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              color: kPrimaryLightColor.withOpacity(0.4),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          MyWebsiteView(
                                            title:
                                                'CVF Report - ${cvf.PJPCVF_Id}',
                                            url:
                                                'https://intranet.zeelearn.com/cvfreport.html?cid=${cvf.PJPCVF_Id}',
                                          )));
                                },
                                child: Text(
                                  'View Report',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container()
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();
    isLoading = false;
    debugPrint('PJP List onSuccess ');
    if (value is String) {
      PJPReportRequest request = PJPReportRequest(
          employeeCode: employeeCode,
          fromDate: Utility.convertShortDate(fromDate),
          toDate: Utility.convertShortDate(toDate));
      IntranetServiceHandler.loadPjpReport(request, this);
    } else if (value is UpdatePJPStatusResponse) {
      UpdatePJPStatusResponse val = value;
      //debugPrint(val.toJson());
      if (val.responseData == 0) {
        //rejected
        Utility.getRejectionDialog(
            context, 'Rejected', 'The Pjp is rejected by you..', this);
      } else {
        Utility.getConfirmationDialogPJP(context, this);
      }
    } else if (value is PjpListResponse) {
      debugPrint('PJP List onSuccess PjpListResponse');
      PjpListResponse response = value;
      //debugPrint(response.toString());
      String json = jsonEncode(response);
      savePJPLocally(json);
      //debugPrint('onResponse in if ${widget.mFilterSelection.type}');
      isLoading = false;
      mPjpList.clear();
      debugPrint('PJP List onSuccess ${response.responseData.toString()}');
      if (response.responseData != null && response.responseData.length > 0) {
        if (response != null && response.responseData != null) {
          if (widget.mFilterSelection == null ||
              widget.mFilterSelection.type == FILTERStatus.MYTEAM) {
            debugPrint('FOR MY TEAM');
            //mPjpList.addAll(response.responseData);
            for (int index = 0; index < response.responseData.length; index++) {
              mPjpList.addAll(response.responseData);
            }
          } else if (widget.mFilterSelection.type == FILTERStatus.MYSELF) {
            debugPrint('FOR MY SELF');
            for (int index = 0; index < response.responseData.length; index++) {
              if (response.responseData[index].isSelfPJP == '1') {
                mPjpList.add(response.responseData[index]);
              }
            }
          } else if (widget.mFilterSelection.type == FILTERStatus.NONE) {
            debugPrint('FOR MY CUSTOM TEAM');
            for (int index = 0; index < response.responseData.length; index++) {
              if (response.responseData[index].isSelfPJP == '0') {
                mPjpList.add(response.responseData[index]);
              }
            }
          } else {
            //debugPrint('In else');
            for (int index = 0; index < response.responseData.length; index++) {
              for (int jIndex = 0;
                  jIndex < widget.mFilterSelection.filters.length;
                  jIndex++) {
                if (response.responseData[index].displayName ==
                    widget.mFilterSelection.filters[jIndex].name) {
                  mPjpList.add(response.responseData[index]);
                }
              }
            }
          }

          mPjpList.sort((a, b) {
            var adate = a.fromDate; //before -> var adate = a.expiry;
            var bdate = b.fromDate; //var bdate = b.expiry;
            return -bdate.compareTo(adate);
          });
          //mPjpList.addAll(response.responseData);
          debugPrint('========================${mPjpList.length}');
          //debugPrint(response.toJson());
          //mPjpList = mPjpList.reversed.toList();
        }
      } else {
        debugPrint('onResponse in if else');
      }
    }
    setState(() {
      //mPjpList.addAll(response.responseData);
    });
  }

  void approvePjp(PJPInfo pjpInfo, int isApprove) {
    UpdatePJPStatusRequest request = UpdatePJPStatusRequest(
        PJP_id: int.parse(pjpInfo.PJP_Id),
        Is_Approved: isApprove,
        Workflow_user: employeeId.toString());
    IntranetServiceHandler.updatePJPStatus(request, this);
  }

  @override
  void onClick(int action, value) {
    //debugPrint('onClick called ${value}');
    if (value is PJPInfo) {
      PJPInfo pjpInfo = value;
      if (action == Utility.ACTION_OK) {
        approvePjp(pjpInfo, 1);
      } else if (action == Utility.ACTION_CCNCEL) {
        approvePjp(pjpInfo, 0);
      }
    }
  }
}
