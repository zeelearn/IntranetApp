import 'package:Intranet/pages/outdoor/cubit/getplandetailscubit/getplandetails_cubit.dart';
import 'package:Intranet/pages/outdoor/model/getplandetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'calendar/scrolling_years_calendar.dart';
import 'calendar/utils/dates.dart';
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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetplandetailsCubit>(context).getPlanDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Month'),
        automaticallyImplyLeading: true,
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
        child: ListView(
          shrinkWrap: true,
          children: [
            DropdownButton<String>(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
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
                          ),
                        ))
                    .then((value) =>
                        BlocProvider.of<GetplandetailsCubit>(context)
                            .getPlanDetails());
              },
              monthTitleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColorStatus(String? type) {
    if (type == "FILL CVF") {
      return Colors.yellow;
    } else if (type == 'Pending') {
      return Colors.red;
    } else if (type == 'Completed') {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }
}
