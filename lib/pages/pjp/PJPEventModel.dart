import 'dart:ui';

import 'package:Intranet/pages/auth/config.dart';

class PJPEventModel{
  final String title;
  final String subtitle;
  final String visitType;
  final String purposeOfVisit;
  final String businessType;
  final String fromDate;
  final String toDate;
  final Color boxColor;
  final String icons;
  final String checkInTime;
  bool isCheckin;
  String ampm;

  PJPEventModel({
    required this.title,required  this.subtitle,required this.visitType,required this.purposeOfVisit,
    required this.businessType,
    required this.fromDate,
    required this.toDate,
    required  this.boxColor,
    required this.icons,
    required this.isCheckin,
    required this.checkInTime,
    required this.ampm
  });
}