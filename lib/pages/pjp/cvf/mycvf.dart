import 'dart:async';
import 'dart:convert';

import 'package:Intranet/api/request/cvf/get_cvf_request.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:order_tracker_zen/order_tracker_zen.dart';

import '../../../api/APIService.dart';
import '../../../api/ServiceHandler.dart';
import '../../../api/request/cvf/update_cvf_status_request.dart';
import '../../../api/response/cvf/get_all_cvf.dart';
import '../../../api/response/cvf/update_status_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../firebase/anylatics.dart';
import '../../helper/LightColor.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/LocationHelper.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../iface/onResponse.dart';
import '../../utils/theme/colors/light_colors.dart';

class MyCVFListScreen extends StatefulWidget {
  MyCVFListScreen({Key? key}) : super(key: key);

  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<MyCVFListScreen>
    implements onResponse, onClickListener {
  int employeeId = 0;
  int businessId = 0;
  List<GetDetailedPJP> mCvfList = [];
  bool isLoading = true;
  bool isInternet = true;
  Map<String, String> offlineStatus = Map();
  late GetDetailedPJP McvfView;
  var hiveBox;
  //FilterSelection mFilterSelection = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //debugPrint('int init state My CVF');
    Future.delayed(Duration.zero, () {
      this.getUserInfo();
    });
  }

