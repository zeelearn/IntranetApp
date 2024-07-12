import 'dart:collection';

import 'package:saathi/models/franchiseeModel.dart';
import 'package:saathi/models/getTicketFilterMasterModel.dart' as dept;
import 'package:saathi/models/getTicketFilterMasterModel.dart';
import 'package:saathi/models/userSSODataModel.dart';


class DashboardFilterData {
  HashMap<int, String> mFilter = new HashMap<int, String>();
  final HashMap<String, List<String>> selectedAttributes;
  List<String>? zoneList=[];
  List<String>? franchinseeList=[];
  List<String>? employeeList=[];
  

  DashboardFilterData(this.selectedAttributes,
      {this.zoneList,
      this.franchinseeList,
      this.employeeList});
}
