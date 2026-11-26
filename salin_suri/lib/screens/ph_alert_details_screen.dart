import 'package:flutter/material.dart';

import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../data/filtration_records.dart';
import '../data/notification_store.dart';
import 'history_details_screen.dart';

/// Notification Details for the Pre Filtration Alert (Figma 423:148). Opened from the pH
/// Alert in Notification; the readings come from the [AlertItem].
class PhAlertDetailsScreen extends StatelessWidget {
  const PhAlertDetailsScreen({super.key, required this.alert});

  final AlertItem alert;

  static const _turbidityMax = 5.0;
  static Color get _grey => AppColors.muted;

  @override
  Widget build(BuildContext context) {
    const spec = SensorSpec.ph;
    final min = spec.limitMin!, max = spec.limitMax!;
    final ph = alert.ph, turbidity = alert.turbidity;
    final phAbove = ph != null && ph > max;
    final turbAbove = turbidity != null && turbidity > _turbidityMax;

    return Scaffold(
      appBar: const AppTopBar(title: 'Pre-Filtration Alert', showBack: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('pH, Turbidity Alert',
                          style: AppText.sf(25, weight: FontWeight.w700)),
                      Text('Warning',
                          style: AppText.sf(13, color: AppColors.alert)),
                    ],
                  ),
                  Text(alert.body,
                      style: AppText.sf(14, color: _grey).copyWith(height: 20 / 14)),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                  const SizedBox(height: 15),
                  if (ph != null)
                    _Reading(
                      value: ph.toStringAsFixed(1),
                      status: phAbove ? 'Above reference range' : 'Within reference range',
                      bad: phAbove,
                      range: 'ph reference range: $min-$max',
                    ),
                  if (turbidity != null) ...[
                    const SizedBox(height: 15),
                    _Reading(
                      value: turbidity.toStringAsFixed(1),
                      status: turbAbove ? 'Above reference range' : 'Within reference range',
                      bad: turbAbove,
                      range: 'NTU reference range: \u2264${_turbidityMax.toStringAsFixed(0)} NTU',
                    ),
                  ],
                  const SizedBox(height: 15),
                  Text('What happened?', style: AppText.sf(18)),
                  const SizedBox(height: 15),
                  Text(
                    "The sensors detected an increase in the water's acidity and turbidity. "
                    'This may indicate water\u2019s acidity and turbidity or changes in the '
                    'water entering the filtration system.',
                    style: AppText.sf(18),
                  ),
                  const SizedBox(height: 15),
                  if (_alertRecord(alert) != null)
                  Center(
                    child: SizedBox(
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
                        // The pre-filtration run this alert was raised for.
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => HistoryDetailsScreen(
                                    record: _alertRecord(alert)!))),
                        child: Text('View Filtration Details',
                            style: AppText.sf(15, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                  const SizedBox(height: 15),
                  Text('Notified at ${alert.time}',
                      style: AppText.sf(13, color: _grey)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('What to check next?',
                style: AppText.sf(25, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Check the latest sensor readings. If unusual readings persist, '
              'verify the sensor and filtration condition.',
              style: AppText.sf(14, color: _grey).copyWith(height: 20 / 14),
            ),
          ],
        ),
      ),
    );
  }
}

/// Big reading with its status and reference range (Figma 904:1007 / 961:470).
class _Reading extends StatelessWidget {
  const _Reading(
      {required this.value,
      required this.status,
      required this.bad,
      required this.range});

  final String value;
  final String status;
  final bool bad;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 79,
          child: Text(value, style: AppText.sf(50, weight: FontWeight.w600)),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status,
                  style: AppText.sf(13,
                      weight: FontWeight.w600,
                      color: bad ? AppColors.alert : AppColors.good)),
              const SizedBox(height: 3),
              Text(range, style: AppText.sf(13, color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

/// The filtration run this alert was raised for, or null when the alert doesn't name one
/// (or the run isn't in the loaded history).
FiltrationRecord? _alertRecord(AlertItem alert) {
  final n = alert.filtrationNumber;
  if (n == null) return null;
  final store = FiltrationStore.instance;
  for (final r in [...store.active, ...store.archived, ...store.deleted]) {
    if (r.number == n) return r;
  }
  return null;
}
