import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/employee_list_response.dart';
import 'package:Intranet/modules/projects/bindings/project_configuration_binding.dart';
import 'package:Intranet/modules/projects/controllers/project_configuration_controller.dart';
import 'package:Intranet/modules/projects/models/reassignable_project.dart';
import 'package:Intranet/modules/projects/utils/projects_sidebar_roles.dart';
import 'package:Intranet/modules/projects/views/project_configuration_screen.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_employee_picker.dart';
import 'package:Intranet/modules/projects/widgets/reassignment_projects_table.dart';

import 'fake_project_reassignment_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(Get.reset);

  test('openFromHive is available for Business Head', () {
    expect(ProjectsSidebarRoles.canShowConfiguration('BH'), isTrue);
    expect(ProjectsSidebarRoles.canShowConfiguration('MAN'), isFalse);
    expect(ProjectsSidebarRoles.canShowConfiguration('ZM'), isFalse);
  });

  testWidgets('projects table shows select-all and status chips', (tester) async {
    const projects = [
      ReassignableProject(
        id: 'PRJ001',
        name: 'Sunrise Academy',
        status: 'Active',
        teamLabels: ['North'],
        ownerId: '1001',
        ownerName: 'Amit Verma',
      ),
      ReassignableProject(
        id: 'PRJ002',
        name: 'Green Valley School',
        status: 'In Progress',
        teamLabels: ['West'],
        ownerId: '1001',
        ownerName: 'Amit Verma',
      ),
      ReassignableProject(
        id: 'PRJ003',
        name: 'Blue Ridge Public School',
        status: 'Pending',
        teamLabels: ['East'],
        ownerId: '1001',
        ownerName: 'Amit Verma',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReassignmentProjectsTable(
            shrinkWrap: true,
            projects: projects,
            selectedIds: const {'PRJ001'},
            onToggle: (_) {},
            onSelectAllPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Select all (3)'), findsOneWidget);
    expect(find.text('Sunrise Academy'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('With: Amit Verma'), findsNWidgets(3));
  });

  FakeProjectReassignmentRepository _fixtureRepo() {
    return FakeProjectReassignmentRepository(
      employees: [
        EmployeeInfo(
          employeeFullName: 'Amit Verma',
          employeeContactNumber: '9876543210',
          employeeEmailId: 'amit.verma@example.com',
          employeeCode: 'EMP001',
          employeeDesignation: 'Business Head',
          empAppStatus: 'Active',
          display: 'Amit Verma (EMP001)',
          employeeId: '1001',
        ),
        EmployeeInfo(
          employeeFullName: 'Neha Kapoor',
          employeeContactNumber: '9876543211',
          employeeEmailId: 'neha.kapoor@example.com',
          employeeCode: 'EMP002',
          employeeDesignation: 'Zone Manager',
          empAppStatus: 'Active',
          display: 'Neha Kapoor (EMP002)',
          employeeId: '1002',
        ),
      ],
      projects: const [
        ReassignableProject(
          id: 'PRJ001',
          name: 'Sunrise Academy',
          status: 'Active',
          teamLabels: ['North'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p1',
          taskId: 1,
        ),
        ReassignableProject(
          id: 'PRJ002',
          name: 'Green Valley School',
          status: 'In Progress',
          teamLabels: ['West'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p2',
          taskId: 2,
        ),
        ReassignableProject(
          id: 'PRJ003',
          name: 'Blue Ridge Public School',
          status: 'Pending',
          teamLabels: ['East'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p3',
          taskId: 3,
        ),
        ReassignableProject(
          id: 'PRJ004',
          name: 'Heritage International',
          status: 'Active',
          teamLabels: ['South'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p4',
          taskId: 4,
        ),
        ReassignableProject(
          id: 'PRJ005',
          name: 'Maple Leaf Academy',
          status: 'In Progress',
          teamLabels: ['North'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p5',
          taskId: 5,
        ),
        ReassignableProject(
          id: 'PRJ006',
          name: 'Silver Oak School',
          status: 'Active',
          teamLabels: ['Central'],
          ownerId: '1001',
          ownerName: 'Amit Verma',
          projectId: 'p6',
          taskId: 6,
        ),
      ],
    );
  }

  testWidgets('configuration screen loads API-backed employees and actions',
      (tester) async {
    const userId = 101;
    final tag = ProjectConfigurationBinding.makeTag(userId);
    final controller = ProjectConfigurationController(
      repository: _fixtureRepo(),
    );
    Get.put(controller, tag: tag);

    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: ProjectConfigurationScreen(
          userId: userId,
          managerCode: '14002030',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Project Reassignment'), findsOneWidget);
    expect(find.textContaining('Submit'), findsWidgets);
    expect(find.text('Add Configuration'), findsOneWidget);
    expect(find.text('Current employee'), findsOneWidget);
    expect(find.text('Task status'), findsWidgets);
    expect(find.text('Mapped Projects (0)'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);

    await controller.load();
    final source =
        controller.employees.firstWhere((e) => e.employeeCode == 'EMP001');
    await controller.selectSourceAndLoad(source);
    await tester.pumpAndSettle();

    expect(controller.sourceEmployee.value?.employeeCode, 'EMP001');
    expect(controller.sourceProjects, hasLength(6));
    expect(find.text('Project Reassignment'), findsOneWidget);
    expect(find.text('Mapped Projects (6)'), findsOneWidget);
  });

  testWidgets('selecting a project row marks the checkbox selected',
      (tester) async {
    const userId = 202;
    final tag = ProjectConfigurationBinding.makeTag(userId);
    final controller = ProjectConfigurationController(
      repository: _fixtureRepo(),
    );
    Get.put(controller, tag: tag);

    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      GetMaterialApp(
        home: ProjectConfigurationScreen(
          userId: userId,
          managerCode: '14002030',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await controller.load();
    final source =
        controller.employees.firstWhere((e) => e.employeeCode == 'EMP001');
    await controller.selectSourceAndLoad(source);
    await tester.pumpAndSettle();

    expect(controller.selectedProjectIds, isEmpty);
    controller.toggleProject('PRJ001');
    await tester.pump();

    expect(controller.selectedProjectIds, contains('PRJ001'));

    controller.toggleSelectAllProjects();
    await tester.pump();
    expect(controller.selectedProjectIds, hasLength(6));
  });

  testWidgets('picker clear deselects the chosen employee', (tester) async {
    final employee = EmployeeInfo(
      employeeFullName: 'Amit Verma',
      employeeContactNumber: '9876543210',
      employeeEmailId: 'amit.verma@example.com',
      employeeCode: 'EMP001',
      employeeDesignation: 'Business Head',
      empAppStatus: 'Active',
      display: 'Amit Verma (EMP001)',
      employeeId: '1001',
    );
    EmployeeInfo? selected = employee;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ReassignmentEmployeePicker(
                label: 'Current employee',
                hint: 'Search',
                employees: [employee],
                selected: selected,
                showSelectedCard: true,
                onQueryChanged: (_) {},
                onSelected: (value) => setState(() => selected = value),
                onCleared: () => setState(() => selected = null),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Amit Verma'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();

    expect(selected, isNull);
    expect(find.byType(ReassignmentEmployeeCard), findsNothing);
  });
}
