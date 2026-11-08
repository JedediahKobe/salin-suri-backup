import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/line_chart.dart';

/// Placeholder readings. Replace with your BLE / API data source.
class SampleData {
  SampleData._();

  static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static List<ChartSeries> preAndPost(List<double> pre, List<double> post) => [
        ChartSeries(values: pre, colors: const [AppColors.preSeries]),
        ChartSeries(values: post, colors: const [AppColors.postSeries]),
      ];

  static const gradient = <Color>[Color(0xFF8B5CF6), Color(0xFFE832C4)];
}
