import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'hash_checker_page.dart';

class HashCheckerApp extends StatelessWidget {
  const HashCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hash Checker',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HashCheckerPage(),
    );
  }
}
