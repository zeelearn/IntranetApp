import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  test('seedPlaceholders fills KPI and lists', () {
    final c = DashboardScreenV2Controller(userId: '1');
    c.seedPlaceholders();
    expect(c.kpiStats.length, 4);
    expect(c.kpiStats[0].label, 'My PJP');
    expect(c.kpiStats[0].value, '24');
    expect(c.projectStatusSegments.isNotEmpty, true);
    expect(c.recentActivities.length, greaterThanOrEqualTo(3));
    expect(c.upcomingReminders.length, greaterThanOrEqualTo(3));
    expect(c.notificationCount.value, 3);
  });
}
