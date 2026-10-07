// Dashboard V2
//
// A responsive Flutter dashboard rebuilt from the new Figma design.
// State is driven by GetX (`DashboardV2Controller`). The same view renders two
// visual states:
//   * Empty state  -> when no data is available (illustrative placeholders).
//   * Data state   -> when stats, charts and lists are populated.
//
// Toggle the AppBar database icon (debug helper) to preview both states.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

/// Centralised colour palette extracted from the Figma design so the UI stays
/// consistent and easy to re-theme.
class DashV2Colors {
  DashV2Colors._();

  static const Color scaffold = Color(0xFFF4F6FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFEDF1F7);
  static const Color shadow = Color(0x0F1A2B4A);

  static const Color textDark = Color(0xFF1F2A44);
  static const Color textMuted = Color(0xFF8A94A6);
  static const Color textFaint = Color(0xFFB4BCCB);

  // Accent colours used across cards, charts and quick actions.
  static const Color blue = Color(0xFF4C6FFF);
  static const Color green = Color(0xFF2BB673);
  static const Color amber = Color(0xFFFFA63D);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color teal = Color(0xFF14B8A6);
  static const Color red = Color(0xFFEF4E6B);
  static const Color pink = Color(0xFFEC5990);
  static const Color slate = Color(0xFFCBD3E1);

  static Color tint(Color base) => base.withValues(alpha: 0.12);
}

/// Typography helpers backed by Google Fonts (matches the rest of the app).
class DashV2Text {
  DashV2Text._();

  static TextStyle title = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
  );
  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: DashV2Colors.textMuted,
  );
  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: DashV2Colors.textDark,
  );
  static TextStyle cardLabel = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DashV2Colors.textMuted,
  );
  static TextStyle bigValue = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
  );
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: DashV2Colors.textMuted,
  );
  static TextStyle link = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: DashV2Colors.blue,
  );
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// A top summary card (PJP, CVF, Helpdesk, etc.).
class SummaryStat {
  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String valueCaption;
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const SummaryStat({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.valueCaption,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });
}

/// A single slice/segment used by both donut charts and progress bars.
class ChartSegment {
  final String label;
  final double value;
  final Color color;
  final String display;

  const ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.display,
  });
}

/// A generic two/three-column row inside the list cards.
class ListEntry {
  final String id;
  final String primary;
  final String secondary;
  final String trailing;
  final String status;
  final Color statusColor;

  const ListEntry({
    required this.id,
    required this.primary,
    required this.secondary,
    required this.trailing,
    this.status = '',
    this.statusColor = DashV2Colors.textMuted,
  });
}

/// A quick action shortcut at the bottom of the dashboard.
class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// Lightweight model describing a chart card's empty placeholder.
class EmptyConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String actionLabel;

  const EmptyConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.actionLabel,
  });
}

/// A side-menu entry. A group is an item that owns [children]; otherwise it is
/// a leaf that maps to a [route].
class NavItem {
  final String key;
  final String label;
  final IconData icon;
  final String? route;
  final int badge;
  final List<NavItem> children;

  const NavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.route,
    this.badge = 0,
    this.children = const [],
  });

  bool get isGroup => children.isNotEmpty;
}

/// A selectable business / brand for the workspace switcher.
class Business {
  final String code;
  final String name;
  final Color color;

  const Business({required this.code, required this.name, required this.color});

  /// Two-letter monogram shown inside the avatar.
  String get monogram =>
      code.length >= 2 ? code.substring(0, 2).toUpperCase() : code.toUpperCase();
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Holds all reactive state for the v2 dashboard.
///
/// In a real integration, [loadDashboard] would call a repository/API and map
/// the response into the observable fields. Here it swaps between curated empty
/// and populated datasets so both Figma states can be previewed.
class DashboardV2Controller extends GetxController {
  final userName = 'Sudhir'.obs;
  final userFullName = 'Sudhir Patil'.obs;
  final userRole = 'Manager'.obs;
  final dateRange = 'May 15 - May 21, 2025'.obs;
  final notificationCount = 3.obs;

  final isLoading = false.obs;

  /// Master switch between the "no data" and "full data" designs.
  final hasData = true.obs;

  // ---- Shell / navigation state -------------------------------------------

  /// Whether the desktop sidebar is expanded (true) or collapsed to a rail.
  final sidebarExpanded = true.obs;

  /// Currently selected leaf route key.
  final selectedRoute = 'dashboard'.obs;

  /// Keys of the currently expanded menu groups.
  final expandedGroups = <String>{}.obs;

  /// Available businesses and the active selection.
  final businesses = const <Business>[
    Business(code: 'KZ', name: 'Kidzee', color: DashV2Colors.blue),
    Business(code: 'ML', name: 'MLZS', color: DashV2Colors.green),
    Business(code: 'ZL', name: 'Zee Learn', color: DashV2Colors.purple),
    Business(code: 'MT', name: 'Mount Litera', color: DashV2Colors.amber),
  ];
  late final selectedBusiness = businesses.first.obs;

