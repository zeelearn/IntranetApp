import 'dart:typed_data';

import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/pjp/cvf/mycvf.dart';
import 'package:Intranet/pages/pjp/cvf/v2/cvf.dart';
import 'package:Intranet/pages/summary%20dashboard/summary_dashboard.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:expensestracker/app/hiveDatabase/hive_database.dart';
import 'package:expensestracker/presentation/app.dart';
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_binding.dart';
import 'package:expensestracker/presentation/controllers/dashboard/dashboard_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:saathi/models/getStaticDashboardModel.dart';
import 'package:saathi/zllsaathi.dart';

import '../bpms/bpms_dashboard.dart';
import '../helper/utils.dart';
import '../legal_mis/all_legal_status_page.dart';
import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../pjp/pjp_list_manager_exceptional.dart';
import '../report/myreport.dart';
import '../utils/theme/colors/light_colors.dart';

class HomePageMenu extends StatefulWidget {
  bool isBpms;
  String mUserName;
  String name;
  String empID;
  Uint8List? profileAvtar;
  int businessId;

  HomePageMenu(
      this.isBpms, this.mUserName, this.name, this.profileAvtar, this.empID,
      {this.businessId = 0, super.key});

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

class _HomePageMenuState extends State<HomePageMenu> {
  bool _isLoadingDashboard = true;
  GetStaticDashboardModel? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<DashboardPageController>()) {
      DashboardBinding().dependencies();
    }
  }

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // if (widget.businessId == 0) _buildBusinessNotMappedCard(),
                _buildMenuGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> businsesRequiredMenu = [
    'My PJP',
    'My CVF',
    'PJP-CVF Approval (Exp)',
    'PJP Dashboard',
    'ZllSaathi'
  ];

  bool validateBusiness(String businessName) {
    if (businsesRequiredMenu.contains(businessName) && !isBusinessMapped) {
      Utility.showMessage(
          context, 'Business not mapped. Please connect with your manager.');
      return false;
    }
    return true;
  }

  get isBusinessMapped => widget.businessId != 0;
  Widget _buildMenuGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        bool isBpms = widget.isBpms;

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildMenuCard(
              title: 'My PJP',
              icon: Icons.electric_car,
              // disabled: !isBusinessMapped,
              onTap: () {
                if (!validateBusiness('My PJP')) return;

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
              // disabled: !isBusinessMapped,
              onTap: () {
                if (!validateBusiness('My CVF')) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyCVFListScreenV2(),
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
                // disabled: !isBusinessMapped,
                onTap: () {
                  if (!validateBusiness('PJP-CVF Approval (Exp)')) return;

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
                        builder: (context) =>
                            BPMSDashboard(userId: franchiseeId.toString()),
                      ),
                    );
                  } catch (e) {
                    Utility.showMessage(
                        context, 'BPMS is not applicable for the current user');
                  }
                },
              ),
            _buildMenuCard(
              title: 'ZllSaathi',
              icon: Icons.ac_unit,
              onTap: () {
                if (!validateBusiness('ZllSaathi')) return;

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
                      email: widget.name,
                    ),
                  ),
                );
              },
            ),
            if (notiflowAccessList.any((element) => element == widget.empID))
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
                            'https://notiflow-51883.web.app/?u_name=${widget.empID}&password=12345&color=0277BD',
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
                // disabled: !isBusinessMapped,
                onTap: () {
                  if (!validateBusiness('PJP-CVF Approval (Exp)')) return;

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
              // disabled: !isBusinessMapped,
              onTap: () {
                if (!validateBusiness('PJP Dashboard')) return;

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
    );
  }

  /*  Widget _buildDashboardHeader() {
    if (_isLoadingDashboard) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
                child: Text("Dashboard data unavailable: $_errorMessage",
                    style: const TextStyle(color: Colors.red))),
            IconButton(
                onPressed: _fetchDashboardData,
                icon: const Icon(Icons.refresh, color: Colors.red))
          ],
        ),
      );
    }

    // Assuming GetStaticDashboardModel has numeric stats based on Saathi API
    // We iterate over the data if available or use specific fields
    // The 'data' field is a List, so we need to access the first element.
    // The NoSuchMethodError suggests that `stats` might not be a DashboardData object
    // but rather a raw Map<String, dynamic> or an object with different property names.
    // Let's treat it as dynamic and access properties using `[]` operator for robustness.
    final dynamic stats = _dashboardData?.data?.firstOrNull;

    // Helper to safely get value from dynamic object (Map or actual object)
    String _getStatValue(dynamic statObject, String key,
        {String defaultValue = "0"}) {
      if (statObject is Map<String, dynamic>) {
        return statObject[key]?.toString() ?? defaultValue;
      }
      return defaultValue; // Fallback if not a map (shouldn't happen if error is NoSuchMethodError)
    }

    if (stats == null) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      int columns = constraints.maxWidth > 800 ? 4 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: 4, // Display top 4 metrics
        itemBuilder: (context, index) {
          // Mapping logic based on Saathi dashboard structure
          String label = "";
          String value = "0";
          IconData icon = Icons.analytics;
          Color color = Colors.blue;

          switch (index) {
            case 0:
              label = "Total Tickets";
              value = _getStatValue(stats, 'totalTickets');
              icon = Icons.confirmation_number_outlined;
              color = Colors.indigo;
              break;
            case 1:
              label = "Pending";
              value = _getStatValue(stats, 'openTickets',
                  defaultValue: _getStatValue(
                      stats, 'openTicket')); // Fallback for singular
              icon = Icons.hourglass_empty;
              color = Colors.orange;
              break;
            case 2:
              label = "Resolved";
              value = _getStatValue(stats, 'resolvedTickets',
                  defaultValue: _getStatValue(stats,
                      'resolveTickets')); // Fallback for inconsistent plural
              icon = Icons.check_circle_outline;
              color = Colors.green;
              break;
            case 3:
              label = "Closed";
              value = _getStatValue(stats, 'closedTickets');
              icon = Icons.task_alt;
              color = Colors.blueGrey;
              break;
          }

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(value,
                          style: GoogleFonts.lexendDeca(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  } */

  openExpense(BuildContext context) async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    var empCode = int.tryParse(
            hiveBox.get(LocalConstant.KEY_EMPLOYEE_CODE)?.toString() ?? '0') ??
        0;
    //await HiveDatabase.clear();
    // The host (Intranet) app is already a GetMaterialApp. Pushing the expense
    // module's own GetMaterialApp as a route registers a second global
    // navigator keys and crashes ("Duplicate GlobalKey detected" /
    // DefaultSelectionStyle assertion). Embed it on the existing navigator.
    await openExpenseTracker(eCode: empCode.toString());
    //  Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => MyApp(
    //           key: UniqueKey(),
    //               eCode: empCode.toString(),

    //               isExternal: true,
    //               buildContext: context,
    //             )));
  }

  openSaarthi(BuildContext context) async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    String username =
        hiveBox.get(LocalConstant.KEY_USER_NAME) ?? widget.mUserName;
    //main();
    ZllSaathi(context, username, widget.profileAvtar);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ZllSaathiScreenWidget(username: mUserName)));
    //
    // String _url = 'https://intranet-9fda2.web.app/dashboard?u_name=${mUserName}';
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

  Widget _buildBusinessNotMappedCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade400),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Business not mapped',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please connect with your manager.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    final Color backgroundColor = disabled ? Colors.grey.shade300 : Colors.blue;
    final Color iconColor = disabled ? Colors.grey.shade600 : Colors.white;
    final Color textColor = disabled ? Colors.grey.shade700 : Colors.white;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Card(
        elevation: disabled ? 1 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: disabled
                ? LinearGradient(
                    colors: [backgroundColor, backgroundColor],
                  )
                : LinearGradient(
                    colors: [Colors.blue.withOpacity(0.8), backgroundColor],
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
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend Deca',
                  color: textColor,
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
