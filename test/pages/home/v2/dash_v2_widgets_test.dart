import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_kpi_row.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_project_status_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_grid.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_recent_activity_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_sidebar.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_upcoming_reminders_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_web_top_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _WidgetTestController extends DashboardScreenV2Controller {
  _WidgetTestController() : super(userId: 'widget-test');

  String? tappedQuickAccess;
  String? tappedSidebar;
  var sidebarToggleCount = 0;
  var searchTapCount = 0;
  var notificationsTapCount = 0;
  var newProjectTapCount = 0;
  var projectsTapCount = 0;

  @override
  void onInit() {
    seedPlaceholders();
  }

  @override
  Future<void> onQuickAccessTap(String key) async {
    tappedQuickAccess = key;
  }

  @override
  Future<void> onSidebarTap(String key) async {
    tappedSidebar = key;
  }

  @override
  void toggleSidebar() {
    sidebarToggleCount++;
    super.toggleSidebar();
  }

  @override
  void onSearchTap() {
    searchTapCount++;
  }

  @override
  void onNotificationsTap() {
    notificationsTapCount++;
  }

  @override
  Future<void> openNewProject() async {
    newProjectTapCount++;
  }

  @override
  Future<void> openProjects() async {
    projectsTapCount++;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('mobile KPI row renders all controller statistics',
      (tester) async {
    Get.put<DashboardScreenV2Controller>(_WidgetTestController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: SizedBox(width: 390, child: DashKpiRow())),
      ),
    );

    expect(find.text('My PJP'), findsOneWidget);
    expect(find.text('My CVF'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
  });

  testWidgets('quick access grid uses two columns and forwards taps',
      (tester) async {
    final controller = _WidgetTestController();
    Get.put<DashboardScreenV2Controller>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox(width: 390, child: DashQuickAccessGrid()),
        ),
      ),
    );

    final cards = find.byType(DashQuickAccessCard);
    final projects = tester.getTopLeft(cards.at(0));
    final myPjp = tester.getTopLeft(cards.at(1));
    final myCvf = tester.getTopLeft(cards.at(2));
    expect(projects.dy, myPjp.dy);
    expect(myCvf.dy, greaterThan(projects.dy));

    await tester.tap(find.text('Projects'));
    expect(controller.tappedQuickAccess, 'projects');
  });

  testWidgets('sidebar highlights dashboard and forwards navigation',
      (tester) async {
    final controller = _WidgetTestController();
    Get.put<DashboardScreenV2Controller>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: SizedBox(width: 280, child: DashSidebar())),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Approvals'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    await tester.tap(find.text('PJP').first);
    expect(controller.tappedSidebar, 'pjp');
  });

  testWidgets('web top bar renders identity and forwards header actions',
      (tester) async {
    final controller = _WidgetTestController();
    controller
      ..userFullName.value = 'Asha Patil'
      ..firstName.value = 'Asha'
      ..designation.value = 'Project Manager';
    Get.put<DashboardScreenV2Controller>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox(width: 1200, child: DashWebTopBar()),
        ),
      ),
    );

    expect(find.text('Search here…'), findsOneWidget);
    expect(find.text('Stay updated with your tasks'), findsOneWidget);
    expect(find.text('Asha Patil'), findsOneWidget);
    expect(find.text('Project Manager'), findsOneWidget);
    expect(find.text('May 20 – May 26, 2024'), findsOneWidget);
    expect(find.text('+ New Project'), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle sidebar'));
    await tester.tap(find.byTooltip('Search'));
    await tester.tap(find.byTooltip('Notifications'));
    await tester.tap(find.text('+ New Project'));

    expect(controller.sidebarToggleCount, 1);
    expect(controller.searchTapCount, 1);
    expect(controller.notificationsTapCount, 1);
    expect(controller.newProjectTapCount, 1);
  });

  testWidgets('project status card renders chart legend and projects action',
      (tester) async {
    final controller = _WidgetTestController();
    Get.put<DashboardScreenV2Controller>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 480,
            height: 520,
            child: DashProjectStatusCard(),
          ),
        ),
      ),
    );

    expect(find.text('Project Status Overview'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    for (final segment in controller.projectStatusSegments) {
      expect(find.text(segment.label), findsOneWidget);
    }

    await tester.tap(find.text('View All Projects'));
    expect(controller.projectsTapCount, 1);
  });

  testWidgets('activity and reminder cards render controller placeholders',
      (tester) async {
    Get.put<DashboardScreenV2Controller>(_WidgetTestController());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: Row(
              children: [
                Expanded(child: DashRecentActivityCard()),
                Expanded(child: DashUpcomingRemindersCard()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('PJP plan submitted'), findsOneWidget);
    expect(find.text('Upcoming Reminders'), findsOneWidget);
    expect(find.text('Submit weekly PJP'), findsOneWidget);
    expect(find.text('View All'), findsNWidgets(2));
  });
}