  /// The full side-menu tree mirrored from the design.
  final List<NavItem> navItems = const [
    NavItem(key: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, route: 'dashboard'),
    NavItem(key: 'pjp', label: 'PJP', icon: Icons.assignment_outlined, children: [
      NavItem(key: 'my_pjp', label: 'My PJP', icon: Icons.circle, route: 'my_pjp'),
      NavItem(key: 'pjp_approval', label: 'PJP Approval', icon: Icons.circle, route: 'pjp_approval'),
      NavItem(key: 'create_pjp', label: 'Create PJP', icon: Icons.circle, route: 'create_pjp'),
    ]),
    NavItem(key: 'cvf', label: 'CVF', icon: Icons.fact_check_outlined, children: [
      NavItem(key: 'my_cvf', label: 'My CVF', icon: Icons.circle, route: 'my_cvf'),
      NavItem(key: 'cvf_approval', label: 'CVF Approval', icon: Icons.circle, route: 'cvf_approval'),
      NavItem(key: 'create_cvf', label: 'Create CVF', icon: Icons.circle, route: 'create_cvf'),
    ]),
    NavItem(key: 'helpdesk', label: 'Helpdesk', icon: Icons.headset_mic_outlined, children: [
      NavItem(key: 'my_tickets', label: 'My Tickets', icon: Icons.circle, route: 'my_tickets'),
      NavItem(key: 'all_tickets', label: 'All Tickets', icon: Icons.circle, route: 'all_tickets'),
    ]),
    NavItem(key: 'expenses', label: 'Expenses', icon: Icons.account_balance_wallet_outlined, children: [
      NavItem(key: 'my_expenses', label: 'My Expenses', icon: Icons.circle, route: 'my_expenses'),
      NavItem(key: 'expense_approvals', label: 'Approvals', icon: Icons.circle, route: 'expense_approvals'),
      NavItem(key: 'expense_reports', label: 'Reports', icon: Icons.circle, route: 'expense_reports'),
    ]),
    NavItem(key: 'advance', label: 'Advance Requisition', icon: Icons.request_quote_outlined, route: 'advance'),
    NavItem(key: 'employee_claim', label: 'Employee Claim', icon: Icons.people_alt_outlined, route: 'employee_claim'),
    NavItem(key: 'reports', label: 'Reports', icon: Icons.bar_chart_outlined, route: 'reports'),
    NavItem(key: 'notifications', label: 'Notifications', icon: Icons.notifications_outlined, route: 'notifications', badge: 3),
    NavItem(key: 'settings', label: 'Settings', icon: Icons.settings_outlined, route: 'settings'),
  ];

  void toggleSidebar() => sidebarExpanded.toggle();

  void toggleGroup(String key) {
    if (expandedGroups.contains(key)) {
      expandedGroups.remove(key);
    } else {
      expandedGroups.add(key);
    }
    expandedGroups.refresh();
  }

  void selectRoute(String route) => selectedRoute.value = route;

  void selectBusiness(Business business) => selectedBusiness.value = business;

  final summaryStats = <SummaryStat>[].obs;
  final pjpStatus = <ChartSegment>[].obs;
  final ticketStatus = <ChartSegment>[].obs;
  final expenseBreakup = <ChartSegment>[].obs;

  final pjpTotal = 0.obs;
  final ticketTotal = 0.obs;
  final totalClaimed = '0'.obs;

  final pjpApprovals = <ListEntry>[].obs;
  final openTickets = <ListEntry>[].obs;
  final recentExpenses = <ListEntry>[].obs;

  late final List<QuickAction> quickActions = _buildQuickActions();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  /// Simulates fetching the dashboard payload, then maps it into state.
  Future<void> loadDashboard() async {
    isLoading.value = true;
    // Simulated network latency; replace with the real repository call.
    await Future.delayed(const Duration(milliseconds: 350));
    if (hasData.value) {
      _applyPopulatedData();
    } else {
      _applyEmptyData();
    }
    isLoading.value = false;
  }

  /// Debug helper to flip between the two Figma states.
  void toggleData() {
    hasData.value = !hasData.value;
    loadDashboard();
  }

  void _applyEmptyData() {
    summaryStats.assignAll(const [
      SummaryStat(
        title: 'PJP',
        icon: Icons.assignment_outlined,
        color: DashV2Colors.blue,
        value: '0',
        valueCaption: 'Total PJP',
        leftLabel: 'My PJP',
        leftValue: '0',
        rightLabel: 'Approval Pending',
        rightValue: '0',
      ),
      SummaryStat(
        title: 'CVF',
        icon: Icons.fact_check_outlined,
        color: DashV2Colors.green,
        value: '0',
        valueCaption: 'Total CVF',
        leftLabel: 'My CVF',
        leftValue: '0',
        rightLabel: 'Approval Pending',
        rightValue: '0',
      ),
      SummaryStat(
        title: 'PJP Approval Pending',
        icon: Icons.pending_actions_outlined,
        color: DashV2Colors.amber,
        value: '0',
        valueCaption: 'From My Side',
        leftLabel: 'Overdue',
        leftValue: '0',
        rightLabel: 'Due Today',
        rightValue: '0',
      ),
      SummaryStat(
        title: 'Helpdesk Tickets',
        icon: Icons.headset_mic_outlined,
        color: DashV2Colors.purple,
        value: '0',
        valueCaption: 'Open Tickets',
        leftLabel: 'In Progress',
        leftValue: '0',
        rightLabel: 'Open',
        rightValue: '0',
      ),
      SummaryStat(
        title: 'Expenses',
        icon: Icons.account_balance_wallet_outlined,
        color: DashV2Colors.teal,
        value: '\u20B90',
        valueCaption: 'Total Expenses',
        leftLabel: 'Pending Approval',
        leftValue: '0',
        rightLabel: 'Reimbursable',
        rightValue: '\u20B90',
      ),
    ]);

    pjpStatus.clear();
    ticketStatus.clear();
    expenseBreakup.clear();
    pjpTotal.value = 0;
    ticketTotal.value = 0;
    totalClaimed.value = '\u20B90';
    pjpApprovals.clear();
    openTickets.clear();
    recentExpenses.clear();
  }

