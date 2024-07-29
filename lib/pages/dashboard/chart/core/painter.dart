import 'dart:math' as Math;

import 'package:flutter/material.dart';

import 'animated_circular_chart.dart';
import 'circular_chart.dart';
import 'stack.dart';

class AnimatedCircularChartPainter extends CustomPainter {
  AnimatedCircularChartPainter(this.animation, this.labelPainter,this.labelSubPainter)
      : super(repaint: animation);

  final Animation<CircularChart> animation;
  final TextPainter? labelPainter;
  final TextPainter? labelSubPainter;

  @override
  void paint(Canvas canvas, Size size) {
    if(labelPainter!=null)
    _paintLabel(canvas, size, labelPainter!);
    if(labelSubPainter!=null)
      _paintSubLabel(canvas, size, labelSubPainter!);
    _paintChart(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(AnimatedCircularChartPainter old) => false;
}

class CircularChartPainter extends CustomPainter {
  CircularChartPainter(this.chart, this.labelPainter,this.labelSubPainter);

  final CircularChart chart;
  final TextPainter labelPainter;
  final TextPainter labelSubPainter;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLabel(canvas, size, labelPainter);
    _paintChart(canvas, size, chart);
    _paintSubLabel(canvas, size, labelSubPainter);
  }

  @override
  bool shouldRepaint(CircularChartPainter old) => true;
}

const double _kRadiansPerDegree = Math.pi / 180;

void _paintLabel(Canvas canvas, Size size, TextPainter labelPainter) {
  if (labelPainter != null) {
    labelPainter.paint(
      canvas,
      new Offset(
        size.width / 2 - labelPainter.width / 2,
        size.height / 2 - labelPainter.height / 1.4,
      ),
    );
  }
}

void _paintSubLabel(Canvas canvas, Size size, TextPainter labelSubPainter) {
  if (labelSubPainter != null) {
    labelSubPainter.paint(
      canvas,
      new Offset(
        size.width / 2 - labelSubPainter.width / 2,
        size.height / 1.7- labelSubPainter.height / 2,
      ),
    );
  }
}

void _paintChart(Canvas canvas, Size size, CircularChart chart) {
  final Paint segmentPaint = new Paint()
    ..style = chart.chartType == CircularChartType.Radial
        ? PaintingStyle.stroke
        : PaintingStyle.fill
    ..strokeCap = chart.edgeStyle == SegmentEdgeStyle.round
        ? StrokeCap.round
        : StrokeCap.butt;

  for (final CircularChartStack stack in chart.stacks) {
    for (final segment in stack.segments) {
      segmentPaint.color = segment.color;
      segmentPaint.strokeWidth = stack.width;
    

      canvas.drawArc(
        new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
        stack.startAngle * _kRadiansPerDegree,
        segment.sweepAngle * _kRadiansPerDegree,
        chart.chartType == CircularChartType.Pie,
        segmentPaint,
      );
    }
  }
}
