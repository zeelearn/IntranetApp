import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/ServiceHandler.dart';
import 'package:intranet/api/response/pjp/pjplistresponse.dart';
import 'package:intranet/pages/helper/constants.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/pjp/cvf/mypjpcvf.dart';
import 'package:intranet/pages/widget/input_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../api/APIService.dart';
import '../../api/request/pjp/add_pjp_request.dart';
import '../../api/response/pjp/add_pjp_response.dart';
import '../helper/DBConstant.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LocalConstant.dart';
import '../iface/onResponse.dart';
import '../utils/theme/colors/light_colors.dart';
import '../widget/primary_button.dart';
import 'models/PjpModel.dart';

class AddNewPJPScreen extends StatefulWidget {

  int employeeId;
  AddNewPJPScreen({Key? key,required this.employeeId}) : super(key: key);

  @override
  State<AddNewPJPScreen> createState() => _AddNewPJPState();
}

class _AddNewPJPState extends State<AddNewPJPScreen> implements onResponse{

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  var _remarkController = TextEditingController(text: '');
  late PJPModel mPjpModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mPjpModel = PJPModel(
        pjpId: 0,
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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text(
          "Add New PJP",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            children: [
              Container(
                height: 300.0,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add(const Duration(days: 30)),
                  initialSelectedRange: PickerDateRange(
                      DateTime.now(),
                      DateTime.now()),
                  onSelectionChanged: _onSelectionChanged,
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      selectedDates(),
                      getInput('Enter Remark'),
                      /*BookingPropertyFeatures(),*/
                      SizedBox(
                        height: 10.0,
                      ),
                      PrimaryButton(
                        text: "Add NEW PJP",
                        onPressed: () {
                          addNewPjp();
                          Utility.showMessage(context, 'Please wait..');
                        },
                      )
                    ],
                  ),
                )
              )

            ],
          ),
        ),
      ),
    );
  }

  getInput(String hint){
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Color.fromRGBO(215, 219, 221, 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: TextFormField(
        controller: _remarkController,
        obscureText: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.0,
            color: Color.fromRGBO(124, 124, 124, 1),
            fontWeight: FontWeight.w600,
          ),

          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        print('range');
        print(args.value.toString());
        _fromDate = args.value.startDate;
        _toDate = args.value.endDate ?? args.value.startDate;

        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
        print(_range);
      } else if (args.value is DateTime) {
        print('dateTime');
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        print('datetime lise');
        _dateCount = args.value.length.toString();
      } else {
        print('else');
        _rangeCount = args.value.length.toString();
      }
    });
  }

  selectedDates() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "NEW PJP",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "From Date",
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      '${DateFormat('MMM dd').format(_fromDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      '${DateFormat('EEEE').format(_fromDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 45.0,
                  height: 45.0,
                  decoration: BoxDecoration(
                    color: kPrimaryLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FlutterIcons.arrowright_ant,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "To Date",
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      '${DateFormat('MMM dd').format(_toDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      '${DateFormat('EEEE').format(_toDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  addNewPjp() {
    Utility.showLoaderDialog(context);
    //mCategoryList.clear();
    //print('categoty');
    mPjpModel.fromDate = _fromDate;
    mPjpModel.toDate = _toDate;
    AddPJPRequest request = AddPJPRequest(
        FromDate: Utility.convertShortDate(mPjpModel.fromDate),
        ToDate: Utility.convertShortDate(mPjpModel.toDate),
        ByEmployee_Id: widget.employeeId.toString(),
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
          mPjpModel.fromDate = _fromDate as DateTime;
          mPjpModel.toDate = _toDate as DateTime;
          mPjpModel.isSync = true;
          //mPjpModel.isActive = true;
          mPjpModel.remark = _remarkController.text.toString();
          print('New PJP ID ${mPjpModel.pjpId} ');

          addPJPinDB(1);
          Navigator.pop(context, 'DONE');
          //IntranetServiceHandler.loadPjpSummery(widget.employeeId, mPjpModel.pjpId,this);
        } else {
          addPJPinDB(0);
          Utility.showMessage(context, 'Unable to Add New PJP Details');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  onsetp2(PJPInfo infoModel) {
    print('onStep 2');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MyPJPCVFListScreen(mPjpInfo: infoModel,
          )),
    );
  }



  addPJPinDB(int isSync) async {
    DBHelper dbHelper = DBHelper();

    Map<String, Object> data = {
      DBConstant.DATE: Utility.parseDate(DateTime.now()),
      DBConstant.FROM_DATE: Utility.parseDate(_fromDate),
      DBConstant.TO_DATE: Utility.parseDate(_toDate),
      DBConstant.IS_SYNC: 0,
      DBConstant.IS_DELETE: 0,
      DBConstant.REMARK: _remarkController.text.toString(),
      DBConstant.IS_ACTIVE: 1,
      DBConstant.IS_CHECK_IN: 0,
      DBConstant.IS_CHECK_OUT: 0,
      DBConstant.IS_CVF_COMPLETED: 0,
      DBConstant.EMP_CODE: widget.employeeId,
      DBConstant.MODIFIED_DATE: Utility.parseDate(DateTime.now()),
      DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
    };
    dbHelper.insert(LocalConstant.TABLE_PJP_INFO, data);
    print('db update');

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
    print('onResponse');
    Navigator.of(context).pop();
    if(value is PjpListResponse){
      PjpListResponse response = value;
      print('onResponse in if ');
      if(response.responseData!=null && response.responseData.length>0){
        print('onResponse ${response.responseData.length}');
        onsetp2(response.responseData[0]);
      }else{
        print('onResponse in if else');
      }
    }else{
      print('onResponse in else');
    }
  }



}