  void _applyPopulatedData() {
    summaryStats.assignAll(const [
      SummaryStat(
        title: 'PJP',
        icon: Icons.assignment_outlined,
        color: DashV2Colors.blue,
        value: '12',
        valueCaption: 'Total PJP',
        leftLabel: 'My PJP',
        leftValue: '5',
        rightLabel: 'Approval Pending',
        rightValue: '3',
      ),
      SummaryStat(
        title: 'CVF',
        icon: Icons.fact_check_outlined,
        color: DashV2Colors.green,
        value: '8',
        valueCaption: 'Total CVF',
        leftLabel: 'My CVF',
        leftValue: '4',
        rightLabel: 'Approval Pending',
        rightValue: '2',
      ),
      SummaryStat(
        title: 'PJP Approval Pending',
        icon: Icons.pending_actions_outlined,
        color: DashV2Colors.amber,
        value: '3',
        valueCaption: 'From My Side',
        leftLabel: 'Overdue',
        leftValue: '2',
        rightLabel: 'Due Today',
        rightValue: '1',
      ),
      SummaryStat(
        title: 'Helpdesk Tickets',
        icon: Icons.headset_mic_outlined,
        color: DashV2Colors.purple,
        value: '7',
        valueCaption: 'Open Tickets',
        leftLabel: 'In Progress',
        leftValue: '4',
        rightLabel: 'Open',
        rightValue: '3',
      ),
      SummaryStat(
        title: 'Expenses',
        icon: Icons.account_balance_wallet_outlined,
        color: DashV2Colors.teal,
        value: '\u20B984,500',
        valueCaption: 'Total Claimed',
        leftLabel: 'Pending Approval',
        leftValue: '4',
        rightLabel: 'Reimbursable',
        rightValue: '\u20B928,300',
      ),
    ]);

    pjpTotal.value = 12;
    pjpStatus.assignAll(const [
      ChartSegment(
          label: 'Approved',
          value: 5,
          color: DashV2Colors.green,
          display: '5 (41.7%)'),
      ChartSegment(
          label: 'Pending Approval',
          value: 3,
          color: DashV2Colors.amber,
          display: '3 (25.0%)'),
      ChartSegment(
          label: 'In Progress',
          value: 2,
          color: DashV2Colors.blue,
          display: '2 (16.7%)'),
      ChartSegment(
          label: 'Draft',
          value: 2,
          color: DashV2Colors.slate,
          display: '2 (16.7%)'),
    ]);

    ticketTotal.value = 7;
    ticketStatus.assignAll(const [
      ChartSegment(
          label: 'Open',
          value: 3,
          color: DashV2Colors.red,
          display: '3 (42.9%)'),
      ChartSegment(
          label: 'In Progress',
          value: 4,
          color: DashV2Colors.blue,
          display: '4 (57.1%)'),
      ChartSegment(
          label: 'On Hold',
          value: 0,
          color: DashV2Colors.amber,
          display: '0 (0%)'),
      ChartSegment(
          label: 'Resolved',
          value: 0,
          color: DashV2Colors.green,
          display: '0 (0%)'),
    ]);

    totalClaimed.value = '\u20B984,500';
    expenseBreakup.assignAll(const [
      ChartSegment(
          label: 'Approved',
          value: 28300,
          color: DashV2Colors.green,
          display: '\u20B928,300 (33.5%)'),
      ChartSegment(
          label: 'Pending Approval',
          value: 32200,
          color: DashV2Colors.amber,
          display: '\u20B932,200 (38.1%)'),
      ChartSegment(
          label: 'Rejected',
          value: 4000,
          color: DashV2Colors.red,
          display: '\u20B94,000 (4.7%)'),
      ChartSegment(
          label: 'Paid',
          value: 20000,
          color: DashV2Colors.blue,
          display: '\u20B920,000 (23.7%)'),
    ]);

    pjpApprovals.assignAll(const [
      ListEntry(
          id: 'PJP-125',
          primary: 'Rahul Sharma',
          secondary: 'May 20, 2025',
          trailing: '\u20B925,000',
          status: 'May 22, 2025',
          statusColor: DashV2Colors.red),
      ListEntry(
          id: 'PJP-124',
          primary: 'Priya Mehta',
          secondary: 'May 19, 2025',
          trailing: '\u20B918,500',
          status: 'May 21, 2025',
          statusColor: DashV2Colors.red),
      ListEntry(
          id: 'PJP-123',
          primary: 'Amit Verma',
          secondary: 'May 18, 2025',
          trailing: '\u20B912,000',
          status: 'May 20, 2025',
          statusColor: DashV2Colors.red),
    ]);

    openTickets.assignAll(const [
      ListEntry(
          id: 'HD-478',
          primary: 'Login Issue',
          secondary: 'High',
          trailing: '',
          status: 'Open',
          statusColor: DashV2Colors.red),
      ListEntry(
          id: 'HD-476',
          primary: 'System Error',
          secondary: 'Medium',
          trailing: '',
          status: 'In Progress',
          statusColor: DashV2Colors.blue),
      ListEntry(
          id: 'HD-474',
          primary: 'Access Issue',
          secondary: 'Medium',
          trailing: '',
          status: 'Open',
          statusColor: DashV2Colors.red),
      ListEntry(
          id: 'HD-472',
          primary: 'Report Issue',
          secondary: 'Low',
          trailing: '',
          status: 'In Progress',
          statusColor: DashV2Colors.blue),
    ]);

    recentExpenses.assignAll(const [
      ListEntry(
          id: 'EXP-245',
          primary: 'Travel',
          secondary: 'May 20, 2025',
          trailing: '\u20B95,600',
          status: 'Pending',
          statusColor: DashV2Colors.amber),
      ListEntry(
          id: 'EXP-244',
          primary: 'Meals',
          secondary: 'May 19, 2025',
          trailing: '\u20B91,250',
          status: 'Approved',
          statusColor: DashV2Colors.green),
      ListEntry(
          id: 'EXP-243',
          primary: 'Office Supplies',
          secondary: 'May 18, 2025',
          trailing: '\u20B92,300',
          status: 'Pending',
          statusColor: DashV2Colors.amber),
      ListEntry(
          id: 'EXP-242',
          primary: 'Client Meeting',
          secondary: 'May 17, 2025',
          trailing: '\u20B93,000',
          status: 'Approved',
          statusColor: DashV2Colors.green),
    ]);
  }

