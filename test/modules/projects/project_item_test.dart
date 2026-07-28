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
      });

      expect(item.crmId, '259262000101590371');
      expect(item.franchiseeId, 7230);
      expect(item.totalNoOfTask, 12);
      expect(item.feeType, 'ST');
      expect(item.taskSummary.completed, 2);
      expect(item.taskSummary.inProgress, 1);
      expect(item.taskSummary.pending, 3);
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
      });
      final json = item.toJson();
      expect(json['CRM_id'], 'crm-1');
      expect(json['Franchisee_Name'], 'Name');

      final copied = item.copyWith(franchiseeName: 'Updated');
      expect(copied.franchiseeName, 'Updated');
      expect(copied.crmId, item.crmId);
    });
  });
}
