import 'package:Intranet/pages/outdoor/cubit/getplandetailscubit/getplandetails_cubit.dart';
import 'package:Intranet/pages/outdoor/model/getplandetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

import '../../helper/LocalConstant.dart';
import 'calendar/scrolling_years_calendar.dart';
import 'calendar/utils/dates.dart';
import 'employeeFilter.dart';
import 'selectedMonthPlanner.dart';

final today = DateUtils.dateOnly(DateTime.now());

class MyOutdoorPlanner extends StatefulWidget {
  const MyOutdoorPlanner({super.key});

  @override
  State<MyOutdoorPlanner> createState() => _MyOutdoorPlannerState();
}

class _MyOutdoorPlannerState extends State<MyOutdoorPlanner> {
  String? selectedYear = DateTime.now().year.toString();

  List<HighlightDateColorModel> highlightedDate = [];

  List<GetPlanData> listofGetplanData = [];
  String employeeID = '0';

  @override
  void initState() {
    super.initState();
    var hive = Hive.box(LocalConstant.KidzeeDB);

    employeeID = hive.get(LocalConstant.KEY_EMPLOYEE_ID);
    BlocProvider.of<GetplandetailsCubit>(context)
        .getPlanDetails(int.parse(employeeID));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Month'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmplyeeFilter(),
                  )).then((value) {
                if (value != null) {
                  employeeID = value
                      .toString()
                      .substring(0, value.toString().length - 2);
                  BlocProvider.of<GetplandetailsCubit>(context)
                      .getPlanDetails(int.parse(employeeID));
                }
              });
            },
          ),
        ],
      ),
      body: BlocListener<GetplandetailsCubit, GetplandetailsState>(
        listener: (context, getPlandetailState) {
          if (getPlandetailState is GetplandetailsSuccessState) {
            listofGetplanData.clear();
            highlightedDate.clear();

            listofGetplanData = getPlandetailState.listofplandata;
            for (var element in getPlandetailState.listofplandata) {
              element.visitDate != null
                  ? highlightedDate.add(HighlightDateColorModel(
                      dateTime: DateTime.parse(element.visitDate!),
                      color: getColorStatus(element.status)))
                  : null;
            }

            setState(() {});
          } else if (getPlandetailState is GetplandetailsErrorState) {
            Fluttertoast.showToast(
                msg: getPlandetailState.error,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        },
        child: BlocBuilder<GetplandetailsCubit, GetplandetailsState>(
          builder: (context, state) {
            if (state is GetplandetailsLoadingState) {
              // Utility.showLoaderDialog(context);
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Container(
                        margin: const EdgeInsets.only(left: 7),
                        child: const Text("Loading...")),
                  ],
                ),
              );
            } else if (state is GetplandetailsErrorState) {
              return Center(
                child: Text(state.error),
              );
            } else {
              return ListView(
                shrinkWrap: true,
                children: [
                  DropdownButton<String>(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    underline: const SizedBox.shrink(),
                    isExpanded: false,
                    hint: const Text('Select Year'),
                    value: selectedYear,
                    items: <String>[
                      '2026',
                      '2025',
                      '2024',
                      '2023',
                      '2022',
                      '2021',
                      '2020'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedYear = value;
                      setState(
                        () {},
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ScrollingYearsCalendar(
                    context: context,
                    initialDate:
                        DateTime.now().copyWith(year: int.parse(selectedYear!)),
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 1))
                        .copyWith(year: int.parse(selectedYear!)),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 1))
                        .copyWith(year: int.parse(selectedYear!)),
                    currentDateColor: Colors.white,
                    highlightedDates: highlightedDate,
                    highlightedDateColor: Colors.deepOrange,
                    monthNames: const <String>[
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ],
                    onMonthTap: (int year, int month) {
                      debugPrint('Tapped $month/$year');
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectedMonthPlanner(
                                  year: year,
                                  month: month,
                                  highlightDate: listofGetplanData,
                                  selectedEmplyee: employeeID,
                                ),
                              ))
                          .then((value) =>
                              BlocProvider.of<GetplandetailsCubit>(context)
                                  .getPlanDetails(int.parse(employeeID)));
                    },
                    monthTitleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Color getColorStatus(String? type) {
    if (type == "FILL CVF") {
      return const Color(0xFFFFBF00);
    } else if (type == 'Pending') {
      return const Color(0xFFF08080);
    } else if (type == 'Completed') {
      return const Color(0xFF2ECC71);
    } else {
      return Colors.transparent;
    }
  }
}