  List<QuickAction> _buildQuickActions() => const [
        QuickAction(
            title: 'Create PJP',
            subtitle: 'Create PJP request',
            icon: Icons.add,
            color: DashV2Colors.blue),
        QuickAction(
            title: 'Create CVF',
            subtitle: 'Create new CVF request',
            icon: Icons.add,
            color: DashV2Colors.green),
        QuickAction(
            title: 'Raise Ticket',
            subtitle: 'Report an issue',
            icon: Icons.confirmation_number_outlined,
            color: DashV2Colors.purple),
        QuickAction(
            title: 'Add Expense',
            subtitle: 'Submit new expense',
            icon: Icons.receipt_long_outlined,
            color: DashV2Colors.pink),
        QuickAction(
            title: 'Advance Request',
            subtitle: 'Request advance',
            icon: Icons.request_quote_outlined,
            color: DashV2Colors.amber),
        QuickAction(
            title: 'Employee Claim',
            subtitle: 'Submit claim',
            icon: Icons.assignment_turned_in_outlined,
            color: DashV2Colors.teal),
      ];
}

// ---------------------------------------------------------------------------
// View
// ---------------------------------------------------------------------------

class DashboardV2Page extends StatelessWidget {
  const DashboardV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardV2Controller());
    return _DashboardShell(controller: controller);
  }
}

/// Width below which the sidebar is hidden behind a drawer and the layout
/// switches to a mobile-friendly single column.
const double _kSidebarBreakpoint = 1000;

/// The application shell: animated left navigation + top app bar + body.
/// Adapts between a persistent sidebar (wide screens) and a drawer (mobile).
class _DashboardShell extends StatelessWidget {
  const _DashboardShell({required this.controller});

  final DashboardV2Controller controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kSidebarBreakpoint;

