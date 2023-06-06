enum FILTERStatus { MYSELF, MYTEAM,NONE,CUSTOM }
class FilterSelection{
  List<FilterModel> filters=[];
  FILTERStatus type;
  FilterSelection({
    required this.filters,
    required this.type
  });
}

class FilterModel {
  final int id;
  final int employeeId;
  final String name;
  bool isSelected=false;

  FilterModel({
    required this.id,
    required this.name,
    required this.employeeId,
  });
}