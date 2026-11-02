import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/pages/helper/mobile_applications_store.dart';
import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';

void main() {
  group('MyMobileApplication', () {
    test('parses login myMobileApplications payload', () {
      final app = MyMobileApplication.fromJson({
        'business_ID': 4.0,
        'employee_Id': '2863',
        'business_Name': 'BP Management',
        'imageURL': '../Images/icons/bpmgmt.png',
        'header_Path': null,
        'footer_Path': null,
        'path':
            'https://businesspartner.zeelearn.com/Singlesignonlogin.aspx?Token=ABC  ',
      });

      expect(app.businessId, 4);
      expect(app.normalizedName, 'BP Management');
      expect(app.hasValidLaunchUrl, isTrue);
      expect(
        app.launchUrl,
        'https://businesspartner.zeelearn.com/Singlesignonlogin.aspx?Token=ABC',
      );
    });
  });

  group('ResponseData.myMobileApplications', () {
    test('parses list and ignores malformed entries', () {
      final data = ResponseData.fromJson({
        'employeeDetails': [],
        'employeeRoles': [],
        'businessApplications': [],
        'myMobileApplications': [
          {
            'business_ID': 0.0,
            'employee_Id': '2863',
            'business_Name': 'Legal MIS',
            'imageURL': '../Images/icons/application_form_add.png',
            'path':
                'https://legalmis.zeelearn.com/login?t=TOKEN&s=legal_mis',
          },
          {
            'business_ID': 0.0,
            'employee_Id': '2863',
            'business_Name': 'Intranet 2.0',
            'path': 'https://intranetapp.zeelearn.com/',
          },
        ],
      });

      expect(data.myMobileApplications.length, 2);
      expect(data.myMobileApplications.first.normalizedName, 'Legal MIS');
      final json = data.toJson();
      expect(json['myMobileApplications'], isA<List>());
      expect((json['myMobileApplications'] as List).length, 2);
    });
  });

  group('MobileApplicationsStore.forDashboard', () {
    test('keeps only BP Management with valid URLs (Legal MIS excluded)', () {
      final apps = [
        MyMobileApplication(
          businessId: 1,
          employeeId: '1',
          businessName: 'eKidzee',
          imageUrl: '',
          path: 'https://app.zeelearn.com/',
        ),
        MyMobileApplication(
          businessId: 0,
          employeeId: '1',
          businessName: 'Legal MIS',
          imageUrl: '',
          path: 'https://legalmis.zeelearn.com/login?t=1',
        ),
        MyMobileApplication(
          businessId: 4,
          employeeId: '1',
          businessName: 'BP Management',
          imageUrl: '',
          path: 'https://businesspartner.zeelearn.com/',
        ),
      ];

      final visible = MobileApplicationsStore.forDashboard(apps);
      expect(visible.map((e) => e.normalizedName).toList(), [
        'BP Management',
      ]);
    });
  });

  group('DashV2MenuCatalog.visibleQuickAccess', () {
    test('shows BP Management only; Legal MIS is not a dashboard tile', () {
      final without = DashV2MenuCatalog.visibleQuickAccess(
        isBpms: false,
        employeeCode: 'x',
      );
      expect(without.any((e) => e.key == 'legal_mis'), isFalse);
      expect(without.any((e) => e.key == 'bp_management'), isFalse);

      final withBoth = DashV2MenuCatalog.visibleQuickAccess(
        isBpms: false,
        employeeCode: 'x',
        mobileAppNames: {
          MobileApplicationsStore.legalMis,
          MobileApplicationsStore.bpManagement,
        },
      );
      expect(withBoth.any((e) => e.key == 'legal_mis'), isFalse);
      expect(withBoth.any((e) => e.key == 'bp_management'), isTrue);
    });
  });
}
