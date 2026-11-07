import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';
import '../widgets/accordion.dart';
import '../widgets/common.dart';
import '../widgets/line_chart.dart';
import 'notification_screen.dart';
import 'sensors_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _stage = 'Pre-filtration';

  bool get _isPre => _stage == 'Pre-filtration';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Salin-Suri',
        trailing: CircleChip(
          icon: Icons.notifications_none_rounded,
          dot: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen())),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 110),
        children: [
          // ── Sensors ───────────────────────────────────────────
          SectionTitle(
            'Sensors',
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SensorsScreen())),
              child: Text('See All →',
                  style: AppText.inter(11,
                      weight: FontWeight.w500, color: AppColors.accent)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 133,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in SensorInfo.all.take(3)) ...[
                  SensorCard(info: s, width: 180, radius: 15),
                  const SizedBox(width: 15),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Live dashboard ────────────────────────────────────
          SectionTitle(
            'Live Dashboard',
            trailing: DropdownPill(
              value: _stage,
              options: const ['Pre-filtration', 'Post-filtration'],
              onChanged: (v) => setState(() => _stage = v),
            ),
          ),
          const SizedBox(height: 8),
          // Values change depending on pre or post filtration (Figma annotation).
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: StatsPanel(
              key: ValueKey(_stage),
              height: 159,
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Updated:', style: AppText.sf(13)),
                      const SizedBox(height: 4),
                      Text('September 24 • 10:37 am',
                          style: AppText.sf(14, weight: FontWeight.w600)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Battery Percentage:', style: AppText.sf(13)),
                      const SizedBox(height: 4),
                      Text('87%',
                          style: AppText.sf(14, weight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              cells: [
                StatCell(label: 'Temperature', value: _isPre ? '29.6 °C' : '28.9 °C'),
                StatCell(label: 'pH level', value: _isPre ? '9.8' : '7.2'),
                StatCell(label: 'Turbidity', value: _isPre ? '8.4 NTU' : '2.1 NTU'),
                StatCell(label: 'TDS', value: _isPre ? '240 ppm' : '118 ppm'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _StatusCard(title: 'Within Range', caption: 'Water Quality Range')),
              SizedBox(width: 6),
              Expanded(child: _StatusCard(title: 'Connected', caption: 'Device Status')),
            ],
          ),
          const SizedBox(height: 28),

          // ── Monitoring insights (accordion) ───────────────────
          const SectionTitle('Monitoring Insights'),
          const SizedBox(height: 10),
          AccordionGroup(
            initialIndex: 0, // first one expanded, the rest collapsed, as in Figma
            items: [
              AccordionItemData(
                title: 'pH Level Monitoring',
                subtitle: 'Monitor pH Level changes',
                body: _InsightChart(pre: SampleData.phPre, post: SampleData.phPost),
              ),
              AccordionItemData(
                title: 'Water Temperature Monitoring',
                subtitle: 'Monitor temperature changes',
                body: _InsightChart(pre: SampleData.tempPre, post: SampleData.tempPost),
              ),
              AccordionItemData(
                title: 'Turbidity Monitoring',
                subtitle: 'Monitor turbidity changes',
                body: _InsightChart(pre: SampleData.turbPre, post: SampleData.turbPost),
              ),
              AccordionItemData(
                title: 'TDS Monitoring',
                subtitle: 'Monitor TDS changes',
                body: _InsightChart(pre: SampleData.tdsPre, post: SampleData.tdsPost),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.good, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(title, style: AppText.inter(17, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Text(caption, style: AppText.inter(12)),
        ],
      ),
    );
  }
}

/// Expanded body of an insight accordion: chart + Pre/Post legend.
class _InsightChart extends StatelessWidget {
  const _InsightChart({required this.pre, required this.post});

  final List<double> pre;
  final List<double> post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          LineChart(series: SampleData.preAndPost(pre, post), height: 250),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Legend(color: AppColors.preSeries, label: 'Pre-Filtration'),
              SizedBox(width: 40),
              _Legend(color: AppColors.postSeries, label: 'Post-Filtration'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppText.sf(12)),
      ],
    );
  }
}
