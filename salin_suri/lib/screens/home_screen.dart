import 'package:flutter/material.dart';

import '../data/sensor_specs.dart';
import '../main.dart' show AppShell;
import '../data/notification_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'history_screen.dart';
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
        trailing: ListenableBuilder(
          listenable: NotificationStore.instance,
          builder: (context, _) => CircleChip(
            appIcon: AppIconType.bell,
            dot: NotificationStore.instance.hasUnread,
          // Notification is a tab in the shell now.
          onTap: () => AppShell.of(context)?.select(2),
          ),
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
                  SensorCard(info: s, width: 143, radius: 20),
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

          // ── Monitoring insights (Figma 603:272...: tappable link cards) ──
          const SectionTitle('Monitoring Insights'),
          const SizedBox(height: 10),
          for (final item in _insights) ...[
            _InsightLinkCard(
              title: item.title,
              subtitle: item.subtitle,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => HistoryScreen(spec: item.spec))),
            ),
            const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }
}

class _Insight {
  const _Insight(this.title, this.subtitle, this.spec);

  final String title;
  final String subtitle;
  final SensorSpec spec;
}

const _insights = <_Insight>[
  _Insight('pH Level Monitoring', 'Monitoring ph Level changes', SensorSpec.ph),
  _Insight('Water Temperature Monitoring', 'Monitoring temperature changes',
      SensorSpec.temperature),
  _Insight('Turbidity Monitoring', 'Monitoring turbidity changes',
      SensorSpec.turbidity),
  _Insight('TDS Monitoring', 'Monitoring TDS changes', SensorSpec.tds),
];

/// 385x80 card, r10, with title/subtitle and a chevron-right.
class _InsightLinkCard extends StatelessWidget {
  const _InsightLinkCard(
      {required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.inter(18, weight: FontWeight.w500)),
                      const SizedBox(height: 9),
                      Text(subtitle, style: AppText.inter(12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.text, size: 28),
              ],
            ),
          ),
        ),
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
