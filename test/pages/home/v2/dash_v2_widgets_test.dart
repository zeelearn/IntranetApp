import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_kpi_row.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_card.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_quick_access_grid.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _WidgetTestController extends DashboardScreenV2Controller {
  _WidgetTestController() : super(userId: 'widget-test');

  String? tappedQuickAccess;
  String? tappedSidebar;

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
}
