import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../api/APIService.dart';
import '../../../api/request/cvf/add_cvf_request.dart';
import '../../../api/request/cvf/category_request.dart';
import '../../../api/request/cvf/centers_request.dart';
import '../../../api/request/cvf/questions_request.dart';
import '../../../api/response/cvf/QuestionResponse.dart';
import '../../../api/response/cvf/add_cvf_response.dart';
import '../../../api/response/cvf/category_response.dart';
import '../../../api/response/cvf/centers_respinse.dart';
import '../../helper/DBConstant.dart';
import '../../helper/DatabaseHelper.dart';
import '../../helper/LightColor.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/LocalStrings.dart';
import '../../helper/LocationHelper.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../utils/theme/colors/light_colors.dart';
import '../../widget/MyWidget.dart';
import '../../widget/options/dropdown.dart';
import '../PJPForm.dart';

class AddCVFScreen extends StatefulWidget {
  PJPInfo mPjpModel;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  AddCVFScreen({Key? key, required this.mPjpModel}) : super(key: key);

  @override
  State<AddCVFScreen> createState() => _AddCVFState();
}

class _AddCVFState extends State<AddCVFScreen> implements onClickListener{

  TextEditingController _activityNameController = TextEditingController();

  List<GetDetailedPJP> mCVFList = [];

  DateTime cvfDate = DateTime.now();
  List<CategotyInfo> mCategoryList = [];
  List<FranchiseeInfo> mFrianchiseeList = [];
  TimeOfDay? vistitDateTime;
  String _CenterName='';
  bool _isNotify = false;
  String _purposeMultiSelect = 'Select';
  List<String> _selectedItems = [];
  bool isAddCVF = false;
  int employeeId = 0;
  int businessId = 0;
  double latitude=0.0;
  double longitude=0.0;
  String appVersion='';
  TextEditingController _timeController = TextEditingController();
  var hiveBox;
  var _categoryController = TextEditingController(text: 'Select Purpose');
  var _dateController = TextEditingController();
  String location = "Search Location";

