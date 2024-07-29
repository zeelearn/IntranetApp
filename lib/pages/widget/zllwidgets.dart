import 'package:Intranet/pages/Responsive.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ZllWidgets{
  
  static Widget getAppBarUI(String title,String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: LightColors.kDarkBlue,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: LightColors.kDarkBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            child: Image.asset('assets/images/useravtar.png'),
          )
        ],
      ),
    );
  }

  static Widget getSearchBarUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: HexColor('#F8FAFB'),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: LightColors.kLightBlue,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Search for course',
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('#B9BABC'),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: HexColor('#B9BABC'),
                            ),
                          ),
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.search, color: HexColor('#B9BABC')),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }

  static Widget getCard(BuildContext context, String title,String count) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Card(
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
              const SizedBox(height: 10),
              Responsive.isDesktop(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(count,style: LightColors.textHeaderStyle16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: Color(0xff77839a),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  :  Column(
                      children: <Widget>[
                        Text(
                          count,
                          style: const TextStyle(
                            color: Color(0xff77839a),
                            fontSize: 14,
                          ),
                        ),
                         SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: LightColors.kBlue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
              // const SizedBox(
              //   height: 38,
              // ),
              // Expanded(
              //   child: BarChart(
              //     BarChartData(
              //       barTouchData: BarTouchData(
              //         touchTooltipData: BarTouchTooltipData(
              //           //tooltipBgColor: Colors.grey,
              //           getTooltipItem: (_a, _b, _c, _d) => null,
              //         ),
              //       ),
              //       titlesData: FlTitlesData(
              //         show: true,
              //         rightTitles: SideTitles(showTitles: false),
              //         topTitles: SideTitles(showTitles: false),
              //         leftTitles: SideTitles(showTitles: false),
              //         bottomTitles: SideTitles(
              //           rotateAngle: Responsive.isMobile(context) ? 45 : 0,
              //           showTitles: true,
              //           getTextStyles: (context, value) => TextStyle(
              //             color: Styles.defaultLightGreyColor,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 12,
              //           ),
              //           getTitles: (double value) {
              //             switch (value.toInt()) {
              //               case 0:
              //                 return 'Mon';
              //               case 1:
              //                 return 'Tue';
              //               case 2:
              //                 return 'Wed';
              //               case 3:
              //                 return 'Thu';
              //               case 4:
              //                 return 'Fri';
              //               case 5:
              //                 return 'Sat';
              //               case 6:
              //                 return 'Sun';
              //               default:
              //                 return '';
              //             }
              //           },
              //         ),
              //       ),
              //       borderData: FlBorderData(
              //         show: false,
              //       ),
              //       barGroups: MockData.getBarChartitems(
              //         barColor,
              //         width: Responsive.isMobile(context) ? 10 : 25,
              //       ),
              //       gridData: FlGridData(show: false),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget singleItemQuickStats(
      {String? title,
      Color textColor = Colors.black,
      String? value,
      IconData? icon,
      double? width,
      Color? iconColor}) {
    return Container(
      width: width,
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
              color: iconColor!.withOpacity(.1),
              spreadRadius: 2,
              offset: Offset(0.5, 0.5),
              blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title!,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          SizedBox(
            height: 10,
          ),
          icon == null
              ? Text(
                  value!,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value!,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      icon,
                      color: iconColor,
                    )
                  ],
                ),
        ],
      ),
    );
  }

}