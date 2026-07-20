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

  static const _projects = DashQuickAccessItem(
    key: 'projects',
    title: 'Projects',
    subtitle: 'Manage project workflows',
    icon: Icons.approval,
    color: DashV2Colors.blue,
    requiresBusiness: false,
  );

  static const _myPjp = DashQuickAccessItem(
    key: 'my_pjp',
    title: 'My PJP',
    subtitle: 'View your PJP plans',
    icon: Icons.electric_car,
    color: DashV2Colors.green,
    requiresBusiness: true,
  );

  static const _myCvf = DashQuickAccessItem(
    key: 'my_cvf',
    title: 'My CVF',
    subtitle: 'Customer visit forms',
    icon: Icons.calendar_today,
    color: DashV2Colors.amber,
    requiresBusiness: true,
  );

  static const _myReport = DashQuickAccessItem(
    key: 'my_report',
    title: 'My Report',
    subtitle: 'Analytics and reports',
    icon: Icons.multiline_chart,
    color: DashV2Colors.purple,
    requiresBusiness: false,
  );

  static const _pjpCvfApprovalExp = DashQuickAccessItem(
    key: 'pjp_cvf_approval_exp',
    title: 'PJP-CVF Approval (Exp)',
    subtitle: 'Exceptional approvals',
    icon: Icons.approval,
    color: DashV2Colors.teal,
    requiresBusiness: true,
  );

  static const _bpms = DashQuickAccessItem(
    key: 'bpms',
    title: 'BPMS',
    subtitle: 'Business process management',
    icon: Icons.business,
    color: DashV2Colors.primary,
    requiresBusiness: false,
    bpmsOnly: true,
  );

  static const _zllSaathi = DashQuickAccessItem(
    key: 'zll_saathi',
    title: 'ZllSaathi',
    subtitle: 'Saathi dashboard',
    icon: Icons.ac_unit,
    color: DashV2Colors.pink,
    requiresBusiness: true,
  );

  static const _expenses = DashQuickAccessItem(
    key: 'expenses',
    title: 'Expense',
    subtitle: 'Track and submit expenses',
    icon: Icons.account_balance_wallet,
    color: DashV2Colors.green,
    requiresBusiness: false,
  );

  static const _contracts = DashQuickAccessItem(
    key: 'contracts',
    title: 'Contracts',
    subtitle: 'Legal status and contracts',
    icon: Icons.legend_toggle_sharp,
    color: DashV2Colors.amber,
    requiresBusiness: false,
  );

  static const _notiflow = DashQuickAccessItem(
    key: 'notiflow',
    title: 'Notiflow',
    subtitle: 'Notification workflows',
    icon: Icons.notifications,
    color: DashV2Colors.blue,
    requiresBusiness: false,
    notiflowOnly: true,
  );

  static const _pjpDashboard = DashQuickAccessItem(
    key: 'pjp_dashboard',
    title: 'PJP Dashboard',
    subtitle: 'Summary dashboard',
    icon: Icons.group,
    color: DashV2Colors.purple,
    requiresBusiness: true,
  );

  static List<DashQuickAccessItem> visibleQuickAccess({
    required bool isBpms,
    required String employeeCode,
  }) {
    final items = <DashQuickAccessItem>[
      _projects,
      _myPjp,
      _myCvf,
      _myReport,
      if (isBpms) _bpms else _pjpCvfApprovalExp,
      _zllSaathi,
      _expenses,
      _contracts,
      if (notiflowAccessList.contains(employeeCode)) _notiflow,
      if (isBpms) _pjpCvfApprovalExp,
      _pjpDashboard,
    ];
    return items;
  }

  static List<DashNavItem> sidebarItems({required bool isBpms}) {
    return const [
      DashNavItem(
        key: 'dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
      ),
      DashNavItem(
        key: 'pjp',
        label: 'PJP',
        icon: Icons.electric_car,
      ),
      DashNavItem(
        key: 'cvf',
        label: 'CVF',
        icon: Icons.calendar_today,
      ),
      DashNavItem(
        key: 'projects_nav',
        label: 'Projects',
        icon: Icons.approval,
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