        if (isWide) {
          return Scaffold(
            backgroundColor: DashV2Colors.scaffold,
            body: Row(
              children: [
                _SideMenu(controller: controller),
                Expanded(
                  child: Column(
                    children: [
                      _TopAppBar(controller: controller, isWide: true),
                      Expanded(child: _DashboardBody(controller: controller)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: DashV2Colors.scaffold,
          drawer: Drawer(
            width: 270,
            child: _SideMenu(controller: controller, inDrawer: true),
          ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: _TopAppBar(controller: controller, isWide: false),
          ),
          body: _DashboardBody(controller: controller),
        );
      },
    );
  }
}

/// The scrollable dashboard content (header, stats, charts, lists, actions).
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardV2Controller controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cols = _columnsForWidth(constraints.maxWidth);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 720 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(controller: controller),
                  const SizedBox(height: 16),
                  _SummaryGrid(controller: controller, columns: cols),
                  const SizedBox(height: 20),
                  _OverviewSection(controller: controller, columns: cols),
                  const SizedBox(height: 20),
                  _ListSection(controller: controller, columns: cols),
                  const SizedBox(height: 24),
                  _QuickActionsSection(controller: controller, columns: cols),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  /// Responsive breakpoints: phone (1) -> tablet (2) -> desktop (3).
  int _columnsForWidth(double width) {
    if (width >= 1080) return 3;
    if (width >= 680) return 2;
    return 1;
  }
}

// ---------------------------------------------------------------------------
// Animated side menu
// ---------------------------------------------------------------------------

class _SideMenu extends StatelessWidget {
  const _SideMenu({required this.controller, this.inDrawer = false});

  final DashboardV2Controller controller;
  final bool inDrawer;

  static const double _expandedWidth = 256;
  static const double _collapsedWidth = 76;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Always read the observable so GetX registers the dependency, even when
      // the drawer forces the expanded layout.
      final sidebarExpanded = controller.sidebarExpanded.value;
      final expanded = inDrawer ? true : sidebarExpanded;
      final width = expanded ? _expandedWidth : _collapsedWidth;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        width: width,
        decoration: const BoxDecoration(
          color: DashV2Colors.card,
          border: Border(right: BorderSide(color: DashV2Colors.border)),
        ),
        // Lay the content out at its target width and clip, so mid-animation
        // frames never overflow the shrinking/growing container.
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: width,
            maxWidth: width,
            child: SizedBox(
              width: width,
              child: SafeArea(
                child: Column(
                  children: [
                    _SidebarHeader(
                        controller: controller,
                        expanded: expanded,
                        inDrawer: inDrawer),
                    _BusinessSelector(controller: controller, expanded: expanded),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            for (final item in controller.navItems)
                              item.isGroup
                                  ? _NavGroup(
                                      controller: controller,
                                      item: item,
                                      expanded: expanded)
                                  : _NavTile(
                                      controller: controller,
                                      item: item,
                                      expanded: expanded,
                                      isChild: false),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: DashV2Colors.border),
                    _SidebarProfile(controller: controller, expanded: expanded),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.controller,
    required this.expanded,
    required this.inDrawer,
  });

  final DashboardV2Controller controller;
  final bool expanded;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            expanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          if (expanded)
            Flexible(
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DashV2Colors.blue, DashV2Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text('ZE',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('ZEELEARN',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: DashV2Colors.textDark,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          // Collapse on desktop; close the drawer on mobile.
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: expanded ? 'Collapse menu' : 'Expand menu',
            onPressed: () {
              if (inDrawer) {
                Navigator.of(context).maybePop();
              } else {
                controller.toggleSidebar();
              }
            },
            icon: Icon(
              inDrawer
                  ? Icons.close_rounded
                  : (expanded ? Icons.menu_open_rounded : Icons.menu_rounded),
              size: 20,
              color: DashV2Colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Workspace / business switcher (Kidzee, MLZS, ...).
class _BusinessSelector extends StatelessWidget {
  const _BusinessSelector({required this.controller, required this.expanded});

  final DashboardV2Controller controller;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.selectedBusiness.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: PopupMenuButton<Business>(
          tooltip: 'Switch business',
          offset: const Offset(0, 48),
          color: DashV2Colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: DashV2Colors.border),
          ),
          onSelected: controller.selectBusiness,
          itemBuilder: (context) => [
            for (final b in controller.businesses)
              PopupMenuItem<Business>(
                value: b,
                child: Row(
                  children: [
                    _businessAvatar(b, 26),
                    const SizedBox(width: 10),
                    Text(b.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: b.code == current.code
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: DashV2Colors.textDark,
                        )),
                    const Spacer(),
                    if (b.code == current.code)
                      const Icon(Icons.check_rounded,
                          size: 16, color: DashV2Colors.blue),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: expanded ? 10 : 0, vertical: 8),
            decoration: BoxDecoration(
              color: DashV2Colors.scaffold,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DashV2Colors.border),
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                _businessAvatar(current, 28),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Business',
                            style: GoogleFonts.poppins(
                                fontSize: 9, color: DashV2Colors.textMuted)),
                        Text(current.name,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DashV2Colors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.unfold_more_rounded,
                      size: 18, color: DashV2Colors.textMuted),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _businessAvatar(Business b, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: b.color,
        borderRadius: BorderRadius.circular(7),
      ),
      alignment: Alignment.center,
      child: Text(b.monogram,
          style: GoogleFonts.poppins(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          )),
    );
  }
}

/// An expandable menu group with an animated submenu reveal.
class _NavGroup extends StatelessWidget {
  const _NavGroup({
    required this.controller,
    required this.item,
    required this.expanded,
  });

  final DashboardV2Controller controller;
  final NavItem item;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Snapshot both observables inside the Obx scope so the group reacts to
      // route changes and expand/collapse toggles.
      final currentRoute = controller.selectedRoute.value;
      final openGroups = controller.expandedGroups.toList();
      final isOpen = openGroups.contains(item.key);
      final hasActiveChild =
          item.children.any((c) => c.route == currentRoute);

      return Column(
        children: [
          _NavTile(
            controller: controller,
            item: item,
            expanded: expanded,
            isChild: false,
            highlight: hasActiveChild,
            trailing: expanded
                ? AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: DashV2Colors.textMuted),
                  )
                : null,
            onTap: () {
              if (!expanded) controller.toggleSidebar();
              controller.toggleGroup(item.key);
            },
          ),
          // Animated expand / collapse of the children.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: (isOpen && expanded)
                ? Column(
                    children: [
                      for (final child in item.children)
                        _NavTile(
                          controller: controller,
                          item: child,
                          expanded: expanded,
                          isChild: true,
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      );
    });
  }
}

/// A single navigation row (group header, leaf or child).
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.controller,
    required this.item,
    required this.expanded,
    required this.isChild,
    this.highlight = false,
    this.trailing,
    this.onTap,
  });

  final DashboardV2Controller controller;
  final NavItem item;
  final bool expanded;
  final bool isChild;
  final bool highlight;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read the observable unconditionally. Group-header tiles have a null
      // route, so relying on a short-circuited `&&` would leave this Obx
      // without a dependency and trigger GetX's "improper use" error.
      final currentRoute = controller.selectedRoute.value;
      final selected = item.route != null && currentRoute == item.route;
      final active = selected || highlight;
      final color = active ? DashV2Colors.blue : DashV2Colors.textMuted;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: selected ? DashV2Colors.tint(DashV2Colors.blue) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap ??
                () {
                  if (item.route != null) {
                    controller.selectRoute(item.route!);
                    // Close the drawer after a mobile selection.
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.of(context).maybePop();
                    }
                  }
                },
            child: Container(
              height: 42,
              padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 10 : 0),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  if (isChild && expanded)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 6, right: 14),
                      decoration: BoxDecoration(
                        color: active ? DashV2Colors.blue : DashV2Colors.textFaint,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    _IconWithBadge(
                      icon: item.icon,
                      color: color,
                      badge: item.badge,
                    ),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? DashV2Colors.textDark
                              : DashV2Colors.textMuted,
                        ),
                      ),
                    ),
                    if (item.badge > 0 && !isChild)
                      _Pill(text: '${item.badge}', color: DashV2Colors.blue),
                    if (trailing != null) trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge(
      {required this.icon, required this.color, required this.badge});

  final IconData icon;
  final Color color;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 20, color: color),
        if (badge > 0)
          Positioned(
            right: -6,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: DashV2Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          )),
    );
  }
}

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile({required this.controller, required this.expanded});

  final DashboardV2Controller controller;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment:
            expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: DashV2Colors.tint(DashV2Colors.blue),
            child: const Icon(Icons.person, size: 20, color: DashV2Colors.blue),
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(controller.userFullName.value,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DashV2Colors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
                  Obx(() => Text(controller.userRole.value,
                      style: DashV2Text.caption)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: DashV2Colors.textMuted),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top app bar
// ---------------------------------------------------------------------------

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({required this.controller, required this.isWide});

  final DashboardV2Controller controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: DashV2Colors.card,
        border: Border(bottom: BorderSide(color: DashV2Colors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!isWide)
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: DashV2Colors.textDark),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            Expanded(child: _SearchField(isWide: isWide)),
            const SizedBox(width: 12),
            _NotificationBell(controller: controller),
            const SizedBox(width: 8),
            _ProfileMenu(controller: controller, isWide: isWide),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 520 : double.infinity),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DashV2Colors.scaffold,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DashV2Colors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 18, color: DashV2Colors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search for anything...',
                    hintStyle: DashV2Text.cardLabel,
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: DashV2Colors.textDark),
                ),
              ),
              if (isWide)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: DashV2Colors.card,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: DashV2Colors.border),
                  ),
                  child: Text('⌘ K', style: DashV2Text.caption),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.controller});

  final DashboardV2Controller controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.notificationCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => controller.selectRoute('notifications'),
            icon: const Icon(Icons.notifications_outlined,
                color: DashV2Colors.textMuted),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: DashV2Colors.red, shape: BoxShape.circle),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                alignment: Alignment.center,
                child: Text('$count',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
        ],
      );
    });
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.controller, required this.isWide});

  final DashboardV2Controller controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      color: DashV2Colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DashV2Colors.border),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('My Profile')),
        PopupMenuItem(value: 'settings', child: Text('Settings')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      onSelected: (v) {
        if (v == 'settings') controller.selectRoute('settings');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: DashV2Colors.tint(DashV2Colors.blue),
            child: const Icon(Icons.person, size: 18, color: DashV2Colors.blue),
          ),
          if (isWide) ...[
            const SizedBox(width: 8),
            Obx(() => Text(controller.userFullName.value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashV2Colors.textDark,
                ))),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: DashV2Colors.textMuted),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final DashboardV2Controller controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: DashV2Text.title),
              const SizedBox(height: 4),
              Obx(() => Text(
                    "Welcome back, ${controller.userName.value}! "
                    "Here's what's happening today.",
                    style: DashV2Text.subtitle,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Debug helper to flip empty <-> populated states.
            IconButton(
              tooltip: 'Toggle sample data',
              onPressed: controller.toggleData,
              icon: const Icon(Icons.cached_rounded,
                  color: DashV2Colors.textMuted),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DashV2Colors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DashV2Colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: DashV2Colors.textMuted),
                  const SizedBox(width: 8),
                  Obx(() => Text(controller.dateRange.value,
                      style: DashV2Text.cardLabel)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: DashV2Colors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary stat cards
// ---------------------------------------------------------------------------

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.controller, required this.columns});

  final DashboardV2Controller controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    // Match the Figma row counts: desktop -> all 5, tablet -> 3, phone -> 2.
    final perRow = columns == 3 ? 5 : (columns == 2 ? 3 : 2);
    return Obx(() {
      // Read the observable synchronously inside the Obx scope so GetX can
      // register the dependency, then build from the immutable snapshot.
      final stats = controller.summaryStats.toList();
      return _Wrap(
        spacing: 14,
        runSpacing: 14,
        itemCount: stats.length,
        perRow: perRow,
        builder: (i) => _SummaryCard(stat: stats[i]),
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stat});

  final SummaryStat stat;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DashV2Colors.tint(stat.color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: stat.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(stat.title,
                    style: DashV2Text.cardLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: DashV2Colors.textFaint),
            ],
          ),
          const SizedBox(height: 14),
          Text(stat.value, style: DashV2Text.bigValue),
          const SizedBox(height: 2),
          Text(stat.valueCaption, style: DashV2Text.caption),
          const SizedBox(height: 14),
          const Divider(height: 1, color: DashV2Colors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: stat.leftLabel, value: stat.leftValue),
              ),
              Expanded(
                child:
                    _MiniStat(label: stat.rightLabel, value: stat.rightValue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DashV2Colors.textDark,
            )),
        const SizedBox(height: 2),
        Text(label, style: DashV2Text.caption, maxLines: 1),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Overview section (charts)
