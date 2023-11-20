import 'dart:math';

import 'package:Intranet/pages/bpms/auth/ui/bpms_home.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/pages/home/task_category_entity.dart';
import 'package:Intranet/pages/pjp/cvf/mycvf.dart';

import '../bpms/bpms_dashboard.dart';
import '../helper/utils.dart';
import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../report/myreport.dart';
import '../utils/theme/colors/light_colors.dart';
import '../utils/theme/theme.dart';

class HomePageMenu extends StatelessWidget {
  Text subheading(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  @override
  Widget build123(BuildContext context) {
    List<TaskCategoryItemEntity> dataList =[];
    dataList.add(TaskCategoryItemEntity(
        title: "My PJP",
        gradient: AppTheme.purpleGradient,
        action: MyPjpListScreen(
          mFilterSelection: FilterSelection(
              filters: [],
              type: FILTERStatus.MYSELF),)
    ));dataList.add(TaskCategoryItemEntity(
        title: "My CVF",
        gradient: AppTheme.greenGradient,
        action: MyCVFListScreen()
    ));dataList.add(TaskCategoryItemEntity(
        title: "Reports",
        gradient: AppTheme.brownGradient,
        action: MyReportsScreen()
    ));
    return GridView.extent(
      childAspectRatio: (2 / 2),
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: EdgeInsets.all(10.0),
      maxCrossAxisExtent: 200.0,
      children: List.generate(50, (index) {
        return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  dataList[index].action);
            },
            child: Container(
              padding: EdgeInsets.all(20.0),
              color: RandomColorModel().getColor(),
              margin: EdgeInsets.all(1.0),
              child: Center(
                child: GridTile(
                  child: Text(
                    'Item $index',
                    textAlign: TextAlign.center,
                    style:const TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.bold),
                  ),
                  /*child: Icon(Icons.access_alarm,
                      size: 40.0, color: Colors.white),*/
                ),
              ),
            )
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 12),
          child: Column(children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyPjpListScreen(
                                  mFilterSelection: FilterSelection(
                                      filters: [],
                                      type: FILTERStatus.MYSELF),)));
                  },
                  child:  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.4,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.indigoAccent,
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Icon(
                                Icons.electric_car,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0, 8, 0, 0),
                              child: Text(
                                'My PJP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyCVFListScreen()));
                  },
                  child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.4,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 3,
                              color: Colors.indigoAccent,
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0, 8, 0, 0),
                              child: Text(
                                'My CVF',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                child:
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //_getMenu(context, 'BPMS', BPMSHome()),
                    _getMenu(context, 'My Report', MyReportsScreen()),
                    GestureDetector(
                      onTap: () async {
                        var box = await Utility.openBox();
                        int frichiseeId = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BPMSDashboard(userId: frichiseeId.toString(),)));
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.4,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Colors.indigoAccent,
                                offset: Offset(0, 1),
                              )
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 8, 0, 0),
                                child: Text(
                                  'BPMS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Lexend Deca',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ]
          ),
        ),
      ),
    );
  }

  _getMenu(BuildContext context, String title, action) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => action));
      },
      child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.4,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.indigoAccent,
                  offset: Offset(0, 1),
                )
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding:
                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                  child: Icon(
                    Icons.multiline_chart,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text('${title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
class RandomColorModel {
  Random random = Random();
  Color getColor() {
    return Color.fromARGB(random.nextInt(300), random.nextInt(300),
        random.nextInt(300), random.nextInt(300));
  }
}