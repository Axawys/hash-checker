import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hashchecker/ui/hash_checker_app.dart';

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue();
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocalesTestValue();
  });

  testWidgets('HashChecker app smoke test in English', (WidgetTester tester) async {
    await tester.pumpWidget(const HashCheckerApp());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Compare hashes'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('How to use'), findsOneWidget);
    expect(find.text('Basic workflow'), findsOneWidget);
  });

  testWidgets('HashChecker app smoke test in Russian', (WidgetTester tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('ru');
    tester.binding.platformDispatcher.localesTestValue = const [Locale('ru')];

    await tester.pumpWidget(const HashCheckerApp());

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Сверить хеш-суммы'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Как пользоваться'), findsOneWidget);
    expect(find.text('Основной порядок'), findsOneWidget);
  });
}
