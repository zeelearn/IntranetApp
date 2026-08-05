import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/utils/projects_sidebar_roles.dart';

void main() {
  group('ProjectsSidebarRoles', () {
    test('keeps common menus open for all roles', () {
      for (final role in ['MAN', 'BH', 'ZM', 'EMP', '', null]) {
        expect(ProjectsSidebarRoles.canShowProjects(role), isTrue);
        expect(ProjectsSidebarRoles.canShowAllIndents(role), isTrue);
        expect(ProjectsSidebarRoles.canShowCenterKitReport(role), isTrue);
      }
    });

    test('allows Visual Charts for MAN, BH, ZM only', () {
      expect(ProjectsSidebarRoles.canShowVisualCharts('MAN'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('BH'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('ZM'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('man'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('bh'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('zm'), isTrue);
      expect(ProjectsSidebarRoles.canShowVisualCharts('EMP'), isFalse);
      expect(ProjectsSidebarRoles.canShowVisualCharts(''), isFalse);
      expect(ProjectsSidebarRoles.canShowVisualCharts(null), isFalse);
    });
  });
}
