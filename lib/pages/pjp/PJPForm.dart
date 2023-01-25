import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/request/cvf/add_cvf_request.dart';
import 'package:intranet/api/request/pjp/add_pjp_request.dart';
import 'package:intranet/api/response/cvf/centers_respinse.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/pjp/models/PjpModel.dart';
import 'package:intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:intranet/pages/widget/MyWidget.dart';
import 'package:intranet/pages/widget/check/checkbox.dart';
import 'package:intranet/pages/widget/date_time/time_picker.dart';
import 'package:intranet/pages/widget/options/dropdown.dart';

import '../../api/APIService.dart';
import '../../api/request/cvf/category_request.dart';
import '../../api/request/cvf/centers_request.dart';
import '../../api/response/cvf/add_cvf_response.dart';
import '../../api/response/cvf/category_response.dart';
import '../../api/response/pjp/add_pjp_response.dart';
import '../helper/DBConstant.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LightColor.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../widget/date_time/date_range_picker.dart';
import '../widget/form.dart';
import 'cvf/quiz_screen.dart';
import 'models/PJPCenterDetails.dart';
import 'new_pjp.dart';

class AddNewPjp extends StatefulWidget {
  @override
  _AddNewPjp createState() => _AddNewPjp();
}

class StepInfo {
  bool isFirstStep = false;
  bool isSecondStep = false;
}

