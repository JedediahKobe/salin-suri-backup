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
  static const _recorded = '27/10/26 at 9:10 am';
  static const _grey = Color(0xFFB8B8B8);

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
      appBar: const AppTopBar(title: 'pH Alert Details', showBack: true),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('pH Level Alert', style: AppText.sf(25, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(summary, style: AppText.sf(14, color: _grey)),
              const SizedBox(height: 16),
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(18, 10, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                        ? const Color(0xFFFF8585)
                                        : AppColors.good),
                              ),
                              const SizedBox(height: 1),
                              Text('ph reference range: $min-$max',
                                  style: AppText.sf(13, color: _grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'pH Level Outside Reference Range Pre-filtration pH reached '
                      '${_reading.toStringAsFixed(1)}, which is above the reference range.',
                      textAlign: TextAlign.justify,
                      style: AppText.sf(13, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(_recorded,
                          style: AppText.sf(12, color: _grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 33),
              Text('What to check next?',
                  style: AppText.sf(25, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Check the latest sensor readings. If unusual readings persist, '
                'verify the sensor and filtration condition.',
                style: AppText.sf(14, color: _grey).copyWith(height: 20 / 14),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
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
                    // "Monitoring page" = the pH sensor page.
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const SensorPage(spec: SensorSpec.ph))),
                    child: Text('Go Back to Monitoring Page',
                        style: AppText.sf(15, weight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
