import 'package:flutter/material.dart';

import '../data/live_readings.dart';
import '../data/backend/time_format.dart';
import '../data/sample_data.dart';
import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/segmented_tabs.dart';
import 'monitoring_history_screen.dart';

/// History / insight screen for one parameter (Figma 67:221, 583:295, 583:480, 583:665):
/// pre/post tabs, summary stats, chart, then a Statistical Summary card.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.spec});

  final SensorSpec spec;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0; // 0 = Pre-filtration, 1 = Post-filtration

  static const _tabLabels = ['Pre-filtration', 'Post-filtration'];
  static const _readingLabels = ['Pre-Filtration', 'Post-Filtration'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LiveReadings.instance,
      builder: (context, _) => _buildPage(
          context, LiveReadings.instance.snapshot.parameter(widget.spec.id)),
    );
  }

  Widget _buildPage(BuildContext context, ParameterData data) {
    final s = widget.spec;
    final isPre = _tab == 0;
    final value = isPre ? data.historyPre : data.historyPost;
    final series = isPre ? data.historyPreSeries : data.historyPostSeries;

    return Scaffold(
      appBar: AppTopBar(
        title: s.historyTitle,
        showBack: true,
        // Figma: the top-right button is now History, which opens the list of
        // past filtration runs.
        trailing: CircleChip(
          appIcon: AppIconType.history,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MonitoringHistoryScreen())),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(11, 13, 11, 24),
        children: [
          SegmentedTabs(
            labels: _tabLabels,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 12),

          // Everything below swaps with a directional slide + fade.
          TabContentSwitcher(
            index: _tab,
            child: Column(
              children: [
                StatsPanel(
                  cells: [
                    StatCell(label: _readingLabels[_tab], value: s.formatOrDash(value)),
                    StatCell(label: s.limitLabel, value: s.limitValue),
                    StatCell(
                      label: s.statusLabel,
                      value: '',
                      valueWidget: value == null
                          ? Text('--',
                              style: AppText.sf(17, weight: FontWeight.w600))
                          : _StatusBadge(
                              within: s.within(value),
                              text: s.within(value)
                                  ? s.statusWithin
                                  : s.statusOutside,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 346,
                  child: SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(16, 19, 8, 16),
                  child: Column(
                    children: [
                      Text(s.historyChartTitle,
                          textAlign: TextAlign.center,
                          style: AppText.sf(20, weight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      LineChart(
                        series: [
                          ChartSeries(
                            values: series,
                            colors: SampleData.gradient,
                          ),
                        ],
                        minY: s.minY,
                        maxY: s.maxY,
                        step: s.step,
                        height: 230,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 12),
                if (value == null)
                  const SurfaceCard(
                    child: EmptyState(
                      compact: true,
                      icon: Icons.insights_rounded,
                      title: 'No trend yet',
                      message:
                          'The trend overview appears once readings are recorded.',
                    ),
                  )
                else
                  _TrendOverview(
                    spec: s,
                    series: series,
                    latest: value,
                    updatedAt: LiveReadings.instance.snapshot.updatedAt,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Trend Overview" card (Figma 935:926): headline reading, change indicator, latest
/// timestamp, divider and an Observation paragraph.
class _TrendOverview extends StatelessWidget {
  const _TrendOverview({
    required this.spec,
    required this.series,
    required this.latest,
    this.updatedAt,
  });

  final SensorSpec spec;
  final List<double> series;
  final double latest;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final delta = series.last - series.first;
    final range = (spec.maxY - spec.minY).abs();
    final stable = delta.abs() < range * 0.05;
    final label = stable ? 'Stable' : (delta < 0 ? 'Decreasing' : 'Increasing');
    final unit = spec.unit.trim();
    final change =
        '${stable ? '~ ' : ''}${delta.abs().toStringAsFixed(spec.decimals)}${unit.isEmpty ? '' : ' $unit'}';
    final latestText = spec.format(latest).trim();
    String observation(double d, bool flat) => flat
        ? 'Readings remained relatively consistent during the monitoring period.'
        : (d < 0
            ? 'Readings moved downward during the monitoring period.'
            : 'Readings moved upward during the monitoring period.');
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trend Overview',
                    style: AppText.sf(25, weight: FontWeight.w600)),
                Text(label,
                    style: AppText.sf(11,
                        weight: FontWeight.w500, color: AppColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(latestText,
                        style: AppText.sf(30, weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    if (!stable)
                      Icon(
                          delta < 0
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          size: 14,
                          color: AppColors.accent),
                    Text(change,
                        style: AppText.sf(15, color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                    updatedAt == null
                        ? 'Latest reading time unavailable'
                        : 'Latest Reading as of ${liveTime(updatedAt!)}',
                    style: AppText.sf(15, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Observation',
                style: AppText.sf(20, weight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(31, 10, 10, 10),
            child: Text(
              observation(delta, stable),
              style: AppText.sf(15, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.within, required this.text});

  final bool within;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = within ? AppColors.good : AppColors.bad;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: AppText.inter(15, weight: FontWeight.w700)),
      ],
    );
  }
}
