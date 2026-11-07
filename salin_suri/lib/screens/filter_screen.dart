import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'notification_screen.dart';

class _Stage {
  const _Stage(this.name, this.purpose, this.type, this.asset, this.icon);

  final String name;
  final String purpose;
  final String type;
  final String asset;
  final IconData icon;
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // The three stages follow the filtration setup: fiber pre-filter, adsorbent
  // media, then the sand-and-gravel polishing layer.
  static const _stages = [
    _Stage(
      'Coconut Husk Fiber',
      'Traps larger particles, dirt, and suspended solids',
      'Mechanical Filtration',
      'assets/images/coconut_husk.png',
      Icons.grass_rounded,
    ),
    _Stage(
      'Activated Carbon & Biochar',
      'Helps reduce dissolved impurities, color, and unwanted odor through adsorption',
      'Adsorption Filtration',
      'assets/images/stage2.png',
      Icons.layers_rounded,
    ),
    _Stage(
      'Sand & Gravel',
      'Captures finer suspended particles as water passes through the final filter layer',
      'Depth Filtration',
      'assets/images/stage3.png',
      Icons.water_rounded,
    ),
  ];

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_page + delta).clamp(0, _stages.length - 1);
    if (next != _page) {
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Filtration Guide',
            style: AppText.sf(20, weight: FontWeight.w700)),
        content: Text(
          'Water passes through three filtration stages. Coconut husk fiber '
          'captures larger particles, activated carbon and rice husk biochar '
          'provide adsorbent media, and sand with gravel helps retain finer '
          'suspended particles. This system is intended for household '
          'washing and cleaning, not for drinking water.',
          style: AppText.inter(14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it',
                style: AppText.inter(14,
                    weight: FontWeight.w600, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Salin-Suri',
        trailing: CircleChip(
          icon: Icons.notifications_none_rounded,
          dot: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
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
                  child: Text(
                    'Filtration\nStage ${_page + 1} of ${_stages.length}',
                    style: AppText.poppins(28),
                  ),
                ),
                CircleChip(
                  icon: Icons.lightbulb_outline_rounded,
                  size: 48,
                  onTap: _showGuide,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _stages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final stage = _stages[i];
                  return Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AssetOrIcon(
                              asset: stage.asset,
                              fallback: stage.icon,
                              height: 180,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _Arrow(
                                icon: Icons.chevron_left_rounded,
                                onTap: () => _go(-1),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _Arrow(
                                icon: Icons.chevron_right_rounded,
                                onTap: () => _go(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Text(
                          stage.name,
                          textAlign: TextAlign.center,
                          style: AppText.poppins(
                            stage.name.length > 22 ? 22 : 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _InfoColumn(
                                  title: 'Purpose',
                                  body: stage.purpose,
                                ),
                              ),
                              const VerticalDivider(
                                width: 24,
                                thickness: 1,
                                color: AppColors.divider,
                              ),
                              Expanded(
                                child: _InfoColumn(
                                  title: 'Filtration Type',
                                  body: stage.type,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 90),
                    ],
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
  Widget build(BuildContext context) =>
      CircleChip(icon: icon, onTap: onTap, size: 36);
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
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppText.poppins(12, weight: FontWeight.w400),
        ),
      ],
    );
  }
}
