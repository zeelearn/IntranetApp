import 'package:Intranet/pages/pjp/cvf/add_cvf.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/LightColor.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/pjp/cvf/mypjpcvf.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../api/APIService.dart';
import '../../api/request/pjp/add_pjp_request.dart';
import '../../api/response/pjp/add_pjp_response.dart';
import '../helper/DBConstant.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LocalConstant.dart';
import '../iface/onClick.dart';
import '../iface/onResponse.dart';
import '../widget/primary_button.dart';
import 'models/PjpModel.dart';

class AddNewPJPScreen extends StatefulWidget {
  int employeeId;
  int businessId;
  DateTime currentDate;
  AddNewPJPScreen(
      {Key? key,
      required this.employeeId,
      required this.businessId,
      required this.currentDate})
      : super(key: key);

  @override
  State<AddNewPJPScreen> createState() => _AddNewPJPState();
}

class _AddNewPJPState extends State<AddNewPJPScreen>
    implements onResponse, onClickListener {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
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
    _fromDate = widget.currentDate;
    _toDate = widget.currentDate;
    _focusedDay = widget.currentDate;
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
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 1100;
    final bool isTablet = width >= 600 && width <= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        elevation: 0.0,
        centerTitle: false,
        title: Text(
          "Add New PJP",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 900),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
            child: isDesktop || isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildCalendarCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildFormCard()),
                    ],
                  )
                : Column(
                    children: [
                      _buildCalendarCard(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_outlined,
                    color: kPrimaryLightColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Select Journey Dates",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LightColors.kDarkBlue,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            TableCalendar(
              firstDay:
                  DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              rangeStartDay: _fromDate,
              rangeEndDay: _toDate,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  if (start != null) {
                    _fromDate = start;
                    _toDate = end ?? start;
                  }
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: kPrimaryLightColor),
                ),
                todayTextStyle: const TextStyle(color: Colors.black),
                selectedTextStyle: const TextStyle(color: Colors.white),
                rangeStartTextStyle: const TextStyle(color: Colors.white),
                rangeEndTextStyle: const TextStyle(color: Colors.white),
                rangeStartDecoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: kPrimaryLightColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectedDatesSummary(),
            const SizedBox(height: 24),
            Text(
              "Purpose of Visit",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: LightColors.kDarkBlue,
              ),
            ),
            const SizedBox(height: 12),
            _buildRemarkInput(),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "CREATE PJP PLAN",
              onPressed: addNewPjp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkInput() {
    return TextFormField(
      controller: _remarkController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Enter specific details about your visit purpose...',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryLightColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSelectedDatesSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryLightColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryLightColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDateDisplay("From Date", _fromDate),
          const Icon(Icons.arrow_forward_rounded,
              color: kPrimaryLightColor, size: 24),
          _buildDateDisplay("To Date", _toDate),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(String label, DateTime date) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('MMM dd').format(date),
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColors.kDarkBlue),
        ),
        Text(
          DateFormat('EEEE').format(date),
          style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  // Keep for compatibility but redirected to modern implementation
  getInput(String hint) {
    return _buildRemarkInput();
  }

  // Keep for compatibility but redirected to modern implementation
  selectedDates() {
    return _buildSelectedDatesSummary();
  }

  Future<bool> isValidate() async {
    if (_remarkController.text.isEmpty) {
      Utility.showMessages(context, "Please Enter Remark and submit again");
      return false;
    }else if (_remarkController.text.trim().isEmpty) {
      Utility.showMessages(context, "Please Enter Remark and submit again");
      return false;
    } else if (!await Utility.isInternet()) {
      Utility.noInternetConnection(context);
      return false;
    } else {
      return true;
    }
  }

  AddPJPRequest? request;
  addNewPjp() async {
    if (await isValidate()) {
      Utility.showLoaderDialog(context);
      //mCategoryList.clear();
      mPjpModel.fromDate = _fromDate;
      mPjpModel.toDate = _toDate;
      request = AddPJPRequest(
          Business_Id: widget.businessId,
          FromDate: Utility.convertShortDate(mPjpModel.fromDate),
          ToDate: Utility.convertShortDate(mPjpModel.toDate),
          ByEmployee_Id: widget.employeeId.toString(),
          remarks: _remarkController.text.toString());
      mPjpModel.remark = _remarkController.text.toString();
      APIService apiService = APIService();
      apiService.addNewPJP(request!).then((value) {
        Navigator.of(context).pop();
        if (value != null) {
          if (value == null || value.responseData == null) {
            //Utility.showMessage(context, 'data not found');
            Utility().showPJPStatusDialog(
              pageContext: context,
              pjp: mPjpModel,
              listener: this,
              isSuccess: false,
              message:"Something went wrong. Please try again"
            );
          } else if (value is NewPJPResponse) {
            NewPJPResponse response = value;
            //DBHelper().updatePJP(1, mPjpModel.pjpId, response.responseData);
            mPjpModel.pjpId = response.responseData;
            mPjpModel.fromDate = _fromDate as DateTime;
            mPjpModel.toDate = _toDate as DateTime;
            mPjpModel.isSync = true;
            //mPjpModel.isActive = true;
            mPjpModel.remark = _remarkController.text.toString();

            addPJPinDB(1);
            String message = response.responseMessage ?? "Your PJP has been created successfully.";
            
            // Utility.showMessageSingleButton(
            //     context, "PJP Added successfully", this,
            //     object: mPjpModel);

            Utility().showPJPStatusDialog(
              pageContext: context,
              pjp: mPjpModel,
              listener: this,
              isSuccess: true,
              message: message
            );
           
            // Utility.showMessageMultiButton(context, "Done", "Add CVF",
            //     "Success", "PJP Added successfully", mPjpModel, this);

            //IntranetServiceHandler.loadPjpSummery(widget.employeeId, mPjpModel.pjpId,this);
          } else {
            addPJPinDB(0);
            Utility().showPJPStatusDialog(
              pageContext: context,
              pjp: mPjpModel,
              listener: this,
              isSuccess: false,
              message:"Something went wrong. Please try again"
            );
          }
        }else{
          Utility().showPJPStatusDialog(
              pageContext: context,
              pjp: mPjpModel,
              listener: this,
              isSuccess: false,
              message:"Something went wrong. Please try again"
            );
        }
        setState(() {});
      });
    }
  }

  
  onsetp2(PJPInfo infoModel) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MyPJPCVFListScreen(
                mPjpInfo: infoModel,
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
    if (value is PjpListResponse) {
      PjpListResponse response = value;
      if (response.responseData != null && response.responseData.length > 0) {
        onsetp2(response.responseData[0]);
      } else {
      }
    } else {
    }
  }

  @override
  void onClick(int action, value) {
    // print("onClick action: $action, value: $value");
    if (action == Utility.ACTION_OK) {
      Navigator.of(context).pop(value);
    } else if (action == Utility.ACTION_CCNCEL) {
      if (value is PJPModel) {
        PJPModel model = value;
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddCVFScreen(
                    mPjpModel: PJPInfo(
                        PJP_Id: model.pjpId.toString(),
                        displayName: '',
                        fromDate: request!.FromDate,
                        toDate: request!.ToDate,
                        remarks: request!.remarks,
                        isSelfPJP: '1',
                        Status: '',
                        ApprovalStatus: 'pending'),
                  )),
        );
      }
    } else {
      Navigator.pop(context, 'DONE');
    }
  }
}
