import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/line_chart.dart';

/// Placeholder readings. Replace with your BLE / API data source.
class SampleData {
  SampleData._();

  static const phPre = <double>[10, 9.5, 8.2, 8.6, 9.2, 8.9, 7.8, 8.3, 9.1, 9.6, 8.8, 8.4, 7.6, 9.0];
  static const phPost = <double>[9.0, 7.4, 7.7, 8.1, 7.6, 6.9, 7.8, 7.0, 6.7, 6.0, 7.2, 7.6, 7.1, 8.4];

  static const tempPre = <double>[7.5, 8.0, 7.8, 8.6, 8.2, 8.9, 8.4, 8.0, 8.7, 8.3];
  static const tempPost = <double>[6.8, 7.1, 7.0, 7.4, 7.2, 7.6, 7.3, 7.1, 7.5, 7.2];

  static const turbPre = <double>[9.2, 8.8, 9.0, 8.5, 8.9, 8.3, 8.6, 8.1, 8.4, 8.0];
  static const turbPost = <double>[6.5, 6.8, 6.6, 7.0, 6.7, 7.1, 6.9, 6.6, 7.0, 6.8];

  static const tdsPre = <double>[8.0, 8.5, 9.0, 8.7, 9.3, 9.0, 8.6, 9.1, 8.8, 9.4];
  static const tdsPost = <double>[7.0, 7.2, 7.5, 7.1, 7.6, 7.3, 7.0, 7.4, 7.2, 7.5];

  static const phHistoryPre = <double>[7.9, 9.1, 8.4, 6.8, 8.1, 8.15, 7.8];
  static const phHistoryPost = <double>[7.2, 7.5, 7.3, 7.0, 7.4, 7.2, 7.1];
  static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static List<ChartSeries> preAndPost(List<double> pre, List<double> post) => [
        ChartSeries(values: pre, colors: const [AppColors.preSeries]),
        ChartSeries(values: post, colors: const [AppColors.postSeries]),
      ];

  static const gradient = <Color>[Color(0xFF8B5CF6), Color(0xFFE832C4)];
}
