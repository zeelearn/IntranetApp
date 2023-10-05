import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/APIService.dart';
import '../utils/theme/colors/light_colors.dart';

class EmployeeListScreen extends StatefulWidget {
  String displayName;

  EmployeeListScreen({Key? key, required this.displayName}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  int employeeId = 0;

  List<EmployeeInfo> employeeList = [];
  List<EmployeeInfo> masterEmployeeList = [];
  String _search="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('didChangeAppLifecycleState ${state} ');
    if (state == AppLifecycleState.resumed) {
      loadEmployeeList();
    }
  }

  Future<void> getUserInfo() async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId = int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    loadEmployeeList();
  }

  loadEmployeeList() {
    Utility.showLoaderDialog(context);
    employeeList.clear();
    masterEmployeeList.clear();
    APIService apiService = APIService();
    apiService.getEmployeeList().then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is EmployeeListResponse) {
          EmployeeListResponse response = value;
          if (response != null &&
              response.responseData != null) {
            employeeList.addAll(response.responseData);
            masterEmployeeList.addAll(response.responseData);
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

  updateList(){
    employeeList.clear();
    if(_search.isNotEmpty && _search.length>0){
      for(int index=0;index<masterEmployeeList.length;index++){
        if(masterEmployeeList[index].employeeCode.contains(_search) ||
        masterEmployeeList[index].employeeFullName.contains(_search) ||
            masterEmployeeList[index].employeeDesignation.contains(_search) ||
            masterEmployeeList[index].employeeEmailId.contains(_search) ||
            masterEmployeeList[index].employeeContactNumber.contains(_search)
        ){
          employeeList.add(masterEmployeeList[index]);
        }
      }
    }else{
      employeeList.addAll(masterEmployeeList);
    }
    debugPrint('${_search}  ${employeeList.length}');
    setState(() {

    });
  }
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Employee Directory');
  Widget customleading = const Icon(
    Icons.arrow_back,
    color: Colors.white,
    size: 28,
  );
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: LightColors.kLightYellow,
        appBar: AppBar(
          title: customSearchBar,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: customleading,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    // Perform set of instructions.
                    customIcon = const Icon(Icons.cancel);

                    customleading = const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    );
                    customSearchBar =  ListTile(
                      title: TextField(
                        onChanged: (value) {
                          _search = value;
                          updateList();
                        },
                        decoration: InputDecoration(
                          hintText: 'search employee name here',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    _search = "";
                    updateList();
                    customleading =  InkWell(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    );
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('Employee Directory');
                  }
                });
              },
              icon: customIcon,
            )
          ],
          centerTitle: true,
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
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                Container(
                  color: LightColors.kLightBlue,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),

                    ],
                  ),
                ),

                getLeaveListView(),
              ],
            ),
          ),
        ));
  }

  getLeaveListView() {
    if (employeeList == null || employeeList.length <= 0) {
      debugPrint('data not found');
      return Utility.emptyDataSet(context,"Employee List are not avaliable, Please try again later");
    } else {
      return Flexible(
          child: ListView.builder(
            itemCount: employeeList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return getRow(employeeList[index]);
            },
          ));
    }
  }

  getRow(EmployeeInfo info) {

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('assets/icons/ic_user.png'),
      ),
      title: Text(
        '${info.employeeFullName}\n${info.employeeDesignation}',
      ),
      subtitle: Text(info.employeeEmailId),
      trailing: InkWell(
        onTap: () => makecall(info.employeeContactNumber),
        child: const Icon(Icons.call),
      ),
      onTap: () {
        Text('Another data');
      },
    );
  }
  makecall(String phone){
    if(phone.isNotEmpty) {
      launchUrl(Uri.parse("tel:${phone}"));
    }else{
      Utility.showMessages(context, 'Mobile number not avaliable');
    }
  }


}
