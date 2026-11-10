import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Figma "color system" variable collection (modes: Dark, Light).
class AppPalette {
  const AppPalette({
    required this.backgroundPrimary,
    required this.backgroundCard,
    required this.backgroundSecondary,
    required this.backgroundInner,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentPrimary,
    required this.cardDivider,
    required this.backgroundNav,
    required this.border,
  });

  final Color backgroundPrimary;
  final Color backgroundCard;
  final Color backgroundSecondary;

  /// Slightly different card tone used for small inner cards (onboarding, toggle track).
  final Color backgroundInner;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentPrimary;
  final Color cardDivider;
  final Color backgroundNav;
  final Color border;

  static const dark = AppPalette(
    backgroundPrimary: Color(0xFF161618),
    backgroundCard: Color(0xFF2D3535),
    backgroundSecondary: Color(0xFF1F272C),
    backgroundInner: Color(0xFF252B2B),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB7B7B7),
    accentPrimary: Color(0xFF76CE98),
    cardDivider: Color(0xFF909090),
    backgroundNav: Color(0xFF111213),
    border: Color(0xFF4D4D4C),
  );

  static const light = AppPalette(
    backgroundPrimary: Color(0xFFF4F6F4),
    backgroundCard: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFE9E9E9),
    backgroundInner: Color(0xFFE9E9E9),
    textPrimary: Color(0xFF202724),
    textSecondary: Color(0xFF8D8D8D),
    accentPrimary: Color(0xFF27885B),
    cardDivider: Color(0xFFACACAC),
    backgroundNav: Color(0xFFFFFFFF),
    border: Color(0xFFBFBFBF),
  );
}

/// Current theme mode, shared app-wide. Flip it with `AppTheme.mode.value = ...`
/// (the Settings "Dark Mode" toggle does); the app root rebuilds everything.
class AppTheme {
  AppTheme._();

  static final mode = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static bool get isDark => mode.value != ThemeMode.light;
  static AppPalette get palette => isDark ? AppPalette.dark : AppPalette.light;
}

/// Design tokens taken from the Figma file. Theme-aware colors are getters, so they follow
/// [AppTheme.mode]; series and status colors are the same in both modes.
class AppColors {
  AppColors._();

  static Color get background => AppTheme.palette.backgroundPrimary;
  static Color get bar => AppTheme.palette.backgroundNav;
  static Color get barBorder => AppTheme.palette.border;
  static Color get surface => AppTheme.palette.backgroundCard;
  static Color get surfaceInner => AppTheme.palette.backgroundInner;
  static Color get iconChip => AppTheme.palette.backgroundSecondary;
  static Color get accent => AppTheme.palette.accentPrimary;
  static Color get text => AppTheme.palette.textPrimary;
  static Color get muted => AppTheme.palette.textSecondary;
  static Color get divider => AppTheme.palette.cardDivider;

  static const preSeries = Color(0xFF9B3B2E);
  static const postSeries = Color(0xFF8B5CF6);
  static const alertRed = Color(0xFFD40000);
  static const good = Color(0xFF1DB954);
  static const bad = Color(0xFFD13438);
  static const guideBlue = Color(0xFF4F9BE0);
}

/// Text styles. SF Pro in the design maps to the platform font (SF on iOS, Roboto on Android).
/// Without an explicit [color] they use the theme's primary text color.
class AppText {
  AppText._();

  static TextStyle sf(double size,
          {FontWeight weight = FontWeight.w400, Color? color}) =>
      TextStyle(
          fontSize: size, fontWeight: weight, color: color ?? AppColors.text);

  static TextStyle inter(double size,
          {FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.inter(
          fontSize: size, fontWeight: weight, color: color ?? AppColors.text);

  static TextStyle poppins(double size,
          {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.poppins(
          fontSize: size, fontWeight: weight, color: color ?? AppColors.text);
}

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final scheme = brightness == Brightness.dark
      ? ColorScheme.dark(primary: p.accentPrimary, surface: p.backgroundCard)
      : ColorScheme.light(primary: p.accentPrimary, surface: p.backgroundCard);
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: p.backgroundPrimary,
    colorScheme: scheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    useMaterial3: true,
  );
}
