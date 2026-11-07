import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/ph_info_modal.dart';
import '../widgets/modals/sensor_status_modal.dart';
import 'history_screen.dart';
import 'sensors_screen.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key, required this.info});

  final SensorInfo info;

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String _stage = 'Pre-filtration';

  // Sample readings (pre / post).
  static const double _pre = 9.8;
  static const double _post = 7.2;

  @override
  Widget build(BuildContext context) {
    final change = (_post - _pre).abs();
    // Figma annotation: when post is higher than pre the arrow flips (up) and turns red.
    final postHigher = _post > _pre;

    final isPre = _stage == 'Pre-filtration';
    final series = [
      ChartSeries(
        values: isPre ? SampleData.phPre : SampleData.phPost,
        colors: SampleData.gradient,
      ),
    ];

    return Scaffold(
      appBar: AppTopBar(
        title: widget.info.pageTitle,
        showBack: true,
        trailing: CircleChip(
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => showPhInfoModal(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'DFRobot Gravity\n${widget.info.name.replaceAll('\n', ' ')}',
                  style: AppText.poppins(28),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      color: AppColors.iconChip, shape: BoxShape.circle),
                  child: const Icon(Icons.history_rounded,
                      color: AppColors.accent, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AssetOrIcon(
            asset: 'assets/images/ph_sensor.png',
            fallback: Icons.sensors_rounded,
            height: 176,
          ),
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
              const StatCell(label: 'Pre-Filtration', value: '9.8'),
              const StatCell(label: 'Post Filtration', value: '7.2'),
              StatCell(
                label: 'Change',
                value: change.toStringAsFixed(1),
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      postHigher
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 16,
                      color: postHigher ? AppColors.bad : AppColors.good,
                    ),
                    const SizedBox(width: 4),
                    Text(change.toStringAsFixed(1),
                        style: AppText.sf(17, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('pH Level Over Time',
                        style: AppText.sf(20, weight: FontWeight.w600)),
                    DropdownPill(
                      value: _stage,
                      options: const ['Pre-filtration', 'Post-filtration'],
                      onChanged: (v) => setState(() => _stage = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LineChart(series: series, height: 240),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
