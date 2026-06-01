import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:hashchecker/ui/hash_checker_app.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue();
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets('HashChecker app smoke test in English', (WidgetTester tester) async {
    await tester.pumpWidget(const HashCheckerApp());

    expect(find.text('Hash Checker'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Compare hashes'), findsOneWidget);
  });

  testWidgets('HashChecker app smoke test in Russian', (WidgetTester tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('ru');
    tester.binding.platformDispatcher.localesTestValue = const [Locale('ru')];

    await tester.pumpWidget(const HashCheckerApp());

    expect(find.text('Hash Checker'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Сверить хеш-суммы'), findsOneWidget);
  });
}
