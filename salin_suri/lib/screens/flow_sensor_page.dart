import 'package:flutter/material.dart';

import '../data/parameter_info.dart';
import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/sensor_status_modal.dart';

/// Water Flow sensor page (Figma 676:122). About modal copy: 676:194 / 676:272 / 676:350.
/// All readings are dummy data.
class FlowSensorPage extends StatelessWidget {
  const FlowSensorPage({super.key});

  static const _series = <double>[
    24, 21, 13.8, 16.6, 15, 11.6, 24, 15.5, 8.3, 15.2, 28.6, 20.5, 17.3, 11.6,
    16, 12.5, 7.8, 10.3, 19.3,
  ];

  @override
  Widget build(BuildContext context) {
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
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showSensorStatusModal(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Sensor Status',
                    style: AppText.sf(11,
                        weight: FontWeight.w500, color: AppColors.accent)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatsPanel(
            cells: [
              const StatCell(label: 'Water Flow Rate', value: '20L/min'),
              StatCell(
                label: 'Status',
                value: '',
                valueWidget: Text('Water is flowing',
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
                    ChartSeries(values: _series, colors: SampleData.gradient),
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
