import 'dart:math';
import 'dart:typed_data';

import 'package:Intranet/pages/dashboard/chart/radial.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/home/dashboard.dart';
import 'package:Intranet/pages/pjp/cvf/mycvf.dart';
import 'package:flutter/material.dart';
import 'package:saathi/zllsaathi.dart';

import '../bpms/bpms_dashboard.dart';
import '../helper/utils.dart';
import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../pjp/pjp_list_manager_exceptional.dart';
import '../report/myreport.dart';
import '../utils/theme/colors/light_colors.dart';

class HomePageMenu extends StatelessWidget {
  bool isBpms;
  String mUserName;
  Uint8List? profileAvtar;
  HomePageMenu(this.isBpms, this.mUserName, Uint8List? profileAvtar);

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
    double width = MediaQuery.of(context).size.width;
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
                                      filters: [], type: FILTERStatus.MYSELF),
                                )));
                  },
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
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
                            padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
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
                      width: MediaQuery.of(context).size.width * 0.4,
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
                            padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
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
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //_getMenu(context, 'BPMS', BPMSHome()),
                    _getMenu(context, 'My Report', Icons.multiline_chart,
                        MyReportsScreen()),
                    !isBpms
                        ? _getMenu(context, 'PJP-CVF Approval (Exp)',
                            Icons.approval, PJPManagerExceptionalScreen())
                        : GestureDetector(
                            onTap: () async {
                              var box = await Utility.openBox();
                              try {
                                int frichiseeId =
                                    box.get(LocalConstant.KEY_FRANCHISEE_ID)
                                        as int;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BPMSDashboard(
                                            userId: frichiseeId.toString())));
                              } catch (e) {
                                Utility.showMessage(context,
                                    'BPMS is not application for current user');
                              }
                            },
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 16, 0, 0),
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
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                )),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //_getMenu(context, 'BPMS', BPMSHome()),
                    GestureDetector(
                      onTap: () {
                        openSaarthi(context);
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
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
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                                child: Icon(
                                  Icons.ac_unit,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                child: Text(
                                  'ZllSaathi',
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
                    //_getMenu(context, 'My Report',Icons.multiline_chart, MyReportsScreen()),
                  ],
                )),

                Padding(padding: EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: (){
                   Navigator.push(
                    context, MaterialPageRoute(builder: (context) => DashboardPage()));
                  },
                  child: Text('My Dashboard'),)),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              isBpms ? _getMenu(context, 'PJP-CVF Approval (Exp)', Icons.approval ,PJPManagerExceptionalScreen()) : SizedBox(width: 0,),
              _getMenu(context, 'My Planning',Icons.approval , MyOutdoorPlanner())
            ],)*/
          ]),
        ),
      ),
    );
  }

  openSaarthi(BuildContext context) async {
    print(mUserName);
    //main();
    ZllSaathi(context, mUserName,profileAvtar);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ZllSaathiScreenWidget(username: mUserName)));
    //
    // String _url = 'https://intranet-9fda2.web.app/dashboard?u_name=${mUserName}';
    // print('opening zeeSarthi...................');
    // if(kIsWeb){
    //   final Uri url = Uri.parse(_url);
    //   if (!await launchUrl(url)) {
    //     throw Exception('Could not launch $_url');
    //   }
    // }else{
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => PrivacyPolicyScreen(url: _url,)));
    // }
  }

  _getMenu(BuildContext context, String title, IconData icon, action) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => action));
      },
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Text(
                  '${title}',
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
