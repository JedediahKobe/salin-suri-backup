import 'package:flutter/material.dart';

import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'sensor_page.dart';

/// pH Alert Details (Figma 423:148). Opened from the pH Alert in Notification.
/// Reading and timestamp are dummy data until alerts come from the backend.
class PhAlertDetailsScreen extends StatelessWidget {
  const PhAlertDetailsScreen({super.key});

  static const _reading = 9.8;
  static const _recorded = '27/10/26, 9:10am';
  static Color get _grey => AppColors.muted;

  @override
  Widget build(BuildContext context) {
    const spec = SensorSpec.ph;
    final min = spec.limitMin!, max = spec.limitMax!;
    final above = _reading > max;
    final below = _reading < min;
    final summary = above
        ? 'Pre-filtration pH exceeded the reference range.'
        : below
            ? 'Pre-filtration pH fell below the reference range.'
            : 'Pre-filtration pH is within the reference range.';

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
                      Text('pH Level Alert',
                          style: AppText.sf(25, weight: FontWeight.w700)),
                      Text('Warning',
                          style: AppText.sf(13, color: AppColors.alert)),
                    ],
                  ),
                  Text(summary,
                      style: AppText.sf(14, color: _grey).copyWith(height: 20 / 14)),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(_reading.toStringAsFixed(1),
                          style: AppText.sf(50, weight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              above
                                  ? 'Above reference range'
                                  : below
                                      ? 'Below reference range'
                                      : 'Within reference range',
                              style: AppText.sf(13,
                                  weight: FontWeight.w600,
                                  color: (above || below)
                                      ? AppColors.alert
                                      : AppColors.good),
                            ),
                            const SizedBox(height: 3),
                            Text('ph reference range: $min-$max',
                                style: AppText.sf(13, color: _grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text('What happened?', style: AppText.sf(18, color: _grey)),
                  const SizedBox(height: 15),
                  Text(
                    "The ph sensor detected an increase in the water's acidity. "
                    'This may indicate water\u2019s acidity or changes in the water '
                    'entering the filtration system.',
                    style: AppText.sf(18, weight: FontWeight.w600, color: _grey),
                  ),
                  const SizedBox(height: 15),
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
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
                        onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SensorPage(spec: SensorSpec.ph))),
                        child: Text('View Sensor Details',
                            style: AppText.sf(15, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
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