// ---------------------------------------------------------------------------

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.controller, required this.columns});

  final DashboardV2Controller controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Snapshot every observable this section depends on inside the Obx
      // scope, then build the UI from the snapshots.
      final pjp = controller.pjpStatus.toList();
      final tickets = controller.ticketStatus.toList();
      final expenses = controller.expenseBreakup.toList();
      final pjpTotal = controller.pjpTotal.value;
      final ticketTotal = controller.ticketTotal.value;
      final totalClaimed = controller.totalClaimed.value;

      final cards = <Widget>[
        _ChartCard(
          title: 'PJP Status Overview',
          hasData: pjp.isNotEmpty,
          empty: const EmptyConfig(
            icon: Icons.assignment_outlined,
            color: DashV2Colors.blue,
            title: 'No PJP found',
            message: "You don't have any PJP created yet.",
            actionLabel: 'Create PJP',
          ),
          footerLabel: 'View All PJP',
          child: _DonutWithLegend(
            total: pjpTotal.toString(),
            totalLabel: 'Total',
            segments: pjp,
          ),
        ),
        _ChartCard(
          title: 'Helpdesk Ticket Summary',
          hasData: tickets.isNotEmpty,
          empty: const EmptyConfig(
            icon: Icons.headset_mic_outlined,
            color: DashV2Colors.purple,
            title: 'No tickets found',
            message: 'There are no helpdesk tickets at the moment.',
            actionLabel: 'Raise Ticket',
          ),
          footerLabel: 'View All Tickets',
          child: _DonutWithLegend(
            total: ticketTotal.toString(),
            totalLabel: 'Total',
            segments: tickets,
          ),
        ),
        _ChartCard(
          title: 'Expenses Overview',
          hasData: expenses.isNotEmpty,
          empty: const EmptyConfig(
            icon: Icons.account_balance_wallet_outlined,
            color: DashV2Colors.teal,
            title: 'No expenses available',
            message: "You haven't submitted any expenses yet.",
            actionLabel: 'Add Expense',
          ),
          footerLabel: 'View All Expenses',
          child: _ExpenseBreakdown(
            total: totalClaimed,
            segments: expenses,
          ),
        ),
      ];

      return _Wrap(
        spacing: 16,
        runSpacing: 16,
        itemCount: cards.length,
        perRow: columns,
        builder: (i) => cards[i],
      );
    });
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.hasData,
    required this.empty,
    required this.child,
    required this.footerLabel,
  });

  final String title;
  final bool hasData;
  final EmptyConfig empty;
  final Widget child;
  final String footerLabel;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: DashV2Text.sectionTitle)),
              const _MonthChip(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: hasData
                ? child
                : _EmptyPlaceholder(config: empty),
          ),
          if (hasData) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: DashV2Colors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(footerLabel, style: DashV2Text.link),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: DashV2Colors.blue),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DashV2Colors.scaffold,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashV2Colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This Month', style: DashV2Text.caption),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: DashV2Colors.textMuted),
        ],
      ),
    );
  }
}

