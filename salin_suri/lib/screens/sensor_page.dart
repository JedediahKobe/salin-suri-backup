import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/ph_info_modal.dart';
import '../widgets/modals/sensor_status_modal.dart';
import 'history_screen.dart';
import 'sensors_screen.dart';

class _ReadingProfile {
  const _ReadingProfile({
    required this.label,
    required this.unit,
    required this.pre,
    required this.post,
    required this.preValue,
    required this.postValue,
    required this.minY,
    required this.maxY,
    required this.step,
    required this.preSeries,
    required this.postSeries,
  });

  final String label;
  final String unit;
  final String preValue;
  final String postValue;
  final double pre;
  final double post;
  final double minY;
  final double maxY;
  final double step;
  final List<double> preSeries;
  final List<double> postSeries;

  String get change => (pre - post).abs().toStringAsFixed(
        unit == 'mg/L' ? 0 : 1,
      );
  bool get postHigher => post > pre;
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key, required this.info});

  final SensorInfo info;

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String _stage = 'Pre-filtration';

  _ReadingProfile get _profile {
    switch (widget.info.name) {
      case 'Temperature':
        return const _ReadingProfile(
          label: 'Temperature',
          unit: '°C',
          pre: 28.4,
          post: 28.1,
          preValue: '28.4 °C',
          postValue: '28.1 °C',
          minY: 24,
          maxY: 32,
          step: 2,
          preSeries: [30, 29, 26.7, 27.6, 27.1, 25.9, 30, 27.2, 24.8, 27.1, 31.5, 28.9, 27.8, 25.9, 27.4, 26.2, 24.6, 25.5, 28.5],
          postSeries: [28.1, 27.8, 27.6, 27.9, 27.5, 27.4, 28.1, 27.7, 27.2, 27.4],
        );
      case 'Turbidity':
        return const _ReadingProfile(
          label: 'Turbidity',
          unit: 'NTU',
          pre: 2.2,
          post: 0.7,
          preValue: '2.2 NTU',
          postValue: '0.7 NTU',
          minY: 0,
          maxY: 4,
          step: 1,
          preSeries: [3, 2.5, 1.3, 1.8, 1.5, 0.9, 3, 1.7, 0.4, 1.5, 3.8, 2.5, 1.8, 0.9, 1.6, 1.1, 0.3, 0.7, 2.2],
          postSeries: [0.7, 0.8, 0.6, 0.9, 0.7, 0.6, 0.8, 0.7, 0.5, 0.7],
        );
      case 'Total Dissolved\nSolids (TDS)':
        return const _ReadingProfile(
          label: 'TDS',
          unit: 'mg/L',
          pre: 320,
          post: 180,
          preValue: '320 mg/L',
          postValue: '180 mg/L',
          minY: 100,
          maxY: 500,
          step: 100,
          preSeries: [400, 350, 230, 275, 250, 195, 400, 260, 140, 255, 475, 345, 280, 195, 265, 210, 130, 175, 325],
          postSeries: [180, 185, 175, 190, 180, 170, 185, 178, 165, 180],
        );
      default:
        return const _ReadingProfile(
          label: 'pH Level',
          unit: '',
          pre: 9.8,
          post: 7.2,
          preValue: '9.8',
          postValue: '7.2',
          minY: 6,
          maxY: 10,
          step: 1,
          preSeries: [10, 9.5, 8.2, 8.6, 9.2, 8.9, 7.8, 8.3, 9.1, 9.6, 8.8, 8.4, 7.6, 9.0],
          postSeries: [9.0, 7.4, 7.7, 8.1, 7.6, 6.9, 7.8, 7.0, 6.7, 6.0, 7.2, 7.6, 7.1, 8.4],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final isPre = _stage == 'Pre-filtration';
    final series = [
      ChartSeries(
        values: isPre ? profile.preSeries : profile.postSeries,
        colors: SampleData.gradient,
      ),
    ];
    final isPh = profile.label == 'pH Level';

    return Scaffold(
      appBar: AppTopBar(
        title: widget.info.pageTitle,
        showBack: true,
        trailing: CircleChip(
          icon: Icons.lightbulb_outline_rounded,
          onTap: () => showPhInfoModal(context),
        ),
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
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.iconChip,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_rounded,
                      color: AppColors.accent, size: 28),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 205,
            child: isPh
                ? const AssetOrIcon(
                    asset: 'assets/images/ph_sensor.png',
                    fallback: Icons.sensors_rounded,
                    height: 176,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          SectionTitle(
            'Real-time Monitoring',
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showSensorStatusModal(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Sample data',
                  style: AppText.sf(11,
                      weight: FontWeight.w500, color: AppColors.accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatsPanel(
            height: 100,
            cells: [
              StatCell(label: 'Pre-Filtration', value: profile.preValue),
              StatCell(label: 'Post-Filtration', value: profile.postValue),
              StatCell(
                label: 'Change${profile.unit.isEmpty ? '' : ' (${profile.unit})'}',
                value: profile.change,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profile.postHigher
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 16,
                      color: profile.postHigher ? AppColors.bad : AppColors.good,
                    ),
                    const SizedBox(width: 4),
                    Text(profile.change,
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
                    Flexible(
                      child: Text(
                        '${profile.label}${profile.unit.isEmpty ? '' : ' (${profile.unit})'}',
                        style: AppText.sf(20, weight: FontWeight.w600),
                      ),
                    ),
                    DropdownPill(
                      value: _stage,
                      options: const ['Pre-filtration', 'Post-filtration'],
                      onChanged: (value) => setState(() => _stage = value),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LineChart(
                  series: series,
                  height: 260,
                  minY: profile.minY,
                  maxY: profile.maxY,
                  step: profile.step,
                  strokeWidth: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
