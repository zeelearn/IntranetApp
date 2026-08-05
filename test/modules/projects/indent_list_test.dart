import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/models/payment_link_result.dart';
import 'package:Intranet/modules/projects/repositories/indent_repository.dart';
import 'package:Intranet/modules/projects/services/indent_local_service.dart';
import 'package:Intranet/modules/projects/services/indent_remote_service.dart';
import 'package:Intranet/modules/projects/utils/indent_action_roles.dart';

IndentItem _sample({
  String name = 'Walia Eduskills Path',
  String code = 'KDZ- Walia Eduskills Path',
  String zone = 'N',
  String state = 'Rajasthan',
  String agreement = '10227',
  int indentId = 1100476,
  String indentStatus = 'Pending Fin Clearing',
  String createdBy = 'Ashutosh Srivastava',
  String payment = 'Pending',
  String project = 'Pending',
  double? apprAmount,
}) {
  return IndentItem(
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
    createdBy: createdBy,
    paymentStatus: payment,
    projectStatus: project,
    businessRefId: 7917,
  );
}

void main() {
  group('IndentItem parsing', () {
    test('parses API sample payload fields', () {
      final item = IndentItem.fromJson({
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
        'Created_By': 'Ashutosh Srivastava',
        'PaymentStatus': 'Pending',
        'ProjectStatus': 'Pending',
        'BusinessRef_Id': 7917,
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
      expect(item.paymentStatus, 'Pending');
      expect(item.projectStatus, 'Pending');
      expect(item.businessRefId, 7917);
    });

    test('handles Indent_Id alias and string numbers', () {
      final item = IndentItem.fromJson({
        'Indent_Id': '99',
        'PIL': '100.5',
        'Appr_Amount': '50',
        'Due_Amount': '25',
        'BusinessRef_Id': '7',
      });
      expect(item.indentId, 99);
      expect(item.pil, 100.5);
      expect(item.apprAmount, 50);
      expect(item.dueAmount, 25);
      expect(item.businessRefId, 7);
    });

    test('toJson round-trips key fields', () {
      final original = _sample(apprAmount: 1000);
      final again = IndentItem.fromJson(original.toJson());
      expect(again, equals(original));
    });

    test('canGeneratePaymentLink is false when Completed', () {
      expect(_sample(payment: 'Completed').canGeneratePaymentLink, isFalse);
      expect(_sample(payment: 'completed').canGeneratePaymentLink, isFalse);
      expect(_sample(payment: 'Pending').canGeneratePaymentLink, isTrue);
    });

    test('Franchisee_Id preferred over BusinessRef_Id', () {
      final item = IndentItem.fromJson({
        'Franchisee_Id': 2354,
        'BusinessRef_Id': 7917,
      });
      expect(item.businessRefId, 2354);
      expect(item.franchiseeId, 2354);
    });
  });

  group('IndentActionRoles', () {
    test('allows MAN and BH only', () {
      expect(IndentActionRoles.canAccessFinanceActions('MAN'), isTrue);
      expect(IndentActionRoles.canAccessFinanceActions('BH'), isTrue);
      expect(IndentActionRoles.canAccessFinanceActions('man'), isTrue);
      expect(IndentActionRoles.canAccessFinanceActions('bh'), isTrue);
      expect(IndentActionRoles.canAccessFinanceActions('ZM'), isFalse);
      expect(IndentActionRoles.canAccessFinanceActions('EMP'), isFalse);
      expect(IndentActionRoles.canAccessFinanceActions(''), isFalse);
      expect(IndentActionRoles.canAccessFinanceActions(null), isFalse);
    });
  });

  group('IndentListResponse', () {
    test('parses envelope with data list', () {
      final response = IndentListResponse.fromJson({
        'success': 200,
        'data': [
          {
            'Franchisee_Name': 'A',
            'indent_Id': 1,
            'PaymentStatus': 'Pending',
          },
          {
            'Franchisee_Name': 'B',
            'indent_Id': 2,
            'PaymentStatus': 'Cleared',
          },
        ],
      });
      expect(response.success, 200);
      expect(response.data, hasLength(2));
      expect(response.data.first.franchiseeName, 'A');
      expect(response.data.last.paymentStatus, 'Cleared');
    });

    test('tolerates missing or non-list data', () {
      expect(IndentListResponse.fromJson({'success': 200}).data, isEmpty);
      expect(
        IndentListResponse.fromJson({'success': 200, 'data': 'bad'}).data,
        isEmpty,
      );
    });
  });

  group('IndentListFilter', () {
    test('empty has no active filters', () {
      expect(IndentListFilter.empty.hasActiveFilters, isFalse);
      expect(IndentListFilter.empty.activeCount, 0);
    });

    test('activeCount and hasActiveFilters', () {
      const f = IndentListFilter(
        indentStatus: 'Pending',
        zoneCode: 'N',
      );
      expect(f.hasActiveFilters, isTrue);
      expect(f.activeCount, 2);
    });

    test('copyWith clear flags', () {
      const base = IndentListFilter(
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

  group('IndentRepository.applyQuery', () {
    late IndentRepository repo;
    late List<IndentItem> source;

    setUp(() {
      repo = IndentRepository(
        remoteService: IndentRemoteService(),
        localService: IndentLocalService(),
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
          createdBy: 'Riya',
          payment: 'Cleared',
          project: 'In Progress',
        ),
        _sample(
          name: 'East Hub',
          code: 'EH-02',
          zone: 'E',
          state: 'West Bengal',
          agreement: '30001',
          indentId: 3300,
          indentStatus: 'Rejected',
          createdBy: 'Amit',
          payment: 'Pending',
          project: 'Pending',
        ),
      ];
    });

    test('returns all when search and filter empty', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: IndentListFilter.empty,
      );
      expect(result, hasLength(3));
    });

    test('search by franchisee name (case insensitive)', () {
      final result = repo.applyQuery(
        source: source,
        search: 'walia',
        filter: IndentListFilter.empty,
      );
      expect(result, hasLength(1));
      expect(result.first.indentId, 1100476);
    });

    test('search by indent id and agreement', () {
      expect(
        repo.applyQuery(
          source: source,
          search: '2200',
          filter: IndentListFilter.empty,
        ).single.indentId,
        2200,
      );
      expect(
        repo.applyQuery(
          source: source,
          search: '30001',
          filter: IndentListFilter.empty,
        ).single.agreementNo,
        '30001',
      );
    });

    test('search by created by', () {
      final result = repo.applyQuery(
        source: source,
        search: 'riya',
        filter: IndentListFilter.empty,
      );
      expect(result.single.createdBy, 'Riya');
    });

    test('filters by indent / payment / project status', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: const IndentListFilter(
          indentStatus: 'Approved',
          paymentStatus: 'Cleared',
          projectStatus: 'In Progress',
        ),
      );
      expect(result, hasLength(1));
      expect(result.single.indentId, 2200);
    });

    test('filters by zone and state', () {
      final result = repo.applyQuery(
        source: source,
        search: '',
        filter: const IndentListFilter(zoneCode: 'E', stateName: 'West Bengal'),
      );
      expect(result.single.indentId, 3300);
    });

    test('combines search and filter', () {
      final result = repo.applyQuery(
        source: source,
        search: 'pending',
        filter: const IndentListFilter(zoneCode: 'N'),
      );
      expect(result, hasLength(1));
      expect(result.single.indentId, 1100476);
    });

    test('returns empty when nothing matches', () {
      final result = repo.applyQuery(
        source: source,
        search: 'zzz-no-match',
        filter: IndentListFilter.empty,
      );
      expect(result, isEmpty);
    });
  });

  group('PaymentLinkResult', () {
    test('parses success envelope with msg in data list', () {
      final result = PaymentLinkResult.fromJson({
        'success': 200,
        'data': [
          {'msg': 'Payment link sent successfully'},
        ],
      });
      expect(result.success, isTrue);
      expect(result.message, 'Payment link sent successfully');
    });

    test('parses message field fallback', () {
      final result = PaymentLinkResult.fromJson({
        'success': 200,
        'message': 'Email queued',
      });
      expect(result.success, isTrue);
      expect(result.message, 'Email queued');
    });

    test('marks failure when success code is not 200 and no success text', () {
      final result = PaymentLinkResult.fromJson({
        'success': 400,
        'message': 'Indent not found',
      });
      expect(result.success, isFalse);
      expect(result.message, 'Indent not found');
    });
  });
}
