import 'dart:convert';

import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatus_request.dart';
import 'package:Intranet/pages/helper/LocationHelper.dart';
import 'package:Intranet/pages/pjp/cvf/add_cvf.dart';
import 'package:expensestracker/app/util/util.dart';
import 'package:expensestracker/presentation/pages/advance_requisition/add_advance_requisition_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';

import '../../api/response/pjp/pjplistresponse.dart';
import '../../api/response/pjp/update_pjpstatus_response.dart';
import '../firebase/anylatics.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../iface/onClick.dart';
import '../iface/onResponse.dart';
import '../model/filter.dart';
import '../utils/theme/colors/light_colors.dart';
import 'add_new_pjp.dart';
import 'cvf/pjpcvf.dart';
import 'filters.dart';

class MyPjpListScreen extends StatefulWidget {
  FilterSelection mFilterSelection;

  MyPjpListScreen({Key? key, required this.mFilterSelection}) : super(key: key);

  @override
  _MyPjpListState createState() => _MyPjpListState();
}

class _MyPjpListState extends State<MyPjpListScreen>
    implements onResponse, onClickListener {
  List<PJPInfo> mPjpList = [];
  int employeeId = 0;
  int businessId = 0;
  var hiveBox;
  bool isLoading = true;
  //FilterSelection mFilterSelection = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isInternet = true;
  List<bool> _isChecked = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyPjp');
    Future.delayed(Duration.zero, () {
      this.getUserInfo();
    });
  }

  getAddress() async {
    LocationData location = await LocationHelper.getLocation(context);
    if (location != null) {
      double latitude = location.latitude!;
      double longitude = location.longitude!;
      print('Location is ${latitude} ${longitude}');
      print('Address is ${Utility.getAddress(latitude, longitude)}');
    } else {
      print('location data not found');
    }
  }

  Future<void> getUserInfo() async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);

    isInternet = await Utility.isInternet();
    if (isInternet) {
      IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
    } else {
      var pjpList = hiveBox.get(getId());
      try {
        isLoading = false;
        PjpListResponse response = PjpListResponse.fromJson(
          json.decode(pjpList),
        );

        if (response != null && response.responseData != null)
          mPjpList.addAll(response.responseData);
        _isChecked = List<bool>.filled(mPjpList.length, false);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = hiveBox.get(getId());
      isLoading = false;
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
      _isChecked = List<bool>.filled(mPjpList.length, false);
      setState(() {});
      isLoad = true;
    } catch (e) {
      isLoad = false;
    }
    return isLoad;
  }

  bool _isSelectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("My PJP"),
          actions: <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'Filter',
              onPressed: () {
                openNewPjp();
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {
                openFilters();
              },
            ), //IconButton

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () async {
                  var hiveBox = await Utility.openBox();
                  await Hive.openBox(LocalConstant.KidzeeDB);

                  String employeeCode =
                      hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
                  debugPrint('Employee code is - $employeeCode');
                  Utils.isExternal = true;
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            child: AddAdvanceRequisitionPage(
                              e_id: employeeCode,
                            ),
                          ));
                },
                child: Image.asset(
                  'assets/icons/advance.png',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
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
              IntranetServiceHandler.loadPjpSummery(
                  employeeId, 0, businessId, this);
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                /*Row(
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
                          //approveAcquisitinoSingle();
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
            ),*/
                SizedBox(
                  height: 10,
                ),
                getPjpListView(),
              ],
            ),
          ),
        ));
  }

  updateSelection() {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue = "[";
    if (_isChecked != null && _isChecked.length > 0) {
      for (int index = 0; index < _isChecked.length; index++) {
        _isChecked[index] = _isSelectAll;
      }
    }
    mPjpList.sort((a, b) {
      var adate = a.fromDate; //before -> var adate = a.expiry;
      var bdate = b.fromDate; //var bdate = b.expiry;
      return -bdate.compareTo(adate);
    });
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
    IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
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
        }
      }
      IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
    }
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
  }

  getPjpListView() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    } else if (mPjpList.isEmpty) {
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
          return getView(mPjpList[index], index);
        },
      ));
    }
  }

  getView(PJPInfo pjpInfo, int index) {
    return GestureDetector(
      onTap: () {
        if (pjpInfo.ApprovalStatus == 'Approved') {
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CVFListScreen(mPjpInfo: pjpInfo, isView: true)));
          // Utility.showMessageSingleButton(
          //     context,
          //     'This pjp is not approved yet, Please connect with your manager',
          //     this);
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
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
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
                    ElevatedButton(
                        style: ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.all(5))),
                        onPressed: () async {
                          var hiveBox = await Utility.openBox();
                          await Hive.openBox(LocalConstant.KidzeeDB);

                          String employeeCode = hiveBox
                              .get(LocalConstant.KEY_EMPLOYEE_CODE) as String;
                          debugPrint('Employee code is - $employeeCode');
                          Utils.isExternal = true;
                          showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                    child: AddAdvanceRequisitionPage(
                                      e_id: employeeCode,
                                      pjpId: pjpInfo.PJP_Id,
                                    ),
                                  ));
                        },
                        child: Text(
                          'Add Advance',
                          style: LightColors.smallTextStyle
                              .copyWith(color: Colors.white),
                        )),
                  ],
                ),
              ),
              /*Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 1,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F4F8),
                ),
              ),*/
              ListTile(
                title: Padding(
                  padding: EdgeInsetsDirectional.all(0),
                  child: Text(
                    'Date : ${Utility.getShortDate(pjpInfo.fromDate)} to ${Utility.getShortDate(pjpInfo.toDate)}',
                    style: const TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Color(0xFF090F13),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                subtitle: /*Expanded(
                  flex: 1,
                  child:*/
                    Text(
                  'Remark : ${pjpInfo.remarks}',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF95A1AC),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                //),
                trailing: /*pjpInfo.isSelfPJP=='0' && pjpInfo.ApprovalStatus =='Pending'? OutlinedButton(
                  onPressed: () {
                    if (pjpInfo.isSelfPJP=='0' || widget.mFilterSelection.type == FILTERStatus.MYSELF && pjpInfo.ApprovalStatus =='Approved') {
                      Utility.showMessageMultiButton(context,'Approve','Reject', 'PJP : ${pjpInfo.PJP_Id}', 'Are you sure to approve the PJP, created by ${pjpInfo.displayName}',pjpInfo, this);
                    }else{
                      Utility.showMessages(context, 'Please wait Your manager need to approve the PJP');
                    }
                  },
                  child: Checkbox(
                    checkColor: Colors.black,
                    activeColor: LightColors.kLavender,
                    value: _isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked[index] = value!;
                        //singleSelection(position);
                      });
                    },
                  ) */ /*Text(
                    'Approve',
                    style: TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Color(0xFF4B39EF)  ,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )*/ /*,
                ) : */
                    pjpInfo.ApprovalStatus == 'Approved'
                        ? Image.asset(
                            'assets/icons/ic_checked.png',
                            height: 50,
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
                              if (pjpInfo.ApprovalStatus != 'Approved' &&
                                  pjpInfo.ApprovalStatus != 'Rejected')
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddCVFScreen(
                                                mPjpModel: pjpInfo,
                                              )),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 15),
                                    child: Card(
                                      color: kPrimaryLightColor,
                                      elevation: 5,
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10, 10, 10, 10),
                                        child: Text(
                                          'ADD CVF',
                                          style: TextStyle(
                                            fontFamily: 'Lexend Deca',
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
        }
      }
      IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
    }
  }

  @override
  void onError(value) {
    isLoading = false;
    setState(() {});
    //Navigator.of(context).pop();
  }

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  String getId() {
    return '${businessId}${employeeId.toString()}${LocalConstant.KEY_MY_PJP}';
  }

  savePJPLocally(String json) async {
    if (hiveBox == null) {
      hiveBox = await Hive.openBox(LocalConstant.KidzeeDB);
    }
    hiveBox.put(getId(), json);
  }

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();
    isLoading = false;
    if (value is String) {
      IntranetServiceHandler.loadPjpSummery(employeeId, 0, businessId, this);
    } else if (value is UpdatePJPStatusResponse) {
      UpdatePJPStatusResponse val = value;
      if (val.responseData == 0) {
        //rejected
        Utility.getRejectionDialog(
            context, 'Rejected', 'The Pjp is rejected by you..', this);
      } else {
        Utility.getConfirmationDialogPJP(context, this);
      }
    } else if (value is PjpListResponse) {
      PjpListResponse response = value;
      String json = jsonEncode(response);
      print(json);
      savePJPLocally(json);
      isLoading = false;
      mPjpList.clear();
      if (response.responseData != null && response.responseData.length > 0) {
        if (response != null && response.responseData != null) {
          if (widget.mFilterSelection == null ||
              widget.mFilterSelection.type == FILTERStatus.MYTEAM) {
            debugPrint('FOR MY TEAM');
            for (int index = 0; index < response.responseData.length; index++) {
              if (response.responseData[index].isSelfPJP == '0') {
                for (int jIndex = 0;
                    jIndex < widget.mFilterSelection.filters.length;
                    jIndex++) {
                  if (widget.mFilterSelection.filters[jIndex].isSelected &&
                      response.responseData[index].displayName.trim() ==
                          widget.mFilterSelection.filters[jIndex].name.trim()) {
                    mPjpList.add(response.responseData[index]);
                  }
                }
              }
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
            debugPrint('In else');
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
          _isChecked = List<bool>.filled(mPjpList.length, false);
        }
      }
    }
    print(mPjpList.length);
    setState(() {
      isLoading = false;
    });
  }

  void approvePjp(PJPInfo pjpInfo, int isApprove) {
    UpdatePJPStatusRequest request = UpdatePJPStatusRequest(
        PJP_id: int.parse(pjpInfo.PJP_Id),
        Is_Approved: isApprove,
        Workflow_user: employeeId.toString());
    IntranetServiceHandler.updatePJPStatus(request, this);
  }

/*  void approvePjpList() {
    StringBuffer DocXML = new StringBuffer("<root>");
    for(int index=0;index<mPjpList.length;index++){
      if(mPjpList[index].ApprovalStatus)
    //<subroot><PJP_id>135</PJP_id><Is_Approved>0</Is_Approved></subroot><subroot><PJP_id>136</PJP_id><Is_Approved>1</Is_Approved></subroot>
    }
    DocXML.write("</root>");
    UpdatePJPStatusListRequest request = UpdatePJPStatusListRequest(DocXML: DocXML, Workflow_user: Workflow_user)
    IntranetServiceHandler.updatePJPStatusList(request, this);
  }*/

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
