import 'package:flutter/material.dart';

import 'screens/filter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

void main() => runApp(const SalinSuriApp());

class SalinSuriApp extends StatefulWidget {
  const SalinSuriApp({super.key});

  @override
  State<SalinSuriApp> createState() => _SalinSuriAppState();
}

class _SalinSuriAppState extends State<SalinSuriApp> {
  bool _onboarded = false; // persist with shared_preferences in a real app

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salin-Suri',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: _onboarded
          ? const AppShell()
          : OnboardingScreen(onFinished: () => setState(() => _onboarded = true)),
    );
  }
}

/// Home / Filter / Settings with the floating pill nav bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [HomeScreen(), FilterScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: PillNavBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