class _AddNewPjp extends State<AddNewPjp> {
  final formKey = GlobalKey<FormState>();
  final centerKey = GlobalKey<FormState>();
  DateTime start = DateTime(1, DateTime.now().month - 1, DateTime.now().year);
  DateTime end = DateTime(
      DateTime.now().day, DateTime.now().month + 1, DateTime.now().year);
  DateTime cvfDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  StepInfo mStepInfo = StepInfo();
  int employeeId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mPjpModel = PJPModel(
        pjpId: mPjpId,
        dateTime: DateTime.now(),
        fromDate: DateTime.now(),
        toDate: DateTime.now(),
        remark: '',
        isSync: false,
        employeeId: '',
        centerList: [],
        isDelete: false,
        isActive: false,
        isCheckIn: false,
        isCheckOut: false,
        isCVFCompleted: false,
        isEdit: true,
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now());
    getUserInfo();

  }

  Future<void> getUserInfo() async {
    var hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    getPjpList();
    getCategoryList();
  }

  DateTime? fromDate = null;
  DateTime? toDate;
  TimeOfDay? vistitDateTime;
  late int mPjpId = 0;
  late String _purpose = '';
  late String _CenterName;
  late bool _isNotify = false;
  late String _purposeMultiSelect = 'Select';
  late PJPModel mPjpModel;
  late bool isCheckIn = false;
  List<FranchiseeInfo> mFrianchiseeList = [];
  late List<CategotyInfo> mCategoryList = [];
  late List<PJPModel> mPjpList = [];

  List<String> _selectedItems = [];
  late PJPCentersInfo pjpCentersInfo;

  addPJPinDB(int isSync) async {
    DBHelper dbHelper = DBHelper();

    Map<String, Object> data = {
      DBConstant.DATE: Utility.parseDate(DateTime.now()),
      DBConstant.FROM_DATE: Utility.parseDate(fromDate!),
      DBConstant.TO_DATE: Utility.parseDate(toDate!),
      DBConstant.IS_SYNC: 0,
      DBConstant.IS_DELETE: 0,
      DBConstant.REMARK: _remarkController.text.toString(),
      DBConstant.IS_ACTIVE: 1,
      DBConstant.IS_CHECK_IN: 0,
      DBConstant.IS_CHECK_OUT: 0,
      DBConstant.IS_CVF_COMPLETED: 0,
      DBConstant.EMP_CODE: '',
      DBConstant.MODIFIED_DATE: Utility.parseDate(DateTime.now()),
      DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
    };
    dbHelper.insert(LocalConstant.TABLE_PJP_INFO, data);

    getPjpList();
  }

  addCentersinDB() async {
    DBHelper dbHelper = DBHelper();
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      Map<String, Object> data = {
        DBConstant.FRANCHISEE_ID: mFrianchiseeList[index].franchiseeId,
        DBConstant.FRANCHISEE_NAME: mFrianchiseeList[index].franchiseeName,
        DBConstant.FRANCHISEE_CODE: mFrianchiseeList[index].franchiseeCode,
        DBConstant.ZONE: mFrianchiseeList[index].franchiseeZone,
        DBConstant.STATE: mFrianchiseeList[index].franchiseeState,
        DBConstant.CITY: mFrianchiseeList[index].franchiseeCity
      };
      dbHelper.insert(LocalConstant.TABLE_CVF_FRANCHISEE, data);
    }
  }

  addPJPCentersinDB() async {
    DBHelper dbHelper = DBHelper();
    for (int index = 0; index < mPjpModel.centerList.length; index++) {
      Map<String, Object> data = {
        DBConstant.PJP_ID: mPjpModel.pjpId,
        DBConstant.CENTRE_CODE:
            mPjpModel.centerList[index].centerCode as String,
        DBConstant.CENTRE_NAME:
            mPjpModel.centerList[index].centerName as String,
        DBConstant.PURPOSE: mPjpModel.centerList[index].purpose as String,
        DBConstant.DATE:
            Utility.parseDate(mPjpModel.centerList[index].dateTime as DateTime),
        DBConstant.IS_ACTIVE: 1,
        DBConstant.IS_NOTIFY: 1,
        DBConstant.IS_SYNC: 0,
        DBConstant.IS_CHECK_IN: 0,
        DBConstant.IS_CHECK_OUT: 0,
        DBConstant.IS_CVF_COMPLETED: 0,
        DBConstant.IS_NOTIFY: 1,
        DBConstant.MODIFIED_DATE: Utility.parseDate(DateTime.now()),
        DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
      };
      dbHelper.insert(LocalConstant.TABLE_PJP_CENTERS_DETAILS, data);
    }

    //getPjpList();
  }

  getPjpList() async {
    DBHelper helper = DBHelper();
    mPjpList.clear();
    List<PJPModel> pjpListModels = await helper.getPjpList();
    print('pjp list ${pjpListModels.length}');
    if (pjpListModels != null) {
      mPjpList.addAll(pjpListModels);
    }
    List<FranchiseeInfo> franchiseeList = await helper.getFranchiseeList();
    mFrianchiseeList.clear();
    if (franchiseeList == null || franchiseeList.length == 0) {
      print('data load ssss');
      loadCenterList();
    } else {
      mFrianchiseeList.addAll(franchiseeList);
      print('data ssss');
    }
    setState(() {});

    /*mPjpList.clear();
    if(pjpListModels!=null){
      mPjpList.addAll(pjpListModels);
    }*/
    mPjpId = pjpListModels.length + 1;
    mPjpModel.pjpId = mPjpId;

  }

  loadCenterList() {
    Utility.showLoaderDialog(context);
    mFrianchiseeList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 1, time.day);
    CentersRequestModel requestModel =
        CentersRequestModel(EmployeeId: employeeId, Brand: 1);
    APIService apiService = APIService();
    apiService.getCVFCenters(requestModel).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CentersResponse) {
          CentersResponse response = value;
          if (response != null && response.responseData != null) {
            mFrianchiseeList.addAll(response.responseData);
            addCentersinDB();
            setState(() {});
          }
          print('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  getCategoryList() async {
    print('fetch category----');
    fetchCategory();
  }

  fetchCategory() {
    Utility.showLoaderDialog(context);
    mCategoryList.clear();
    print('categoty');
    CVFCategoryRequest request = CVFCategoryRequest(Category_Id: "0");
    APIService apiService = APIService();
    apiService.getCVFCategoties(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFCategoryResponse) {
          CVFCategoryResponse response = value;
          if (response != null) {
            mCategoryList.addAll(response.responseData);
          }
          setState(() {});
          print('category list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  addNewPjp() {
    Utility.showLoaderDialog(context);
    //mCategoryList.clear();
    //print('categoty');
    AddPJPRequest request = AddPJPRequest(
        FromDate: Utility.convertShortDate(mPjpModel.fromDate),
        ToDate: Utility.convertShortDate(mPjpModel.toDate),
        ByEmployee_Id: employeeId.toString(),
        remarks: _remarkController.text.toString());
    print(request.toJson());
    APIService apiService = APIService();
    apiService.addNewPJP(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is NewPJPResponse) {
          NewPJPResponse response = value;
          //DBHelper().updatePJP(1, mPjpModel.pjpId, response.responseData);
          mPjpModel.pjpId = response.responseData;
          mPjpModel.fromDate = fromDate as DateTime;
          mPjpModel.toDate = toDate as DateTime;
          mPjpModel.isSync = true;
          //mPjpModel.isActive = true;
          mPjpModel.remark = _remarkController.text.toString();
          print('New PJP ID ${mPjpModel.pjpId} ');

          addPJPinDB(1);

          onsetp2();
        } else {
          addPJPinDB(0);
          onsetp2();
          Utility.showMessage(context, 'data not found');
        }
      }
      //Navigator.of(context).pop();
      //setState(() {});
    });
  }

  addNewPjpModel(PJPModel model) {
    Utility.showLoaderDialog(context);
    print('categoty');
    AddPJPRequest request = AddPJPRequest(
        FromDate: Utility.convertShortDate(model.fromDate),
        ToDate: Utility.convertShortDate(model.toDate),
        ByEmployee_Id: employeeId.toString(),
        remarks: model.remark.toString());
    print(request.toJson());
    APIService apiService = APIService();
    apiService.addNewPJP(request).then((value) {
      print(value.toString());
      Navigator.of(context).pop();
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is NewPJPResponse) {
          NewPJPResponse response = value;
          //DBHelper().updatePJP(1, mPjpModel.pjpId, response.responseData);
          DBHelper().updatePJP(1, model.pjpId,model.isCheckIn ? 1 :0,model.isCheckOut ? 1 :0, response.responseData);
          model.pjpId = response.responseData;
          model.isSync = true;
          //mPjpModel.isActive = true;
          onsetp2();
          print('New PJP ID ${mPjpModel.pjpId} ');
          setState(){};
        } else {
          addPJPinDB(0);
          onsetp2();
          Utility.showMessage(context, 'data not found');
        }
      }

      //setState(() {});
    });
  }

  onsetp2() {
    print('step2 push');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewPJP(
                mPjpModel: mPjpModel,
              )),
    );
  }

  addNewCVF() {
    Utility.showLoaderDialog(context);
    mCategoryList.clear();
    print('categoty');
    String xml =
        '<root><tblPJPCVF><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility.convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime?.hour}:${vistitDateTime?.minute}</Visit_Time><Category_Id>${getCategoryId()}</Category_Id></tblPJPCVF></root>';
    AddCVFRequest request =
        AddCVFRequest(PJP_Id: mPjpModel.pjpId, DocXml: xml, UserId: employeeId);
    APIService apiService = APIService();
    apiService.saveCVF(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is NewCVFResponse) {
          NewCVFResponse response = value;
          print(response.toString());
          if (response != null) {
            //mPjpModel.pjpId=response.responseData;
          }

          Utility.showMessage(context, 'CVF Saved in server');
          setState(() {});
          //print('category list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.light;
    return Scaffold(
      appBar: getAppbar(),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            !mStepInfo.isFirstStep ? getPJPForm() : getCenterForm(),
            SizedBox(
              height: 10,
            ),
            getPjpListWidget(),
          ],
        ),
      ),
      /*floatingActionButton:FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          savePJP();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => IntranetHomePage(userId:'')));

        },
        label: const Text('SAVE PJP'),
        icon: const Icon(Icons.thumb_up),
        backgroundColor: Colors.pink,
      ),*/
    );
  }

  savePJP() async{
    bool isInternet = await Utility.isInternet();
    if(isInternet) {
      addNewPjp();
    } else {
      addPJPinDB(0);
      Utility.showMessage(context, 'Internet Connection not avaliable, PJP Data Stored in local Database');
    }

    /*if (mPjpModel != null) {
      addPJPinDB(0);
      addPJPCentersinDB();
    }*/
  }

  getPjpListWidget() {
    double width = MediaQuery.of(context).size.width;
    if (mPjpList == null || mPjpList.length <= 0) {
      print('data not found');
      return Text('');
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: mPjpList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return centersList(mPjpList[index], width);
        },
      ));
    }
  }

  centersList(PJPModel model, double width) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
          padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            padding: EdgeInsets.all(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.10,
                    decoration: BoxDecoration(
                      color: LightColors.kLightGray1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          model.pjpId.toString(),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'PJP ID',
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewPJP(
                                mPjpModel: model,
                              )),
                        );
                      },
                      child:
                      Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(color: LightColors.kLightGray),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Utility.shortDate(model.fromDate)} To ${Utility.shortDate(model.toDate)}',
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              model.remark,
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  ),
                 Expanded(
                        flex: 1,
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.10,
                          decoration: BoxDecoration(
                            color: LightColors.kLightGray1,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if(!model.isSync)
                                      addNewPjpModel(model);
                                    else if(!model.isCheckIn) {
                                      print('check in');
                                      DBHelper().updatePJP(1, model.pjpId, 1,
                                          model.isCheckOut ? 1 : 0,
                                          model.pjpId);
                                      getPjpList();
                                      setState(){};
                                    }
                                  },
                                  child: Image.asset(
                                    model.isSync ? !model.isCheckIn ? 'assets/icons/ic_checkin.png' : 'assets/icons/ic_filling_form.png' : 'assets/icons/ic_retry.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                Text(
                                  model.isSync ? !model.isCheckIn ? 'Check In' : 'CVF' : 'Upload\n Again',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          )),
    );
  }

  _header(double width) {
    return Padding(
        padding: EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
          ),
          padding: EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.10,
                  decoration: BoxDecoration(
                    color: LightColors.kLightGray1,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${mPjpModel.toDate.difference(mPjpModel.fromDate).inDays}',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Days',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.30,
                  decoration: BoxDecoration(color: LightColors.kLightGray),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Utility.shortDate(mPjpModel.fromDate)} to ${Utility.shortDate(mPjpModel.toDate)}',
                          style: TextStyle(color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            mPjpModel.remark,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _showMultiSelect(BuildContext context) async {
    if (mCategoryList == null || mCategoryList.length == 0) {
      fetchCategory();
    } else {
      print('category length ${mCategoryList.length}');
    }

    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final _items = getPurposeList();

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _purposeMultiSelect = '';
        _selectedItems = results;
        if (results.contains('Activity') && results.length > 1) {
          Utility.showMessage(
              context, 'Activity is not comes with another option');
        } else {
          String token = '';
          for (int index = 00; index < _selectedItems.length; index++) {
            _purposeMultiSelect += token + _selectedItems[index];
            token = ' , ';
          }
        }
      });
    }
  }

  getCenterForm() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          _header(size.width),
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      String value = _showMultiSelect(context);
                      Utility.showMessage(context, value);
                      setState() {
                        _purposeMultiSelect = value;
                      }

                      ;
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: LightColors.kLightGray1)),
                      child: Text(
                        maxLines: 4,
                        _purposeMultiSelect == ''
                            ? 'Select Category'
                            : _purposeMultiSelect,
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  datePicker(context),
                  SizedBox(
                    height: 10,
                  ),
                  FastTimePicker(
                    name: 'Time',
                    onChanged: (value) {
                      vistitDateTime = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _purposeMultiSelect == 'Activity'
                      ? getActivity(size)
                      : getCenter(size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getActivity(Size size) {
    TextEditingController _activityNameController = TextEditingController();
    return Column(
      children: [
        MyWidget().normalTextField(
            context, 'Enter Activity Name', _activityNameController),
        SizedBox(
          height: 10,
        ),
        MyWidget().normalTextAreaField(
            context, 'Enter Activity Location', _activityNameController),
        GestureDetector(
          onTap: () {
            formKey.currentState?.build(context);

            setState(() {});
          },
          child: Container(
            alignment: Alignment.center,
            height: size.height / 20,
            width: size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: LightColor.brighter,
              boxShadow: [
                BoxShadow(
                  color: LightColors.kLightRed,
                  offset: const Offset(0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'Add Activity',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  getCenter(Size size) {
    return Column(
      children: [
        FastDropdown(
          name: 'Select Center',
          key: centerKey,
          hint: Text('Select Center'),
          onChanged: (value) {
            _CenterName = value as String;
            // Utility.showMessage(context, '${value}');
          },
          items: getList(mFrianchiseeList),
        ),
        SizedBox(
          height: 10,
        ),
        FastCheckbox(
          name: 'Is Notify to Business Partner',
          titleText: 'Is Notify to Business Partner',
          onChanged: (value) {
            _isNotify = value as bool;
            setState() {}
            ;
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            formKey.currentState?.build(context);

            DateTime time = DateTime(cvfDate.year, cvfDate.month, cvfDate.day,
                vistitDateTime?.hour as int, vistitDateTime?.minute as int);
            mPjpModel.centerList.add(PJPCentersInfo(
                pjpId: mPjpModel.pjpId,
                dateTime: time,
                centerCode: getCenterCode(_CenterName),
                centerName: _CenterName,
                isActive: true,
                isNotify: true,
                purpose: _purposeMultiSelect,
                isCheckIn: false,
                isCheckOut: false,
                isSync: false,
                isCompleted: false,
                createdDate: DateTime.now(),
                modifiedDate: DateTime.now()));

            addNewCVF();
            setState(() {});
          },
          child: Container(
            alignment: Alignment.center,
            height: size.height / 20,
            width: size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: LightColor.brighter,
              boxShadow: [
                BoxShadow(
                  color: LightColors.kLightRed,
                  offset: const Offset(0, 5.0),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Text(
              'Add Franchisee',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  getFrichanseeId() {
    int code = 0;
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length < 25) {
        if (_CenterName == mFrianchiseeList[index].franchiseeName) {
          code = mFrianchiseeList[index].franchiseeId.toInt();
        }
      } else if (_CenterName ==
          mFrianchiseeList[index].franchiseeName.substring(0, 25)) {
        code = mFrianchiseeList[index].franchiseeId.toInt();
      }
    }
    return code;
  }

  Widget datePicker(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: LightColors.kLightGray1)),
        height: 60,
        child: Center(
            child: TextField(
          controller: _dateController,
          //editing controller of this TextField
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today), //icon of text field
              labelText: "Enter Date" //label text of field
              ),
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: mPjpModel.fromDate,
                firstDate: mPjpModel.fromDate,
                //DateTime.now() - not to allow to choose before today.
                lastDate: mPjpModel.toDate);

            if (pickedDate != null) {
              print(
                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
              cvfDate = pickedDate;
              String formattedDate =
                  DateFormat('dd-MMM-yyyy').format(pickedDate);
              print(
                  formattedDate); //formatted date output using intl package =>  2021-03-16
              setState(() {
                _dateController.text =
                    formattedDate; //set output date to TextField value.
              });
            } else {}
          },
        )));
  }

  getPJPForm() {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.light;
    if (true) {
      //show Form
      return Card(
        margin: EdgeInsets.all(10),
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: FastForm(
              formKey: formKey,
              children: [
                FastDateRangePicker(
                  name: 'field_check_in_out',
                  labelText: 'PJP - Date Range',
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  onChanged: (value) {
                    fromDate = value?.start as DateTime;
                    toDate = value?.end as DateTime;

                    //Utility.showMessage(context, '${value?.start?.day} to ${value?.end?.day}');
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                MyWidget()
                    .normalTextField(context, 'Remark', _remarkController),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    savePJP();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height / 20,
                    width: size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: LightColor.brighter,
                      boxShadow: [
                        BoxShadow(
                          color: LightColors.kLightRed,
                          offset: const Offset(0, 5.0),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )),
      );
    } else {
      return Text('');
    }
  }

  AppBar getAppbar() {
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: true,
      title: Text(
        'Permanent Journey Planner',
        style:
            TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
      ),
      /*shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),*/
      /*leading: InkWell(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.subject,
          color: Colors.white,
        ),
      ),*/
    );
  }

  void validate(BuildContext context) {
    if (fromDate == null || toDate == null) {
      Utility.showMessage(context, 'Please select Date Range');
    } else {
      addPJPinDB(0);
    }
  }

  void updateCVFAction(PJPModel model) {
    Utility.showMessage(context, 'action captured');

    if (!model.isCheckIn) {
      DBHelper dbHelper = DBHelper();
      Map<String, Object> data = {
        DBConstant.IS_CHECK_IN: 1,
      };
      List<int> whereArugs = [model.pjpId, 0];
      //dbHelper.updateData(LocalConstant.TABLE_PJP_INFO, data,DBConstant.ID,whereArugs);
      dbHelper.updateCheckIn(LocalConstant.TABLE_PJP_INFO, 1, model.pjpId);
      //getPjpList();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen()),
      );
    }
  }

  getList(List<FranchiseeInfo> mFrianchiseeList) {
    List<String> data = ['Select'];
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length > 25) {
        data.add(mFrianchiseeList[index].franchiseeName.substring(0, 25));
      } else
        data.add(mFrianchiseeList[index].franchiseeName);
    }
    return data;
  }

  getPurposeList() {
    List<String> list = [];
    for (int index = 0; index < mCategoryList.length; index++) {
      if (mCategoryList[index].categoryName.length > 25) {
        list.add(mCategoryList[index].categoryName.substring(0, 25));
      } else
        list.add(mCategoryList[index].categoryName);
    }
    return list;
  }

  getCategoryId() {
    int id = 0;
    for (int index = 0; index < mCategoryList.length; index++) {
      if (_purposeMultiSelect == mCategoryList[index].categoryName) {
        id = mCategoryList[index].categoryId;
      }
    }
    return id;
  }

  getCenterCode(String centerName) {
    String code = '';
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName == centerName) {
        code = mFrianchiseeList[index].franchiseeCode;
      }
    }
    return code;
  }
}

class MultiSelect extends StatefulWidget {
  final List<String> items;

  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
