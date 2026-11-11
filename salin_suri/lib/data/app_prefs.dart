import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Thin wrapper over shared_preferences. Call [load] once before runApp; it also
/// restores the saved theme into [AppTheme.mode].
class AppPrefs {
  AppPrefs._();

  static late SharedPreferences _p;

  static const _kTheme = 'theme_mode';
  static const _kOnboarded = 'onboarded';
  static const _kNotifications = 'notifications';

  static Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    AppTheme.mode.value =
        _p.getString(_kTheme) == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static bool get onboarded => _p.getBool(_kOnboarded) ?? false;
  static bool get notifications => _p.getBool(_kNotifications) ?? true;

  static Future<void> setThemeMode(ThemeMode m) =>
      _p.setString(_kTheme, m == ThemeMode.light ? 'light' : 'dark');
  static Future<void> setOnboarded(bool v) => _p.setBool(_kOnboarded, v);
  static Future<void> setNotifications(bool v) =>
      _p.setBool(_kNotifications, v);
}
