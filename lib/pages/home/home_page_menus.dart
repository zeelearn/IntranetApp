import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intranet/pages/home/task_category_entity.dart';
import 'package:intranet/pages/pjp/cvf/mycvf.dart';
import 'package:intranet/pages/utils/extensions.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    'Home Page',
                    style: AppTheme.headline3,
                    textAlign: TextAlign.start,
                  ),
                 /* TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: AppTheme.text1,
                    ),
                  ),*/
                ],
              ),
              SizedBox(height: 20),
              taskCategoryGridView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget taskCategoryGridView() {
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
    ));/*dataList.add(TaskCategoryItemEntity(
      title: "Attendance",
      gradient: AppTheme.donkerGradient,
    ));dataList.add(TaskCategoryItemEntity(
      title: "Leave",
      gradient: AppTheme.pinkGradient,
    ));*/
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (BuildContext context, int index) {
        final taskItem = dataList[index];
        return taskCategoryItemWidget(context,
            taskItem, 1, index,taskItem.action);
      },
      staggeredTileBuilder: (int index) =>
          StaggeredTile.count(2, index.isEven ? 2.2 : 2.2),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
    );
  }

  Widget taskCategoryItemWidget(BuildContext context,
      TaskCategoryItemEntity categoryItem, int totalTasks, int index,action) {
    return Container(
      decoration: BoxDecoration(
        gradient: categoryItem.gradient.withDiagonalGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.getShadow(categoryItem.gradient.colors[1]),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Flexible(
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: AutoSizeText(
                  (index + 1).toString(),
                  style: AppTheme.headline2,
                  minFontSize: 14,
                ),
              ),
            ),*/
            SizedBox(height: 12),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Hero(
                      tag: Keys.heroTitleCategory + index.toString(),
                      child: Text(
                        categoryItem.title,
                        style: AppTheme.headline3.withWhite,
                        maxLines: index.isEven ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  /*Icon(Icons.arrow_right, color: Colors.white),*/
                ],
              ),
            ),
            SizedBox(height: 16),
            /*Text(
              '$totalTasks Task',
              style: AppTheme.text1.withWhite,
            ),*/
          ],
        ),
      ).addRipple(onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                action));
      }),
    );
  }

  @override
  Widget build1(BuildContext context) {
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
                  child: Expanded(
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
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyCVFListScreen()));
                  },
                  child: Expanded(
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
                    _getMenu(context, 'My Report', MyReportsScreen()),
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
      child: Expanded(
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
      ),
    );
  }
}
