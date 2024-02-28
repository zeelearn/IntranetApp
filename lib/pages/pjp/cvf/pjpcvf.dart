import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LightColor.dart';
import 'package:Intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:location/location.dart';
import 'package:order_tracker_zen/order_tracker_zen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../api/ServiceHandler.dart';
import '../../../api/request/cvf/update_cvf_status_request.dart';
import '../../../api/response/cvf/update_status_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../firebase/anylatics.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/LocationHelper.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../iface/onResponse.dart';
import '../../utils/theme/colors/light_colors.dart';
import 'add_cvf.dart';

class CVFListScreen extends StatefulWidget {
  PJPInfo mPjpInfo;

  CVFListScreen({Key? key, required this.mPjpInfo}) : super(key: key);


  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<CVFListScreen> implements onResponse,onClickListener{
  int employeeId = 0;
  int businessId = 0;
  List<GetDetailedPJP> mCvfList = [];
  bool isLoading = true;
  bool isInternet=true;
  Map<String,String> offlineStatus=Map();

  final int FILTER_ALL =0;
  final int FILTER_COMPLETED =1;
  final int FILTER_CHECKIN =2;
  final int FILTER_FILL =3;

  int mFilterSelection=0;
  var hiveBox;

  //FilterSelection mFilterSelection = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      this.getUserInfo();
    });
  }


  Future<void> getUserInfo() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId =  hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    isInternet = await Utility.isInternet();
    DBHelper helper=DBHelper();
    offlineStatus = await helper.getCheckInStatus();
    if(isInternet){
      this.loadAllCVF();
    }else{
      if(!getLocalData()){
        this.loadAllCVF();
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = hiveBox.get(getId());
      isLoading = false;
      mCvfList.clear();
      PjpListResponse response = PjpListResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null)
        for (int index = 0; index < response.responseData.length; index++) {
          mCvfList
              .addAll(response.responseData[index].getDetailedPJP!);
        }
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  String getId(){
    if(widget.mPjpInfo.PJP_Id.isNotEmpty){
      return '${employeeId.toString()}_${LocalConstant.KEY_MY_CVF}_${widget.mPjpInfo.PJP_Id}';
    }
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_CVF}';
  }

  saveCVFLocally(String json) async{
    hiveBox.put(getId(), json);
  }

  loadAllCVF() {
    IntranetServiceHandler.loadPjpSummery(
        employeeId, int.parse(widget.mPjpInfo.PJP_Id),businessId, this);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyCVF');
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("My CVF"),
          actions:   <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {
                showModel();
              },
            ),
             IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'ADD CVF',
              onPressed: () {
                goToSecondScreen(context);
              }
            ) , //IconButton
          ] ,
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
              loadAllCVF();
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                getCVFListView(),
              ],
            ),
          ),
        ));
  }

  void goToSecondScreen(BuildContext context) async {
    /*var result = await Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new FiltersScreen(),
      fullscreenDialog: true,)
    );*/
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCVFScreen(
            mPjpModel: widget.mPjpInfo,
          )),
    );
    IntranetServiceHandler.loadPjpSummery(
        employeeId, int.parse(widget.mPjpInfo.PJP_Id),businessId, this);
  }

  getCVFListView() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (mCvfList.isEmpty) {
      return Utility.emptyDataSet(context,"your CVF list is Empty");
    } else {


      List<GetDetailedPJP> list = [];
      list.addAll(mCvfList);

      if(mFilterSelection==FILTER_COMPLETED){
        list.clear();
        for(int index=0;index<mCvfList.length;index++){
          if(mCvfList[index].Status=='Completed'){
            list.add(mCvfList[index]);
          }
        }
      }else if(mFilterSelection==FILTER_CHECKIN){
        list.clear();
        for(int index=0;index<mCvfList.length;index++){
          if(mCvfList[index].Status.trim()=='Check In'){
            list.add(mCvfList[index]);
          }
        }
      }else if(mFilterSelection==FILTER_FILL){
        list.clear();
        for(int index=0;index<mCvfList.length;index++){
          if(mCvfList[index].Status=='FILL CVF'){
            list.add(mCvfList[index]);
          }
        }
      }
      list = list.reversed.toList();
      return Flexible(
          child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return getCvfView(list[index]);
        },
      ));
    }
  }

  showModel(){
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.select_all),
                title: new Text('All'),
                onTap: () {
                  mFilterSelection = FILTER_ALL;
                  Navigator.pop(context);
                  setState(() {

                  });
                },
              ),
              ListTile(
                leading: new Icon(Icons.check),
                title: new Text('Completed'),
                onTap: () {
                  mFilterSelection = FILTER_COMPLETED;
                  Navigator.pop(context);
                  setState(() {

                  });
                },
              ),
              ListTile(
                leading: new Icon(Icons.add_chart_sharp),
                title: new Text('Check In'),
                onTap: () {
                  mFilterSelection = FILTER_CHECKIN;
                  Navigator.pop(context);
                  setState(() {

                  });
                },
              ),
              ListTile(
                leading: new Icon(Icons.pending_actions_sharp),
                title: new Text('FILL CVF'),
                onTap: () {
                  mFilterSelection = FILTER_FILL;
                  Navigator.pop(context);
                  setState(() {

                  });
                },
              ),
            ],
          );
        });
  }

  getList(GetDetailedPJP cvfView){
    List<Widget> _widgetlist = [];
    for(int index=0;index<cvfView.purpose!.length;index++){
      _widgetlist.add(ListTile(
        title: Container(
          margin: EdgeInsets.all(5),
          child: new Text(cvfView.purpose![index].categoryName),
        ),
        onTap: () {
          Navigator.pop(context);
          navigateQuestions(cvfView, cvfView.purpose![index].categoryId,cvfView.purpose![index].categoryName);
        },
      ),);
    }
    return _widgetlist;
  }
  getCategoryBottomList(GetDetailedPJP cvfView,int index){
    if(index==0){
      return Container(color: kPrimaryLightColor,
      child: Padding(padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Center(
                child: const Text('Select Category',style: TextStyle(
                    fontStyle: FontStyle.normal,
                    color: Colors.white,
                    letterSpacing: 0.4,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
                ),
              ),
            ],)
          )
      ,);
    }else
    return ListTile(
      title: Container(
        margin: EdgeInsets.all(5),
        child: new Text(cvfView.purpose![index-1].categoryName),
      ),
      onTap: () {
        Navigator.pop(context);
        navigateQuestions(cvfView, cvfView.purpose![index-1].categoryId,cvfView.purpose![index-1].categoryName);
      },
    );
  }

  selectCategory(BuildContext context,GetDetailedPJP cvfView) async{
    if(cvfView.purpose!.length==0){
      //return '';
      Utility.showMessageSingleButton(context, 'Category Not mapped for this CVF, Please create another CVF', this);
    }else if(cvfView.purpose!.length==1){
      navigateQuestions(cvfView, cvfView.purpose![0].categoryId,cvfView.purpose![0].categoryName);
    }else{
      showModalBottomSheet(
        useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (context) {
              return FractionallySizedBox(

                child: ListView.builder(
                      itemCount: cvfView.purpose!.length+1,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return getCategoryBottomList(cvfView,index);
                      },
                    ),
              );
            });
    }
  }
  navigateQuestions(GetDetailedPJP cvfView,String categoryId,String categoryName){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuestionListScreen(
            cvfView: cvfView,
            PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
            employeeId: employeeId,
            mCategory: categoryName,
            mCategoryId: categoryId,
            isViewOnly: widget.mPjpInfo.isSelfPJP=='0' ? true : false,
          )),
    );
  }

  getCheckInCheckOut(GetDetailedPJP cvfInfo){
    List<TrackerData> list =[];
    list.add(getCheckInOutValues('Check In', cvfInfo.CheckInAddress, Utility.getShortDateTime(cvfInfo.DateTimeIn)));
    if(cvfInfo.Status.toString().toLowerCase().contains('comp') && cvfInfo.CheckOutAddress.isNotEmpty)
      list.add(getCheckInOutValues('Check Out', cvfInfo.CheckOutAddress, Utility.getShortDateTime(cvfInfo.DateTimeOut)));
    return list;
  }

  getCheckInOutValues(String status,String address,String date){
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

  getTimeLine(GetDetailedPJP cvfInfo){
    if(cvfInfo.CheckInAddress.isEmpty || cvfInfo.Status.toString().contains('Check In')){
      return SizedBox(width: 0,);
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

  getCvfView(GetDetailedPJP cvfView) {
    if(cvfView.Status.trim()=='NA'){
      cvfView.Status = 'Check In';
    }
    if(offlineStatus.containsKey(cvfView.PJPCVF_Id.toString())){
      cvfView.Status = offlineStatus[cvfView.PJPCVF_Id].toString();
    }
    return GestureDetector(
      onTap: () {
        if(widget.mPjpInfo.isSelfPJP=='0'){
          selectCategory(context, cvfView);
        }else if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          Utility.onConfirmationBox(context,'Check In','Cancel', 'PJP Status Update?', 'Would you like to Check In?',cvfView, this);
        }else if(cvfView.Status =='Completed'){
          selectCategory(context, cvfView);
        }else if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');

        } else {

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
                              '${Utility.shortDate(
                                  Utility.convertServerDate(cvfView.visitDate))}',
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
                                  '${Utility.shortTime(
                                      Utility.convertTime(cvfView.visitTime))} ${Utility.shortTimeAMPM(
                                      Utility.convertTime(cvfView.visitTime))}',
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
                    cvfView.ActivityTitle.isEmpty || cvfView.ActivityTitle=='NA' ? cvfView.franchiseeName : cvfView.ActivityTitle,
                    style: const TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Color(0xFF090F13),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                subtitle:  Text(
                  cvfView.Address=='Search Location' ? cvfView.franchiseeCode:
                  cvfView.Address.length < 50 ? cvfView.Address : cvfView.Address.substring(0,50)+'..',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: LightColor.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                trailing: cvfView.Status =='Check Out' ? OutlinedButton(
                  onPressed: () {
                    selectCategory(context, cvfView);
                  },
                  child: Text(
                    cvfView.Status,
                    style: TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Color(0xFF4B39EF)  ,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ) : cvfView.Status=='Completed' ? Image.asset(
                  'assets/icons/ic_checked.png',
                  height: 50,
                ) : Text(
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
                      )
                  ),
                ) ,
              ),
              getTimeLine(cvfView)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getCategoryList(GetDetailedPJP cvfView){
    List<Widget> list = [];
    for(int index=0;index<cvfView.purpose!.length;index++){
      list.add(getTextCategory(cvfView, cvfView.purpose![index].categoryName,index==0?true : false));
      if(index>=2){
        list.add(getTextCategory(cvfView, 'more..',index==0?true : false));
        break;
      }
    }
    return list;
  }

  getView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
        } else {
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
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Utility.shortDate(
                                  Utility.convertServerDate(cvfView.visitDate)),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  Utility.shortTime(
                                      Utility.convertTime(cvfView.visitTime)),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  Utility.shortTimeAMPM(
                                      Utility.convertTime(cvfView.visitTime)),
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 5, child: getview(cvfView)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getCategoryView(GetDetailedPJP cvfView) {
    if (cvfView.purpose!.isEmpty) {
      return Text('No Category Found');
    } else {
      return Flexible(
          child: ListView.builder(
            reverse: true,
            itemCount: 2,
            shrinkWrap: false,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Text('${cvfView.purpose![index].categoryName} ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    background: Paint()
                      ..color = Colors.blue
                      ..strokeWidth = 20
                      ..strokeJoin = StrokeJoin.round
                      ..strokeCap = StrokeCap.round
                      ..style = PaintingStyle.stroke,
                    color: Colors.white,
                  ));
            },
          ));
    }
  }

  getview(final GetDetailedPJP cvfView) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Text(
                  cvfView.franchiseeCode != 'NA'
                      ? 'Fran Code : ${cvfView.franchiseeCode}'
                      : '',
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
                  'Ref Id : C-${cvfView.PJPCVF_Id}',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 30,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          cvfView.franchiseeName != 'NA'
                              ? '${cvfView.franchiseeName}'
                              : '${cvfView.Address}',
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF090F13),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cvfView.franchiseeName != 'NA' || cvfView.franchiseeName != ' NA'
                            ? 'PJP Remark - '
                            : 'Activity Name ',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: /*Flexible(
                        child: */Text(
                            cvfView.franchiseeName != 'NA' || cvfView.franchiseeName != ' NA'
                                ? ''
                                : '${cvfView.ActivityTitle}',
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal)),
                      ),
                    /*),*/
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: getTextRounded(cvfView, 'Fill CVF')),
          ],
        ),
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: LightColors.kLightGray,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Colors.white70,
                offset: Offset(0, 1),
              )
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child:
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: LightColors.kLightGray,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.white70,
                        offset: Offset(0, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(' Category '),
                      cvfView.purpose!.length > 0
                          ? getTextCategory(
                          cvfView, cvfView.purpose![0].categoryName,true)
                          : Text(''),
                      cvfView.purpose!.length > 1
                          ? getTextCategory(
                          cvfView, cvfView.purpose![1].categoryName,false)
                          : Text(''),
                      cvfView.purpose!.length > 2
                          ? getTextCategory(
                          cvfView, cvfView.purpose![2].categoryName,false)
                          : Text(''),
                      cvfView.purpose!.length > 3
                          ? getTextCategory(
                          cvfView, cvfView.purpose![3].categoryName,false)
                          : Text(''),
                      cvfView.purpose!.length > 4
                          ? getTextCategory(
                          cvfView, cvfView.purpose![4].categoryName,false)
                          : Text(''),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }

  getTextCategory(GetDetailedPJP cvfView, String categoryname,bool isfirst) {
    return
      GestureDetector(
        onTap: () {
          if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
            Utility.showMessage(context, 'Please Click on Check In button');
          } else {
            selectCategory(context, cvfView);
          }
        },
        child: Padding(
          padding:
          EdgeInsets.only(left: isfirst ? 0 :10),
          child: Text('${categoryname}',
              textAlign: TextAlign.center,
              style: TextStyle(
                /*background: Paint()
                  ..color = LightColors.kLightRed
                  ..strokeWidth = 18
                  ..strokeJoin = StrokeJoin.round
                  ..strokeCap = StrokeCap.round
                  ..style = PaintingStyle.stroke,*/
                color: Color(0xFF4B39EF),
              )),
        ),
      );
  }



  getTextRounded(GetDetailedPJP cvfView, String name) {

    if(offlineStatus.containsKey(cvfView.PJPCVF_Id.toString())){
      cvfView.Status = offlineStatus[cvfView.PJPCVF_Id].toString();
    }

    return GestureDetector(
      onTap: () {
        if(cvfView.Status =='Completed'){
          Utility.showMessageSingleButton(context, 'The PJP is Already Completed', this);
        }else if(cvfView.Status =='Check Out'){
          selectCategory(context, cvfView);
          Utility.showMessageSingleButton(context, 'Please Fill All questions and check out', this);
        }else if (cvfView.Status == 'FILL CVF') {
          selectCategory(context, cvfView);
        } else {
          _showMyDialog(cvfView);
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

  updateCVF(GetDetailedPJP cvfView) async{
    isInternet = await Utility.isInternet();
    if(isInternet){
      //online
      IntranetServiceHandler.updateCVFStatus(
          employeeId,
          cvfView,
          Utility.getDateTime(),
          getNextStatus(cvfView.Status),
          this);
    }else{
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
    double latitude=0.0;
    double longitude=0.0;
    LocationData location = await LocationHelper.getLocation(context);
    if(location!=null){
      latitude = location.latitude!;
      longitude = location.longitude!;
    }
    print('pjpcvf ');
    String address = await Utility.getAddress(latitude, longitude);
    print('pjpcvf ${address}');
      UpdateCVFStatusRequest request = UpdateCVFStatusRequest(
          PJPCVF_id: cvfView.PJPCVF_Id,
          DateTime: Utility.getDateTime(),
          Status: cvfView.Status,
          Employee_id: employeeId,
          Latitude: cvfView.Status=='FILL CVF' ? cvfView.Latitude : latitude,
          Longitude: cvfView.Status=='FILL CVF' ? cvfView.Longitude : longitude,
          Address: address,
          CheckOutLatitude: cvfView.Status=='Completed' ? latitude : 0.0,
          CheckOutLongitude: cvfView.Status=='Completed' ? longitude : 0.0,
          CheckOutAddress: cvfView.Status=='Completed' ? address : '');

      DBHelper helper = DBHelper();
      helper.insertCheckIn(
          cvfView.PJPCVF_Id, jsonEncode(request.toJson()), getNextStatus(cvfView.Status), 0);
      Navigator.of(context).pop();

      offlineStatus = await helper.getCheckInStatus();
      if(!getLocalData()){
        this.loadAllCVF();
      }
      setState(() {

      });
      Utility.onSuccessMessage(context,'Status Updated','Thanks for updating the CVF status', this);

  }

  Future<void> _showMyDialog(GetDetailedPJP cvfView) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CVF Update Status'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                /*Text('This is a demo alert dialog.'),*/
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
                /*IntranetServiceHandler.updateCVFStatus(
                    employeeId,
                    cvfView.PJPCVF_Id,
                    Utility.getDateTime(),
                    getNextStatus(cvfView.Status),
                    this);*/
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
    isLoading=false;
    setState(() {

    });
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
      Utility.onSuccessMessage(context,'Status Updated','Thanks for updating the CVF status', this);
    }else if (value is PjpListResponse) {
      PjpListResponse response = value;
      isLoading=false;

      if (response.responseData != null && response.responseData.length > 0) {
        String json = jsonEncode(response);
        saveCVFLocally(json);
        mCvfList.clear();
        for (int index = 0; index < response.responseData.length; index++) {
          mCvfList
              .addAll(response.responseData[index].getDetailedPJP!);
        }
        setState(() {
          //mPjpList.addAll(response.responseData);
        });

      }
    } else if (value is PjpListResponse) {
      PjpListResponse response = value;
      if (response.responseData != null && response.responseData.length > 0) {
        this.loadAllCVF();
      }
    }else if(value is String){
      this.loadAllCVF();
    }
    setState(() {

    });
  }

  @override
  void onClick(int action, value) {
    if(value is GetDetailedPJP) {
      Navigator.of(context).pop();
      GetDetailedPJP cvfView = value;
      if (action == Utility.ACTION_OK) {
        updateCVF(cvfView);
      } else if (action == Utility.ACTION_CCNCEL) {

      }
    }
  }

}
