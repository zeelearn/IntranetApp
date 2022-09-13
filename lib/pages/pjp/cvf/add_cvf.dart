import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/request/cvf/add_cvf_request.dart';
import '../../../api/request/cvf/category_request.dart';
import '../../../api/request/cvf/centers_request.dart';
import '../../../api/response/cvf/add_cvf_response.dart';
import '../../../api/response/cvf/category_response.dart';
import '../../../api/response/cvf/centers_respinse.dart';
import '../../helper/DBConstant.dart';
import '../../helper/DatabaseHelper.dart';
import '../../helper/LightColor.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/LocalStrings.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../home/IntranetHomePage.dart';
import '../../utils/theme/colors/light_colors.dart';
import '../../widget/MyWidget.dart';
import '../../widget/check/checkbox.dart';
import '../../widget/date_time/time_picker.dart';
import '../../widget/options/dropdown.dart';
import '../PJPForm.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class AddCVFScreen extends StatefulWidget {
  PJPInfo mPjpModel;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  AddCVFScreen({Key? key, required this.mPjpModel}) : super(key: key);

  @override
  State<AddCVFScreen> createState() => _AddCVFState();
}

class _AddCVFState extends State<AddCVFScreen> {

  TextEditingController _activityNameController = TextEditingController();

  List<GetDetailedPJP> mCVFList = [];

  DateTime cvfDate = DateTime.now();
  late List<CategotyInfo> mCategoryList = [];
  List<FranchiseeInfo> mFrianchiseeList = [];
  TimeOfDay? vistitDateTime;
  late String _CenterName='';
  late bool _isNotify = false;
  late String _purposeMultiSelect = 'Select';
  List<String> _selectedItems = [];
  bool isAddCVF = false;
  int employeeId = 0;
  double latitude=0.0;
  double longitude=0.0;

  var _categoryController = TextEditingController(text: 'Select Purpose');
  var _dateController = TextEditingController(text: 'Select Date');
  var _locationController = TextEditingController(text: 'Select Location');
  String location = "Search Location";

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
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

