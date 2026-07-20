import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/project_list_filter.dart';

void main() {
  group('ProjectListFilter', () {
    test('empty has no active filters', () {
      expect(ProjectListFilter.empty.hasActiveFilters, isFalse);
    });

    test('hasActiveFilters when any field set', () {
      expect(
        const ProjectListFilter(feeType: 'ST').hasActiveFilters,
        isTrue,
      );
      expect(
        ProjectListFilter(approvedFrom: DateTime(2026, 1, 1)).hasActiveFilters,
        isTrue,
      );
    });

    test('copyWith updates and clear flags', () {
      const base = ProjectListFilter(
        feeType: 'ST',
        tierName: 'Tier 1',
        createdBy: 'Admin',
      );
      final updated = base.copyWith(feeType: 'LT', clearCreatedBy: true);
      expect(updated.feeType, 'LT');
      expect(updated.tierName, 'Tier 1');
      expect(updated.createdBy, isNull);
      expect(updated.hasActiveFilters, isTrue);
    });

    test('equality via Equatable', () {
      const a = ProjectListFilter(feeType: 'ST');
      const b = ProjectListFilter(feeType: 'ST');
      const c = ProjectListFilter(feeType: 'LT');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
