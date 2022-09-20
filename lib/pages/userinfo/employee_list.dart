import 'package:flutter/material.dart';
import 'package:intranet/api/response/employee_list_response.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print('didChangeAppLifecycleState ${state} ');
    if (state == AppLifecycleState.resumed) {
      loadEmployeeList();
    }
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
    loadEmployeeList();
  }

  loadEmployeeList() {
    Utility.showLoaderDialog(context);
    employeeList.clear();
    APIService apiService = APIService();
    apiService.getEmployeeList().then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is EmployeeListResponse) {
          EmployeeListResponse response = value;
          if (response != null &&
              response.responseData != null) {
            employeeList.addAll(response.responseData);
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


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: LightColors.kLightYellow,
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
                        'Employee List',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          //search functionality
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.search_sharp,
                            size: 20,
                          ),
                        ),
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
      print('data not found');
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
      trailing: Icon(Icons.call),
      onTap: () {
        Text('Another data');
      },
    );
  }


}
