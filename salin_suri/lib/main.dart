import 'package:flutter/material.dart';

import 'screens/filter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notification_screen.dart';
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
  void initState() {
    super.initState();
    AppTheme.mode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppTheme.mode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
    // Colours are read from AppColors while building, so widgets that don't depend on
    // Theme (including const ones) must be rebuilt too. This keeps navigation and
    // state intact, unlike re-keying the whole app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void rebuild(Element e) {
        e.markNeedsBuild();
        e.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salin-Suri',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: AppTheme.mode.value,
      home: _onboarded
          ? const AppShell()
          : OnboardingScreen(onFinished: () => setState(() => _onboarded = true)),
    );
  }
}

/// Home / Filter / Notification / Settings with the floating pill nav bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Lets a screen inside the shell (e.g. the Home bell) switch tabs.
  static _AppShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppShellState>();

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    FilterScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  void select(int i) => setState(() => _index = i);

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
