import 'package:flutter/material.dart';

import '../data/filter_materials.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'maintenance_history_screen.dart';
import 'monitoring_history_screen.dart';

/// Filtration screen: a carousel of [FilterMaterial] cards (Figma Filter Media Card
/// 112:1075). The lightbulb opens the current material's info modal (134:*).
class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _materials = FilterMaterial.all;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_page + delta).clamp(0, _materials.length - 1);
    _controller.animateToPage(next,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Salin-Suri'),
      // The whole page scrolls (Figma 97:451): carousel card, then Filtration Insights.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Filtration\n${_materials[_page].stageLabel}',
                    style: AppText.poppins(28)),
              ),
              CircleChip(
                appIcon: AppIconType.bulb,
                size: 48,
                onTap: () => _materials[_page].showInfo(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _controller,
              itemCount: _materials.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final m = _materials[i];
                return Column(
                  children: [
                    // Shrinks (never overflows) if the text below needs more room.
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AssetOrIcon(
                              asset: m.asset,
                              fallback: m.fallbackIcon,
                              height: 150),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _Arrow(
                                icon: Icons.chevron_left_rounded,
                                onTap: () => _go(-1)),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _Arrow(
                                icon: Icons.chevron_right_rounded,
                                onTap: () => _go(1)),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(m.name,
                          textAlign: TextAlign.center,
                          style: AppText.poppins(28)),
                    ),
                    const SizedBox(height: 16),
                    SurfaceCard(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _InfoColumn(
                                    title: 'Purpose', body: m.purpose)),
                            VerticalDivider(
                                width: 24,
                                thickness: 1,
                                color: AppColors.divider),
                            Expanded(
                                child: _InfoColumn(
                                    title: 'Filtration Type',
                                    body: m.filtrationType)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Text('Filtration Insights',
              style: AppText.sf(22, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          _InsightCard(
            title: 'Maintenance History',
            subtitle: 'Monitor filter maintenance',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const MaintenanceHistoryScreen())),
          ),
          const SizedBox(height: 10),
          _InsightCard(
            title: 'Filtration History',
            subtitle: 'View all filtrations and parameters report',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const MonitoringHistoryScreen())),
          ),
        ],
      ),
    );
  }
}

/// Link card under "Filtration Insights" (Figma 689:136 / 689:142).
class _InsightCard extends StatelessWidget {
  const _InsightCard(
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
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.inter(18, weight: FontWeight.w500)),
                    const SizedBox(height: 9),
                    Text(subtitle, style: AppText.inter(12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.text),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CircleChip(icon: icon, onTap: onTap, size: 36);
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: AppText.sf(17, weight: FontWeight.w700)),
        const SizedBox(height: 14),
        Text(body,
            textAlign: TextAlign.center,
            style: AppText.poppins(12, weight: FontWeight.w400)),
      ],
    );
  }
}
