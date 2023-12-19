import 'dart:convert';

import 'package:Intranet/api/request/pjp/pjp_s_approval.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/pjp/update_pjpstatus_request.dart';

import '../../api/request/pjp/update_pjpstatuslist_request.dart';
import '../../api/response/general_response.dart';
import '../../api/response/pjp/pjp_exceptional_list.dart';
import '../../api/response/pjp/update_pjpstatus_response.dart';
import '../firebase/anylatics.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../iface/onClick.dart';
import '../iface/onResponse.dart';
import '../model/filter.dart';
import '../utils/theme/colors/light_colors.dart';
import '../widget/MyWidget.dart';
import 'add_new_pjp.dart';
import 'cvf/pjpcvf.dart';
import 'filters.dart';

class PjpExceotionalScreen extends StatefulWidget {
  FilterSelection mFilterSelection;
  List<PjpExceptionalModel> mPjpList;
  bool isApproved;
  PjpExceotionalScreen({Key? key, required this.mFilterSelection,required this.mPjpList,required this.isApproved}) : super(key: key);

  @override
  _MyPjpListState createState() => _MyPjpListState();
}

class _MyPjpListState extends State<PjpExceotionalScreen> implements onResponse,onClickListener{
  List<PjpExceptionalModel> mPjpList = [];
  int employeeId = 0;
  int businessId = 0;
  var hiveBox;
  bool isLoading=true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isInternet=true;
  List<bool> _isChecked = [];

  @override
  void initState() {
    print('exceptional page');
    super.initState();
    FirebaseAnalyticsUtils().sendAnalyticsEvent('PJP Approval - Exceptional');
    Future.delayed(Duration.zero, () {
      this.getUserInfo();

    });
  }

