import 'package:flutter/material.dart';

import '../data/live_readings.dart';
import '../data/parameter_info.dart';
import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/sensor_status_modal.dart';

/// Water Flow sensor page (Figma 676:122). About modal copy: 676:194 / 676:272 / 676:350.
class FlowSensorPage extends StatelessWidget {
  const FlowSensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LiveReadings.instance,
      builder: (context, _) => _buildPage(context, LiveReadings.instance.snapshot),
    );
  }

  Widget _buildPage(BuildContext context, LiveSnapshot live) {
    final rate = live.flowRate;
    return Scaffold(
      appBar: AppTopBar(
        title: 'Water Flow Sensor',
        showBack: true,
        trailing: CircleChip(
          appIcon: AppIconType.bulb,
          onTap: () => showParameterInfoModal(context, ParameterInfo.waterFlow),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        children: [
          Text('YF-S201 Water\nFlow Sensor', style: AppText.poppins(28)),
          const SizedBox(height: 16),
          AssetOrIcon(
              asset: 'assets/images/water_flow_sensor.png',
              fallback: Icons.waves_rounded,
              height: 177),
          const SizedBox(height: 30),
          SectionTitle(
            'Real-time Monitoring',
            trailing:
                SensorStatusPill(onTap: () => showSensorStatusModal(context)),
          ),
          const SizedBox(height: 12),
          StatsPanel(
            cells: [
              StatCell(
                  label: 'Water Flow Rate',
                  value: rate == null ? '--' : '${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 1)}L/min'),
              StatCell(
                label: 'Status',
                value: '',
                valueWidget: Text(
                    rate == null ? '--' : (rate > 0 ? 'Water is flowing' : 'No water flow'),
                    style: AppText.inter(14, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Water Flow Monitoring',
                    style: AppText.sf(20, weight: FontWeight.w600)),
                const SizedBox(height: 12),
                LineChart(
                  series: [
                    ChartSeries(values: live.flowSeries, colors: SampleData.gradient),
                  ],
                  minY: 6,
                  maxY: 30,
                  step: 6,
                  height: 240,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
