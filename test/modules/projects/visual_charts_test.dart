import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/visual_chart_item.dart';
import 'package:Intranet/modules/projects/repositories/visual_charts_repository.dart';
import 'package:Intranet/modules/projects/services/visual_charts_local_service.dart';
import 'package:Intranet/modules/projects/services/visual_charts_remote_service.dart';

void main() {
  group('VisualChartItem parsing', () {
    test('parses API sample fields', () {
      final item = VisualChartItem.fromJson({
        'Name': 'KIDZEE Project Dashboard',
        'Description': 'KIDZEE Project Dashboard',
        'URL':
            'https://analytics.zoho.in/open-view/211650000004688016/77d29e5d835d6445e9acb4e9be814fde',
      });
      expect(item.name, 'KIDZEE Project Dashboard');
      expect(item.description, 'KIDZEE Project Dashboard');
      expect(item.url, contains('analytics.zoho.in'));
      expect(item.hasValidUrl, isTrue);
    });

    test('accepts Url / url aliases', () {
      expect(
        VisualChartItem.fromJson({'Url': 'https://example.com'}).url,
        'https://example.com',
      );
      expect(
        VisualChartItem.fromJson({'url': 'https://example.com/a'}).url,
        'https://example.com/a',
      );
    });

    test('hasValidUrl rejects empty and non-http', () {
      expect(const VisualChartItem(name: 'a', description: '', url: '').hasValidUrl,
          isFalse);
      expect(
        const VisualChartItem(
          name: 'a',
          description: '',
          url: 'ftp://x',
        ).hasValidUrl,
        isFalse,
      );
    });

    test('toJson round-trip', () {
      const original = VisualChartItem(
        name: 'MLZS Project Dashboard',
        description: 'MLZS Project Dashboard',
        url: 'https://analytics.zoho.in/open-view/1',
      );
      expect(VisualChartItem.fromJson(original.toJson()), equals(original));
    });
  });

  group('VisualChartsResponse', () {
    test('parses envelope', () {
      final response = VisualChartsResponse.fromJson({
        'success': 200,
        'data': [
          {
            'Name': 'KIDZEE Project Dashboard',
            'Description': 'KIDZEE Project Dashboard',
            'URL': 'https://analytics.zoho.in/a',
          },
          {
            'Name': 'MLZS Project Dashboard',
            'Description': 'MLZS Project Dashboard',
            'URL': 'https://analytics.zoho.in/b',
          },
        ],
      });
      expect(response.success, 200);
      expect(response.data, hasLength(2));
      expect(response.data.first.name, 'KIDZEE Project Dashboard');
      expect(response.data.last.name, 'MLZS Project Dashboard');
    });

    test('tolerates missing data', () {
      expect(VisualChartsResponse.fromJson({'success': 200}).data, isEmpty);
      expect(
        VisualChartsResponse.fromJson({'success': 200, 'data': 'x'}).data,
        isEmpty,
      );
    });
  });

  group('VisualChartsRepository.applySearch', () {
    late VisualChartsRepository repo;
    late List<VisualChartItem> source;

    setUp(() {
      repo = VisualChartsRepository(
        remoteService: VisualChartsRemoteService(),
        localService: VisualChartsLocalService(),
      );
      source = const [
        VisualChartItem(
          name: 'KIDZEE Project Dashboard',
          description: 'KIDZEE Project Dashboard',
          url: 'https://a',
        ),
        VisualChartItem(
          name: 'MLZS Project Dashboard',
          description: 'MLZS analytics view',
          url: 'https://b',
        ),
      ];
    });

    test('empty search returns all', () {
      expect(
        repo.applySearch(source: source, search: ''),
        hasLength(2),
      );
    });

    test('search by name case insensitive', () {
      final result = repo.applySearch(source: source, search: 'kidzee');
      expect(result, hasLength(1));
      expect(result.single.name, contains('KIDZEE'));
    });

    test('search by description', () {
      final result = repo.applySearch(source: source, search: 'analytics');
      expect(result.single.name, contains('MLZS'));
    });

    test('no match returns empty', () {
      expect(
        repo.applySearch(source: source, search: 'zzz'),
        isEmpty,
      );
    });
  });

  group('VisualChartsLocalService cache key', () {
    test('includes user type and id', () {
      final local = VisualChartsLocalService();
      expect(
        local.cacheKey(userType: 'ZM', userId: 432902),
        'visual_charts_ZM_432902',
      );
    });
  });
}
