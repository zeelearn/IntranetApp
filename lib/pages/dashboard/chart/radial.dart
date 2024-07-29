import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/widget/indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as Math;

import 'core/animated_circular_chart.dart';
import 'core/entry.dart';


class RandomizedRadialChartExample extends StatefulWidget {
  double targetAck;
  double actualAck;
  double targetEnrollment=0.0;
  double actualEnrollment;

  RandomizedRadialChartExample({required this.targetAck, required this.actualAck,required this.actualEnrollment,required this.targetEnrollment});

  // @override
  // _RandomizedRadialChartExampleState createState() => _RandomizedRadialChartExampleState();

  @override
  State<StatefulWidget> createState() {
    return _RandomizedRadialChartExampleState();
  }
}

class _RandomizedRadialChartExampleState extends State<RandomizedRadialChartExample> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  //final _chartSize = const Size(300.0, 300.0);
  final Math.Random random = new Math.Random();
  List<CircularStackEntry>? data;

  @override
  void initState() {
    super.initState();

    //_chartSize = Size(context.height*0.3, context.height*0.3);
    data = _generateRandomData();
  }

  double value = 60.0;



  List<CircularStackEntry> _generateRandomData() {
    //int stackCount = random.nextInt(20);
    print('actual Enrollment ${widget.actualEnrollment}');
    print('target ${widget.targetEnrollment}');
    List<CircularStackEntry> data=[];
    // List<CircularStackEntry> data = new List.generate(stackCount, (i) {
    //   int segCount = random.nextInt(20);
    //   List<CircularSegmentEntry> segments =  new List.generate(segCount, (j) {
    //     Color randomColor =  Color((Math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);//ColorPalette.primary.random(random);
    //     return new CircularSegmentEntry(random.nextDouble(), randomColor, rankKey: 'Random');
    //   });
    //   return new CircularStackEntry(segments, rankKey: 'Circular');
    // });
    List<CircularSegmentEntry> list1 = [];
    list1.add(CircularSegmentEntry(widget.actualEnrollment, LightColors.kDarkBlue, rankKey: 'Enrollment'));
    list1.add(CircularSegmentEntry(widget.targetEnrollment, LightColors.kLightGray1, rankKey: 'Enrollment'));
    data.add(CircularStackEntry(list1, rankKey: 'Enrollment'));

    // List<CircularSegmentEntry> list3 = [];
    //     list3.add(const CircularSegmentEntry(0.0, LightColors.kDarkBlue, rankKey: 'a'));
    // list3.add(const CircularSegmentEntry(1, Colors.white, rankKey: 'a'));
    // data.add(CircularStackEntry(list3, rankKey: 'a'));

    List<CircularSegmentEntry> list2 = [];
    list2.add(CircularSegmentEntry(widget.actualAck, LightColors.kGreen, rankKey: 'ACK'));
    list2.add(CircularSegmentEntry(widget.targetEnrollment, LightColors.kLightGray1, rankKey: 'ACK'));
    data.add(CircularStackEntry(list2, rankKey: 'ACK'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          //color: LightColors.notWhite,
          //height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [ 
              Container(
                child: new AnimatedCircularChart(
                  key: _chartKey,
                  holeLabel: '${widget.actualEnrollment.toInt()}',
                  holeSubLabel: '${widget.actualAck.toInt()}',
                  labelStyle: LightColors.headerTitleSelected,
                  holeRadius: 50,
                  percentageValues: false,
                  duration: Duration(milliseconds: 1500),
                  size: Size(context.height*0.37, context.height*0.37),//_chartSize,
                  edgeStyle: SegmentEdgeStyle.round,
                  initialChartData: data!,
                  chartType: CircularChartType.Radial,
                ),
              ),
              // Container(
              //   child: const Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Indicator(
              //         color: Colors.grey,
              //         text: 'Target',
              //         isSquare: true,
              //       ),
              //       SizedBox(
              //         height: 4,
              //       ),
              //       Indicator(
              //         color: LightColors.kRed,
              //         text: 'Enrollment (200)',
              //         isSquare: true,
              //       ),
              //       SizedBox(
              //         height: 4,
              //       ),
              //       Indicator(
              //         color: LightColors.kDarkOrange,
              //         text: 'ACK (200)',
              //         isSquare: true,
              //       ),
              //       SizedBox(
              //         height: 4,
              //       ),
              //     ],
              //   ),
              // ),
            ],
            ),
      ),
    );
  }
}