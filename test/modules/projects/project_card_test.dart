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

    // No message displayed when Branding_Indent_Id is null
    expect(
      find.textContaining('Branding Kit indent already created with Indent Id'),
      findsNothing,
    );
  });

  testWidgets(
      'disables Branding Kit button and displays message when Branding_Indent_Id is not null',
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
      'Branding_Indent_Id': '1051468',
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

    final buttonText = find.text('Branding Kit');
    expect(buttonText, findsOneWidget);

    final outlinedButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Branding Kit'),
    );
    // Button must be disabled
    expect(outlinedButton.onPressed, isNull);

    // Message must be displayed on card
    final expectedMessage =
        'Branding Kit indent already created with Indent Id 1051468.';
    expect(find.text(expectedMessage), findsOneWidget);

    // Tapping the disabled button does not invoke onBrandingKit callback
    await tester.tap(buttonText);
    await tester.pump();
    expect(tapped, isFalse);

    // Message is also displayed via SnackBar upon tapping
    expect(find.text(expectedMessage), findsWidgets);
  });
}
