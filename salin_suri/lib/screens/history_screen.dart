import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;
    final isPre = _tab == 0;
    final value = isPre ? s.historyPre : s.historyPost;

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
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
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
                    StatCell(label: _tabLabels[_tab], value: s.format(value)),
                    StatCell(label: s.limitLabel, value: s.limitValue),
                    StatCell(
                      label: s.statusLabel,
                      value: '',
                      valueWidget: _StatusBadge(
                        within: s.within(value),
                        text: s.within(value) ? s.statusWithin : s.statusOutside,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SurfaceCard(
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
                            values: isPre
                                ? s.historyPreSeries
                                : s.historyPostSeries,
                            colors: SampleData.gradient,
                          ),
                        ],
                        minY: s.minY,
                        maxY: s.maxY,
                        step: s.step,
                        height: 250,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StatisticalSummary(
                    stats: isPre ? s.preSummary : s.postSummary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticalSummary extends StatelessWidget {
  const _StatisticalSummary({required this.stats});

  final SummaryStats stats;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(35, 19, 16, 22),
      child: Column(
        children: [
          Text('Statistical Summary',
              style: AppText.sf(20, weight: FontWeight.w600)),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Stat(value: stats.average, label: 'Average Reading')),
              Expanded(child: _Stat(value: stats.median, label: 'Median Reading')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Stat(value: stats.minimum, label: 'Minimum Range')),
              Expanded(child: _Stat(value: stats.maximum, label: 'Maximum Range')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppText.sf(30, weight: FontWeight.w700)),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.sf(15)),
      ],
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
