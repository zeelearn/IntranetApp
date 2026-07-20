import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-BPMS user sees PJP-CVF Approval and not BPMS', () {
    final items = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: false,
      employeeCode: '99999999',
    );
    final keys = items.map((e) => e.key).toList();
    expect(keys, contains('pjp_cvf_approval_exp'));
    expect(keys, isNot(contains('bpms')));
    expect(keys, contains('projects'));
    expect(keys, contains('my_pjp'));
    expect(keys, contains('expenses'));
    expect(keys, isNot(contains('notiflow')));
  });

  test('BPMS user sees BPMS and still sees PJP-CVF Approval', () {
    final keys = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: true,
      employeeCode: '99999999',
    ).map((e) => e.key).toList();
    expect(keys, contains('bpms'));
    expect(keys, contains('pjp_cvf_approval_exp'));
  });

  test('notiflow allow-list emp code includes Notiflow', () {
    final keys = DashV2MenuCatalog.visibleQuickAccess(
      isBpms: false,
      employeeCode: '14002156',
    ).map((e) => e.key).toList();
    expect(keys, contains('notiflow'));
  });

  test('sidebar always includes dashboard, pjp, cvf, projects, approvals_pjp, logout', () {
    final keys = DashV2MenuCatalog.sidebarItems(isBpms: false)
        .map((e) => e.key)
        .toList();
    expect(keys, containsAll(['dashboard', 'pjp', 'cvf', 'projects_nav', 'approvals_pjp', 'logout']));
  });
}
