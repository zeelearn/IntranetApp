import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import '../../../api/APIService.dart';
import '../../../api/request/pjp/employee_request.dart';
import '../../../api/response/pjp/employee_response.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/utils.dart';
import '../../model/filter.dart';

class EmplyeeFilter extends StatefulWidget {
  const EmplyeeFilter({super.key});

  @override
  State<EmplyeeFilter> createState() => _EmplyeeFilterState();
}

class _EmplyeeFilterState extends State<EmplyeeFilter> {
  final FilterSelection _selection =
      FilterSelection(filters: [], type: FILTERStatus.MYSELF);

  List<EmployeeInfoModel> allEmployeeList = [];
  List<EmployeeInfoModel> foundEmployeeList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadSummery();
    });
  }

  void _runFilter(String enteredKeyword) {
    List<EmployeeInfoModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = allEmployeeList;
    } else {
      results = allEmployeeList
          .where((emplyeeinfo) => emplyeeinfo.ename
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      foundEmployeeList = results;
    });
  }

  loadSummery() {
    Utility.showLoaderDialog(context);
    foundEmployeeList.clear();
    var hive = Hive.box(LocalConstant.KidzeeDB);

    var employeeId = hive.get(LocalConstant.KEY_EMPLOYEE_ID);
    EmployeeListRequest request =
        EmployeeListRequest(SuperiorId: int.parse(employeeId.toString()));
    APIService apiService = APIService();
    apiService.getEmployeeListPJP(request).then((value) {
      debugPrint(' value is ${value.toString()}');
      if (value != null) {
        if (value == null || value.responseData == null) {
          debugPrint('value is nill');
          Utility.showMessage(context, 'data not found');
        } else if (value is EmployeeListPJPResponse) {
          debugPrint('value is in object');
          EmployeeListPJPResponse response = value;
          allEmployeeList.clear();
          allEmployeeList.addAll(response.responseData);
          foundEmployeeList.clear();
          foundEmployeeList.addAll(response.responseData);
          setState(() {});
          debugPrint('summery list ${_selection.filters.length}');
        } else {
          debugPrint('value is null');
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        centerTitle: true,
        /*   actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'APPLY',
            onPressed: () {
              Navigator.pop(context, _selection);
            },
          ),
        ], */
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    var hive = Hive.box(LocalConstant.KidzeeDB);

                    var employeeId = hive.get(LocalConstant.KEY_EMPLOYEE_ID);

                    Navigator.pop(context, employeeId + '.0');
                  },
                  child: Container(
                      margin: const EdgeInsets.all(
                        20,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ), //Border.all
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Self',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Lottie.asset('assets/json/tap_animation.json',
                              height: 40, fit: BoxFit.fitHeight)
                        ],
                      ))),
              Container(
                  margin: const EdgeInsets.only(right: 20, left: 20),
                  padding: const EdgeInsets.all(8),
                  child: const Text('My Team')),
              Container(
                margin: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                child: TextField(
                    onChanged: _runFilter,
                    decoration: const InputDecoration(
                      hintText: 'Employee name',
                      border: UnderlineInputBorder(),
                      labelText: 'Employee name',
                      hintStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal),
                    )),
              ),
              getFilterListView(),
            ]),
      ),
    );
  }

  getFilterListView() {
    if (foundEmployeeList.isEmpty) {
      debugPrint('PJP List not available');
      return Utility.emptyDataSet(context, "Filters are not avaliable");
    } else {
      return getListView();
    }
  }

  getListView() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: foundEmployeeList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(
                              context, foundEmployeeList[index].employeeId);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              foundEmployeeList[index].ename,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5),
                            ),
                            Lottie.asset('assets/json/tap_animation.json',
                                height: 40, fit: BoxFit.fitHeight)
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
