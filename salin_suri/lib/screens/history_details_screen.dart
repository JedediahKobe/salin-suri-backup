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
    final readings =
        'pH ${r.phText}, temperature ${r.temperatureText}, turbidity '
        '${r.turbidityText}, and TDS ${r.tdsText}.';

    return Scaffold(
      appBar: const AppTopBar(title: 'Monitoring History', showBack: true),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Monitoring Report',
                                  style: AppText.sf(20, weight: FontWeight.w700)),
                              Text(r.time,
                                  style: AppText.sf(13, color: _grey)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(
                              height: 1, thickness: 1, color: AppColors.divider),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: _Reading(
                                      value: '${r.phText} pH', label: 'pH Level')),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _Reading(
                                      value: r.temperatureText,
                                      label: 'Temperature')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _Reading(
                                      value: r.turbidityText, label: 'Turbidity')),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _Reading(value: r.tdsText, label: 'TDS')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Report Summary',
                              style: AppText.sf(25, weight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              style: AppText.sf(16, color: AppColors.muted),
                              children: [
                                TextSpan(
                                    text:
                                        '${r.stage} readings for ${r.title} were '),
                                TextSpan(
                                    text: readings,
                                    style: AppText.sf(16)),
                                TextSpan(
                                    text: r.withinThresholds
                                        ? ' All readings were within the set thresholds.'
                                        : ' Some readings were outside the set thresholds.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Note: These parameters are not only the sole basis to determine water is safe to drink.',
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
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
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

class _Reading extends StatelessWidget {
  const _Reading({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.sf(20, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: AppText.sf(15)),
      ],
    );
  }
}
