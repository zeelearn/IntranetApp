import 'package:Intranet/pages/filter/filterrequest.dart';
import 'package:Intranet/pages/filter/myFilterData.dart';
import 'package:flutter/material.dart';
import 'package:saathi/models/getTicketFilterMasterModel.dart';
import 'package:saathi/screens/ticket/filter/accept_bottom_navigation.dart';
import 'package:saathi/screens/ticket/filter/filter_selectable_item.dart';
import 'package:saathi/screens/ticket/filter/filter_selectable_visible_option.dart';
import 'package:saathi/widget/dropdown.dart';
import 'package:saathi/widget/ui/block_subtitle.dart';


class FiltersAppScreen extends StatefulWidget {
  FilterRequest? mFilterRequest;
  DashboardFilterData filterData;
  FiltersAppScreen({this.mFilterRequest, required this.filterData});

  @override
  State<StatefulWidget> createState() {
    return _FiltersScreenState();
  }
}

class _FiltersScreenState extends State<FiltersAppScreen> {
  var franchiseeTextEditingController = TextEditingController();
  var employeeTextEditingController = TextEditingController();

  Date? selectedFilterCreatedDate;


  @override
  void initState() {
    super.initState();
    if (widget.mFilterRequest != null) loadFilterSelection();
  }

  loadFilterSelection() {
    if (widget.filterData.franchinseeList != null) {
      for (int index = 0; index <
          widget.filterData.franchinseeList!.length; index++) {
        if (widget.filterData.franchinseeList![index] ==
            widget.mFilterRequest!.franchisee) {
          franchiseeTextEditingController.text =
          '${widget.filterData.franchinseeList![index]} - ${widget.filterData
              .franchinseeList![index]}';
        }
      }
    }


    if (widget.filterData.employeeList != null) {
      for (int index = 0; index <
          widget.filterData.employeeList!.length; index++) {
        if (widget.filterData.employeeList![index] == widget.mFilterRequest!.employee) {
          employeeTextEditingController.text = widget.filterData.employeeList![index];
        }
      }
    }
    
  }

  getZoneWidget() {
    return FilterSelectableVisibleOption<String>(
      title: 'Zones',
      onSelected: (String value) {
        _onAttributeSelected('Zone', value);
        widget.mFilterRequest!.zone =
            widget.mFilterRequest!.zone == value ? '' : value;
      },
      children:
          Map.fromEntries(widget.filterData.zoneList!.map((option) => MapEntry(
              option,
              FilterSelectableItem(
                text: option,
                isSelected: widget.filterData.selectedAttributes['Zone'] != null
                    ? widget.filterData.selectedAttributes['Zone']!
                        .contains(option)
                    : false,
              )))),
    );
  }



  

  getFranchinseeList() {
    return Column(
      children: <Widget>[
        OpenFlutterBlockSubtitle(title: 'Franchisee List'),
        SizedBox(
          height: 15,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15 * 2),
          color: Colors.white,
          child: ZeeDropDown(
            title: 'Franchisee',
            textController: franchiseeTextEditingController,
            hintText: 'Franchisee',
            items: widget.filterData.franchinseeList!,
            displayFunction: (p0) =>
                '${p0}',
            onChanged: (p0) {
              if (p0 != null) {
                franchiseeTextEditingController.text = p0.toString();
                widget.mFilterRequest!.franchisee = p0.toString();
              } else {
                //selectedFilterFranchisee = p0;
              }
            },
          ),
        )
      ],
    );
  }

  getEmployeeList() {
    return Column(
      children: <Widget>[
        OpenFlutterBlockSubtitle(title: 'Employee List'),
        SizedBox(
          height: 15,
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15 * 2),
          color: Colors.white,
          child: ZeeDropDown(
            title: 'Employee',
            textController: employeeTextEditingController,
            hintText: 'Employee',
            items: widget.filterData.employeeList!,
            displayFunction: (p0) =>
            '${p0}',
            onChanged: (p0) {
              if (p0 != null) {
                employeeTextEditingController.text = p0.toString();
                widget.mFilterRequest!.employee = p0.toString();
              } else {
                //selectedFilterFranchisee = p0;
              }
            },
          ),
        )
      ],
    );
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Filters'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.filterData.zoneList != null) getZoneWidget(),
          //if (widget.filterData.priorityList != null) renderPriority(),
          if (widget.filterData.franchinseeList != null) getFranchinseeList(),
          if (widget.filterData.employeeList != null) getEmployeeList(),
        ]),
      ),
      bottomNavigationBar: AcceptBottomNavigation(
        onApply: () {
          // if (selectedFilterCreatedDate != null &&
          //     selectedFilterCreatedDate!.type.toLowerCase() == 'custom' &&
          //     (selectedFromDate == null || selectedEndDate == null)) {
          //   ToastUtility.showError(
          //       msg:
          //           'Please select ${selectedFromDate == null ? 'Start Date' : selectedEndDate == null ? 'End Date' : ''}');
          //   return;
          // }
          Navigator.of(context).pop(widget.mFilterRequest);
        },
        onDiscard: () {
          clearFilter();
          Navigator.of(context).pop(widget.mFilterRequest);
        },
      ),
    );
  }

  clearFilter() {
    widget.mFilterRequest!.clear();
    setState(() {});
  }

  void _onAttributeSelected(String attribute, String value) {
    if (widget.filterData.selectedAttributes[attribute] == null) {
      widget.filterData.selectedAttributes[attribute] = [];
    }
    if (widget.filterData.selectedAttributes[attribute]!.contains(value)) {
      debugPrint('remove value ${value}');
      setState(() {
        widget.filterData.selectedAttributes[attribute]!.remove(value);
      });
    } else {
      debugPrint('add value ${value}');
      setState(() {
        widget.filterData.selectedAttributes[attribute]!.clear();
        widget.filterData.selectedAttributes[attribute]!.add(value);
      });
    }
  }
}
