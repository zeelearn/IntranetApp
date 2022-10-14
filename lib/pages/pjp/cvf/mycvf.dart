import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intranet/api/request/cvf/get_cvf_request.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/ServiceHandler.dart';
import '../../../api/request/cvf/update_cvf_status_request.dart';
import '../../../api/response/cvf/get_all_cvf.dart';
import '../../../api/response/cvf/update_status_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../firebase/anylatics.dart';
import '../../helper/LightColor.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../iface/onResponse.dart';
import '../../utils/theme/colors/light_colors.dart';
import 'CheckInModel.dart';

class MyCVFListScreen extends StatefulWidget {

  MyCVFListScreen({Key? key}) : super(key: key);

  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<MyCVFListScreen> implements onResponse,onClickListener{
  int employeeId = 0;
  List<GetDetailedPJP> mCvfList = [];
  bool isLoading = true;
  bool isInternet=true;
  late final prefs;
  Map<String,String> offlineStatus=Map();
  late GetDetailedPJP McvfView;

  //FilterSelection mFilterSelection = FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('int init state');
    Future.delayed(Duration.zero, () {
      this.getUserInfo();

    });

  }


  Future<void> getUserInfo() async {
    prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
      loadData();
  }

  loadData() async{
    isInternet = await Utility.isInternet();
    DBHelper helper=DBHelper();
    //helper.getCheckInStatus();
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
      var attendanceList = prefs.getString(getId());
      isLoading = false;
      print(attendanceList.toString());
      GetAllCVFResponse response = GetAllCVFResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null)
        mCvfList.addAll(response.responseData);
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  String getId(){
    return '${employeeId.toString()}_${LocalConstant.KEY_MY_CVF}';
  }

  saveCVFLocally(String json) async{

    prefs.setString(getId(), json);
  }

