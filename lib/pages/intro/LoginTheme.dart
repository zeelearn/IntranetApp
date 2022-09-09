import 'package:flutter/widgets.dart';

class LoginTheme {
  final String title;
  final AssetImage landscape;
  final List<Color> backgroundGradient;
  final Widget circle;
  final Widget rays;

  LoginTheme(
      {required this.circle,
        required this.backgroundGradient,
        required this.landscape,
        required this.title,
        required this.rays});
}