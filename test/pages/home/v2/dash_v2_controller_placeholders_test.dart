import 'dart:async';
import 'dart:typed_data';

import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('forced profile fetch bypasses cached avatar', () async {
    var fetchCount = 0;
    final c = DashboardScreenV2Controller(
      userId: '1',
      profileImageFetcher: (_, __) => fetchCount++,
    );
    c.profileAvatarBytes.value = Uint8List.fromList([1]);

    await c.getProfileImage();
    await c.getProfileImage(force: true);

    expect(fetchCount, 1);
  });

  test('foreground registration replaces and disposes subscriptions', () async {
    final cancelledEmployees = <String>[];
    final c = DashboardScreenV2Controller(
      userId: '1',
      foregroundNotificationRegistrar: (employeeId) async {
        final messages = StreamController<RemoteMessage>(
          onCancel: () => cancelledEmployees.add(employeeId),
        );
        return messages.stream.listen((_) {});
      },
    );

    await c.registerForegroundNotifications('101');
    await c.registerForegroundNotifications('202');
    expect(cancelledEmployees, ['101']);

    c.onClose();
    await Future<void>.delayed(Duration.zero);
    expect(cancelledEmployees, ['101', '202']);
  });
}
