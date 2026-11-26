import 'package:flutter/material.dart';

import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../data/filtration_records.dart';
import 'history_details_screen.dart';

/// Notification Details for the Pre Filtration Alert (Figma 423:148). Opened from the pH Alert in Notification.
/// Reading and timestamp are dummy data until alerts come from the backend.
class PhAlertDetailsScreen extends StatelessWidget {
  const PhAlertDetailsScreen({super.key});

  static const _ph = 9.8;
  static const _turbidity = 6.0;
  static const _turbidityMax = 5.0;
  static const _recorded = '27/10/26, 9:10am';
  static Color get _grey => AppColors.muted;

  @override
  Widget build(BuildContext context) {
    const spec = SensorSpec.ph;
    final min = spec.limitMin!, max = spec.limitMax!;
    final phAbove = _ph > max;
    final turbAbove = _turbidity > _turbidityMax;

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
                  Text('Pre-filtration pH and turbidity exceeded the reference range.',
                      style: AppText.sf(14, color: _grey).copyWith(height: 20 / 14)),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                  const SizedBox(height: 15),
                  _Reading(
                    value: _ph.toStringAsFixed(1),
                    status: phAbove ? 'Above reference range' : 'Within reference range',
                    bad: phAbove,
                    range: 'ph reference range: $min-$max',
                  ),
                  const SizedBox(height: 15),
                  _Reading(
                    value: _turbidity.toStringAsFixed(1),
                    status: turbAbove ? 'Above reference range' : 'Within reference range',
                    bad: turbAbove,
                    range: 'NTU reference range: \u2264${_turbidityMax.toStringAsFixed(0)} NTU',
                  ),
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
                                    record: _alertRecord()))),
                        child: Text('View Filtration Details',
                            style: AppText.sf(15, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                  const SizedBox(height: 15),
                  Text('Notified at $_recorded',
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

/// The pre-filtration run the alert was raised for (#135). Falls back to the first record
/// when the database doesn't have that number.
FiltrationRecord _alertRecord() {
  final all = [
    ...FiltrationStore.instance.active,
    ...FiltrationStore.instance.archived,
    ...FiltrationStore.instance.deleted,
  ];
  return all.firstWhere((r) => r.number == 135,
      orElse: () => all.isNotEmpty ? all.first : FiltrationRecord.sample.last);
}