  Future<void> getUserInfo() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    loadData();
  }

  loadData() async {
    isInternet = await Utility.isInternet();
    DBHelper helper = DBHelper();
    //helper.getCheckInStatus();
    offlineStatus = await helper.getCheckInStatus();
    if (isInternet) {
      this.loadAllCVF();
    } else {
      if (!getLocalData()) {
        this.loadAllCVF();
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = hiveBox.get(getId());
      isLoading = false;
      debugPrint(attendanceList.toString());
      GetAllCVFResponse response = GetAllCVFResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null)
        mCvfList.addAll(response.responseData);
      setState(() {});
      isLoad = true;
    } catch (e) {
      isLoad = false;
    }
    return isLoad;
  }

  String getId() {
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_CVF}';
  }

  saveCVFLocally(String json) async {
    hiveBox.put(getId(), json);
  }

  loadAllCVF() {
    isLoading = true;

    Utility.showLoaderDialog(context);

    mCvfList.clear();
    GetAllCVF request =
        GetAllCVF(Employee_id: employeeId, Business_id: businessId);
    APIService apiService = APIService();
    apiService.getAllCVF(request).then((value) {
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is GetAllCVFResponse) {
          GetAllCVFResponse response = value;
          if (response != null && response.responseData != null) {
            String json = jsonEncode(response);
            saveCVFLocally(json);
            mCvfList.addAll(response.responseData);
            mCvfList.sort((a, b) {
              //sorting in descending order
              return DateTime.parse(a.visitDate)
                  .compareTo(DateTime.parse(b.visitDate));
            });
          }
          debugPrint('pjp list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      if (mounted) {
        setState(() {
          //mPjpList.addAll(response.responseData);
        });

        Navigator.of(context).pop();
      } else {
        debugPrint(
            'Screen is not mounted while loading cvf data and removing loader');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyCVF');
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("My CVF"),
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
              //loadPjpSummery();
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                getCVFListView(),
              ],
            ),
          ),
        ));
  }

  getCVFListView() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    } else if (mCvfList.isEmpty) {
      return Utility.emptyDataSet(context, "your CVF list is Empty");
    } else {
      mCvfList = mCvfList.reversed.toList();
      return Flexible(
          child: ListView.builder(
        itemCount: mCvfList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return getCvfView(mCvfList[index]);
        },
      ));
    }
  }

  List<Widget> getCategoryList(GetDetailedPJP cvfView) {
    List<Widget> list = [];
    for (int index = 0; index < cvfView.purpose!.length; index++) {
      list.add(getTextCategory(cvfView, cvfView.purpose![index].categoryName,
          index == 0 ? true : false));
      if (index >= 1) {
        list.add(getTextCategory(cvfView, 'more..', index == 0 ? true : false));
        break;
      }
    }
    return list;
  }

  getCvfView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        print(cvfView.toJson());
        if(cvfView.approvalStatus.toLowerCase().contains('reject')){
            Utility.showMessage(context, 'This PJP is rejected by your manager');
        }else if(!cvfView.approvalStatus.toLowerCase().contains('approv')){
            Utility.showMessage(context, 'PJP not yet approve, Please connect with your manager');
        }else if (cvfView.Status == 'Check In' ||
            cvfView.Status == ' Check In' ||
            cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
          Utility.onConfirmationBox(
              context,
              'Check In',
              'Cancel',
              'PJP Status Update?',
              'Would you like to Check In?',
              cvfView,
              this);
        } else if (cvfView.Status == 'Completed') {
          selectCategory(context, cvfView);

          //Utility.showMessageSingleButton(context, 'The Center Visit Form is already submitted, Now you can only view the CVF', this);
        } /* else if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
        } */
        else {
          selectCategory(context, cvfView);
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
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                            child: Icon(
                              Icons.date_range,
                              color: Color(0xFF4B39EF),
                              size: 20,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                            child: Text(
                              '${Utility.shortDate(Utility.convertServerDate(cvfView.visitDate))}',
                              style: TextStyle(
                                fontFamily: 'Lexend Deca',
                                color: Color(0xFF4B39EF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(10, 5, 0, 4),
                                child: Icon(
                                  Icons.access_time,
                                  color: Color(0xFF4B39EF),
                                  size: 15,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                                child: Text(
                                  '${Utility.shortTime(Utility.convertTime(cvfView.visitTime))} ${Utility.shortTimeAMPM(Utility.convertTime(cvfView.visitTime))}',
                                  style: TextStyle(
                                    fontFamily: 'Lexend Deca',
                                    color: Color(0xFF4B39EF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        'Ref Id : ${cvfView.PJPCVF_Id}',
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
              ListTile(
                title: Padding(
                  padding: EdgeInsetsDirectional.all(0),
                  child: Text(
                    cvfView.ActivityTitle == 'NA'
                        ? cvfView.franchiseeName
                        : cvfView.ActivityTitle,
                    style: const TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Color(0xFF090F13),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                subtitle: Text(
                  cvfView.Address == 'Search Location'
                      ? cvfView.franchiseeCode
                      : cvfView.Address.length < 50
                          ? cvfView.Address
                          : cvfView.Address.substring(0, 50) + '..',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: LightColor.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                trailing:  cvfView.approvalStatus.toLowerCase().contains('reject') ? Text(
                          'PJP Rejected',
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF4B39EF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ) : !cvfView.approvalStatus.toLowerCase().contains('approv') ? null : cvfView.Status == 'Check Out'
                    ? OutlinedButton(
                        onPressed: () {
                          selectCategory(context, cvfView);
                        },
                        child: Text(
                          cvfView.Status,
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF4B39EF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : cvfView.Status == 'Completed'
                        ? Image.asset(
                            'assets/icons/ic_checked.png',
                            height: 50,
                          )
                        : Text(
                            cvfView.Status,
                            style: TextStyle(
                              fontFamily: 'Lexend Deca',
                              color: LightColors.kRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
              ),
              Container(
                color: LightColors.kLightGray,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: getCategoryList(cvfView),
                        ),
                      )),
                ),
              ),
              getTimeLine(cvfView),
            ],
          ),
        ),
      ),
    );
  }

  getCheckInCheckOut(GetDetailedPJP cvfInfo) {
    List<TrackerData> list = [];
    list.add(getCheckInOutValues('Check In', cvfInfo.CheckInAddress,
        Utility.getShortDateTime(cvfInfo.DateTimeIn)));
    if (cvfInfo.Status.toString().toLowerCase().contains('comp') &&
        cvfInfo.CheckOutAddress.isNotEmpty)
      list.add(getCheckInOutValues('Check Out', cvfInfo.CheckOutAddress,
          Utility.getShortDateTime(cvfInfo.DateTimeOut)));
    return list;
  }

  getCheckInOutValues(String status, String address, String date) {
    return TrackerData(
      title: status,
      date: date,
      // Provide an array of TrackerDetails objects to display more details about this step.
      tracker_details: [
        // TrackerDetails contains detailed information about a specific event in the order tracking process.
        TrackerDetails(
          title: address,
          datetime: '',
        ),
      ],
    );
  }

  getTimeLine(GetDetailedPJP cvfInfo) {
    if (cvfInfo.CheckInAddress.isEmpty ||
        cvfInfo.Status.toString().contains('Check In')) {
      return SizedBox(
        width: 0,
      );
    }
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add padding around the OrderTrackerZen widget for better presentation.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            // OrderTrackerZen is the main widget of the package which displays the order tracking information.
            child: OrderTrackerZen(
              // Provide an array of TrackerData objects to display the order tracking information.
              tracker_data: getCheckInCheckOut(cvfInfo),
            ),
          ),
        ],
      ),
    );
  }

  getTextCategory(GetDetailedPJP cvfView, String categoryname, bool isfirst) {
    return GestureDetector(
      onTap: () {
        if (cvfView.Status == 'Check In' ||
            cvfView.Status == ' Check In' ||
            cvfView.Status == 'NA') {
          Utility.showMessage(context, 'Please Click on Check In button');
        } else {
          selectCategory(context, cvfView);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: isfirst ? 0 : 10),
        child: Text('${categoryname}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B39EF),
            )),
      ),
    );
  }

/*   getTextRounded(GetDetailedPJP cvfView, String name) {
    if (offlineStatus.containsKey(cvfView.PJPCVF_Id.toString())) {
      cvfView.Status = offlineStatus[cvfView.PJPCVF_Id].toString();
      debugPrint(
          'Status get it from Offline ${cvfView.Status}  ${cvfView.PJPCVF_Id}');
    } else {
      debugPrint(' ${cvfView.PJPCVF_Id} key not found');
    }

    return GestureDetector(
      onTap: () {
        debugPrint('GestureDetector====');
        if (cvfView.Status == 'Completed') {
          Utility.showMessageSingleButton(
              context, 'The PJP is Already Completed', this);
        } else if (cvfView.Status == 'Check Out') {
          selectCategory(context, cvfView);
          Utility.showMessageSingleButton(
              context, 'Please Fill All questions and check out', this);
        } else if (cvfView.Status == 'FILL CVF') {
          debugPrint('selectCategory');
          selectCategory(context, cvfView);
        } else {
          Utility.onConfirmationBox(
              context,
              'Check In',
              'Cancel',
              'PJP Status Update?',
              'Would you like to Check In?',
              cvfView,
              this);
          //_showMyDialog(cvfView);
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, // BoxShape.circle or BoxShape.retangle
            /*color: Colors.red,*/
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
              ),
            ]),
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          child: Text(cvfView.Status == 'NA' ? 'Check In' : cvfView.Status,
              textAlign: TextAlign.center,
              style: TextStyle(
                  background: Paint()
                    ..color = LightColors.kAbsent
                    ..strokeWidth = 15
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke,
                  color: Colors.black,
                  fontSize: 12)),
        ),
      ),
    );
  }
 */
  getList(GetDetailedPJP cvfView) {
    List<Widget> _widgetlist = [];
    for (int index = 0; index < cvfView.purpose!.length; index++) {
      _widgetlist.add(
        ListTile(
          title: Container(
            margin: EdgeInsets.all(5),
            child: new Text(cvfView.purpose![index].categoryName),
          ),
          onTap: () {
            Navigator.pop(context);
            navigateQuestions(cvfView, cvfView.purpose![index].categoryId,
                cvfView.purpose![index].categoryName);
          },
        ),
      );
    }
    return _widgetlist;
  }

  selectCategory(BuildContext context, GetDetailedPJP cvfView) async {
    if (cvfView.purpose!.length == 0) {
      //return '';
    } else if (cvfView.purpose!.length == 1) {
      navigateQuestions(cvfView, cvfView.purpose![0].categoryId,
          cvfView.purpose![0].categoryName);
    } else {
      showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return FractionallySizedBox(
              child: ListView.builder(
                itemCount: cvfView.purpose!.length + 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return getCategoryBottomList(cvfView, index);
                },
              ),
            );
          });
      /*showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: EdgeInsets.only(right: 15,left: 15,bottom: 15,top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('Select Category',style: TextStyle(
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.4,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              ),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: getList(cvfView)
                  )
                ],
              ),
            ) ;
          });*/
    }
  }

  getCategoryBottomList(GetDetailedPJP cvfView, int index) {
    if (index == 0) {
      return Container(
        color: kPrimaryLightColor,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Center(
                  child: const Text(
                    'Select Category',
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            )),
      );
    } else
      return ListTile(
        title: Container(
          margin: EdgeInsets.all(5),
          child: new Text(cvfView.purpose![index - 1].categoryName),
        ),
        onTap: () {
          Navigator.pop(context);
          navigateQuestions(cvfView, cvfView.purpose![index - 1].categoryId,
              cvfView.purpose![index - 1].categoryName);
        },
      );
  }

  navigateQuestions(
    GetDetailedPJP cvfView,
    String categoryId,
    String categoryName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuestionListScreen(
                cvfView: cvfView,
                PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                employeeId: employeeId,
                mCategory: categoryName,
                mCategoryId: categoryId,
                isViewOnly: false,
              )),
    );
  }

  updateCVF(GetDetailedPJP cvfView) async {
    isInternet = await Utility.isInternet();
    if (isInternet) {
      IntranetServiceHandler.updateCVFStatus(employeeId, cvfView,
          Utility.getDateTime(), getNextStatus(cvfView.Status), this);
      McvfView = cvfView;
    } else {
      debugPrint('internet not avaliabnle');
      //offline
      saveOffline(cvfView);
    }
  }

  Future<void> saveOffline(GetDetailedPJP cvfView) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Internet not avaliable'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                /*Text('This is a demo alert dialog.'),*/
                Text('Would you like to save CVF Offline'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('YES'),
              onPressed: () {
                saveDataOffline(cvfView);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  saveDataOffline(GetDetailedPJP cvfView) async {
    /*if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      latitude= position.latitude;
      longitude= position.longitude;
    }*/
    print('saveDataOffline');
    LocationData location = await LocationHelper.getLocation(context);
    debugPrint('Status is ${cvfView.Status}');
    String address = '';//await Utility.getAddress(location.latitude!, location.longitude!);
    UpdateCVFStatusRequest request = UpdateCVFStatusRequest(
        PJPCVF_id: cvfView.PJPCVF_Id,
        DateTime: Utility.getDateTime(),
        Status: cvfView.Status,
        Employee_id: employeeId,
        Latitude: cvfView.Status != 'FILL CVF'
            ? cvfView.Latitude
            : location.latitude!,
        Longitude: cvfView.Status != 'FILL CVF'
            ? cvfView.Longitude
            : location.longitude!,
        Address: address,
        CheckOutLatitude:
            cvfView.Status == 'FILL CVF' ? location.latitude! : 0.0,
        CheckOutLongitude:
            cvfView.Status == 'FILL CVF' ? location.longitude! : 0.0,
        CheckOutAddress: cvfView.Status == 'FILL CVF' ? address : '');
    debugPrint('Data saved locally....');
    debugPrint(request.toJson().toString());
    DBHelper helper = DBHelper();
    helper.insertCheckIn(cvfView.PJPCVF_Id, jsonEncode(request.toJson()),
        getNextStatus(cvfView.Status), 0);
    Navigator.of(context).pop();

    offlineStatus = await helper.getCheckInStatus();
    if (!getLocalData()) {
      this.loadAllCVF();
    }
    setState(() {});
    Utility.onSuccessMessage(
        context, 'Status Updated', 'Thanks for updating the CVF status', this);
  }

/*  Future<void> _showMyDialog(GetDetailedPJP cvfView) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CVF Update Status'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                */ /*Text('This is a demo alert dialog.'),*/ /*
                Text('Would you like to Check In CVF?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                updateCVF(cvfView);
                */ /*IntranetServiceHandler.updateCVFStatus(
                    employeeId,
                    cvfView.PJPCVF_Id,
                    Utility.getDateTime(),
                    getNextStatus(cvfView.Status),
                    this);*/ /*
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  String getNextStatus(String key) {
    String value = 'Check In';
    if (key != null)
      switch (key.trim()) {
        case 'Check In':
          value = 'FILL CVF';
          break;
        case 'NA':
          value = 'FILL CVF';
          break;
        case 'Check In':
          value = 'FILL CVF';
          break;
        case 'FILL CVF':
          value = 'Completed';
          break;
        case 'Completed':
          value = 'Check Out';
          break;
        case 'Completed':
          value = 'Check Out';
          break;
      }
    return value;
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

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();

    if (value is UpdateCVFStatusResponse) {
      UpdateCVFStatusResponse response = value;
      Utility.onSuccessMessage(context, 'Status Updated',
          'Thanks for updating the CVF status', this);
    } else if (value is PjpListResponse) {
      PjpListResponse response = value;
      debugPrint('onResponse in if ');
      if (response.responseData != null && response.responseData.length > 0) {
        saveDataOffline(McvfView);
        loadData();
      } else {
        debugPrint('onResponse in if else');
      }
    } else if (value is String) {
      // loadData();
    }
    // setState(() {});
  }

  @override
  void onClick(int action, value) {
    debugPrint(
        'click functions not implemented...... action is - $action and value is - $value');
    if (value is GetDetailedPJP) {
      Navigator.of(context).pop();
      GetDetailedPJP cvfView = value;
      if (action == Utility.ACTION_OK) {
        updateCVF(cvfView);
      } else if (action == Utility.ACTION_CCNCEL) {}
    } else {
      debugPrint('click functions not implemented......');
    }
  }
}
