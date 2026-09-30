import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_item.dart';

void main() {
  group('ProjectItem', () {
    test('fromJson maps GetAllProjectList_new fields', () {
      final item = ProjectItem.fromJson({
        'CRM_id': '259262000101590371',
        'Doc_url': 'https://example.com/doc.pdf',
        'approved_date': '2026-01-15',
        'Franchisee_Code': 'S-R-S-7230',
        'Franchisee_Name': 'Kidzee Siruseri',
        'Franchisee_Id': 7230,
        'deadline': '2026-12-31',
        'CreatedBy': 'Admin',
        'TotalNoOfTask': 12,
        'CatchmentArea': 'Chennai',
        'taskcount': 'C-2,IP-1,P-3',
        'Tier_Name': 'I2 TIER 8',
        'Fee_Type': 'ST',
        'Title': 'Project Title',
        'Responsible_person': 'Manager',
        'id': '99',
        'Illume_Indent_Id': null,
        'Branding_Indent_Id': null,
        'is_illume_dispatch_confirmed': null,
        'is_branding_dispatch_confirmed': null,
        'show_illume_dispatch_btn': 0,
        'show_branding_dispatch_btn': 0,
      });

      expect(item.crmId, '259262000101590371');
      expect(item.franchiseeId, 7230);
      expect(item.totalNoOfTask, 12);
      expect(item.feeType, 'ST');
      expect(item.taskSummary.completed, 2);
      expect(item.taskSummary.inProgress, 1);
      expect(item.taskSummary.pending, 3);
      expect(item.illumeIndentId, isNull);
      expect(item.brandingIndentId, isNull);
      expect(item.isIllumeDispatchConfirmed, isNull);
      expect(item.isBrandingDispatchConfirmed, isNull);
      expect(item.showIllumeDispatchBtn, 0);
      expect(item.showBrandingDispatchBtn, 0);
    });

    test('fromJson falls back project_id when CRM_id missing', () {
      final item = ProjectItem.fromJson({
        'project_id': 'proj-1',
        'Franchisee_Id': '42',
        'TotalNoOfTask': '5',
      });
      expect(item.crmId, 'proj-1');
      expect(item.franchiseeId, 42);
      expect(item.totalNoOfTask, 5);
    });

    test('toJson / copyWith round-trip key fields', () {
      final item = ProjectItem.fromJson({
        'CRM_id': 'crm-1',
        'Franchisee_Name': 'Name',
        'Franchisee_Id': 1,
        'taskcount': 'P-1',
        'Illume_Indent_Id': 'ill-1',
        'Branding_Indent_Id': 'br-1',
        'is_illume_dispatch_confirmed': true,
        'is_branding_dispatch_confirmed': false,
        'show_illume_dispatch_btn': 1,
        'show_branding_dispatch_btn': 1,
      });
      final json = item.toJson();
      expect(json['CRM_id'], 'crm-1');
      expect(json['Franchisee_Name'], 'Name');
      expect(json['Illume_Indent_Id'], 'ill-1');
      expect(json['Branding_Indent_Id'], 'br-1');
      expect(json['is_illume_dispatch_confirmed'], true);
      expect(json['is_branding_dispatch_confirmed'], false);
      expect(json['show_illume_dispatch_btn'], 1);
      expect(json['show_branding_dispatch_btn'], 1);

      final copied = item.copyWith(franchiseeName: 'Updated');
      expect(copied.franchiseeName, 'Updated');
      expect(copied.crmId, item.crmId);
      expect(copied.illumeIndentId, 'ill-1');
    });
  });

  group('CK/BK dispatch state matrix', () {
    ProjectItem base({
      String? illumeIndentId,
      String? brandingIndentId,
      bool? isIllumeConfirmed,
      bool? isBrandingConfirmed,
      int showIllume = 0,
      int showBranding = 0,
    }) {
      return ProjectItem(
        crmId: 'crm',
        docUrl: '',
        approvedDate: '',
        franchiseeCode: '',
        franchiseeName: 'F',
        franchiseeId: 1,
        deadline: '',
        createdBy: '',
        totalNoOfTask: 0,
        catchmentArea: '',
        taskcount: 'P-1',
        tierName: '',
        feeType: '',
        illumeIndentId: illumeIndentId,
        brandingIndentId: brandingIndentId,
        isIllumeDispatchConfirmed: isIllumeConfirmed,
        isBrandingDispatchConfirmed: isBrandingConfirmed,
        showIllumeDispatchBtn: showIllume,
        showBrandingDispatchBtn: showBranding,
      );
    }

    test('TEST 1: CK hidden when Illume_Indent_Id is null', () {
      final item = base(illumeIndentId: null, showIllume: 1);
      expect(item.shouldShowCKDispatch, isFalse);
      expect(item.canConfirmCKDispatch, isFalse);
    });

    test('TEST 2: CK hidden when show_illume_dispatch_btn != 1', () {
      final item = base(illumeIndentId: '123', showIllume: 0);
      expect(item.shouldShowCKDispatch, isFalse);
      expect(item.canConfirmCKDispatch, isFalse);
    });

    test('TEST 3: CK enabled when indent + show=1 + confirmed null', () {
      final item = base(
        illumeIndentId: '123',
        showIllume: 1,
        isIllumeConfirmed: null,
      );
      expect(item.shouldShowCKDispatch, isTrue);
      expect(item.isCKDispatchConfirmed, isFalse);
      expect(item.canConfirmCKDispatch, isTrue);
    });

    test('TEST 4: CK enabled when confirmed false', () {
      final item = base(
        illumeIndentId: '123',
        showIllume: 1,
        isIllumeConfirmed: false,
      );
      expect(item.canConfirmCKDispatch, isTrue);
      expect(item.isCKDispatchConfirmed, isFalse);
    });

    test('TEST 5: CK confirmed green state', () {
      final item = base(
        illumeIndentId: '123',
        showIllume: 1,
        isIllumeConfirmed: true,
      );
      expect(item.shouldShowCKDispatch, isTrue);
      expect(item.isCKDispatchConfirmed, isTrue);
      expect(item.canConfirmCKDispatch, isFalse);
    });

    test('TEST 6: BK hidden when Branding_Indent_Id is null', () {
      final item = base(brandingIndentId: null, showBranding: 1);
      expect(item.shouldShowBKDispatch, isFalse);
      expect(item.canConfirmBKDispatch, isFalse);
    });

    test('TEST 7: BK hidden when show_branding_dispatch_btn != 1', () {
      final item = base(brandingIndentId: '456', showBranding: 0);
      expect(item.shouldShowBKDispatch, isFalse);
      expect(item.canConfirmBKDispatch, isFalse);
    });

    test('TEST 8: BK enabled when indent + show=1 + confirmed null', () {
      final item = base(
        brandingIndentId: '456',
        showBranding: 1,
        isBrandingConfirmed: null,
      );
      expect(item.shouldShowBKDispatch, isTrue);
      expect(item.canConfirmBKDispatch, isTrue);
    });

    test('TEST 9: BK enabled when confirmed false', () {
      final item = base(
        brandingIndentId: '456',
        showBranding: 1,
        isBrandingConfirmed: false,
      );
      expect(item.canConfirmBKDispatch, isTrue);
    });

    test('TEST 10: BK confirmed green state', () {
      final item = base(
        brandingIndentId: '456',
        showBranding: 1,
        isBrandingConfirmed: true,
      );
      expect(item.shouldShowBKDispatch, isTrue);
      expect(item.isBKDispatchConfirmed, isTrue);
      expect(item.canConfirmBKDispatch, isFalse);
    });

    test('nullable bool parsing treats only true as confirmed', () {
      expect(
        ProjectItem.fromJson({
          'is_illume_dispatch_confirmed': 1,
          'Illume_Indent_Id': 'x',
          'show_illume_dispatch_btn': 1,
        }).isCKDispatchConfirmed,
        isTrue,
      );
      expect(
        ProjectItem.fromJson({
          'is_illume_dispatch_confirmed': 0,
          'Illume_Indent_Id': 'x',
          'show_illume_dispatch_btn': 1,
        }).isCKDispatchConfirmed,
        isFalse,
      );
      expect(
        ProjectItem.fromJson({
          'is_illume_dispatch_confirmed': 'true',
          'Illume_Indent_Id': 'x',
          'show_illume_dispatch_btn': 1,
        }).canConfirmCKDispatch,
        isFalse,
      );
    });
  });
}