  Future<void> getUserInfo() async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    employeeId = 2772;
    isInternet = await Utility.isInternet();
    if(isInternet){
      IntranetServiceHandler.loadPjpExceptionalSummery(employeeId, this);
    }else{
      var pjpList = hiveBox.get(getId());
      try {
        isLoading = false;
        PjpExceptionalResponse response = PjpExceptionalResponse.fromJson(
          json.decode(pjpList),
        );
        if (response != null && response.responseData != null)
          mPjpList.addAll(response.responseData);
        sort();
        _isChecked = List<bool>.filled(mPjpList.length, false);
        setState(() {});
      }catch(e){
        IntranetServiceHandler.loadPjpExceptionalSummery(employeeId,this);
      }
    }
  }

  getLocalData() {
    bool isLoad = false;
    try {
      var attendanceList = hiveBox.get(getId());
      isLoading = false;
      //debugPrint(attendanceList.toString());
      PjpExceptionalResponse response = PjpExceptionalResponse.fromJson(
        json.decode(attendanceList!),
      );
      if (response != null && response.responseData != null) {
        mPjpList.addAll(response.responseData);
        sort();
      }
      _isChecked = List<bool>.filled(mPjpList.length, false);
      setState(() {});
      isLoad = true;
    }catch(e){
      isLoad = false;
    }
    return isLoad;
  }

  sort(){
    mPjpList.sort((a, b){ //sorting in descending order
      String start = '${a.pjPId}${a.pjpcvFId}';
      String end = '${b.pjPId}${b.pjpcvFId}';
      return start.compareTo(end);
      //return DateTime.parse(a.fromDate).compareTo(DateTime.parse(b.fromDate));
    });
  }

  bool _isSelectAll=false;

  @override
  Widget build(BuildContext context) {
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
              IntranetServiceHandler.loadPjpExceptionalSummery(employeeId, this);
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
            mPjpList.isEmpty || isLoading ? SizedBox(height: 0,) :
            Row(
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
                          if(isValid()) {
                            _approveRejectAll();
                          }else{
                            Utility.showMessage(context, 'Please Select the PJP');
                          }
                          //approvePjpList(pjpInfo, isApprove);
                        },
                        // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                        style: ElevatedButton.styleFrom(
                            elevation: 12.0,
                            backgroundColor: kPrimaryLightColor,
                            textStyle:
                            const TextStyle(color: LightColors.kLightGreen)),
                        child:  Text('Submit',style: LightColors.textHeaderStyle13Selected,),
                      ),
                    ),
                  ),
                ),
              ],
            ),
                SizedBox(
                  height: 10,
                ),
                getPjpListView(),
              ],
            ),
          ),
        ));
  }

  void _approveRejectAll() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("PJP Approval"),
          content: new Text(
              'Are you sure to approve the PJP request'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                //approvePjpList(0);
                Utility.onConfirmationBox(context, 'REJECT', 'Cancel', 'Reject PJP', 'Are you sure to reject the PJP', Utility.ACTION_REJECT, this);
                //approveAcquisition(model, 'REJ');
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  backgroundColor: LightColors.kRed,
                  textStyle: const TextStyle(color: LightColors.kRed)),
              child:  Text('Reject',style: LightColors.textHeaderStyleWhite,),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                approvePjpList(1);
              },
              // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
              style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  backgroundColor: kPrimaryLightColor,
                  textStyle: const TextStyle(color: LightColors.kLightGreen)),
              child:  Text('Approve',style: LightColors.textHeaderStyleWhite,),
            ),
          ],
        );
      },
    );
  }

  bool isValid(){
    bool isValid = false;
    if (_isChecked != null && _isChecked.length > 0) {
      debugPrint('length ${_isChecked.length}');
      for (int index = 0; index < _isChecked.length; index++) {
        if(_isChecked[index]==true) {
          isValid = true;
          break;
        }
      }
    }
    debugPrint('isValid ${isValid}');
    return isValid;
  }

  updateSelection() {
    //ApproveLeaveRequsitionRequest request = ApproveLeaveRequsitionRequest();
    late var jsonValue="[";
    if (_isChecked != null && _isChecked.length > 0) {

      for (int index = 0; index < _isChecked.length; index++) {
        _isChecked[index] = _isSelectAll;
      }
    }
    sort();
  }

  void openNewPjp() async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddNewPJPScreen(employeeId: employeeId, businessId: businessId, currentDate: DateTime.now(),)),
    );
    //debugPrint('Response Received');

    IntranetServiceHandler.loadPjpExceptionalSummery(employeeId, this);
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
        for(int index=0;index<filter.filters.length;index++){
          if(filter.filters[index].isSelected){
            widget.mFilterSelection.filters.add(filter.filters[index]);
            //debugPrint('--${filter.filters[index].name}');
          }
        }
        //debugPrint(filter.filters.toList());
        IntranetServiceHandler.loadPjpExceptionalSummery(employeeId,  this);
      }
    //Scaffold.of(context).showSnackBar(SnackBar(content: Text("$result"),duration: Duration(seconds: 3),));
  }

  getPjpListView() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else  if (mPjpList.isEmpty) {
      //debugPrint('PJP List not avaliable');
      return Utility.emptyDataSet(context,"your PJP list is Empty, Please plan your journey");
    }else  if (mPjpList.isEmpty && isInternet) {

      return Utility.noInternetDataSet(context);
    } else {
      mPjpList = mPjpList.reversed.toList();
      return Flexible(
          child: ListView.builder(
        itemCount: mPjpList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return getView(mPjpList[index],index);
        },
      ));
    }
  }

  getView(PjpExceptionalModel pjpInfo,int index) {
    return GestureDetector(
      onTap: () {
        if(pjpInfo.isExpectionallyApproved) {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CVFListScreen(mPjpInfo: pjpInfo)));*/
        }/*else if(pjpInfo.isSelfPJP=='1' && pjpInfo.ApprovalStatus=='Rejected'){
          Utility.showMessageSingleButton(context, 'The PJP is Rejected by Manager', this);
        }else if (pjpInfo.isSelfPJP=='1'){
          Utility.showMessageSingleButton(context, 'This pjp is not approved yet, Please connect with your manager', this);
        }*/
      },
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
        child: Container(
          width: double.infinity,
          height: 150,
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
                        'Ref Id : P-${pjpInfo.pjPId}',
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
              ListTile(
                title: Padding(
                  padding: EdgeInsetsDirectional.all(0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check In : ${Utility.getShortDateTime(pjpInfo.dateTimeIn)}',
                        style: const TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xFF090F13),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Check Out : ${Utility.getShortDateTime(pjpInfo.dateTimeOut)}',
                        style: const TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xFF090F13),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ),
                subtitle: /*Expanded(
                  flex: 1,
                  child:*/ Text(
                  'Visit Date : ${Utility.getShortDate(pjpInfo.visitDate)}',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF090F13),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                //),
                trailing: !pjpInfo.isExpectionallyApproved ? /*OutlinedButton(
                  onPressed: () {
                      Utility.showMessageMultiButton(context,'Approve','Reject', 'PJP : ${pjpInfo.pjPId}', 'Are you sure to approve the PJP, created by ${pjpInfo.displayName}',pjpInfo, this);
                  },
                  child: */Checkbox(
                    checkColor: Colors.black,
                    activeColor: LightColors.kLavender,
                    value: _isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked[index] = value!;
                        if(value==false){
                          _isSelectAll=false;
                        }
                        sort();
                      });
                    },
                  //)
                ) : Image.asset(
                'assets/icons/ic_checked.png',
                height: 50,
              )
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
                        '${Utility.getDateDifference(Utility.convertDate(pjpInfo.dateTimeIn), Utility.convertDate(pjpInfo.dateTimeOut))} Days',
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
              ),
            ],
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

      for(int index=0;index<filter.filters.length;index++){
        if(filter.filters[index].isSelected){
          widget.mFilterSelection.filters.add(filter.filters[index]);
          //debugPrint(filter.filters[index].name);
        }
      }
      //debugPrint(filter.filters.toList());
      IntranetServiceHandler.loadPjpExceptionalSummery(employeeId,  this);
    } else {
      //debugPrint('Object not found ${result}');
    }
  }


  @override
  void onError(value) {
    isLoading=false;
    print('=========error ${value}');
    setState(() {

    });
    //Navigator.of(context).pop();
  }

  @override
  void onStart() {
    setState(() {
      isLoading=true;
    });
    //Utility.showLoaderDialog(context);
  }

  String getId(){
    return '${employeeId.toString()}_e_${LocalConstant.KEY_MY_PJP}';
  }

  savePJPLocally(String json) async{
    if(hiveBox==null){
      hiveBox = await Hive.openBox(LocalConstant.KidzeeDB);
    }
    hiveBox.put(getId(), json);
  }

  @override
  void onSuccess(value) {
    //
    isLoading = false;
    debugPrint('PJP List onSuccess ');
    if(value is String){
      print('Approves ${value}');
      //if(value=='SUCCESS')
        //Navigator.of(context).pop();
      IntranetServiceHandler.loadPjpExceptionalSummery(employeeId,  this);
    }else if(value is UpdatePJPStatusResponse){
      UpdatePJPStatusResponse val = value;
      //debugPrint(val.toJson());
      if(val.responseData==0){
        //rejected
        Utility.getRejectionDialog(context, 'Rejected', 'The Pjp is rejected by you..', this);
      }else {
        Utility.getConfirmationDialogPJP(context, this);
      }
    }else if(value is PjpExceptionalResponse){
      //debugPrint('PJP List onSuccess PjpListResponse');
      PjpExceptionalResponse response = value;
      //debugPrint(response.toString());
      String json = jsonEncode(response);
      savePJPLocally(json);
      //debugPrint('onResponse in if ${widget.mFilterSelection.type}');
      isLoading = false;
      mPjpList.clear();
      //debugPrint('PJP List onSuccess ${response.responseData.toString()}');
      if(response.responseData!=null && response.responseData!.length>0){
        if (response != null && response.responseData != null) {
          if (widget.mFilterSelection == null ||widget.mFilterSelection.type == FILTERStatus.MYTEAM) {
            for (int index = 0;index < response.responseData!.length;index++) {
              if(widget.isApproved && response.responseData[index].isExpectionallyApproved || !widget.isApproved && !response.responseData[index].isExpectionallyApproved){
                //mPjpList.add(response.responseData[index]);
                for(int jIndex=0;jIndex<widget.mFilterSelection.filters.length;jIndex++){
                  if(widget.mFilterSelection.filters[jIndex].isSelected && response.responseData[index].displayName==widget.mFilterSelection.filters[jIndex].name){
                      mPjpList.add(response.responseData[index]);
                  }
                }
              }
            }
          } else if (widget.mFilterSelection.type == FILTERStatus.MYSELF) {
            debugPrint('FOR MY SELF');
            for (int index = 0;index < response.responseData.length;index++) {
              if (true /*|| response.responseData[index].isSelfPJP == '1'*/) {
                if(widget.isApproved && response.responseData[index].isExpectionallyApproved || !widget.isApproved && !response.responseData[index].isExpectionallyApproved)
                  mPjpList.add(response.responseData[index]);
              }
            }
          } else if (widget.mFilterSelection.type == FILTERStatus.NONE) {

            for (int index = 0;index < response.responseData.length;index++) {
              debugPrint('FOR MY CUSTOM TEAM - e ${widget.isApproved} ${response.responseData[index].isExpectionallyApproved}');
              if(widget.isApproved && response.responseData[index].isExpectionallyApproved || !widget.isApproved && !response.responseData[index].isExpectionallyApproved)
                  mPjpList.add(response.responseData[index]);
            }
          } else {
            debugPrint('In else');
            for (int index = 0;index < response.responseData.length;index++) {
              for (int jIndex = 0;jIndex < widget.mFilterSelection.filters.length;jIndex++) {
                if (response.responseData[index].displayName == widget.mFilterSelection.filters[jIndex].name) {
                  if(widget.isApproved && response.responseData[index].isExpectionallyApproved || !widget.isApproved && !response.responseData[index].isExpectionallyApproved)
                    mPjpList.add(response.responseData[index]);
                }
              }
            }
          }

          if(mPjpList.length>0)
            sort();
          _isChecked = List<bool>.filled(mPjpList.length, false);
          //mPjpList.addAll(response.responseData);
          //debugPrint('========================${mPjpList.length}');
          //debugPrint(response.toJson());
          //mPjpList = mPjpList.reversed.toList();

        }
      }else{
        //debugPrint('onResponse in if else');
      }
    }else if(value is GeneralResponse){
      GeneralResponse response = value;
      Utility.onSuccessMessage(context, 'PJP Updated', 'PJP status has been updated Successfully', this);
    }
    debugPrint('length ${mPjpList.length}');
    setState(() {
      //mPjpList.addAll(response.responseData);
    });
  }

  void approvePjp(PjpExceptionalModel pjpInfo,int isApprove) {
    /*UpdatePJPStatusRequest request= UpdatePJPStatusRequest(PJP_id: int.parse(pjpInfo.PJP_Id),
        Is_Approved: isApprove, Workflow_user: employeeId.toString());
    IntranetServiceHandler.updatePJPStatus(request, this);*/
  }

  void approvePjpList(int isApprove) {

    StringBuffer DocXML = new StringBuffer("<root>");
    List<Subroot> list = [];
    for(int index=0;index<mPjpList.length;index++){
      if(_isChecked[index]==true) {
        list.add(Subroot(pJPId: mPjpList[index].pjPId, pJPCVFId: mPjpList[index].pjpcvFId,isApproved: isApprove));
        /*DocXML.write("<subroot><PJP_Id>${mPjpList[index]
            .pjPId}</PJP_Id><PJPCVF_Id>${mPjpList[index]
            .pjpcvFId}</PJPCVF_Id><Is_Approved>${isApprove}</Is_Approved></subroot>");*/
      }
    //<subroot><PJP_id>135</PJP_id><Is_Approved>0</Is_Approved></subroot><subroot><PJP_id>136</PJP_id><Is_Approved>1</Is_Approved></subroot>
    }
    DocXML.write("</root>");
    PjpApproval pjpApprovals = PjpApproval(root: Root(subroot: list));
    UpdatePJPStatusListRequest request = UpdatePJPStatusListRequest(DocXML: jsonEncode(pjpApprovals).toString(), Workflow_user: employeeId.toString());
    //debugPrint(request.toJson());
    IntranetServiceHandler.updatePJPStatusExceptional(request, this);
  }

  @override
  void onClick(int action, value) {
    //debugPrint('onClick called ${value}');
    if(value is int){
      if(action==Utility.ACTION_OK && value == Utility.ACTION_REJECT){
        approvePjpList(0);
      }
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }else if(value is PjpExceptionalModel){
      PjpExceptionalModel pjpInfo = value;
      if(action==Utility.ACTION_OK){
        approvePjp(pjpInfo, 1);
      }else if(action==Utility.ACTION_CCNCEL){
        approvePjp(pjpInfo, 0);
      }
    }
  }
}
