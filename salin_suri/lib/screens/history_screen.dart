import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/accordion.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import '../widgets/modals/ph_info_modal.dart';
import '../widgets/segmented_tabs.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0; // 0 = Pre-filtration, 1 = Post-filtration
  String _range = 'Last 7 days';

  static const _tabLabels = ['Pre-filtration', 'Post-filtration'];

  @override
  Widget build(BuildContext context) {
    final isPre = _tab == 0;

    return Scaffold(
      appBar: AppTopBar(
        title: 'ph Level History',
        showBack: true,
        trailing: CircleChip(
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => showPhInfoModal(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
        children: [
          // Tab switcher (sliding pill)
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
                    StatCell(
                        label: _tabLabels[_tab],
                        value: isPre ? '9.8' : '7.2'),
                    const StatCell(label: 'Reference Range', value: '6.5 - 8.5'),
                    StatCell(
                      label: 'Range',
                      value: '',
                      valueWidget: _RangeBadge(withinRange: !isPre),
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
                          Text('pH Level Over Time',
                              style: AppText.sf(20, weight: FontWeight.w600)),
                          DropdownPill(
                            value: _range,
                            options: const ['Last 7 days', 'Last 30 days'],
                            onChanged: (v) => setState(() => _range = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LineChart(
                        series: [
                          ChartSeries(
                            values: isPre
                                ? SampleData.phHistoryPre
                                : SampleData.phHistoryPost,
                            colors: SampleData.gradient,
                          ),
                        ],
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

          // pH Level Guide: accordion (expanded by default in Figma)
          AccordionCard(
            title: 'pH Level Guide',
            titleStyle: AppText.sf(22, weight: FontWeight.w700),
            headerHeight: 56,
            initiallyExpanded: true,
            body: _PhGuide(currentValue: isPre ? 9.8 : 7.2),
          ),
        ],
      ),
    );
  }
}

class _RangeBadge extends StatelessWidget {
  const _RangeBadge({required this.withinRange});

  final bool withinRange;

  @override
  Widget build(BuildContext context) {
    final color = withinRange ? AppColors.good : AppColors.bad;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(withinRange ? 'Within Range' : 'Out of Range',
            style: AppText.inter(15, weight: FontWeight.w700)),
      ],
    );
  }
}

class _GuideEntry {
  const _GuideEntry(this.value, this.title, this.description);

  final double value;
  final String title;
  final String description;
}

class _PhGuide extends StatelessWidget {
  const _PhGuide({required this.currentValue});

  final double currentValue;

  static const _entries = [
    _GuideEntry(6.0, 'Slightly Acidic', 'Below neutral.'),
    _GuideEntry(7.2, 'Neutral', 'Neither acidic nor alkaline'),
    _GuideEntry(8.0, 'Slightly Alkaline', 'Slightly alkaline water'),
    _GuideEntry(9.0, 'Alkaline',
        'More alkaline than the commonly referenced drinking-water range.'),
    _GuideEntry(10.0, 'Strongly Alkaline', 'Strongly alkaline water'),
  ];

  int get _selected {
    var best = 0;
    for (var i = 0; i < _entries.length; i++) {
      if ((_entries[i].value - currentValue).abs() <
          (_entries[best].value - currentValue).abs()) {
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          for (var i = 0; i < _entries.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // marker + connector line
                  SizedBox(
                    width: 42,
                    child: Column(
                      children: [
                        _Marker(selected: i == selected),
                        if (i < _entries.length - 1)
                          Expanded(
                            child: Container(
                                width: 1, color: AppColors.guideBlue),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 64,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_entries[i].value.toStringAsFixed(1),
                          style: AppText.sf(25, weight: FontWeight.w700)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_entries[i].title,
                              style: AppText.sf(15,
                                  weight: i == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(_entries[i].description,
                              style: AppText.sf(12,
                                  color: const Color(0xFFDBDBDB))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.guideBlue, width: 1.5),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: selected ? 28 : 0,
        height: selected ? 28 : 0,
        decoration: const BoxDecoration(
            color: AppColors.guideBlue, shape: BoxShape.circle),
      ),
    );
  }
}
