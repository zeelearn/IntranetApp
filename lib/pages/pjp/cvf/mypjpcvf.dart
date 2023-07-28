import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../api/APIService.dart';
import '../../../api/ServiceHandler.dart';
import '../../../api/request/pjp/get_pjp_list_request.dart';
import '../../../api/response/cvf/get_all_cvf.dart';
import '../../../api/response/cvf/update_status_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onResponse.dart';
import '../../utils/theme/colors/light_colors.dart';
import 'add_cvf.dart';
import 'cvf_questions.dart';

class MyPJPCVFListScreen extends StatefulWidget {
  PJPInfo mPjpInfo;

  MyPJPCVFListScreen({Key? key, required this.mPjpInfo}) : super(key: key);

  @override
  _MyCVFListScreen createState() => _MyCVFListScreen();
}

class _MyCVFListScreen extends State<MyPJPCVFListScreen> implements onResponse {
  int employeeId = 0;
  int businessId = 0;
  String appVersion='';
  bool isNavigate=false;

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
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    IntranetServiceHandler.loadPjpSummery(
        employeeId, int.parse(widget.mPjpInfo.PJP_Id),businessId, this);
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
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
        ),
      bottomNavigationBar: Utility.footer(appVersion),
    );
  }

  getCVFListView() {
    //print(widget.mPjpInfo.toJson());
    if (widget.mPjpInfo.getDetailedPJP!.isEmpty) {
      return GestureDetector(
        onTap: () {
          goToSecondScreen(context);
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
                    color: LightColors.kBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      );
    } else {
      widget.mPjpInfo.getDetailedPJP = widget.mPjpInfo.getDetailedPJP!.reversed.toList();
      return Flexible(
          child: ListView.builder(
            reverse: true,
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
        //print('status clicked ${cvfView.Status}');
        if (cvfView.Status == 'Check In' || cvfView.Status == ' Check In' || cvfView.Status == 'NA') {
          Utility.showMessage(context, 'Please Click on Check In button');
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
                                  Utility.convertTime(cvfView.visitDate)),
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

  getview(final GetDetailedPJP cvfView) {
    //print(cvfView.Status);
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
                              ? widget.mPjpInfo.remarks
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
  }

  getTextCategory(GetDetailedPJP cvfView, String categoryname) {
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
          EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Text('${categoryname}',
              textAlign: TextAlign.center,
              style: TextStyle(
                background: Paint()
                  ..color = LightColors.kLightRed
                  ..strokeWidth = 18
                  ..strokeJoin = StrokeJoin.round
                  ..strokeCap = StrokeCap.round
                  ..style = PaintingStyle.stroke,
                color: Color(0xFF4B39EF),
              )),
        ),
      );
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
                //print('Confirmed');

                Navigator.of(context).pop();

                IntranetServiceHandler.updateCVFStatus(
                    employeeId,
                    cvfView.PJPCVF_Id,
                    Utility.getDateTime(),
                    getNextStatus(cvfView.Status),
                    this);
                //Utility.showMessage(context, '${cvfView.Status} clicked');
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
      switch (key) {
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

  getTextRounded(GetDetailedPJP cvfView, String name) {
    return GestureDetector(
      onTap: () {
        if (cvfView.Status == 'FILL CVF') {
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
          _showMyDialog(cvfView);
        }
      },
      child: Container(
        height: 40,
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
                  fontSize: 12)),
        ),
      ),
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
    print('loadPjpSummery mycvf 642');
    Utility.showLoaderDialog(context);
    List<PJPInfo> pjpList = [];
    PJPListRequest request = PJPListRequest(
        Employee_id: employeeId, PJP_id: int.parse(widget.mPjpInfo.PJP_Id), Business_id: businessId);
    APIService apiService = APIService();
    //print(request.toJson());
    apiService.getPJPList(request).then((value) {
      //print(value.toString());
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
    //loadPjpSummery();
    isNavigate = true;
    IntranetServiceHandler.loadPjpSummery(
        employeeId, int.parse(widget.mPjpInfo.PJP_Id),businessId, this);
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
  }

  @override
  void onError(value) {
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
      IntranetServiceHandler.loadPjpSummery(
          employeeId, int.parse(widget.mPjpInfo.PJP_Id),businessId, this);
    } else if (value is PjpListResponse) {
      PjpListResponse response = value;
      print('onResponse in if ');
      if (response.responseData != null && response.responseData.length > 0) {
        widget.mPjpInfo.getDetailedPJP!.clear();
        for (int index = 0; index < response.responseData.length; index++) {
          widget.mPjpInfo.getDetailedPJP!
              .addAll(response.responseData[index].getDetailedPJP!);
        }
        setState(() {
          //mPjpList.addAll(response.responseData);
        });
        if(isNavigate){
          isNavigate=false;
        }
      } else {
        print('onResponse in if else');
      }
    }
  }
}
