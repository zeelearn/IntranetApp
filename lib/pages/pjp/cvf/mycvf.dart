import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intranet/api/request/cvf/get_cvf_request.dart';
import 'package:intranet/pages/pjp/cvf/cvf_questions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/request/pjp/get_pjp_list_request.dart';
import '../../../api/response/cvf/get_all_cvf.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../utils/theme/colors/light_colors.dart';
import '../new_pjp.dart';
import 'add_cvf.dart';

class MyCVFListScreen extends StatefulWidget {

  MyCVFListScreen({Key? key}) : super(key: key);

  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<MyCVFListScreen> {
  int employeeId = 0;
  List<GetDetailedPJP> mCvfList = [];
  bool isLoading = true;

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
    final prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
    this.loadAllCVF();
  }

  loadAllCVF() {
    isLoading = true;
    Utility.showLoaderDialog(context);
    mCvfList.clear();
    GetAllCVF request = GetAllCVF(Employee_id: employeeId);
    APIService apiService = APIService();
    print(request.toJson());
    apiService.getAllCVF(request).then((value) {
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is GetAllCVFResponse) {
          GetAllCVFResponse response = value;
          if (response != null && response.responseData != null) {
            mCvfList.addAll(response.responseData);
            setState(() {
              //mPjpList.addAll(response.responseData);
            });

          }
          print('pjp list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();

    });
  }

  @override
  Widget build(BuildContext context) {
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
      return GestureDetector(
        onTap: () {
          /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddCVFScreen(
                      mPjpModel: '',
                    )),
          );*/
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Image.asset(
                'assets/icons/ic_add_new.png',
              ),
              SizedBox(
                height: 10,
              ),
              const Text(
                "CVF Detasils are not avaliable",
                style: TextStyle(
                    color: LightColors.kLightGray,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      );
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: mCvfList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return getView(mCvfList[index]);
        },
      ));
    }
  }

  getView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionListScreen(cvfView: cvfView, mCategory: 'All', PJPCVF_Id: int.parse(cvfView.PJPCVF_Id), employeeId: employeeId,mCategoryId: cvfView.purpose![0].categoryId,)),
        );
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
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
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
        itemCount: 2,
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Text('${cvfView.purpose![index].categoryName} ',textAlign: TextAlign.center,
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
                  cvfView.franchiseeCode!=  'NA' ? 'Fran Code : ${cvfView.franchiseeCode}' : '',
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
                  'Ref Id :  C-${cvfView.PJPCVF_Id}',
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
        /*Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 1,
          decoration: BoxDecoration(
            color: Color(0xFFF1F4F8),
          ),
        ),*/
        Row(
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
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          cvfView.franchiseeCode!=  'NA' ? '${cvfView.franchiseeName}' : cvfView.Address,
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
                        cvfView.franchiseeCode!=  'NA' ? 'PJP Remark - ' : 'Activity Name ',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ) ,
                    ),
                    /*Align(
                      alignment: Alignment.centerLeft,
                      child:
                      Flexible(
                        child: Text(cvfView.franchiseeCode!=  'NA' ? '${widget.mPjpInfo.remarks}' : '${cvfView.ActivityTitle}',
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal)),
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: getTextRounded(cvfView, 'Mark Complete')),
          ],
        ),


        /*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
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
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
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
        ),*/
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  cvfView.purpose!.length > 0
                      ? getTextCategory(
                      cvfView, cvfView.purpose![0].categoryName,cvfView.purpose![0].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 1
                      ? getTextCategory(
                      cvfView, cvfView.purpose![1].categoryName,cvfView.purpose![1].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 2
                      ? getTextCategory(
                      cvfView, cvfView.purpose![2].categoryName,cvfView.purpose![2].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 3
                      ? getTextCategory(
                      cvfView, cvfView.purpose![3].categoryName,cvfView.purpose![3].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 4
                      ? getTextCategory(
                      cvfView, cvfView.purpose![4].categoryName,cvfView.purpose![4].categoryId)
                      : Text(''),
                ],
              ),
            )),

        /*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: Icon(
                  Icons.category,
                  color: Color(0xFF4B39EF),
                  size: 20,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Text(
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
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
        ),*/
      ],
    );
  }


  getTextRounded(GetDetailedPJP cvfView, String name) {
    return GestureDetector(
      onTap: () {
        /*if(cvfView.Status =='FILL CVF'){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: employeeId,
                  mCategory: 'All',
                  mCategoryId: cvfView.purpose![0].categoryId,
                )),
          );
        }else {
          _showMyDialog(cvfView);

        }*/
      },
      child: Container(
        margin: EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, // BoxShape.circle or BoxShape.retangle
            /*color: Colors.red,*/
            boxShadow: [BoxShadow(
              color: Colors.grey,
              blurRadius: 10.0,
            ),]
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          child: Text(cvfView.Status =='NA' ? 'Check In' : cvfView.Status,
              textAlign: TextAlign.center,
              style: TextStyle(
                /*shadows:  <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: LightColors.kLightRed,
                      ),
                    ],*/
                  background: Paint()
                    ..color = LightColors.kAbsent
                    ..strokeWidth = 15
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke,
                  color: Colors.black,
                  fontSize: 12
              )),
        ),
      ),
    );
  }

  /*getTextCategory(GetDetailedPJP cvfView, String categoryname) {
    return GestureDetector(
      onTap: () {

      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
        child: Text('${categoryname} ',
            textAlign: TextAlign.center,
            style: TextStyle(
              background: Paint()
                ..color = LightColors.kLightBlue
                ..strokeWidth = 20
                ..strokeJoin = StrokeJoin.round
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke,
              color: Colors.black,
            )),
      ),
    );
  }*/

  /*getview(GetDetailedPJP cvfView) {
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
                  cvfView.franchiseeCode!=  'NA' ? '${cvfView.franchiseeName}' : cvfView.Address,
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
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))}',
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
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 1,
          decoration: BoxDecoration(
            color: Color(0xFFF1F4F8),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Text(
                  '${cvfView.franchiseeName}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF090F13),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        *//*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
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
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
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
        ),*//*
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: _buildRowList(cvfView)//[
                  ,
                  *//*cvfView.purpose!.length > 0
                      ? getTextCategory(cvfView,cvfView.purpose![0].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 1
                      ? getTextCategory(cvfView,cvfView.purpose![1].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 2
                      ? getTextCategory(cvfView,cvfView.purpose![2].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 3
                      ? getTextCategory(cvfView,cvfView.purpose![3].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 4
                      ? getTextCategory(cvfView,cvfView.purpose![4].categoryName)
                      : Text(''),*//*
                //],
              ),
            )),

        *//*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: Icon(
                  Icons.category,
                  color: Color(0xFF4B39EF),
                  size: 20,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Text(
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
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
        ),*//*
      ],
    );
  }*/

  /*List<Widget> _buildRowList(GetDetailedPJP cvfView) {
    List<Widget> _rowWidget = []; // this will hold Rows according to available lines
    for(int index=0;index<cvfView.purpose!.length;index++){
      _rowWidget.add(getTextCategory(cvfView,cvfView.purpose![index].categoryName,cvfView.purpose![index].categoryId));
    }
    return _rowWidget;
  }*/

  getTextCategory(GetDetailedPJP cvfView, String categoryname,String categoryId){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionListScreen(cvfView: cvfView,PJPCVF_Id: int.parse(cvfView.PJPCVF_Id), employeeId: employeeId, mCategory: categoryname,mCategoryId: categoryId,)),
        );
        Utility.showMessage(context, '${categoryname} clicked');
      },
      child: Padding(padding: EdgeInsets.only(left: 10,right: 10, top: 6,bottom: 6),
        child: Text('${categoryname} ',textAlign: TextAlign.center,
            style: TextStyle(
              background: Paint()
                ..color = LightColors.kLightBlue
                ..strokeWidth = 20
                ..strokeJoin = StrokeJoin.round
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke,
              color: Colors.black,
            )),),
    );
  }

}
