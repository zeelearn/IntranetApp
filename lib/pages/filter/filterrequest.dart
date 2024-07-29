// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class FilterRequest {
  late String year='';
  late String month='';
  late String employee='';
  late String? zone='';
  late String? franchisee='';


  FilterRequest(
      {required this.year,
      required this.month,
      required this.employee,
      required this.zone,
      });

  FilterRequest.fromJson(Map<String, dynamic> json) {
    year = json['Year'];
    month = json['Month'];
    employee = json['employee'];
    zone = json['zone'];
  }
  isEmpty(){
    if(employee.isEmpty && year.isEmpty && month.isEmpty && zone!.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  clear(){
    year = '';
    month = '';
    employee = '';
    zone = '';
  }
}