  loadAllCVF() {
    isLoading = true;
    Utility.showLoaderDialog(context);
    mCvfList.clear();
    GetAllCVF request = GetAllCVF(Employee_id: employeeId);
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
          }
          print('pjp list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      setState(() {
        //mPjpList.addAll(response.responseData);
      });
      Navigator.of(context).pop();

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
          /*actions: <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'ADD CVF',
              onPressed: () {
                goToSecondScreen(context);
              },
            ), //IconButton
          ],*/
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
              //loadPjpSummery();
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

  getCVFListView() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else if (mCvfList.isEmpty) {
      return Utility.emptyDataSet(context,"your CVF list is Empty");
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

  getCvfView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
          Utility.onConfirmationBox(context,'Check In','Cancel', 'PJP Status Update?', 'Would you like to Check In?',cvfView, this);
        }else if(cvfView.Status =='Completed'){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  mCategory: 'All',
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategoryId: cvfView.purpose![0].categoryId,
                  isViewOnly: false,
                )),
          );
          //Utility.showMessageSingleButton(context, 'The Center Visit Form is already submitted, Now you can only view the CVF', this);

        }else if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  mCategory: 'All',
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategoryId: cvfView.purpose![0].categoryId,
                  isViewOnly: false,
                )),
          );
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
                    cvfView.ActivityTitle=='NA' ? cvfView.franchiseeName : cvfView.ActivityTitle,
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuestionListScreen(
                              cvfView: cvfView,
                              PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                              employeeId: employeeId,
                              mCategory: 'All',
                              mCategoryId: cvfView.purpose![0].categoryId,
                              isViewOnly: false,
                            )));
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 0, 4, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
            ],
          ),
        ),
      ),
    );
  }

  /*getView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          //Utility.showMessage(context, 'Please Click on Check In button');
          Utility.onConfirmationBox(context,'Check In','Cancel', 'PJP Status Update?', 'Would you like to Check In?',cvfView, this);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  mCategory: 'All',
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategoryId: cvfView.purpose![0].categoryId,
                )),
          );
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
                                  Utility.shortTimeAMPM(Utility.convertTime(cvfView.visitTime)),
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
  }*/

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
              return Text('${cvfView.purpose![0].categoryName} ',
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

  /*getview(final GetDetailedPJP cvfView) {
    print(cvfView.Status);
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
                      child: *//*Flexible(
                        child: *//*Text(
                            cvfView.franchiseeName != 'NA' || cvfView.franchiseeName != ' NA'
                                ? ''
                                : '${cvfView.ActivityTitle}',
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal)),
                      ),
                    *//*),*//*
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
                          cvfView, cvfView.purpose![0].categoryName)
                          : Text(''),
                      cvfView.purpose!.length > 1
                          ? getTextCategory(
                          cvfView, cvfView.purpose![1].categoryName)
                          : Text(''),
                      cvfView.purpose!.length > 2
                          ? getTextCategory(
                          cvfView, cvfView.purpose![2].categoryName)
                          : Text(''),
                      cvfView.purpose!.length > 3
                          ? getTextCategory(
                          cvfView, cvfView.purpose![3].categoryName)
                          : Text(''),
                      cvfView.purpose!.length > 4
                          ? getTextCategory(
                          cvfView, cvfView.purpose![4].categoryName)
                          : Text(''),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }*/



  getTextCategory(GetDetailedPJP cvfView, String categoryname,bool isfirst) {
    return
      GestureDetector(
        onTap: () {
          if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
            Utility.showMessage(context, 'Please Click on Check In button');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuestionListScreen(
                    cvfView: cvfView,
                    PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                    employeeId: employeeId,
                    mCategory: categoryname,
                    mCategoryId: cvfView.purpose![0].categoryId,
                    isViewOnly: false,
                  )),
            );
          }
        },
        child: Padding(
          padding:
          EdgeInsets.only(left: isfirst ? 0 :10),
          child: Text('${categoryname}',
              textAlign: TextAlign.center,
              style: TextStyle(
               /* background: Paint()
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
      print('Status get it from Offline ${cvfView.Status}  ${cvfView.PJPCVF_Id}');
    }else{
      print(' ${cvfView.PJPCVF_Id} key not found');
    }

    return GestureDetector(
      onTap: () {
        if(cvfView.Status =='Completed'){
          Utility.showMessageSingleButton(context, 'The PJP is Already Completed', this);
        }else if(cvfView.Status =='Check Out'){

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategory: 'All',
                  mCategoryId: cvfView.purpose![0].categoryId,
                  isViewOnly: false,
                )),
          );
          Utility.showMessageSingleButton(context, 'Please Fill All questions and check out', this);
        }else if (cvfView.Status == 'FILL CVF') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategory: 'All',
                  mCategoryId: cvfView.purpose![0].categoryId,
                  isViewOnly: false,
                )),
          );
        } else {
          Utility.onConfirmationBox(context,'Check In','Cancel', 'PJP Status Update?', 'Would you like to Check In?',cvfView, this);
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

  updateCVF(GetDetailedPJP cvfView) async{
    isInternet = await Utility.isInternet();
    if(isInternet){
      //online
      print('internet avaliabnle');
      IntranetServiceHandler.updateCVFStatus(
          employeeId,
          cvfView.PJPCVF_Id,
          Utility.getDateTime(),
          getNextStatus(cvfView.Status),
          this);
      McvfView = cvfView;

    }else{
      print('internet not avaliabnle');
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
    if (await Permission.location.request().isGranted) {
      print('Status is ${cvfView.Status}');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      UpdateCVFStatusRequest request = UpdateCVFStatusRequest(
          PJPCVF_id: cvfView.PJPCVF_Id,
          DateTime: Utility.getDateTime(),
          Status: cvfView.Status,
          Employee_id: employeeId,
          Latitude: position.latitude,
          Longitude: position.longitude);
      print('Data saved locally....');
      print(request.toJson());
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
    }else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
      print(statuses[Permission.location]);
    }
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
    } else if (value is PjpListResponse) {
      PjpListResponse response = value;
      print('onResponse in if ');
      if (response.responseData != null && response.responseData.length > 0) {
        saveDataOffline(McvfView);
        loadData();
      } else {
        print('onResponse in if else');
      }
    }else if(value is String){
      this.loadData();
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