/// Donut chart with a centred total and a vertical legend on the right.
class _DonutWithLegend extends StatelessWidget {
  const _DonutWithLegend({
    required this.total,
    required this.totalLabel,
    required this.segments,
  });

  final String total;
  final String totalLabel;
  final List<ChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  startDegreeOffset: -90,
                  sections: [
                    for (final s in segments)
                      if (s.value > 0)
                        PieChartSectionData(
                          color: s.color,
                          value: s.value,
                          radius: 16,
                          showTitle: false,
                        ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(total,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DashV2Colors.textDark,
                      )),
                  Text(totalLabel, style: DashV2Text.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in segments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.label,
                            style: DashV2Text.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(s.display,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DashV2Colors.textDark,
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Total amount + stacked progress bar + legend for the Expenses card.
class _ExpenseBreakdown extends StatelessWidget {
  const _ExpenseBreakdown({required this.total, required this.segments});

  final String total;
  final List<ChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    final sum = segments.fold<double>(0, (p, s) => p + s.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(total,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DashV2Colors.textDark,
            )),
        Text('Total Claimed', style: DashV2Text.caption),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (final s in segments)
                  if (s.value > 0)
                    Expanded(
                      flex: sum == 0 ? 1 : (s.value / sum * 1000).round(),
                      child: Container(color: s.color),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final s in segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.label,
                      style: DashV2Text.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Text(s.display,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DashV2Colors.textDark,
                    )),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// List section
// ---------------------------------------------------------------------------

class _ListSection extends StatelessWidget {
  const _ListSection({required this.controller, required this.columns});

  final DashboardV2Controller controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Snapshot the reactive lists inside the Obx scope. Iterating with
      // toList() registers the dependency and prevents the
      // "improper use of GetX" error caused by deferred builder closures.
      final pjpApprovals = controller.pjpApprovals.toList();
      final openTickets = controller.openTickets.toList();
      final recentExpenses = controller.recentExpenses.toList();

      final cards = <Widget>[
        _ListCard(
          title: 'PJP Approval Pending (From My Side)',
          headers: const ['Request No', 'Employee', 'Amount', 'Due Date'],
          entries: pjpApprovals,
          footerLabel: 'Go to Approval',
          empty: const EmptyConfig(
            icon: Icons.verified_outlined,
            color: DashV2Colors.amber,
            title: 'No pending approvals',
            message: 'Great! You have no PJP approvals pending.',
            actionLabel: '',
          ),
          rowBuilder: (e) => _ThreeColRow(
            a: e.id,
            b: e.primary,
            c: e.trailing,
            d: e.status,
            dColor: e.statusColor,
          ),
        ),
        _ListCard(
          title: 'My Open Helpdesk Tickets',
          headers: const ['Ticket ID', 'Issue Type', 'Status', 'Priority'],
          entries: openTickets,
          footerLabel: 'Go to My Tickets',
          empty: const EmptyConfig(
            icon: Icons.inbox_outlined,
            color: DashV2Colors.blue,
            title: 'No open tickets',
            message: "All caught up! You have no open tickets.",
            actionLabel: '',
          ),
          rowBuilder: (e) => _ThreeColRow(
            a: e.id,
            b: e.primary,
            c: e.status,
            cIsBadge: true,
            cColor: e.statusColor,
            d: e.secondary,
          ),
        ),
        _ListCard(
          title: 'Recent Expenses',
          headers: const ['Exp. No', 'Category', 'Amount', 'Status'],
          entries: recentExpenses,
          footerLabel: 'Go to Expenses',
          empty: const EmptyConfig(
            icon: Icons.receipt_long_outlined,
            color: DashV2Colors.pink,
            title: 'No recent expenses',
            message: 'No expenses found for the selected period.',
            actionLabel: '',
          ),
          rowBuilder: (e) => _ThreeColRow(
            a: e.id,
            b: e.primary,
            c: e.trailing,
            d: e.status,
            dIsBadge: true,
            dColor: e.statusColor,
          ),
        ),
      ];

      return _Wrap(
        spacing: 16,
        runSpacing: 16,
        itemCount: cards.length,
        perRow: columns,
        builder: (i) => cards[i],
      );
    });
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.headers,
    required this.entries,
    required this.footerLabel,
    required this.empty,
    required this.rowBuilder,
  });

  final String title;
  final List<String> headers;
  final List<ListEntry> entries;
  final String footerLabel;
  final EmptyConfig empty;
  final Widget Function(ListEntry) rowBuilder;

  @override
  Widget build(BuildContext context) {
    final hasData = entries.isNotEmpty;
    return _CardShell(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title,
                    style: DashV2Text.sectionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (hasData) Text('View All', style: DashV2Text.link),
            ],
          ),
          const SizedBox(height: 14),
          if (hasData) ...[
            _ThreeColRow(
              a: headers[0],
              b: headers[1],
              c: headers[2],
              d: headers[3],
              isHeader: true,
            ),
            const SizedBox(height: 8),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: rowBuilder(e),
              ),
            const SizedBox(height: 6),
            const Divider(height: 1, color: DashV2Colors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(footerLabel, style: DashV2Text.link),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: DashV2Colors.blue),
              ],
            ),
          ] else
            SizedBox(
              height: 180,
              child: _EmptyPlaceholder(config: empty),
            ),
        ],
      ),
    );
  }
}

