import 'package:Intranet/pages/helper/mobile_applications_store.dart';
import 'package:Intranet/pages/home/v2/models/dash_v2_models.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';

class DashV2Greeting {
  DashV2Greeting._();

  static const subtitle = 'Stay updated with your tasks';

  static String forDateTime(DateTime now, String firstName) {
    final hour = now.hour;
    final String period;
    if (hour < 12) {
      period = 'Morning';
    } else if (hour < 17) {
      period = 'Afternoon';
    } else {
      period = 'Evening';
    }
    return 'Good $period, $firstName 👋';
  }
}

class DashV2MenuCatalog {
  DashV2MenuCatalog._();

  static const notiflowAccessList = [
    '14002156',
    '14002172',
    '14002035',
    '14001828',
    '14001782',
  ];

  // Icons / colors / subtitles aligned to Figma mobile feature cards.
  static const _projects = DashQuickAccessItem(
    key: 'projects',
    title: 'Projects',
    subtitle: 'View & manage projects',
    icon: Icons.analytics_outlined,
    assetIcon: 'assets/icons/ic_project.png',
    color: DashV2Colors.blue,
    requiresBusiness: false,
  );

  static const _myPjp = DashQuickAccessItem(
    key: 'my_pjp',
    title: 'My PJP',
    subtitle: 'View & manage PJP details',
    icon: Icons.electric_car,
    color: DashV2Colors.primary,
    requiresBusiness: true,
  );

  static const _myCvf = DashQuickAccessItem(
    key: 'my_cvf',
    title: 'My CVF',
    subtitle: 'View & manage CVF details',
    icon: Icons.calendar_today_outlined,
    color: DashV2Colors.green,
    requiresBusiness: true,
  );

  static const _myReport = DashQuickAccessItem(
    key: 'my_report',
    title: 'My Report',
    subtitle: 'Analytics & reports',
    icon: Icons.show_chart_rounded,
    color: DashV2Colors.amber,
    requiresBusiness: false,
  );

  static const _pjpCvfApprovalExp = DashQuickAccessItem(
    key: 'pjp_cvf_approval_exp',
    title: 'PJP-CVF Approval (Exp)',
    subtitle: 'Review & approve requests',
    icon: Icons.approval_outlined,
    color: DashV2Colors.purple,
    requiresBusiness: true,
  );

  static const _bpms = DashQuickAccessItem(
    key: 'bpms',
    title: 'BPMS',
    subtitle: 'Business process management',
    icon: Icons.business_outlined,
    color: DashV2Colors.primary,
    requiresBusiness: false,
    bpmsOnly: true,
  );

  static const _expenses = DashQuickAccessItem(
    key: 'expenses',
    title: 'Expenses',
    subtitle: 'Manage all expenses',
    icon: Icons.currency_rupee,
    color: DashV2Colors.pink,
    requiresBusiness: false,
  );

  static const _zllSaathi = DashQuickAccessItem(
    key: 'zll_saathi',
    title: 'ZILSaathi',
    subtitle: 'Dashboard',
    icon: Icons.ac_unit,
    assetIcon: 'assets/icons/ic_saathi.png',
    color: DashV2Colors.teal,
    requiresBusiness: true,
  );

  static const _contracts = DashQuickAccessItem(
    key: 'contracts',
    title: 'Contracts',
    subtitle: 'View & manage contracts',
    icon: Icons.assignment_outlined,
    color: DashV2Colors.yellow,
    requiresBusiness: false,
  );

  static const _notiflow = DashQuickAccessItem(
    key: 'notiflow',
    title: 'NotiFlow',
    subtitle: 'Alerts & updates',
    icon: Icons.notifications_none_rounded,
    color: DashV2Colors.blue,
    requiresBusiness: false,
    notiflowOnly: true,
  );

  static const _pjpDashboard = DashQuickAccessItem(
    key: 'pjp_dashboard',
    title: 'PJP Journey Plan',
    subtitle: 'Permanent Journey Plan',
    icon: Icons.electric_car,
    color: DashV2Colors.purple,
    requiresBusiness: true,
  );

  static const _bpManagement = DashQuickAccessItem(
    key: 'bp_management',
    title: 'Prospect Management',
    subtitle: 'Open Prospect Management portal',
    icon: Icons.handshake_outlined,
    color: DashV2Colors.teal,
    requiresBusiness: false,
  );

  /// Live menus only (no Figma-only Documents). Order mirrors Figma where possible.
  /// [mobileAppNames] — normalized `business_Name` values from myMobileApplications.
  static List<DashQuickAccessItem> visibleQuickAccess({
    required bool isBpms,
    required String employeeCode,
    Set<String> mobileAppNames = const {},
  }) {
    return <DashQuickAccessItem>[
      _pjpDashboard,
      _projects,
      _expenses,
      _myPjp,
      _myCvf,
      if (isBpms) _bpms else _pjpCvfApprovalExp,
      _zllSaathi,
      _contracts,
      if (mobileAppNames.contains(MobileApplicationsStore.bpManagement))
        _bpManagement,
      if (notiflowAccessList.contains(employeeCode)) _notiflow,
      if (isBpms) _pjpCvfApprovalExp,
      _myReport,
    ];
  }

  static List<DashNavItem> sidebarItems({required bool isBpms}) {
    return const [
      DashNavItem(
        key: 'dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
      ),
      DashNavItem(
        key: 'profile',
        label: 'Profile',
        icon: Icons.person_outline_rounded,
      ),
      DashNavItem(
        key: 'pjp',
        label: 'PJP',
        icon: Icons.electric_car,
      ),
      DashNavItem(
        key: 'cvf',
        label: 'CVF',
        icon: Icons.calendar_today_outlined,
      ),
      DashNavItem(
        key: 'projects_nav',
        label: 'Projects',
        icon: Icons.location_on_outlined,
      ),
      DashNavItem(
        key: 'approvals_pjp',
        label: 'PJP',
        icon: Icons.check_circle_outline,
        section: 'Approvals',
      ),
      DashNavItem(
        key: 'logout',
        label: 'Log Out',
        icon: Icons.logout,
      ),
    ];
  }
}
