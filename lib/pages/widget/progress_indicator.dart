/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percent = .5;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: Stack(
            clipBehavior: Clip.none, fit: StackFit.expand,
            children: [
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 15,
                width: constraints.maxWidth,
                backgroundColor: Colors.black,
                percent: percent,
                progressColor: Colors.yellow,
              )
              */
/*Positioned(
                top: 40, // you can adjust this through negatives to raise your child widget
                 // child width / 2 (this is to get the center of the widget),
                child: Center(
                  child: Container(
                    width: 50,
                    alignment: Alignment.topCenter,
                    child: Text('${percent * 100}%'),
                  ),
                ),
              ),*//*

              */
/*Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 15,
                  width: constraints.maxWidth,
                  backgroundColor: Colors.black,
                  percent: percent,
                  progressColor: Colors.yellow,
                ),
              ),*//*

            ],
          ),
        );
      },
    );
  }
}*/
