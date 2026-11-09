import 'package:flutter/material.dart';

import 'parameter_info.dart';

/// Values for the History "Statistical Summary" card.
class SummaryStats {
  const SummaryStats({
    required this.average,
    required this.median,
    required this.minimum,
    required this.maximum,
  });

  final String average;
  final String median;
  final String minimum;
  final String maximum;
}

/// Everything that differs between the Sensor Page / History screens of the four
/// monitored parameters (Figma: Sensor Page 40:39, 583:223, 583:408, 583:593 and
/// History 67:221, 583:295, 583:480, 583:665). The screens are written once and
/// driven by one of these.
///
/// All readings and series below are placeholder sample data; replace them with
/// your BLE / API source.
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
    required this.pre,
    required this.post,
    required this.minY,
    required this.maxY,
    required this.step,
    required this.preSeries,
    required this.postSeries,
    required this.historyChartTitle,
    required this.summary,
    required this.limitLabel,
    required this.limitValue,
    required this.statusLabel,
    required this.statusWithin,
    required this.statusOutside,
    this.limitMin,
    this.limitMax,
    required this.historyPre,
    required this.historyPost,
    required this.historyPreSeries,
    required this.historyPostSeries,
  });

  final String id;

  // Sensor Page
  final String pageTitle;
  final String heading; // second line of "DFRobot Gravity / <heading>"
  final ParameterInfo info;
  final String photoAsset;
  final IconData photoFallback;

  /// pH has a tappable "Sensor Status" link (opens the status modal); the other
  /// sensors show the static label "Sample data".
  final bool hasStatusLink;
  final String chartTitle;
  final String postLabel;
  final String changeLabel;
  final String unit; // appended to formatted readings, e.g. ' °C'
  final int decimals;
  final double pre;
  final double post;

  // Chart axis
  final double minY;
  final double maxY;
  final double step;
  final List<double> preSeries;
  final List<double> postSeries;

  // History
  final String historyTitle;
  final String historyChartTitle;

  /// Statistical Summary card (Figma 614:676...): average, median, minimum, maximum.
  final SummaryStats summary;
  final String limitLabel; // "Reference Range" | "PNSDW 2017"
  final String limitValue;
  final String statusLabel; // "Range" | "Status"
  final String statusWithin;
  final String statusOutside;
  final double? limitMin;
  final double? limitMax;
  final double historyPre;
  final double historyPost;
  final List<double> historyPreSeries; // 7 points, Mon..Sun
  final List<double> historyPostSeries;

  String format(double v) => '${v.toStringAsFixed(decimals)}$unit';

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
    summary: SummaryStats(average: '7.4', median: '7.2', minimum: '6.5', maximum: '8.5'),
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
    pre: 9.8,
    post: 7.2,
    minY: 6,
    maxY: 10,
    step: 1,
    preSeries: [10, 9.5, 8.2, 8.6, 9.2, 8.9, 7.8, 8.3, 9.1, 9.6, 8.8, 8.4, 7.6, 9.0],
    postSeries: [9.0, 7.4, 7.7, 8.1, 7.6, 6.9, 7.8, 7.0, 6.7, 6.0, 7.2, 7.6, 7.1, 8.4],
    limitLabel: 'Reference Range',
    limitValue: '6.5 - 8.5',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Out of Range',
    limitMin: 6.5,
    limitMax: 8.5,
    historyPre: 7.2,
    historyPost: 7.1,
    historyPreSeries: [7.9, 9.1, 8.4, 6.8, 8.1, 8.15, 7.8],
    historyPostSeries: [7.2, 7.5, 7.3, 7.0, 7.4, 7.2, 7.1],
  );

  // ── Temperature ─────────────────────────────────────────────────────
  static const temperature = SensorSpec(
    id: 'temperature',
    historyChartTitle: 'Temperature Level Chart',
    summary: SummaryStats(average: '27.4 °C', median: '26.2 °C', minimum: '--', maximum: '--'),
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
    pre: 28.4,
    post: 28.1,
    minY: 24,
    maxY: 32,
    step: 2,
    preSeries: [30, 29, 26.6, 27.5, 27, 25.9, 30, 28, 24.8, 27.1, 31.5, 28.9, 27.7, 25.9, 27.3, 26.1, 24.6, 25.4, 28.4],
    postSeries: [28.9, 28.4, 27.6, 28.0, 27.7, 27.0, 28.6, 27.9, 26.8, 27.8, 29.0, 28.3, 27.9, 27.2, 27.8, 27.4, 26.9, 27.3, 28.1],
    limitLabel: 'PNSDW 2017',
    limitValue: 'Not specified',
    statusLabel: 'Range',
    statusWithin: 'No set range',
    statusOutside: 'No set range',
    historyPre: 27.6,
    historyPost: 27.2,
    historyPreSeries: [27.7, 30.1, 28.8, 25.5, 28.2, 28.3, 27.6],
    historyPostSeries: [27.1, 28.0, 27.6, 25.9, 27.4, 27.5, 27.2],
  );

  // ── Turbidity ───────────────────────────────────────────────────────
  static const turbidity = SensorSpec(
    id: 'turbidity',
    historyChartTitle: 'Turbidity Level Chart (NTU)',
    summary: SummaryStats(average: '1.4 NTU', median: '1.3 NTU', minimum: '--', maximum: '5 NTU'),
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
    pre: 2.2,
    post: 0.7,
    minY: 0,
    maxY: 4,
    step: 1,
    preSeries: [3.2, 2.9, 2.4, 2.6, 2.2, 1.9, 3.1, 2.5, 1.4, 2.3, 3.6, 2.8, 2.4, 1.9, 2.5, 2.0, 1.6, 1.9, 2.2],
    postSeries: [1.2, 1.0, 0.8, 0.9, 0.7, 0.6, 1.1, 0.9, 0.5, 0.8, 1.3, 1.0, 0.8, 0.6, 0.9, 0.7, 0.5, 0.6, 0.7],
    limitLabel: 'PNSDW 2017',
    limitValue: '≤ 5 NTU',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Above Range',
    limitMax: 5,
    historyPre: 1.8,
    historyPost: 0.6,
    historyPreSeries: [1.85, 3.05, 2.4, 0.75, 2.1, 2.15, 1.8],
    historyPostSeries: [0.8, 1.2, 0.9, 0.4, 0.7, 0.8, 0.6],
  );

  // ── TDS ─────────────────────────────────────────────────────────────
  static const tds = SensorSpec(
    id: 'tds',
    historyChartTitle: 'TDS Level Chart (mg/L)',
    summary: SummaryStats(average: '276 mg/L', median: '278 mg/L', minimum: '--', maximum: '600 mg/L'),
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
    pre: 320,
    post: 180,
    minY: 100,
    maxY: 500,
    step: 100,
    preSeries: [450, 430, 360, 390, 340, 300, 440, 380, 250, 350, 470, 410, 370, 300, 360, 320, 260, 290, 320],
    postSeries: [260, 250, 210, 230, 200, 170, 250, 220, 150, 210, 270, 240, 210, 170, 210, 190, 160, 180, 180],
    limitLabel: 'PNSDW 2017',
    limitValue: '≤ 600 mg/L',
    statusLabel: 'Range',
    statusWithin: 'Within Range',
    statusOutside: 'Above Range',
    limitMax: 600,
    historyPre: 280,
    historyPost: 160,
    historyPreSeries: [270, 420, 350, 150, 300, 310, 280],
    historyPostSeries: [160, 240, 200, 110, 170, 175, 160],
  );
}
