import 'package:flutter/material.dart';

import '../data/filter_materials.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'maintenance_history_screen.dart';

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
      appBar: AppTopBar(
        title: 'Salin-Suri',
        // Entry to Maintenance History (689:169).
        trailing: CircleChip(
          appIcon: AppIconType.history,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MaintenanceHistoryScreen())),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _materials.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final m = _materials[i];
                  // Scrolls instead of overflowing when the screen is short or the
                  // purpose text wraps onto extra lines.
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 150),
                          child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AssetOrIcon(
                                asset: m.asset,
                                fallback: m.fallbackIcon,
                                height: 180),
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
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(m.name,
                            textAlign: TextAlign.center,
                            style: AppText.poppins(28)),
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: IntrinsicHeight(
                          child: Row(
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
                      const SizedBox(height: 24),
                    ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
