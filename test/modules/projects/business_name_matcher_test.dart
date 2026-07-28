import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_business.dart';
import 'package:Intranet/modules/projects/utils/business_name_matcher.dart';

void main() {
  group('normalizeBusinessName', () {
    test('trims, lowercases, strips non-alphanumeric', () {
      expect(normalizeBusinessName('  Kid Zee '), 'kidzee');
    });

    test('strips leading e after normalize', () {
      expect(normalizeBusinessName('eKidzee'), 'kidzee');
      expect(normalizeBusinessName('eMountLitera'), 'mountlitera');
      expect(normalizeBusinessName('Kidzee'), 'kidzee');
    });

    test('empty and whitespace become empty', () {
      expect(normalizeBusinessName(''), '');
      expect(normalizeBusinessName('   '), '');
    });
  });

  group('matchProjectBusinessByName', () {
    final list = [
      const ProjectBusiness(businessId: 1, businessName: 'eKidzee'),
      const ProjectBusiness(businessId: 3, businessName: 'eMountLitera'),
    ];

    test('maps intranet Kidzee to Projects id 1', () {
      final match = matchProjectBusinessByName(
        intranetName: 'Kidzee',
        projectsBusinesses: list,
      );
      expect(match?.businessId, 1);
    });

    test('maps eMountLitera / Mount Litera to id 3', () {
      expect(
        matchProjectBusinessByName(
          intranetName: 'Mount Litera',
          projectsBusinesses: list,
        )?.businessId,
        3,
      );
    });

    test('returns null when no match', () {
      expect(
        matchProjectBusinessByName(
          intranetName: 'BP Management',
          projectsBusinesses: list,
        ),
        isNull,
      );
    });

    test('returns null for empty intranet name', () {
      expect(
        matchProjectBusinessByName(
          intranetName: '',
          projectsBusinesses: list,
        ),
        isNull,
      );
    });
  });

  group('ProjectBusiness', () {
    test('fromJson parses GetBusiness row', () {
      final item = ProjectBusiness.fromJson({
        'Business_Id': 1,
        'Business_Name': 'eKidzee',
      });
      expect(item.businessId, 1);
      expect(item.businessName, 'eKidzee');
    });

    test('ProjectBusinessResponse parses envelope', () {
      final response = ProjectBusinessResponse.fromJson({
        'success': 200,
        'data': [
          {'Business_Id': 1, 'Business_Name': 'eKidzee'},
          {'Business_Id': 3, 'Business_Name': 'eMountLitera'},
        ],
      });
      expect(response.success, 200);
      expect(response.data.length, 2);
      expect(response.data.first.businessId, 1);
    });
  });
}
