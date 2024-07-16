import 'dart:collection';

import 'package:Intranet/pages/dashboard/KPIModel.dart';
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
  int? totalEnrollments=0;
  int? totalAck;
  int? totalCenters=0;
  KPIInfo? kpiInfo;

  

  DashboardFilterData( this.selectedAttributes,
      {required this.kpiInfo,this.zoneList,
      this.franchinseeList,
      this.employeeList,this.totalAck,this.totalEnrollments,this.totalCenters});
}
