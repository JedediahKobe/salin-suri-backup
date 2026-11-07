import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _titles = ['Check Connection', 'Monitor Parameters', 'Track Changes'];
  static const _bodies = [
    'Connect Salin-Suri in the embedded water-quality monitoring system and access sensor readings from your device.',
    'View sensor measurements including pH, temperature, turbidity, TDS, and other supported parameters.',
    'Explore historical readings and compare measurements with configured reference ranges.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _titles.length - 1) {
      widget.onFinished();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _titles.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _Illustration(child: AssetOrIcon(asset: 'assets/images/link.png', fallback: Icons.link_rounded, height: 172)),
                  _Illustration(child: _ParameterCards()),
                  _Illustration(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AssetOrIcon(asset: 'assets/images/pie_chart.png', fallback: Icons.pie_chart_rounded, height: 138, width: 138),
                        AssetOrIcon(asset: 'assets/images/growth_chart.png', fallback: Icons.show_chart_rounded, height: 138, width: 160),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Copy swaps with the page
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Padding(
                key: ValueKey(_page),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(_titles[_page],
                        textAlign: TextAlign.center,
                        style: AppText.poppins(35)),
                    const SizedBox(height: 20),
                    Text(_bodies[_page],
                        textAlign: TextAlign.center,
                        style: AppText.sf(18, weight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Page indicator: active dot stretches into a pill
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _titles.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == _page ? 40 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(last ? 'Get Started' : 'Next',
                        key: ValueKey(last),
                        style: AppText.sf(18, weight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(child: child);
}

/// The three stacked pre/post/change cards of onboarding step 2.
class _ParameterCards extends StatelessWidget {
  const _ParameterCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _MiniCard(pre: '7.3', post: '9.8', change: '2.5', up: true, big: false),
        SizedBox(height: 14),
        _MiniCard(pre: '9.8', post: '7.2', change: '2.6', up: false, big: true),
        SizedBox(height: 14),
        _MiniCard(pre: '9.3', post: '7.2', change: '2.1', up: false, big: false),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.pre,
    required this.post,
    required this.change,
    required this.up,
    required this.big,
  });

  final String pre;
  final String post;
  final String change;
  final bool up;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: big ? 390 : 344,
      height: big ? 100 : 72,
      decoration: BoxDecoration(
        color: big ? AppColors.surface : AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _cell('Pre-Filtration', Text(pre, style: AppText.inter(17, weight: FontWeight.w600))),
          const VerticalDivider(width: 1, color: AppColors.divider, indent: 14, endIndent: 14),
          _cell('Post Filtration', Text(post, style: AppText.sf(17, weight: FontWeight.w600))),
          const VerticalDivider(width: 1, color: AppColors.divider, indent: 14, endIndent: 14),
          _cell(
            'Change',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 16, color: up ? AppColors.bad : AppColors.good),
                const SizedBox(width: 3),
                Text(change, style: AppText.sf(17, weight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, Widget value) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: AppText.inter(12)),
            const SizedBox(height: 10),
            value,
          ],
        ),
      );
}