  Future<void> getUserInfo() async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    debugPrint('Business Id ${businessId}');
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
  }

  fetchCategory() {
    Utility.showLoaderDialog(context);
    mCategoryList.clear();
    debugPrint('categoty');
    CVFCategoryRequest request = CVFCategoryRequest(Category_Id: "0", Business_id: businessId);
    APIService apiService = APIService();
    apiService.getCVFCategoties(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFCategoryResponse) {
          CVFCategoryResponse response = value;
          if (response != null) {
            mCategoryList.addAll(response.responseData);
          }
          setState(() {});
          debugPrint('category list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  getFrichinseeList() async {
    DBHelper helper = DBHelper();

    List<FranchiseeInfo> franchiseeList = await helper.getFranchiseeList(businessId);

    if (franchiseeList == null || franchiseeList.length == 0) {
      debugPrint('data load ssss');
      loadCenterList();
    } else {
      mFrianchiseeList.clear();
      mFrianchiseeList.addAll(franchiseeList);
      debugPrint('data ssss');
    }
  }

  loadCenterList() {
    Utility.showLoaderDialog(context);
    mFrianchiseeList.clear();
    DateTime time = DateTime.now();
    DateTime selectedDate = new DateTime(time.year, time.month - 1, time.day);
    CentersRequestModel requestModel =
        CentersRequestModel(EmployeeId: employeeId, Brand: businessId);
    APIService apiService = APIService();
    apiService.getCVFCenters(requestModel).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CentersResponse) {
          CentersResponse response = value;
          if (response != null && response.responseData != null) {
            mFrianchiseeList.addAll(response.responseData);
            addCentersinDB(businessId);
            setState(() {});
          }
          debugPrint('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  addCentersinDB(businessId) async {
    DBHelper dbHelper = DBHelper();
    dbHelper.deleteData(LocalConstant.TABLE_CVF_FRANCHISEE);
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      Map<String, Object> data = {
        DBConstant.FRANCHISEE_ID: mFrianchiseeList[index].franchiseeId,
        DBConstant.FRANCHISEE_NAME: mFrianchiseeList[index].franchiseeName,
        DBConstant.FRANCHISEE_CODE: mFrianchiseeList[index].franchiseeCode,
        DBConstant.ZONE: mFrianchiseeList[index].franchiseeZone,
        DBConstant.STATE: mFrianchiseeList[index].franchiseeState,
        DBConstant.CITY: mFrianchiseeList[index].franchiseeCity,
        DBConstant.BUSINESS_ID: businessId
      };
      dbHelper.insert(LocalConstant.TABLE_CVF_FRANCHISEE, data);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('cvf list ');
    Future.delayed(Duration.zero, () {
      this.loadUserData();
    });
  }

  loadUserData() async{
    await getUserInfo();
    fetchCategory();
    getFrichinseeList();
  }

  addPJPCentersinDB() async {
    DateTime time = DateTime(cvfDate.year, cvfDate.month, cvfDate.day,
        vistitDateTime?.hour as int, vistitDateTime?.minute as int);
    DBHelper dbHelper = DBHelper();
    Map<String, Object> data = {
      DBConstant.PJP_ID: widget.mPjpModel.PJP_Id,
      DBConstant.CENTRE_CODE: getCenterCode(_CenterName),
      DBConstant.CENTRE_NAME: _CenterName,
      DBConstant.PURPOSE: _purposeMultiSelect,
      DBConstant.DATE: Utility.parseDate(time),
      DBConstant.IS_ACTIVE: 1,
      DBConstant.IS_NOTIFY: _isNotify == true ? 1 : 0,
      /*DBConstant.IS_SYNC: 0,*/
      DBConstant.IS_CHECK_IN: 0,
      DBConstant.IS_CHECK_OUT: 0,
      DBConstant.IS_CVF_COMPLETED: 0,
      DBConstant.IS_NOTIFY: 1,
      DBConstant.MODIFIED_DATE: Utility.parseDate(DateTime.now()),
      DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
    };
    dbHelper.insert(LocalConstant.TABLE_PJP_CENTERS_DETAILS, data);
    //getPjpList();
    isAddCVF = false;
    setState(() {});
  }

  List<GetDetailedPJP> _getEventsForDay(DateTime day) {
    // Implementation example
    debugPrint('day is ' + day.day.toString());
    return getCurrentEvents(day); //kEvents[day] ?? [];
  }

  getCurrentEvents(DateTime date) {
    List<GetDetailedPJP> list = [];
    debugPrint('getEvent----${mCVFList.length}');
    for (int index = 0; index < mCVFList.length; index++) {
      debugPrint(
          '${Utility.shortDate(date)}  -- ${Utility.shortDate(Utility.convertDate(mCVFList[index].visitDate))}');
      if (Utility.shortDate(date) ==
          Utility.shortDate(Utility.convertDate(mCVFList[index].visitDate))) {
        list.add(mCVFList[index]);
      }
    }
    return list;
  }
  Size? size;
  getCenterForm() {
    size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Card(
            color: LightColor.lightGrey,
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10,top:10),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(0),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //if (_CenterName.isNotEmpty) (8.0).addHSpace(),
                          //if (_CenterName.isNotEmpty) "${_CenterName}".grayText(),
                          SizedBox(
                            height: 40,
                            child: TextField(
                                style: TextStyle(color: LightColor.subTitleTextColor),
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  hintText: 'Select Category',
                                ),
                                undoController: null,
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  openCategory();
                                }),
                          )
                        ],
                      ).paddingSymmetric(horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  datePicker(context),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(0),
                      clipBehavior: Clip.antiAlias,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //if (_CenterName.isNotEmpty) (8.0).addHSpace(),
                          //if (_CenterName.isNotEmpty) "${_CenterName}".grayText(),
                          SizedBox(
                            height: 40,
                            child: TextField(
                                style: TextStyle(color: LightColor.subTitleTextColor),
                                controller: _timeController, //editing controller of this TextField
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(Icons.access_time),
                                  hintText: 'Select Time',
                                ),
                                undoController: null,
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  _selectTime(context);
                                }),
                          )
                        ],
                      ).paddingSymmetric(horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _purposeMultiSelect == 'Activity'
                      ? getActivity(size!)
                      : getCenter(size!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay(hour: 12, minute: 00);
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: false), child: child!,
        );
      },

    );
    if(timeOfDay != null )
    {
      setState(() {
        final dt = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, timeOfDay.hour, timeOfDay.minute);
        vistitDateTime=timeOfDay;
        _timeController.text =  DateFormat('hh:mm a').format(dt);
        //controller.text = '${timeOfDay.hourOfPeriod}:${timeOfDay.minute}';
      });

    }

  }

  getFrichanseeId() {
    int code = 0;
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length < 150) {
        if (_CenterName == mFrianchiseeList[index].franchiseeName) {
          code = mFrianchiseeList[index].franchiseeId.toInt();
        }
      } else if (_CenterName == mFrianchiseeList[index].franchiseeName.substring(0, 150)) {
        code = mFrianchiseeList[index].franchiseeId.toInt();
      }
    }
    return code;
  }
  getFrichanseeAddress() {
    String address='';
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (_CenterName == mFrianchiseeList[index].franchiseeName) {
        address = '${mFrianchiseeList[index].franchiseeCity} , ${mFrianchiseeList[index].franchiseeState}';
      }
    }
    return address;
  }

  bool validate(){
    debugPrint("Validating the CVF Form");
    String purpose =  getCategoryList();
    debugPrint('Purpose ${_purposeMultiSelect}');
    debugPrint(_dateController.text);
    if(_purposeMultiSelect.isEmpty){
      Utility.showMessages(context, "Please Select Purpose");
      return false;
    }else if(_dateController.text.isEmpty || _dateController.text.toString()=='Select Date'){
      Utility.showMessages(context, "Please Select CVF Date");
      return false;
    }else if(vistitDateTime==null) {
      Utility.showMessages(context, "Please Select CVF Time");
      return false;
    }else if(_purposeMultiSelect=='Activity'){
      if(_activityNameController.text.isEmpty) {
        Utility.showMessages(context, "Please Select Activity Name");
        return false;
      }else if(location.isEmpty || location=='Search Location') {
        Utility.showMessages(context, "Please Select Location");
        return false;
      }
    }else if( getFrichanseeId()==0){
      Utility.showMessages(context, "Please Select Center");
      return false;
    }
    return true;
  }

  addNewCVF() async {
    if(validate()) {
      Utility.showLoaderDialog(context);
      debugPrint('categoty');
      /*String xml =
        '<root><tblPJPCVF><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility.convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime?.hour}:${vistitDateTime?.minute}</Visit_Time><Category_Id>${getCategoryId()}</Category_Id></tblPJPCVF></root>';
    */
      LocationData deviceLocation = await LocationHelper.getLocation();
      if(deviceLocation!=null){
        double latitude = deviceLocation.latitude!;
        double longitude = deviceLocation.longitude!;
        print('Location is ${latitude} ${longitude}');
      }else{
        print('location data not found');
      }
      /*if (await Permission.location.request().isGranted) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        latitude=position.latitude;
        longitude=position.longitude;
      }*/
      String xml = '<root><tblPJPCVF><Business_Id>${businessId}</Business_Id><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility
          .convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime
          ?.hour}:${vistitDateTime
          ?.minute}</Visit_Time><Category_Id>${getCategoryList()}</Category_Id><Latitude>${latitude}</Latitude><Longitude>${longitude}</Longitude><ActivityTitle>${_activityNameController.text.toString()}</ActivityTitle><Address>${location=='Search Location' ? getFrichanseeAddress() :location}</Address></tblPJPCVF></root>';
      AddCVFRequest request = AddCVFRequest(
          PJP_Id: int.parse(widget.mPjpModel.PJP_Id),
          DocXml: xml,
          UserId: employeeId);
      debugPrint(request.toJson().toString());
      APIService apiService = APIService();
      apiService.saveCVF(request).then((value) {
        print(value);
        Navigator.of(context).pop();
        if (value != null) {
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'data not found');
          } else if (value is NewCVFResponse) {
            NewCVFResponse response = value;
            debugPrint(response.toString());
            if (response != null) {
              //mPjpModel.pjpId=response.responseData;
            }
            try {
              //fetchQuestions(response.responseData);
            }catch(e){}
            Navigator.of(context).pop();
            //Utility.showMessage(context, 'CVF Saved in server');
            setState(() {});
            //debugPrint('category list ${response.responseData.length}');
          } else {
            Utility.showMessage(context, 'data not found');
          }
        }
        //Navigator.of(context).pop();
        setState(() {});
      });
    }else{
      debugPrint("unable to Validate");
    }
  }

  Widget getCenterDropdown(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(0),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //if (_CenterName.isNotEmpty) (8.0).addHSpace(),
            //if (_CenterName.isNotEmpty) "${_CenterName}".grayText(),
            SizedBox(
              height: 40,
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Center ',textAlign: TextAlign.left,),
                value: _CenterName.isNotEmpty ? _CenterName : null,
                underline: SizedBox(),
                onChanged: (String? value) {
                  debugPrint(value);
                  setState(() {
                    _CenterName = value!;
                  });
                },
                alignment: Alignment.centerLeft,
                borderRadius: BorderRadius.circular(15),
                items: getList(mFrianchiseeList)
                    .map((item) => DropdownMenuItem(
                  child: SizedBox(
                    width: size!.width * 0.7,
                    child: Text(
                      item,
                    ),
                  ),
                  value: item,
                ))
                    .toList(),
              ),
            )
          ],
        ).paddingSymmetric(horizontal: 10),
      ),
    );
  }

  getCenter(Size size) {
    return Column(
      children: [
        /*Container(
          decoration: BoxDecoration(
              border: Border.all(color: LightColors.kLightGray1)),
          height: 50,
          child: FastDropdown(
            decoration: MyWidget.getInputDecoratino('Select Center'),
            name: 'Select Center',
            hint: Text('Select Center'),
            onChanged: (value) {
              _CenterName = value as String;
              // Utility.showMessage(context, '${value}');
            },
            builder: (value) {
                return DropdownMenuItem<String>(
                  value: 'Select ',
                  child: Text('Select',style:TextStyle(color:Colors.black),),
                );
            },
            items: getList(mFrianchiseeList),
          ),
        ),*/
        getCenterDropdown(context),
        //getCenterListDropDown(),
        SizedBox(
          height: 10,
        ),
        CheckboxListTile(
            activeColor: Colors.blue[300],
            dense: true,
            //font change
            title: new Text(
              'Is Notify to Business Partner',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5),
            ),
            value: _isNotify,
            onChanged: (val) {
              itemChange(val as bool);
            }),

        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            //formKey.currentState?.build(context);
            /*mPjpModel.centerList.add(PJPCentersInfo(pjpId: mPjpModel.pjpId, dateTime: time, centerCode: getCenterCode(_CenterName),
                centerName: _CenterName, isActive: true, isNotify: true, purpose: _purposeMultiSelect, isCheckIn: false, isCheckOut: false,
                isSync: false, isCompleted: false, createdDate: DateTime.now(), modifiedDate: DateTime.now()));*/
            //addPJPCentersinDB();
              addNewCVF();
            //setState(() {});
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
              'ADD CVF',
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

  void itemChange(bool val) {
    setState(() {
      _isNotify = val;
    });
  }

  Widget datePicker(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(0),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //if (_CenterName.isNotEmpty) (8.0).addHSpace(),
            //if (_CenterName.isNotEmpty) "${_CenterName}".grayText(),
            SizedBox(
              height: 40,
              child: TextField(
                  style: TextStyle(color: LightColor.subTitleTextColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.calendar_today),
                    hintText: 'Select Date',
                  ),

                  undoController: null,
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    _showDatePicker(context);
                  }),
            )
          ],
        ).paddingSymmetric(horizontal: 10),
      ),
    );
  }

  Widget _getLocation(BuildContext context) {
    return InkWell(
              onTap: () async {
                var place = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: LocalStrings.kGoogleApiKey,
                    mode: Mode.overlay,
                    types: [],
                    strictbounds: false,
                    components: [Component(Component.country, 'in')],
                    //google_map_webservice package
                    onError: (err){
                      debugPrint(err.toString());
                    }
                );

                if(place != null){
                  setState(() {
                    location = place.description.toString();
                  });

                  //form google_maps_webservice package
                  final plist = GoogleMapsPlaces(apiKey:LocalStrings.kGoogleApiKey,
                    apiHeaders: await GoogleApiHeaders().getHeaders(),
                    //from google_api_headers package
                  );
                  String placeid = place.placeId ?? "0";
                  final detail = await plist.getDetailsByPlaceId(placeid);
                  final geometry = detail.result.geometry!;
                  latitude = geometry.location.lat;
                  longitude = geometry.location.lng;
                  //var newlatlang = LatLng(lat, lang);


                  //move map camera to selected place with animation
                  //mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newlatlang, zoom: 17)));
                }
              },
              child:Padding(
                padding: EdgeInsets.all(0),
                child: Card(
                  child: Container(
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width - 40,
                      child: ListTile(
                        title:Text(location, style: TextStyle(fontSize: 18),),
                        trailing: Icon(Icons.search),
                        dense: true,
                      )
                  ),
                ),
              )
          );
       /*Container(
        decoration:
            BoxDecoration(border: Border.all(color: LightColors.kLightGray1)),
        height: 45,
        child: Center(
            child: TextField(
          //editing controller of this TextField
          decoration: InputDecoration(
            icon: Icon(Icons.location_pin), //icon of text field
            //label text of field
          ),
          controller: _locationController,
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            _handlePressButton();
          },
        )));*/
  }
  _showLocationDialog(BuildContext context) async{
    /*Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: LocalStrings.kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "en",
        components: [new Component(Component.country, "en")]);*/
    Prediction? p = await PlacesAutocomplete.show(
        offset: 0,
        radius: 1000,
        strictbounds: true,
        region: "us",
        language: "en",
        context: context,
        mode: Mode.overlay,
        apiKey: LocalStrings.kGoogleApiKey,

        components: [new Component(Component.country, "us")],
        types: ["(cities)"],
        hint: "Search City",
    );
    displayPrediction(p!);
  }

  void onError(PlacesAutocompleteResponse response) {
    Utility.showMessage(context, response.errorMessage!);
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      radius: 500,
      apiKey: LocalStrings.kGoogleApiKey,
      onError: onError,
      types: ['establishment'],
      strictbounds: true,
      mode: Mode.overlay,
      language: "en",
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      components: [Component(Component.country, "in")],
    );
    debugPrint('p is ${p!.description!}');
    displayPrediction(p);
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: LocalStrings.kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId.toString());
      final lat = detail.result.geometry?.location.lat;
      final lng = detail.result.geometry?.location.lng;

      Utility.showMessage(context, "${p.description} - $lat/$lng");

    }
  }

  getActivity(Size size) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MyWidget().normalTextField(
            context, 'Enter Activity Name', _activityNameController),
        SizedBox(
          height: 10,
        ),
        _getLocation(context),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            addNewCVF();
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

  _showDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: Utility.convertDate(widget.mPjpModel.fromDate),
        firstDate: Utility.convertDate(widget.mPjpModel.fromDate),
        //DateTime.now() - not to allow to choose before today.
        lastDate: Utility.convertDate(widget.mPjpModel.toDate));

    if (pickedDate != null) {
      setState(() {
        cvfDate = pickedDate;
        String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
        _dateController.text = formattedDate;
      });
    } else {}
  }

  _showMultiSelect(BuildContext context) async {
    if (mCategoryList == null || mCategoryList.length == 0) {
      fetchCategory();
    } else {
      debugPrint('category length ${mCategoryList.length}');
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

        _categoryController.text = _purposeMultiSelect;
        _categoryController.value = _categoryController.value.copyWith(
          text: _purposeMultiSelect,
          selection:
              TextSelection.collapsed(offset: _purposeMultiSelect.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.light;
    return Scaffold(
      key: widget.homeScaffoldKey,
      appBar: getAppbar(),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            getCenterForm(),
          ],
        ),
      ),
      bottomNavigationBar: Utility.footer(appVersion),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IntranetHomePage(userId: '')));
        },
        label: const Text('Add New'),
        icon: const Icon(Icons.thumb_up),
        backgroundColor: Colors.pink,
      ),*/
    );
  }

  BoxDecoration _getEventDecoration(DateTime day) {
    // Implementation example
    //return kEvents[day] ?? [];
    BoxDecoration decoration = BoxDecoration(
      color: Colors.indigo,
      shape: BoxShape.circle,
    );
    String todaysDate = new DateFormat('dd MMM yyyy').format(day);
    /*if(attendanceEvent.containsKey(todaysDate)){
      var list = attendanceEvent[todaysDate]?.toList();
      if(list?[0].title=='Present'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }else if(list?[0].title=='Holiday'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }
    }*/
    return decoration;
  }

  AppBar getAppbar() {
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: true,
      title: Text(
        'Permanent Planner',
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

  List<String> getList(List<FranchiseeInfo> mFrianchiseeList) {
    List<String> data = ['Select'];
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length > 150) {
        data.add(mFrianchiseeList[index].franchiseeName.substring(0, 150));
      } else
        data.add(mFrianchiseeList[index].franchiseeName);
    }
    /*return data.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value,style:TextStyle(color:Colors.black),),
      );
    }).toList();*/
    return data;
  }

  getPurposeList() {
    List<String> list = [];
    for (int index = 0; index < mCategoryList.length; index++) {
      if (mCategoryList[index].categoryName.length > 150) {
        list.add(mCategoryList[index].categoryName.substring(0, 150));
      } else
        list.add(mCategoryList[index].categoryName);
    }
    return list;
  }

  getCategory() {
    int id = 0;
    debugPrint(_categoryController.text.toString());
    for (int index = 0; index < mCategoryList.length; index++) {
      debugPrint(mCategoryList[index].categoryName);
      if (_categoryController.text.toString() == mCategoryList[index].categoryName) {
        id = mCategoryList[index].categoryId;
      }
    }
    debugPrint('Category is ${id}');
    return id;
  }
  getCategoryList() {
    String id = '';
    String token = '';
    debugPrint('controller is ${_categoryController.text.toString()}');
    debugPrint(_categoryController.text.toString());
    var category = _categoryController.text.toString().split(',');
    for (int index = 0; index < mCategoryList.length; index++) {
      for(int jIndex=0;jIndex<category.length;jIndex++) {
        if (category[jIndex].toString().trim() == mCategoryList[index].categoryName.trim()) {
          debugPrint(mCategoryList[index].categoryName);
          id = id + token + mCategoryList[index].categoryId.toString();
          token = ',';
        }
      }
    }
    debugPrint('Category is ${id}');
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

  void openCategory() async {
    _showMultiSelect(context);
  }

  @override
  void onClick(int action, value) {
    // TODO: implement onClick
    Navigator.pop(context, 'DONE');
  }

  syncQuestionsData(int cvfId,categotyId){
    DateTime time = DateTime.now();
    QuestionsRequest request = QuestionsRequest(
        Category_Id: categotyId,
        Business_id: '1',
        PJPCVF_Id: cvfId.toString());
    APIService apiService = APIService();
    apiService.getCVFQuestions(request).then((value) {
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is QuestionResponse) {
          QuestionResponse questionResponse = value;

          if (questionResponse != null && questionResponse.responseData != null) {
            DBHelper dbHelper = DBHelper();
            debugPrint('data saved ....');
            dbHelper.insertCVFQuestions(
                cvfId.toString(),categotyId, json.encode(questionResponse.toJson()), 0);
            setState(() {});
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      // Navigator.of(context).pop();
      setState(() {});
    });
  }

  saveCvfQuestionsPref(int cvfId,String categoryid, String data) async {
    hiveBox.put(
        cvfId.toString() +
            categoryid +
            LocalConstant.KEY_CVF_QUESTIONS,
        data);
  }

  fetchQuestions(int cvfId){
    Utility.showLoaderDialog(context);
    String category = getCategoryList();
    QuestionsRequest request = QuestionsRequest(
        Category_Id: category,
        Business_id: '1',
        PJPCVF_Id: cvfId.toString());
    APIService apiService = APIService();
    apiService.getCVFQuestions(request).then((value) {
      if (value != null) {
        Navigator.of(context).pop();
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is QuestionResponse) {
          QuestionResponse questionResponse = value;

          if (questionResponse != null &&
              questionResponse.responseData != null) {
            saveCvfQuestionsPref(cvfId,category, json.encode(questionResponse.toJson()));

            //mQuestionMaster.addAll(questionResponse.responseData);
            DBHelper dbHelper = DBHelper();
            debugPrint('data saved ....');
            dbHelper.insertCVFQuestions(cvfId.toString(),category,
                json.encode(questionResponse.toJson()), 0);
            //insertQuestions();
            Utility.showMessageSingleButton(context, "CVF added successfully", this);
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      // Navigator.of(context).pop();
      setState(() {});
    });
  }


}
