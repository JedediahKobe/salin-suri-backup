import 'package:flutter/material.dart';

import '../data/parameter_info.dart';
import '../data/sample_data.dart';
import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/accordion.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/parameter_guide.dart';
import '../widgets/segmented_tabs.dart';

/// History / insight screen for one parameter (Figma 67:221, 583:295, 583:480, 583:665).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.spec});

  final SensorSpec spec;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0; // 0 = Pre-filtration, 1 = Post-filtration
  late String _range = widget.spec.rangeOptions.first;

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
        trailing: CircleChip(
          icon: Icons.lightbulb_outline_rounded,
          onTap: () => showParameterInfoModal(context, s.info),
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
                            value: _range,
                            options: s.rangeOptions,
                            onChanged: (v) => setState(() => _range = v),
                          ),
                        ],
                      ),
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
                        xLabels: SampleData.weekdays,
                        height: 250,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Guide accordion (expanded by default in Figma)
          AccordionCard(
            title: s.guideTitle,
            titleStyle: AppText.sf(22, weight: FontWeight.w700),
            headerHeight: 56,
            initiallyExpanded: true,
            body: ParameterGuide(
              entries: s.guide,
              currentValue: value,
              valueSize: s.guideValueSize,
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
