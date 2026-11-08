import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../data/parameter_info.dart';
import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/sensor_status_modal.dart';
import 'history_screen.dart';

/// Sensor detail page. One implementation drives pH, Temperature, Turbidity and TDS
/// (Figma 40:39, 583:223, 583:408, 583:593) via [SensorSpec].
class SensorPage extends StatefulWidget {
  const SensorPage({super.key, required this.spec});

  final SensorSpec spec;

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String _stage = 'Pre-filtration';

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;
    final change = (s.post - s.pre).abs();
    // Figma annotation: when post is higher than pre the arrow flips (up) and turns red.
    final postHigher = s.post > s.pre;
    final isPre = _stage == 'Pre-filtration';

    return Scaffold(
      appBar: AppTopBar(
        title: s.pageTitle,
        showBack: true,
        trailing: CircleChip(
          icon: Icons.lightbulb_outline_rounded,
          onTap: () => showParameterInfoModal(context, s.info),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('DFRobot Gravity\n${s.heading}',
                    style: AppText.poppins(28)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => HistoryScreen(spec: s))),
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
          AssetOrIcon(asset: s.photoAsset, fallback: s.photoFallback, height: 176),
          const SizedBox(height: 30),
          SectionTitle(
            'Real-time Monitoring',
            trailing: s.hasStatusLink
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showSensorStatusModal(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Sensor Status',
                          style: AppText.sf(11,
                              weight: FontWeight.w500, color: AppColors.accent)),
                    ),
                  )
                : Text('Sample data',
                    style: AppText.sf(11,
                        weight: FontWeight.w500, color: AppColors.muted)),
          ),
          const SizedBox(height: 12),
          StatsPanel(
            cells: [
              StatCell(label: 'Pre-Filtration', value: s.format(s.pre)),
              StatCell(label: s.postLabel, value: s.format(s.post)),
              StatCell(
                label: s.changeLabel,
                value: change.toStringAsFixed(s.decimals),
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
                    Text(change.toStringAsFixed(s.decimals),
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
                      child: Text(s.chartTitle,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sf(20, weight: FontWeight.w600)),
                    ),
                    DropdownPill(
                      value: _stage,
                      options: const ['Pre-filtration', 'Post-filtration'],
                      onChanged: (v) => setState(() => _stage = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LineChart(
                  series: [
                    ChartSeries(
                      values: isPre ? s.preSeries : s.postSeries,
                      colors: SampleData.gradient,
                    ),
                  ],
                  minY: s.minY,
                  maxY: s.maxY,
                  step: s.step,
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
