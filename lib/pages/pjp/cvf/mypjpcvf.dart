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

class MyPJPCVFListScreen extends StatefulWidget {
  PJPInfo mPjpInfo;

  MyPJPCVFListScreen({Key? key, required this.mPjpInfo}) : super(key: key);

  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<MyPJPCVFListScreen> {
  int employeeId = 0;
  List<CVFListModel> mCvfList = [];

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
    final prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("My CVF"),
          actions: <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'ADD CVF',
              onPressed: () {
                goToSecondScreen(context);
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
    print(widget.mPjpInfo.toJson());
    if (widget.mPjpInfo.getDetailedPJP!.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddCVFScreen(
                      mPjpModel: widget.mPjpInfo,
                    )),
          );
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
                "Click here to Add new CVF",
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
        itemCount: widget.mPjpInfo.getDetailedPJP!.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return getView(widget.mPjpInfo.getDetailedPJP![index]);
        },
      ));
    }
  }

  getView(GetDetailedPJP cvfView) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionListScreen(cvfView: cvfView, mCategory: 'All', PJPCVF_Id: int.parse(cvfView.PJPCVF_Id), employeeId: employeeId,)),
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
    print(widget.mPjpInfo.toJson());
    if (cvfView.purpose!.isEmpty) {
      return Text('No Category Found');
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: 2,
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Text('${cvfView.purpose![0].categoryName} ',textAlign: TextAlign.center,
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

  getview(GetDetailedPJP cvfView) {
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
                  'Franchisee Code : ${cvfView.franchiseeCode}',
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

  getTextCategory(GetDetailedPJP cvfView, String categoryname){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionListScreen(cvfView: cvfView,PJPCVF_Id: int.parse(cvfView.PJPCVF_Id), employeeId: employeeId, mCategory: categoryname,)),
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

  ListView _horizontalList(int n) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
        n,
        (i) => Container(
          width: 50,
          height: 20,
          color: Colors.black,
          alignment: Alignment.center,
          child: Text('TEST $i'),
        ),
      ),
    );
  }

  loadPjpSummery() {
    Utility.showLoaderDialog(context);
    List<PJPInfo> pjpList = [];
    PJPListRequest request = PJPListRequest(Employee_id: employeeId);
    APIService apiService = APIService();
    apiService.getPJPList(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is PjpListResponse) {
          PjpListResponse response = value;
          for (int index = 0; index < response.responseData.length; index++) {
            if (response.responseData[index].PJP_Id == widget.mPjpInfo.PJP_Id) {
              widget.mPjpInfo.getDetailedPJP =
                  response.responseData[index].getDetailedPJP;
              break;
            }
          }
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
    print('Response Received');

    loadPjpSummery();
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
  }
}
