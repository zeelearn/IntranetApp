import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/bindings/project_configuration_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/services/mock_project_reassignment_service.dart';
import 'package:Intranet/modules/projects/utils/projects_sidebar_roles.dart';
import 'package:Intranet/modules/projects/views/project_configuration_screen.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_projects_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(Get.reset);

  test('openFromHive is BH-gated via sidebar role helper', () {
    expect(ProjectsSidebarRoles.canShowConfiguration('BH'), isTrue);
    expect(ProjectsSidebarRoles.canShowConfiguration('MAN'), isFalse);
  });

  testWidgets('projects table shows select-all and status chips', (tester) async {
    const projects = [
      ReassignableProject(
        id: 'PRJ001',
        name: 'Sunrise Academy',
        status: 'Active',
        teamLabels: ['North'],
        ownerId: 'EMP001',
        ownerName: 'Amit Verma',
      ),
      ReassignableProject(
        id: 'PRJ002',
        name: 'Green Valley School',
        status: 'In Progress',
        teamLabels: ['West'],
        ownerId: 'EMP001',
        ownerName: 'Amit Verma',
      ),
      ReassignableProject(
        id: 'PRJ003',
        name: 'Blue Ridge Public School',
        status: 'Pending',
        teamLabels: ['East'],
        ownerId: 'EMP001',
        ownerName: 'Amit Verma',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReassignmentProjectsTable(
            shrinkWrap: true,
            projects: projects,
            selectedIds: const ['PRJ001'],
            onToggle: (_) {},
            onSelectAllPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Select All (3)'), findsOneWidget);
    expect(find.text('Sunrise Academy'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Owner: Amit Verma'), findsNWidgets(3));
  });

  testWidgets('configuration screen loads mock employees and actions',
      (tester) async {
    const userId = 101;
    final tag = ProjectConfigurationBinding.makeTag(userId);
    final controller = ProjectConfigurationController(
      repository: MockProjectReassignmentRepository(),
    );
    Get.put(controller, tag: tag);

    await tester.pumpWidget(
      GetMaterialApp(
        home: ProjectConfigurationScreen(userId: userId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mass Project Reassignment'), findsOneWidget);
    expect(find.text('Perform Mass Reassignment'), findsOneWidget);
    expect(find.text('Add Another Assignment Pair'), findsOneWidget);
    expect(find.text('Source employee'), findsOneWidget);
    expect(find.text('Target employee'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Amit');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amit Verma').first);
    await tester.pumpAndSettle();

    expect(find.text('Sunrise Academy'), findsOneWidget);
    expect(controller.sourceEmployee.value?.employeeCode, 'EMP001');
    expect(controller.sourceProjects, isNotEmpty);
  });
}
