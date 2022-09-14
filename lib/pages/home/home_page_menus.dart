import 'package:flutter/material.dart';
import 'package:intranet/pages/pjp/cvf/mycvf.dart';

import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../report/myreport.dart';
import '../utils/theme/colors/light_colors.dart';

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
                            builder: (context) => MyPjpListScreen(
                              mFilterSelection: FilterSelection(
                                  filters: [], type: FILTERStatus.MYSELF),)));
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
