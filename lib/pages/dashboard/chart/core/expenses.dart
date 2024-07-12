import 'package:flutter/material.dart';

class Expense {
  final String expenseName;
  final Color color;
  final String actual;
  final String target;

  Expense({
    required this.expenseName,
    required this.color,
    required this.actual,
    required this.target,
  });
}