/// A flexible 4-column row used for both headers and data rows.
class _ThreeColRow extends StatelessWidget {
  const _ThreeColRow({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    this.isHeader = false,
    this.cIsBadge = false,
    this.dIsBadge = false,
    this.cColor = DashV2Colors.textDark,
    this.dColor = DashV2Colors.textDark,
  });

  final String a;
  final String b;
  final String c;
  final String d;
  final bool isHeader;
  final bool cIsBadge;
  final bool dIsBadge;
  final Color cColor;
  final Color dColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _cell(a, isHeader, color: DashV2Colors.blue)),
        Expanded(flex: 3, child: _cell(b, isHeader)),
        Expanded(
            flex: 3,
            child: cIsBadge ? _badge(c, cColor) : _cell(c, isHeader, color: cColor)),
        Expanded(
            flex: 3,
            child: dIsBadge ? _badge(d, dColor) : _cell(d, isHeader, color: dColor)),
      ],
    );
  }

  Widget _cell(String text, bool header, {Color? color}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: header ? 10.5 : 11.5,
        fontWeight: header ? FontWeight.w600 : FontWeight.w500,
        color: header ? DashV2Colors.textMuted : (color ?? DashV2Colors.textDark),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection(
      {required this.controller, required this.columns});

  final DashboardV2Controller controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final perRow = columns == 1 ? 2 : (columns == 2 ? 3 : 6);
    return _CardShell(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: DashV2Text.sectionTitle),
          const SizedBox(height: 14),
          _Wrap(
            spacing: 12,
            runSpacing: 12,
            itemCount: controller.quickActions.length,
            perRow: perRow,
            builder: (i) => _QuickActionTile(action: controller.quickActions[i]),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DashV2Colors.scaffold,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DashV2Colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(action.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DashV2Colors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(action.subtitle,
                      style: DashV2Text.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared building blocks
// ---------------------------------------------------------------------------

/// Standard white card container with soft border and shadow.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashV2Colors.border),
        boxShadow: const [
          BoxShadow(
            color: DashV2Colors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Centered illustration + message + optional CTA for empty states.
class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.config});

  final EmptyConfig config;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DashV2Colors.tint(config.color),
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, color: config.color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(config.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DashV2Colors.textDark,
              )),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(config.message,
                textAlign: TextAlign.center, style: DashV2Text.caption),
          ),
          if (config.actionLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: config.color,
                side: BorderSide(color: config.color.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(config.actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: config.color,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

/// A responsive grid that lays out [itemCount] children at [perRow] per row.
///
/// Unlike [Wrap], every cell in a row is stretched to the tallest sibling
/// (via [IntrinsicHeight]) so cards align at top and bottom exactly like the
/// Figma design. Rows are separated by [runSpacing] and columns by [spacing].
class _Wrap extends StatelessWidget {
  const _Wrap({
    required this.itemCount,
    required this.perRow,
    required this.builder,
    required this.spacing,
    required this.runSpacing,
  });

  final int itemCount;
  final int perRow;
  final Widget Function(int index) builder;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    final columns = perRow.clamp(1, itemCount);

    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            if (i > 0) SizedBox(height: runSpacing),
            builder(i),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (int start = 0; start < itemCount; start += columns) {
      final end = (start + columns).clamp(0, itemCount);
      final cells = <Widget>[];
      for (int i = start; i < end; i++) {
        if (i > start) cells.add(SizedBox(width: spacing));
        cells.add(Expanded(child: builder(i)));
      }
      // Pad the final row so the last cells keep their column width.
      final filled = end - start;
      for (int p = filled; p < columns; p++) {
        cells.add(SizedBox(width: spacing));
        cells.add(const Expanded(child: SizedBox.shrink()));
      }
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: runSpacing),
          rows[r],
        ],
      ],
    );
  }
}
