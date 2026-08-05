import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/center_kit_item.dart';
import 'package:Intranet/modules/projects/repositories/center_kit_repository.dart';
import 'package:Intranet/modules/projects/services/center_kit_local_service.dart';
import 'package:Intranet/modules/projects/services/center_kit_remote_service.dart';

CenterKitItem _sample({
  String name = 'Walia Eduskills Path',
  String code = 'KDZ- Walia Eduskills Path',
  String zone = 'N',
  String state = 'Rajasthan',
  String agreement = '10227',
  int indentId = 1100476,
  String indentStatus = 'Pending Fin Clearing',
  String projectManager = 'Mayank Chauhan',
  String payment = 'Pending',
  double? apprAmount,
}) {
  return CenterKitItem(
    franchiseeCode: code,
    franchiseeName: name,
    zoneCode: zone,
    stateName: state,
    agreementNo: agreement,
    pil: 672130,
    apprAmount: apprAmount,
    dueAmount: 672130,
    dueDate: '2026-11-25T00:00:00.000Z',
    indentId: indentId,
    indentStatus: indentStatus,
    projectManager: projectManager,
    paymentStatus: payment,
  );
}

void main() {
  group('CenterKitItem parsing', () {
    test('parses API sample payload fields', () {
      final item = CenterKitItem.fromJson({
        'Franchisee_Code': 'KDZ- Walia Eduskills Path',
        'Franchisee_Name': 'Walia Eduskills Path',
        'Zone_Code': 'N',
        'State_Name': 'Rajasthan',
        'Agreement_No': '10227',
        'PIL': 672130,
        'Appr_Amount': null,
        'Due_Amount': 672130,
        'Due_Date': '2026-11-25T00:00:00.000Z',
        'indent_Id': 1100476,
        'Indent_Status': 'Pending Fin Clearing',
        'Project_Manager': ' Mayank Chauhan',
        'PaymentStatus': 'Pending',
      });

      expect(item.franchiseeName, 'Walia Eduskills Path');
      expect(item.franchiseeCode, 'KDZ- Walia Eduskills Path');
      expect(item.zoneCode, 'N');
      expect(item.stateName, 'Rajasthan');
      expect(item.agreementNo, '10227');
      expect(item.pil, 672130);
      expect(item.apprAmount, isNull);
      expect(item.dueAmount, 672130);
      expect(item.indentId, 1100476);
      expect(item.indentStatus, 'Pending Fin Clearing');
      expect(item.projectManager, 'Mayank Chauhan');
      expect(item.paymentStatus, 'Pending');
    });

    test('handles Indent_Id alias and string numbers', () {
      final item = CenterKitItem.fromJson({
        'Indent_Id': '99',
        'PIL': '100.5',
        'Appr_Amount': '50',
        'Due_Amount': '25',
        'Project_Manager': '  Alex  ',
      });
      expect(item.indentId, 99);
      expect(item.pil, 100.5);
      expect(item.apprAmount, 50);
      expect(item.dueAmount, 25);
      expect(item.projectManager, 'Alex');
    });

    test('toJson round-trips key fields', () {
      final original = _sample(apprAmount: 1000);
      final again = CenterKitItem.fromJson(original.toJson());
      expect(again, equals(original));
    });
  });

  group('CenterKitListResponse', () {
    test('parses envelope with data list', () {
      final response = CenterKitListResponse.fromJson({
        'success': 200,
        'data': [
          {
            'Franchisee_Name': 'A',
            'indent_Id': 1,
            'PaymentStatus': 'Pending',
            'Project_Manager': 'PM1',
          },
          {
            'Franchisee_Name': 'B',
            'indent_Id': 2,
            'PaymentStatus': 'Cleared',
            'Project_Manager': 'PM2',
          },
        ],
      });
      expect(response.success, 200);
      expect(response.data, hasLength(2));
      expect(response.data.first.franchiseeName, 'A');
      expect(response.data.last.projectManager, 'PM2');
    });

    test('tolerates missing or non-list data', () {
      expect(CenterKitListResponse.fromJson({'success': 200}).data, isEmpty);
      expect(
        CenterKitListResponse.fromJson({'success': 200, 'data': 'bad'}).data,
        isEmpty,
      );
    });
  });

  group('CenterKitFilter', () {
    test('empty has no active filters', () {
      expect(CenterKitFilter.empty.hasActiveFilters, isFalse);
      expect(CenterKitFilter.empty.activeCount, 0);
    });

    test('activeCount and hasActiveFilters', () {
      const f = CenterKitFilter(
        indentStatus: 'Pending',
        projectManager: 'Mayank Chauhan',
      );
      expect(f.hasActiveFilters, isTrue);
      expect(f.activeCount, 2);
    });

    test('copyWith clear flags', () {
      const base = CenterKitFilter(
        indentStatus: 'Pending',
        paymentStatus: 'Pending',
        stateName: 'Rajasthan',
      );
      final updated = base.copyWith(
        zoneCode: 'S',
        clearPaymentStatus: true,
      );
      expect(updated.indentStatus, 'Pending');
      expect(updated.paymentStatus, isNull);
      expect(updated.zoneCode, 'S');
      expect(updated.stateName, 'Rajasthan');
    });
  });

  group('CenterKitRepository.applyQuery', () {
    late CenterKitRepository repo;
    late List<CenterKitItem> source;

    setUp(() {
      repo = CenterKitRepository(
        remoteService: CenterKitRemoteService(),
        localService: CenterKitLocalService(),
      );
      source = [
        _sample(),
        _sample(
          name: 'South Center',
          code: 'SC-01',
          zone: 'S',
          state: 'Karnataka',
          agreement: '20001',
          indentId: 2200,
          indentStatus: 'Approved',
          projectManager: 'Riya',
          payment: 'Cleared',
        ),
        _sample(
          name: 'East Hub',
          code: 'EH-02',
          zone: 'E',
          state: 'West Bengal',
          agreement: '30001',
          indentId: 3300,
          indentStatus: 'Rejected',
          projectManager: 'Amit',
          payment: 'Pending',
        ),
      ];
    });

    test('returns all when search and filter empty', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: CenterKitFilter.empty,
      );
      expect(result, hasLength(3));
    });

    test('search by franchisee name (case insensitive)', () {
      final result = repo.applyQuery(
        source: source,
        search: 'walia',
        filter: CenterKitFilter.empty,
      );
      expect(result, hasLength(1));
      expect(result.first.indentId, 1100476);
    });

    test('search by project manager', () {
      final result = repo.applyQuery(
        source: source,
        search: 'riya',
        filter: CenterKitFilter.empty,
      );
      expect(result.single.projectManager, 'Riya');
    });

    test('search by indent id and agreement', () {
      expect(
        repo
            .applyQuery(
              source: source,
              search: '2200',
              filter: CenterKitFilter.empty,
            )
            .single
            .indentId,
        2200,
      );
      expect(
        repo
            .applyQuery(
              source: source,
              search: '30001',
              filter: CenterKitFilter.empty,
            )
            .single
            .agreementNo,
        '30001',
      );
    });

    test('filters by indent / payment status', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: const CenterKitFilter(
          indentStatus: 'Approved',
          paymentStatus: 'Cleared',
        ),
      );
      expect(result, hasLength(1));
      expect(result.single.indentId, 2200);
    });

    test('filters by zone, state and project manager', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: const CenterKitFilter(
          zoneCode: 'E',
          stateName: 'West Bengal',
          projectManager: 'Amit',
        ),
      );
      expect(result.single.indentId, 3300);
    });

    test('combines search and filter', () {
      final result = repo.applyQuery(
        source: source,
        search: 'pending',
        filter: const CenterKitFilter(zoneCode: 'N'),
      );
      expect(result, hasLength(1));
      expect(result.single.indentId, 1100476);
    });

    test('returns empty when nothing matches', () {
      final result = repo.applyQuery(
        source: source,
        search: 'zzz-no-match',
        filter: CenterKitFilter.empty,
      );
      expect(result, isEmpty);
    });
  });

  group('CenterKitLocalService cache key', () {
    test('null business id uses all key', () {
      final local = CenterKitLocalService();
      expect(local.cacheKey(businessId: null), 'center_kit_all');
      expect(local.cacheKey(businessId: 1), 'center_kit_1');
    });
  });
}
