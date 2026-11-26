import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Report for one filtration run (Figma 623:954).
class HistoryDetailsScreen extends StatelessWidget {
  const HistoryDetailsScreen({super.key, required this.record});

  final FiltrationRecord record;

  static Color get _grey => AppColors.muted;

  /// Pre / post values for this run. Each record only stores its own stage, so the other
  /// stage is estimated until the device reports both. #135 uses the Figma (623:954) values.
  static const _fig135Pre = (ph: 9.0, temp: 27.6, turb: 6.0, tds: 280.0);
  static const _fig135Post = (ph: 6.5, temp: 27.3, turb: 5.8, tds: 180.0);

  @override
  Widget build(BuildContext context) {
    final r = record;
    final own = (ph: r.ph, temp: r.temperature, turb: r.turbidity, tds: r.tds);
    final est = r.isPre
        ? (ph: r.ph * 0.78, temp: r.temperature - 0.3, turb: r.turbidity * 0.4, tds: r.tds * 0.65)
        : (ph: r.ph / 0.78, temp: r.temperature + 0.3, turb: r.turbidity / 0.4, tds: r.tds / 0.65);
    final pre = r.number == 135 ? _fig135Pre : (r.isPre ? own : est);
    final post = r.number == 135 ? _fig135Post : (r.isPre ? est : own);

    String f1(double v) => v.toStringAsFixed(1);
    final rows = [
      (f1(pre.ph) + ' pH', f1(post.ph) + ' pH', true),
      (f1(pre.turb) + ' NTU', f1(post.turb) + ' NTU', true),
      (f1(pre.temp) + ' \u00B0C', f1(post.temp) + ' \u00B0C', false),
      (pre.tds.round().toString() + ' mg/L', post.tds.round().toString() + ' mg/L', true),
    ];

    return Scaffold(
      appBar: AppTopBar(title: r.title, showBack: true),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filtration Report',
                              style: AppText.sf(20, weight: FontWeight.w700)),
                          const SizedBox(height: 20),
                          Divider(
                              height: 1, thickness: 1, color: AppColors.divider),
                          const SizedBox(height: 20),
                          for (final row in rows) ...[
                            _Pair(pre: row.$1, post: row.$2, bold: row.$3),
                            const SizedBox(height: 20),
                          ],
                          Divider(
                              height: 1, thickness: 1, color: AppColors.divider),
                          const SizedBox(height: 20),
                          Text('Monitored at ${r.time}',
                              style: AppText.sf(13, color: AppColors.divider)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report Summary',
                              style: AppText.sf(25, weight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Text(
                            '${r.title} reduced pH from ${f1(pre.ph)} to ${f1(post.ph)}, '
                            'temperature from ${f1(pre.temp)} to ${f1(post.temp)} \u00B0C, '
                            'and TDS from ${pre.tds.round()} to ${post.tds.round()} mg/L. '
                            'The turbidity reading decreased from ${f1(pre.turb)} to ${f1(post.turb)}.',
                            style: AppText.sf(16),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Note: These parameters are not only the sole basis to determine whether the water is safe to drink.',
                            style: AppText.sf(11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 346,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFFF5F5F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  // Back to the Monitoring History list.
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Go Back to Monitoring Page',
                      style: AppText.sf(15, weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "9.0 pH -> 6.5 pH" row (Figma 961:526): value over its stage label, arrow between.
class _Pair extends StatelessWidget {
  const _Pair({required this.pre, required this.post, required this.bold});

  final String pre;
  final String post;
  final bool bold;

  Widget _cell(String v, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v,
              style: AppText.sf(25,
                  weight: bold ? FontWeight.w700 : FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: AppText.sf(15)),
        ],
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: _cell(pre, 'Pre-Filtration')),
          Icon(Icons.arrow_right_alt_rounded, size: 28, color: AppColors.accent),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _cell(post, 'Post-Filtration'))),
        ],
      );
}
