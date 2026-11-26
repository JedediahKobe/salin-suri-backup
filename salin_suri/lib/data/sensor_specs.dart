import 'package:flutter/material.dart';

import 'parameter_info.dart';

/// Everything that differs between the Sensor Page / History screens of the four
/// monitored parameters (Figma: Sensor Page 40:39, 583:223, 583:408, 583:593 and
/// History 67:221, 583:295, 583:480, 583:665). The screens are written once and
/// driven by one of these.
///
/// Only static metadata lives here; the readings come from `LiveReadings`.
class SensorSpec {
  const SensorSpec({
    required this.id,
    required this.pageTitle,
    required this.heading,
    required this.historyTitle,
    required this.info,
    required this.photoAsset,
    required this.photoFallback,
    required this.hasStatusLink,
    required this.chartTitle,
    required this.postLabel,
    required this.changeLabel,
    required this.unit,
    required this.decimals,
    required this.minY,
    required this.maxY,
    required this.step,
    required this.historyChartTitle,
    required this.limitLabel,
    required this.limitValue,
    required this.statusLabel,
    required this.statusWithin,
    required this.statusOutside,
    this.limitMin,
    this.limitMax,
  });

  final String id;

  // Sensor Page
  final String pageTitle;
  final String heading; // second line of "DFRobot Gravity / <heading>"
  final ParameterInfo info;
  final String photoAsset;
  final IconData photoFallback;

  /// pH has a tappable "Sensor Status" link (opens the status modal).
  final bool hasStatusLink;
  final String chartTitle;
  final String postLabel;
  final String changeLabel;
  final String unit; // appended to formatted readings, e.g. ' °C'
  final int decimals;

  // Chart axis
  final double minY;
  final double maxY;
  final double step;

  // History
  final String historyTitle;
  final String historyChartTitle;

  final String limitLabel; // "Reference Range" | "PNSDW 2017"
  final String limitValue;
  final String statusLabel; // "Range" | "Status"
  final String statusWithin;
  final String statusOutside;
  final double? limitMin;
  final double? limitMax;

  String format(double v) => '${v.toStringAsFixed(decimals)}$unit';

  /// Like [format], but "--" when there's no reading yet.
  String formatOrDash(double? v) => v == null ? '--' : format(v);

  /// Whether [v] is inside the configured limits (no limits = always fine).
  bool within(double v) =>
      (limitMin == null || v >= limitMin!) &&
      (limitMax == null || v <= limitMax!);

  static const all = <SensorSpec>[ph, temperature, turbidity, tds];

  static SensorSpec? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ── pH ──────────────────────────────────────────────────────────────
  static const ph = SensorSpec(
    id: 'ph',
    historyChartTitle: 'pH Level Chart',
    pageTitle: 'ph Sensor',
    heading: 'pH Level',
    historyTitle: 'ph Level Insight',
    info: ParameterInfo.ph,
    photoAsset: 'assets/images/ph_sensor.png',
    photoFallback: Icons.sensors_rounded,
    hasStatusLink: true,
    chartTitle: 'pH Level Over Time',
    postLabel: 'Post Filtration',
    changeLabel: 'Change',
    unit: '',
    decimals: 1,
    minY: 6,
    maxY: 10,
    step: 1,
    limitLabel: 'Reference Range',
    limitValue: '6.5 - 8.5',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Out of Range',
    limitMin: 6.5,
    limitMax: 8.5,
  );

  // ── Temperature ─────────────────────────────────────────────────────
  static const temperature = SensorSpec(
    id: 'temperature',
    historyChartTitle: 'Temperature Level Chart',
    pageTitle: 'Temperature Sensor',
    heading: 'Temperature Sensor',
    historyTitle: 'Temperature Level Insight',
    info: ParameterInfo.temperature,
    photoAsset: 'assets/images/temperature_sensor.png',
    photoFallback: Icons.thermostat_rounded,
    hasStatusLink: false,
    chartTitle: 'Temperature (°C)',
    postLabel: 'Post-Filtration',
    changeLabel: 'Change (°C)',
    unit: ' °C',
    decimals: 1,
    minY: 24,
    maxY: 32,
    step: 2,
    limitLabel: 'PNSDW 2017',
    limitValue: 'Not specified',
    statusLabel: 'Range',
    statusWithin: 'No set range',
    statusOutside: 'No set range',
  );

  // ── Turbidity ───────────────────────────────────────────────────────
  static const turbidity = SensorSpec(
    id: 'turbidity',
    historyChartTitle: 'Turbidity Level Chart (NTU)',
    pageTitle: 'Turbidity Sensor',
    heading: 'Turbidity Sensor',
    historyTitle: 'Turbidity Level Insight',
    info: ParameterInfo.turbidity,
    photoAsset: 'assets/images/turbidity_sensor.png',
    photoFallback: Icons.grain_rounded,
    hasStatusLink: false,
    chartTitle: 'Turbidity (NTU)',
    postLabel: 'Post-Filtration',
    changeLabel: 'Change (NTU)',
    unit: ' NTU',
    decimals: 1,
    minY: 0,
    maxY: 4,
    step: 1,
    limitLabel: 'PNSDW 2017',
    limitValue: '≤ 5 NTU',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Above Range',
    limitMax: 5,
  );

  // ── TDS ─────────────────────────────────────────────────────────────
  static const tds = SensorSpec(
    id: 'tds',
    historyChartTitle: 'TDS Level Chart (mg/L)',
    pageTitle: 'TDS Sensor',
    heading: 'TDS Sensor',
    historyTitle: 'TDS Level Insight',
    info: ParameterInfo.tds,
    photoAsset: 'assets/images/tds_sensor.png',
    photoFallback: Icons.opacity_outlined,
    hasStatusLink: false,
    chartTitle: 'TDS (mg/L)',
    postLabel: 'Post-Filtration',
    changeLabel: 'Change (mg/L)',
    unit: ' mg/L',
    decimals: 0,
    minY: 100,
    maxY: 500,
    step: 100,
    limitLabel: 'PNSDW 2017',
    limitValue: '≤ 600 mg/L',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Above Range',
    limitMax: 600,
  );
}
