import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';
import 'package:Intranet/modules/projects/widgets/project_card.dart';

void main() {
  testWidgets('shows and handles Branding Kit for a project BusinessRef_Id',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    final project = ProjectItem.fromJson({
      'CRM_id': 'crm-1',
      'Franchisee_Id': 100,
      'BusinessRef_Id': 200,
      'taskcount': 'P-1',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCard(
            project: project,
            statusLabel: 'Active',
            statusColor: Colors.blue,
            onCommunication: () {},
            onIndentDetails: () {},
            onCardTap: () {},
            onDocuments: () {},
            onViewReport: () {},
            onSendCredentials: () {},
            onBrandingKit: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = find.text('Branding Kit');
    expect(button, findsOneWidget);
    await tester.tap(button);
    expect(tapped, isTrue);
  });
}
