import 'package:Intranet/pages/model/filter.dart';
import 'package:Intranet/pages/pjp/cvf/mycvf.dart';
import 'package:Intranet/pages/pjp/mypjp.dart';
import 'package:Intranet/pages/pjp/pjp_list_manager_exceptional.dart';
import 'package:Intranet/pages/report/myreport.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';

class CategoriesHorizontalListViewBar extends StatelessWidget {
  CategoriesHorizontalListViewBar({Key? key}) : super(key: key);

List<String> categoriesList = [
  "My PJP",
  "My CVF",
  "My Reports",
  "PJP-CVF Approval (Exp)",
  "ZLLSaathi",
];

List<Widget> screens = [
  MyPjpListScreen(mFilterSelection: FilterSelection(
                  filters: [], type: FILTERStatus.MYSELF),),
  MyCVFListScreen(),
  MyReportsScreen(),
  PJPManagerExceptionalScreen(),
  PJPManagerExceptionalScreen(),
];

List<String> categoryLogos = [
  'ic_pjp.png',
  'ic_cvf.png',
  'ic_reports.png', 
  'ic_pjpapproval.png', 
  'ic_zllsaathi.png', 
];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      color: Colors.white70,
      child: ListView.builder(
          itemCount: categoriesList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => screens[index],
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
          height: 50,
          width: 50,
          child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.green,
            child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: Container(
                      padding: EdgeInsets.all(2),
                      child:  Image.asset('assets/images/${categoryLogos[index]}')),
                ),
              ),
            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(categoriesList[index],style: LightColors.subTextStyle,),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}