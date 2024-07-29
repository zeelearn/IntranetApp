import 'package:Intranet/pages/dashboard/KPIModel.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';

class DetailKpiScreen extends StatefulWidget {
  List<KPIModel> kipList;
  //DetailKpiScreen({super.key},required this.list);

  DetailKpiScreen({required this.kipList});

  @override
  State<StatefulWidget> createState() => DetailKpiState();
}


class DetailKpiState extends State<DetailKpiScreen> {

@override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "KPI List",
              style: LightColors.headerTilte,
            ),
            SingleChildScrollView(
              //scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: defaultPadding,
                  columns: [
                    DataColumn(
                      label: Text("Franchisee Name"),
                    ),
                    DataColumn(
                      label: Text("ACK"),
                    ),
                    // DataColumn(
                    //   label: Text("ACK Actual"),
                    // ),
                    DataColumn(
                      label: Text("Enrollment"),
                    ),
                    // DataColumn(
                    //   label: Text("Enrollment Actual"),
                    // ),
                    // DataColumn(
                    //   label: Text("Operation"),
                    // ),
                  ],
                  rows: List.generate(
                    widget.kipList!.length > 50 ? 50 : widget.kipList!.length,
                    (index) => recentUserDataRow(widget.kipList![index], context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow recentUserDataRow(KPIModel model, BuildContext context) {
  return DataRow(
    cells: [
      // DataCell(
      //   Row(
      //     children: [
      //       // TextAvatar(
      //       //   size: 35,
      //       //   backgroundColor: Colors.white,
      //       //   textColor: Colors.white,
      //       //   fontSize: 14,
      //       //   upperCase: true,
      //       //   numberLetters: 1,
      //       //   shape: Shape.Rectangle,
      //       //   text: userInfo.name!,
      //       // ),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      //         child: Text(
      //           model.franchiseCodeName!,
      //           maxLines: 1,
      //           overflow: TextOverflow.ellipsis,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // DataCell(Container(
      //     padding: EdgeInsets.all(5),
      //     decoration: BoxDecoration(
      //       color: getRoleColor(userInfo.role).withOpacity(.2),
      //       border: Border.all(color: getRoleColor(userInfo.role)),
      //       borderRadius: BorderRadius.all(Radius.circular(5.0) //
      //           ),
      //     ),
      //     child: Text(userInfo.role!))),
      DataCell(ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250), //SET max width
          child: Text(model.franchiseCodeName!,
              overflow: TextOverflow.ellipsis))),
      //DataCell(Text(model.franchiseCodeName!)),
      DataCell(Text('${model.targetACK!} / ${model.aCKACT!}')),
      //DataCell(Text(model.aCKACT!)),
      DataCell(Text('${model.targetEN!} / ${model.eNAct!}')),
      //DataCell(Text(model.eNAct!)),
      //DataCell(Text(userInfo.posts!)),
      // DataCell(
      //   Row(
      //     children: [
      //       TextButton(
      //         child: Text('View', style: TextStyle(color: greenColor)),
      //         onPressed: () {},
      //       ),
      //       SizedBox(
      //         width: 6,
      //       ),
      //       TextButton(
      //         child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
      //         onPressed: () {
      //           showDialog(
      //               context: context,
      //               builder: (_) {
      //                 return AlertDialog(
      //                     title: Center(
      //                       child: Column(
      //                         children: [
      //                           Icon(Icons.warning_outlined,
      //                               size: 36, color: Colors.red),
      //                           SizedBox(height: 20),
      //                           Text("Confirm Deletion"),
      //                         ],
      //                       ),
      //                     ),
      //                     content: Container(
      //                       color: secondaryColor,
      //                       height: 70,
      //                       child: Column(
      //                         children: [
      //                           Text(
      //                               "Are you sure want to delete '${userInfo.name}'?"),
      //                           SizedBox(
      //                             height: 16,
      //                           ),
      //                           Row(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: [
      //                               ElevatedButton.icon(
      //                                   icon: Icon(
      //                                     Icons.close,
      //                                     size: 14,
      //                                   ),
      //                                   style: ElevatedButton.styleFrom(
      //                                       primary: Colors.grey),
      //                                   onPressed: () {
      //                                     Navigator.of(context).pop();
      //                                   },
      //                                   label: Text("Cancel")),
      //                               SizedBox(
      //                                 width: 20,
      //                               ),
      //                               ElevatedButton.icon(
      //                                   icon: Icon(
      //                                     Icons.delete,
      //                                     size: 14,
      //                                   ),
      //                                   style: ElevatedButton.styleFrom(
      //                                       primary: Colors.red),
      //                                   onPressed: () {},
      //                                   label: Text("Delete"))
      //                             ],
      //                           )
      //                         ],
      //                       ),
      //                     ));
      //               });
      //         },
      //         // Delete
      //       ),
      //     ],
      //   ),
      // ),
    ],
  );
}

}