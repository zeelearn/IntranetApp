import 'package:flutter/widgets.dart';

class ViewportSize {
  static double height=0;
  static double width=0;

  static getSize(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
  }
}