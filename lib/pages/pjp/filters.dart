import 'package:Intranet/api/request/pjp/employee_request.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/APIService.dart';
import '../../api/response/pjp/employee_response.dart';
import '../helper/LightColor.dart';
import '../helper/utils.dart';
import '../model/filter.dart';

class FiltersScreen extends StatefulWidget {
  int employeeId = 0;
  FiltersScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FiltersScreenState();
  }
}

class _FiltersScreenState extends State<FiltersScreen> {
  final FilterSelection _selection =
      FilterSelection(filters: [], type: FILTERStatus.MYSELF);

  List<FilterModel> allData = [];
  List<EmployeeInfoModel> mEmployeeList = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadSummery();
    });
  }

  loadSummery() {
    Utility.showLoaderDialog(context);
    mEmployeeList.clear();
    EmployeeListRequest request =
        EmployeeListRequest(SuperiorId: widget.employeeId);
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
          _selection.filters.clear();
          for (int index = 0; index < response.responseData.length; index++) {
            _selection.filters.add(FilterModel(
                id: (index + 2),
                name: response.responseData[index].ename,
                employeeId: 0));
            allData.add(FilterModel(
                id: (index + 2),
                name: response.responseData[index].ename,
                employeeId: 0));
          }
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

  void _runFilter(String enteredKeyword) {
    List<FilterModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = allData;
    } else {
      results = allData
          .where((filtermodel) => filtermodel.name
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _selection.filters = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'APPLY',
            onPressed: () {
              Navigator.pop(context, _selection);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          CheckboxListTile(
              activeColor: Colors.pink[300],
              dense: true,
              //font change
              title: const Text(
                'My Self',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              value: _selection.type == FILTERStatus.MYSELF ? true : false,
              onChanged: (val) {
                itemChange(val as bool, -1);
              }),
          CheckboxListTile(
              activeColor: Colors.pink[300],
              dense: true,
              //font change
              title: const Text(
                'My Team',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
              value: _selection.type == FILTERStatus.MYTEAM ? true : false,
              onChanged: (val) {
                itemChange(val as bool, -2);
              }),
          const SizedBox(
            height: 10,
          ),
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
          const SizedBox(
            height: 10,
          ),
          getFilterListView(),
        ]),
      ),
    );
  }

  Widget applyFilter(Size size) {
    return GestureDetector(
      onTap: () {
        //validate(context);
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: LightColor.primary_color,
          boxShadow: const [
            BoxShadow(
              color: LightColor.seeBlue,
              offset: Offset(0, 5.0),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Text(
          'Apply Filter',
          style: GoogleFonts.inter(
            fontSize: 16.0,
            color: LightColor.black,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  getFilterListView() {
    if (_selection.filters.isEmpty) {
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
        itemCount: _selection.filters.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  CheckboxListTile(
                      activeColor: Colors.pink[300],
                      dense: true,
                      //font change
                      title: Text(
                        _selection.filters[index].name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                      value: _selection.filters[index].isSelected,
                      onChanged: (val) {
                        itemChange(val as bool, index);
                      })
                ],
              ),
            ),
          );
        });
  }

  void itemChange(bool val, int index) {
    debugPrint('INDEX $index');
    setState(() {
      if (index == -1) {
        _selection.type = FILTERStatus.MYSELF;
        for (int index = 0; index < _selection.filters.length; index++) {
          _selection.filters[index].isSelected = false;
        }
      } else if (index == -2) {
        if (val) {
          _selection.type = FILTERStatus.MYTEAM;
          for (int index = 0; index < _selection.filters.length; index++) {
            _selection.filters[index].isSelected = val;
          }
        } else {
          _selection.type = FILTERStatus.MYSELF;
        }
        for (int index = 0; index < _selection.filters.length; index++) {
          _selection.filters[index].isSelected = val;
        }
      } else {
        debugPrint('in else');
        _selection.type = FILTERStatus.CUSTOM;
        _selection.filters[index].isSelected = val;
      }
    });
  }
}
