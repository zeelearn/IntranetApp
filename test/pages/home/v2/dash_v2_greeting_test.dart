import 'package:Intranet/pages/home/v2/dash_v2_menu_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('morning greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 9), 'Sudhir'),
      'Good Morning, Sudhir 👋',
    );
  });
  test('afternoon greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 14), 'Sudhir'),
      'Good Afternoon, Sudhir 👋',
    );
  });
  test('evening greeting', () {
    expect(
      DashV2Greeting.forDateTime(DateTime(2026, 7, 20, 19), 'Sudhir'),
      'Good Evening, Sudhir 👋',
    );
  });
}
