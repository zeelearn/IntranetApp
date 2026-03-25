import 'dart:math';
import 'dart:typed_data';

import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/home/dashboard.dart';
import 'package:Intranet/pages/outdoor/outdoor/myoutdoorplanner.dart';
import 'package:Intranet/pages/pjp/cvf/mycvf.dart';
import 'package:Intranet/pages/pjp/dashboard/presentation/dashboard_module.dart';
import 'package:Intranet/pages/summary%20dashboard/summary_dashboard.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:expensestracker/app/hiveDatabase/hive_database.dart';
import 'package:expensestracker/presentation/app.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:saathi/zllsaathi.dart';
import 'package:expensestracker/main.dart' as expenseMainPlaceholder;

import '../bpms/bpms_dashboard.dart';
import '../helper/utils.dart';
import '../legal_mis/all_legal_status_page.dart';
import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../pjp/pjp_list_manager_exceptional.dart';
import '../report/myreport.dart';
import '../utils/theme/colors/light_colors.dart';

class HomePageMenu extends StatelessWidget {
  bool isBpms;
  String mUserName;
  String name;
  String empID;
  Uint8List? profileAvtar;
  HomePageMenu(this.isBpms, this.mUserName, this.name, Uint8List? profileAvtar,
      this.empID,
      {super.key});

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

  List<String> notiflowAccessList = [
    '14002156',
    '14002172',
    '14002035',
    '14001828',
    '14001782'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;

              double childAspectRatio;

              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6;

                childAspectRatio = 1;
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 4;

                childAspectRatio = 1.1;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;

                childAspectRatio = 1;
              } else {
                crossAxisCount = 2;

                childAspectRatio = 1;
              }

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildMenuCard(
                    title: 'My PJP',
                    icon: Icons.electric_car,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPjpListScreen(
                            mFilterSelection: FilterSelection(
                              filters: [],
                              type: FILTERStatus.MYSELF,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'My CVF',
                    icon: Icons.calendar_today,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyCVFListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'My Report',
                    icon: Icons.multiline_chart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyReportsScreen(),
                        ),
                      );
                    },
                  ),
                  if (!isBpms)
                    _buildMenuCard(
                      title: 'PJP-CVF Approval (Exp)',
                      icon: Icons.approval,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PJPManagerExceptionalScreen(),
                          ),
                        );
                      },
                    )
                  else
                    _buildMenuCard(
                      title: 'BPMS',
                      icon: Icons.business,
                      onTap: () async {
                        var box = await Utility.openBox();
                        try {
                          int franchiseeId =
                              box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BPMSDashboard(
                                  userId: franchiseeId.toString()),
                            ),
                          );
                        } catch (e) {
                          Utility.showMessage(context,
                              'BPMS is not applicable for the current user');
                        }
                      },
                    ),
                  _buildMenuCard(
                    title: 'ZllSaathi',
                    icon: Icons.ac_unit,
                    onTap: () {
                      openSaarthi(context);
                    },
                  ),
                  _buildMenuCard(
                    title: 'Expense',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      openExpense(context);
                    },
                  ),
                  _buildMenuCard(
                    title: 'Contracts',
                    icon: Icons.legend_toggle_sharp,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllLegalStatusPage(
                            email: name,
                          ),
                        ),
                      );
                    },
                  ),
                  if (notiflowAccessList.any((element) => element == empID))
                    _buildMenuCard(
                      title: 'Notiflow',
                      icon: Icons.notifications,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyWebsiteView(
                              title: 'ZLLSaathi',
                              url:
                                  'https://notiflow-51883.web.app/?u_name=${empID}&password=12345&color=0277BD',
                            ),
                          ),
                        );
                      },
                    ),
                  /*  _buildMenuCard(
                    title: 'My Dashboard',
                    icon: Icons.dashboard,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    },
                  ), */
                  if (isBpms)
                    _buildMenuCard(
                      title: 'PJP-CVF Approval (Exp)',
                      icon: Icons.approval,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PJPManagerExceptionalScreen(),
                          ),
                        );
                      },
                    ),
                  /*   _buildMenuCard(
                    title: 'My Planning',
                    icon: Icons.calendar_view_day,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyOutdoorPlanner(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'My Dashboard MAN',
                    icon: Icons.dashboard_customize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(),
                        ),
                      );
                    },
                  ), */
                  _buildMenuCard(
                    title: 'PJP Dashboard',
                    icon: Icons.group,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SummaryDashboard(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  openExpense(BuildContext context) async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    var empCode =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE) as String);
    debugPrint('Employee code is - $empCode');
    // expenseMainPlaceholder.main(isExternal: true, eCode: empCode.toString());
    await HiveDatabase.clear();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp(
                  eCode: empCode.toString(),
                  isExternal: true,
                  buildContext: context,
                )));
  }

  openSaarthi(BuildContext context) async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    mUserName = hiveBox.get(LocalConstant.KEY_USER_NAME);
    print('Username: $mUserName');
    //main();
    ZllSaathi(context, mUserName, profileAvtar);
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

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.8), Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 44,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lexend Deca',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