  getFrichinseeList() async {
    DBHelper helper = DBHelper();

    List<FranchiseeInfo> franchiseeList = await helper.getFranchiseeList();

    if (franchiseeList == null || franchiseeList.length == 0) {
      print('data load ssss');
      loadCenterList();
    } else {
      mFrianchiseeList.addAll(franchiseeList);
      print('data ssss');
    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('cvf list ');
    Future.delayed(Duration.zero, () {
      this.loadUserData();
    });
  }

  loadUserData() {
    getUserInfo();
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
    print('day is ' + day.day.toString());
    return getCurrentEvents(day); //kEvents[day] ?? [];
  }

  getCurrentEvents(DateTime date) {
    List<GetDetailedPJP> list = [];
    print('getEvent----${mCVFList.length}');
    for (int index = 0; index < mCVFList.length; index++) {
      print(
          '${Utility.shortDate(date)}  -- ${Utility.shortDate(Utility.convertDate(mCVFList[index].visitDate))}');
      if (Utility.shortDate(date) ==
          Utility.shortDate(Utility.convertDate(mCVFList[index].visitDate))) {
        list.add(mCVFList[index]);
      }
    }
    return list;
  }

  getCenterForm() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.only(left: 10,right: 10),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10,top:10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: LightColors.kLightGray1)),
                    height: 45,
                    child: TextField(
                      //editing controller of this TextField
                      decoration: InputDecoration(
                        icon: Icon(Icons.arrow_drop_down), //icon of text field
                        //label text of field
                      ),
                      controller: _categoryController,
                      style: TextStyle(color: Colors.black),
                      readOnly: true,
                      //set it true, so that user will not able to edit text
                      onTap: () {
                        openCategory();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  datePicker(context),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: LightColors.kLightGray1)),
                    height: 50,
                    child: FastTimePicker(
                      decoration: MyWidget.getInputDecoratino('Select Time'),
                      name: 'Time',
                      onChanged: (value) {
                        vistitDateTime = value;
                      },
                    ),
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

  getFrichanseeId() {
    int code = 0;
    for (int index = 0; index < mFrianchiseeList.length; index++) {
      if (mFrianchiseeList[index].franchiseeName.length < 25) {
        if (_CenterName == mFrianchiseeList[index].franchiseeName) {
          code = mFrianchiseeList[index].franchiseeId.toInt();
        }
      } else if (_CenterName == mFrianchiseeList[index].franchiseeName.substring(0, 25)) {
        code = mFrianchiseeList[index].franchiseeId.toInt();
      }
    }
    return code;
  }

  bool validate(){
    return true;
  }

  addNewCVF() {
    if(validate()) {
      Utility.showLoaderDialog(context);
      print('categoty');
      /*String xml =
        '<root><tblPJPCVF><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility.convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime?.hour}:${vistitDateTime?.minute}</Visit_Time><Category_Id>${getCategoryId()}</Category_Id></tblPJPCVF></root>';
    */
      String xml = '<root><tblPJPCVF><Employee_Id>${employeeId}</Employee_Id><Franchisee_Id>${getFrichanseeId()}</Franchisee_Id><Visit_Date>${Utility
          .convertShortDate(cvfDate)}</Visit_Date><Visit_Time>${vistitDateTime
          ?.hour}:${vistitDateTime
          ?.minute}</Visit_Time><Category_Id>${getCategoryList()}</Category_Id><Latitude>${longitude}</Latitude><Longitude>${latitude}</Longitude><ActivityTitle>${_activityNameController.text.toString()}</ActivityTitle><Address>${location}</Address></tblPJPCVF></root>';
      AddCVFRequest request = AddCVFRequest(
          PJP_Id: int.parse(widget.mPjpModel.PJP_Id),
          DocXml: xml,
          UserId: employeeId);
      print(request.toJson());
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
            Navigator.pop(context, 'DONE');
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
  }

  getCenter(Size size) {
    return Column(
      children: [
        Container(
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
            items: getList(mFrianchiseeList),
          ),
        ),

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

            DateTime time = DateTime(cvfDate.year, cvfDate.month, cvfDate.day,
                vistitDateTime?.hour as int, vistitDateTime?.minute as int);
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
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: LightColors.kLightGray1)),
        height: 45,
        child: Center(
            child: TextField(
          //editing controller of this TextField
          decoration: InputDecoration(
            icon: Icon(Icons.calendar_today), //icon of text field
            //label text of field
          ),
          controller: _dateController,
          readOnly: true,
          //set it true, so that user will not able to edit text
          onTap: () async {
            _showDatePicker(context);
          },
        )));
  }

  Widget _getLocation(BuildContext context) {
    return //search autoconplete input
      Positioned(  //search input bar
          child: InkWell(
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
                      print(err);
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
          )
      ); /*Container(
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
    print('p is ${p!.description!}');
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
        print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
        cvfDate = pickedDate;
        String formattedDate = DateFormat('dd-MMM-yyyy').format(pickedDate);
        print(
            formattedDate); //formatted date output using intl package =>  2021-03-16
        _dateController.text = formattedDate;
      });
    } else {}
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
    print(
        'From Date ${Utility.shortDate(Utility.convertDate(widget.mPjpModel.fromDate))}');
    print(
        'To Date ${Utility.shortDate(Utility.convertDate(widget.mPjpModel.toDate))}');

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

  /*loadCVFList(){
    double width = MediaQuery.of(context).size.width;
    if (mCVFList == null ||  mCVFList.length <= 0) {
      print('CVF LIST not added ');
      return Text('');
    } else {
      return Flexible(
          child: ListView.builder(
            itemCount: mCVFList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return cvfView(mCVFList[index],width);
            },
          ));
    }
  }

  cvfView(PJPCentersInfo model,double width){
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuestionListScreen()),
        );
      },
      child: Padding(padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(color: Colors.grey,),
            padding: EdgeInsets.all(1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width * 0.10,
                    decoration: BoxDecoration(color: LightColors.kLightGray1,),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Utility.shortTime(model.dateTime as DateTime),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          Utility.shortTimeAMPM(model.dateTime as DateTime),
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
                            model.centerName as String,
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            model.purpose as String,
                            style: TextStyle(color: Colors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text(
                              'Code  : ${model.centerCode}',
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
          )
      ),
    );
  }*/

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

  getCategory() {
    int id = 0;
    print(_categoryController.text.toString());
    for (int index = 0; index < mCategoryList.length; index++) {
      print(mCategoryList[index].categoryName);
      if (_categoryController.text.toString() == mCategoryList[index].categoryName) {
        id = mCategoryList[index].categoryId;
      }
    }
    print('Category is ${id}');
    return id;
  }
  getCategoryList() {
    String id = '';
    String token = '';
    print(_categoryController.text.toString());
    for (int index = 0; index < mCategoryList.length; index++) {
      print(mCategoryList[index].categoryName);
      if (_categoryController.text.toString() == mCategoryList[index].categoryName) {
        id = id +token+ mCategoryList[index].categoryId.toString();
        token=',';
      }
    }
    print('Category is ${id}');
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
    String value = _showMultiSelect(context);
  }
}
