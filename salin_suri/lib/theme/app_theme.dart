import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens taken from the Figma file.
class AppColors {
  AppColors._();

  static const background = Color(0xFF161618);
  static const bar = Color(0xFF111213);
  static const barBorder = Color(0xFF4D4C4C);
  static const surface = Color(0xFF2D3535);
  static const surfaceInner = Color(0xFF252B2B);
  static const iconChip = Color(0xFF1F272C);
  static const accent = Color(0xFF76CE98);
  static const muted = Color(0xFFB7B7B7);
  static const divider = Color(0x66FFFFFF);
  static const preSeries = Color(0xFF9B3B2E);
  static const postSeries = Color(0xFF8B5CF6);
  static const alertRed = Color(0xFFD40000);
  static const good = Color(0xFF1DB954);
  static const bad = Color(0xFFD13438);
  static const guideBlue = Color(0xFF4F9BE0);
}

/// Text styles. SF Pro in the design maps to the platform font (SF on iOS, Roboto on Android).
class AppText {
  AppText._();

  static TextStyle sf(double size,
          {FontWeight weight = FontWeight.w400, Color color = Colors.white}) =>
      TextStyle(fontSize: size, fontWeight: weight, color: color);

  static TextStyle inter(double size,
          {FontWeight weight = FontWeight.w400, Color color = Colors.white}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle poppins(double size,
          {FontWeight weight = FontWeight.w700, Color color = Colors.white}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    useMaterial3: true,
  );
}
