import 'dart:collection';
import 'dart:convert';

import 'package:Intranet/pages/dashboard/KPIModel.dart';
import 'package:Intranet/pages/dashboard/chart/core/categorybox.dart';
import 'package:Intranet/pages/dashboard/chart/core/chatindicator.dart';
import 'package:Intranet/pages/dashboard/chart/core/expenses.dart';
import 'package:Intranet/pages/dashboard/chart/radial.dart';
import 'package:Intranet/pages/dashboard/sampledata.dart';
import 'package:Intranet/pages/dashboard/topmenu/topmenu.dart';
import 'package:Intranet/pages/filter/filter.dart';
import 'package:Intranet/pages/filter/filterrequest.dart';
import 'package:Intranet/pages/filter/myFilterData.dart';
import 'package:Intranet/pages/helper/LightColor.dart';
import 'package:Intranet/pages/helper/helpers.dart';
import 'package:Intranet/pages/home/detail_kpi.dart';
import 'package:Intranet/pages/pjp/cvf/Questions.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/widget/indicator.dart';
import 'package:Intranet/pages/widget/month_picker_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:Intranet/pages/widget/zllwidgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../helper/utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State {
  int touchedIndex = -1;
  late DateTime selectedDate = DateTime.now();
  late FilterRequest filterRequest;
  late DashboardFilterData? filterData;
  KPIInfo? kpilist = null;

  int totalENTarget = 0;
  int actualENTarget = 0;
  int totalACKTarget = 0;
  int actualACKTarget = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterRequest = FilterRequest(year: '', month: '', employee: '', zone: '');
    filterData =
        DashboardFilterData(HashMap<String, List<String>>(), kpiInfo: kpilist);
    filterRequest.month = Utility.getShortMonth(DateTime.now());
    insertFilters();
    generateKPIs();
  }

  insertFilters() {
    sample_data.toString();
    if (filterData!.franchinseeList == null) {
      filterData!.franchinseeList = [];
    } else
      filterData!.franchinseeList!.clear();

    if (filterData!.employeeList == null) {
      filterData!.employeeList = [];
    } else {
      filterData!.employeeList!.clear();
    }
    //print(sample_data.toString());
    kpilist = KPIInfo.fromJson(jsonDecode(SampleData.list.toString()));
    filterData!.kpiInfo = kpilist;
    Map<String, String> franchisee = Map<String, String>();
    for (int index = 0; index < kpilist!.data!.length; index++) {
      if (!franchisee.containsKey(kpilist!.data![index].franchiseCodeName)) {
        filterData!.franchinseeList!
            .add(kpilist!.data![index].franchiseCodeName!);
        franchisee.putIfAbsent(kpilist!.data![index].franchiseCodeName!,
            () => kpilist!.data![index].franchiseCodeName!);
      }
    }
    filterData!.zoneList = [];
    Map<String, String> zoneMap = Map<String, String>();
    for (int index = 0; index < kpilist!.data!.length; index++) {
      if (!zoneMap.containsKey(kpilist!.data![index].zone)) {
        filterData!.zoneList!.add(kpilist!.data![index].zone!);
        zoneMap.putIfAbsent(
            kpilist!.data![index].zone!, () => kpilist!.data![index].zone!);
      }
    }

    Map<String, String> employee = Map<String, String>();
    for (int index = 0; index < kpilist!.data!.length; index++) {
      if (!employee.containsKey(kpilist!.data![index].zM)) {
        filterData!.employeeList!.add(kpilist!.data![index].zM!);
        employee.putIfAbsent(
            kpilist!.data![index].zM!, () => kpilist!.data![index].zM!);
      }
    }
    for (int index = 0; index < kpilist!.data!.length; index++) {
      if (!employee.containsKey(kpilist!.data![index].tM)) {
        filterData!.employeeList!.add(kpilist!.data![index].tM!);
        employee.putIfAbsent(
            kpilist!.data![index].tM!, () => kpilist!.data![index].tM!);
      }
    }
    getCenters(kpilist!.data!);
    getEnrollments(kpilist!.data!);
    //filterData!.franchinseeList!.addAll(kpilist!.data.)
  }

  bool isFilterMatch(KPIModel model) {
    bool isFilterMatched = false;
    if (filterRequest.isEmpty()) {
      isFilterMatched = true;
    } else if (filterRequest.franchisee == model.franchiseCodeName) {
      isFilterMatched = true;
    } else if (filterRequest.employee == model.zM ||
        filterRequest.employee == model.tM) {
      isFilterMatched = true;
    } else if (filterRequest.zone == model.zone) {
      isFilterMatched = true;
    } else if (filterRequest.month == model.month) {
      isFilterMatched = true;
    }
    return isFilterMatched;
  }

  List<KPIModel> centers = [];
  getCenters(List<KPIModel> list) {
    if (centers == null) {
      centers = [];
    } else
      centers.clear();
    Map<String, String> centerMap = Map<String, String>();
    for (int index = 0; index < list.length; index++) {
      if (isFilterMatch(list[index])) {
        if (!centerMap.containsKey(kpilist!.data![index].franchiseCodeName)) {
          centers.add(kpilist!.data![index]);
        }
      }
    }
  }

  List<KPIModel> totalEnrollments = [];
  getEnrollments(List<KPIModel> list) {
    totalENTarget = 0;
    actualENTarget = 0;
    totalACKTarget = 0;
    actualACKTarget = 0;
    filterData!.totalEnrollments = 0;
    filterData!.totalAck = 0;
    for (int index = 0; index < list.length; index++) {
      if (isFilterMatch(list[index])) {
        totalENTarget += toInt(list[index].targetEN!);
        totalACKTarget = toInt(list[index].targetACK!);
        actualENTarget += toInt(list[index].eNAct!);
        actualACKTarget = toInt(list[index].aCKACT!);
      }
    }
    filterData!.totalEnrollments = totalENTarget;
    filterData!.totalAck = totalACKTarget;

    filterData?.totalCenters = centers.length;
  }

  generateKPIs() {
    kpilist = KPIInfo.fromJson(jsonDecode(SampleData.list.toString()));
    getCenters(kpilist!.data!);
    getEnrollments(kpilist!.data!);
    // for(int index=0;index< kpilist!.data!.length;index++){
    //   if(filterRequest==null ||  filterRequest.isEmpty()){
    //       totalACKTarget += toInt(kpilist!.data![index].targetACK!);
    //       actualACKTarget += toInt(kpilist!.data![index].aCKACT!);
    //
    //       totalENTarget += toInt(kpilist!.data![index].targetEN!);
    //       actualENTarget += toInt(kpilist!.data![index].eNAct!);
    //       // totalCenters++;
    //       // totalACK++;
    //       // totalEnrollment++;
    //   }else if(filterRequest.employee==kpilist!.data![index].tM || filterRequest.employee==kpilist!.data![index].zM ||
    //       filterRequest.franchisee == kpilist!.data![index].franchiseCodeName
    //   ){
    //     print('generatting kpis 115');
    //       totalACKTarget += toInt(kpilist!.data![index].targetACK!);
    //       actualACKTarget += toInt(kpilist!.data![index].aCKACT!);
    //       totalENTarget += toInt(kpilist!.data![index].targetEN!);
    //       actualENTarget += toInt(kpilist!.data![index].eNAct!);
    //     // totalACK++;
    //     // totalEnrollment++;
    //   }
    // }
    setState(() {});
  }

  int toInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LightColors.kLightGray,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            ZllWidgets.getAppBarUI('Sudhir Patil', 'Good Morning'),
            //Divider(color: LightColors.kLightGray1,),
            CategoriesHorizontalListViewBar(),
            //Divider(color: LightColors.kLightGray1,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showMonthPicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(DateTime.now().year - 1, 5),
                            lastDate: DateTime.now())
                        .then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          filterRequest.month = Utility.getShortMonth(date);
                          print('Date Picker ${selectedDate}');
                          insertFilters();
                        });
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 25),
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: LightColors.kLightGray1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Text(
                      filterRequest.month,
                      style: LightColors.subTextStyle,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FiltersAppScreen(
                          mFilterRequest: filterRequest,
                          filterData: filterData!,
                        ),
                      ),
                    ).then((value) {
                      debugPrint('back to Dashboard....${value}');
                      if (value == null) {
                        //clear Filter
                      } else {
                        filterRequest = value;
                        generateKPIs();
                      }
                      //onClick(ActionConstant.TICKET_LISTING, 0);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 25),
                    child: Icon(Icons.filter_alt),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                          height: context.height * 0.5,
                          child: enrollmentChart()),
                      SizedBox(height: 200, child: _kpi()),
                      //_quickStatsWidget()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  enrollmentChart() {
    print(
        'actual 303 ${totalACKTarget.toDouble()} ${actualACKTarget.toDouble()}');
    print(
        'Target 304 ${totalENTarget.toDouble()} ${actualENTarget.toDouble()}');
    return Card(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        child: CategoryBox(
          suffix: Container(),
          title: "My Progress",
          children: [
            Container(
                child: RandomizedRadialChartExample(
              targetAck: totalACKTarget.toDouble(),
              targetEnrollment: totalENTarget.toDouble(),
              actualAck: actualACKTarget.toDouble(),
              actualEnrollment: actualENTarget.toDouble(),
            )),
            //SizedBox(height: 20,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailKpiScreen(
                      kipList: kpilist == null ? [] : kpilist!.data!,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(bottom: 18),
                height: 100,
                child: _otherExpanses(getKPIStatus()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getKPIStatus() {
    return [
      Expense(
        color: LightColors.kDarkBlue,
        expenseName: "Enrollment",
        target: totalENTarget.toString(),
        actual: actualENTarget.toString(),
      ),
      Expense(
        color: LightColors.kGreen,
        expenseName: "ACK",
        target: totalACKTarget.toString(),
        actual: actualACKTarget.toString(),
      ),
    ];
  }

  _kpi() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: CategoryBox(
          suffix: Container(),
          title: "KPI",
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: _row4Widget(),
            )
          ],
        ),
      ),
    );
  }

  // static List<Expense> get otherExpanses {
  //   return [
  //     Expense(
  //       color: LightColors.kRed,
  //       expenseName: "Enrollment",
  //       target: ,
  //     ),
  //     Expense(
  //       color: LightColors.kDarkOrange,
  //       expenseName: "ACK",
  //       expensePercentage: 350,
  //     ),
  //
  //   ];
  // }
  final ScrollController _scrollController = ScrollController();
  Widget _otherExpanses(List<Expense> otherExpenses) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        color: LightColors.defaultLightWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(2),
        children: otherExpenses
            .map((Expense e) => ExpenseWidget(expense: e))
            .toList(),
      ),
    );
  }

  Widget _quickStatsWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Text(
            "Quick Stats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          _row4Widget()
          // widget.sizingInformation.screenSize.width / 1.4 <= 860
          //     ? _row2by2Widget()
          //     : _row4Widget()
        ],
      ),
    );
  }

  Widget _row4Widget() {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailKpiScreen(
                kipList: kpilist == null ? [] : kpilist!.data!,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ZllWidgets.singleItemQuickStats(
                title: "Centers",
                value: filterData!.totalCenters.toString(),
                width: context.width / 3.8,
                icon: null, //Icons.arrow_upward_outlined,
                iconColor: Colors.green),
            ZllWidgets.singleItemQuickStats(
                title: "Enrollments",
                value: filterData!.totalEnrollments.toString(),
                width: context.width / 3.8,
                icon: null, //Icons.arrow_downward,
                iconColor: LightColors.kRed,
                textColor: LightColors.kDarkBlue),
            ZllWidgets.singleItemQuickStats(
                title: "ACK",
                value: filterData!.totalAck.toString(),
                width: context.width / 3.8,
                icon: null, //Icons.arrow_upward,
                iconColor: Colors.green),
          ],
        ),
      ),
    );
  }

  @override
  Widget getChart() {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Stack(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Expanded(
                  child: Container(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 70,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: LightColors.kDarkOrange,
                text: 'First',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: LightColors.kDarkBlue,
                text: 'Second',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              // Indicator(
              //   color: LightColors.kGreen,
              //   text: 'Third',
              //   isSquare: true,
              // ),
              // SizedBox(
              //   height: 4,
              // ),
              // Indicator(
              //   color: LightColors.kLightRed,
              //   text: 'Fourth',
              //   isSquare: true,
              // ),
              // SizedBox(
              //   height: 18,
              // ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: LightColors.kDarkOrange,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: LightColors.kDarkBlue,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: LightColors.kGreen,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: LightColors.kLightRed,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
