import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Report for one filtration run (Figma 623:954).
class HistoryDetailsScreen extends StatelessWidget {
  const HistoryDetailsScreen({super.key, required this.record});

  final FiltrationRecord record;

  static Color get _grey => AppColors.muted;

  @override
  Widget build(BuildContext context) {
    final r = record;
    final own = RunReading(
        ph: r.ph, temperature: r.temperature, turbidity: r.turbidity, tds: r.tds);
    final pre = r.isPre ? own : r.counterpart;
    final post = r.isPre ? r.counterpart : own;
    final complete = pre != null && post != null;

    String f1(double? v) => v == null ? '--' : v.toStringAsFixed(1);
    String unit(String v, String u) => v == '--' ? v : '$v $u';
    String tds(double? v) => v == null ? '--' : '${v.round()} mg/L';
    final rows = [
      (unit(f1(pre?.ph), 'pH'), unit(f1(post?.ph), 'pH'), true),
      (unit(f1(pre?.turbidity), 'NTU'), unit(f1(post?.turbidity), 'NTU'), true),
      (unit(f1(pre?.temperature), '\u00B0C'), unit(f1(post?.temperature), '\u00B0C'), false),
      (tds(pre?.tds), tds(post?.tds), true),
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
                            complete
                                ? '${r.title} changed pH from ${f1(pre!.ph)} to ${f1(post!.ph)}, '
                                    'temperature from ${f1(pre!.temperature)} to ${f1(post!.temperature)} \u00B0C, '
                                    'and TDS from ${pre!.tds.round()} to ${post!.tds.round()} mg/L. '
                                    'The turbidity reading went from ${f1(pre!.turbidity)} to ${f1(post!.turbidity)} NTU.'
                                : 'A summary will appear once both the pre- and post-filtration readings of this run have been recorded.',
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
