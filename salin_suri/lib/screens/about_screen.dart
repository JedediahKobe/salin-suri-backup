import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// About Salin-Suri (Figma 947:460), opened from Settings > Device.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Text(t, style: AppText.sf(22, weight: FontWeight.w700)),
      );

  Widget _p(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: AppText.sf(15, color: AppColors.muted)),
      );

  Widget _list(List<String> items) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          children: [
            for (final i in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: AppText.sf(15, color: AppColors.muted)),
                  Expanded(
                      child: Text(i, style: AppText.sf(15, color: AppColors.muted))),
                ],
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'About Salin-Suri', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 24),
        children: [
          Center(child: Text('Salin-Suri', style: AppText.sf(22, weight: FontWeight.w700))),
          const SizedBox(height: 4),
          Center(
              child: Text('Water Quality Monitoring System',
                  style: AppText.sf(15, color: AppColors.muted))),
          const SizedBox(height: 4),
          Center(
              child: Text('Version 1.0.0', style: AppText.sf(11, color: AppColors.muted))),
          _h('About the Application'),
          _p('Salin-Suri is a mobile application designed to monitor and assess '
              'water-quality parameters through a multi-sensor embedded monitoring system.'),
          _p('It provides real-time sensor readings, historical data, and pre-filtration '
              'and post-filtration comparisons to help users observe changes in water '
              'quality throughout the filtration process.'),
          _h('Our Purpose'),
          _p('To provide accessible and understandable water-quality monitoring '
              'information through sensor-based measurements and data visualization.'),
          _h('Key Features'),
          _list(const [
            'Real-time water-quality monitoring',
            'Pre-filtration and post-filtration comparison',
            'Historical sensor readings and trend analysis',
            'Filtration system information',
            'Filter maintenance tracking',
            'Device connection and monitoring status',
          ]),
          _h('Monitored Parameters'),
          _list(const [
            'pH Level',
            'Temperature',
            'Turbidity',
            'Total Dissolved Solids (TDS)',
          ]),
          _h('Important Notice'),
          _p('Salin-Suri is intended for monitoring water-quality parameters for '
              'household washing and cleaning applications. Its measurements and '
              'reference comparisons do not establish that water is safe for drinking '
              'or human consumption.'),
          const SizedBox(height: 18),
          Center(
              child: Text('© 2026 Salin-Suri. All rights reserved.',
                  style: AppText.sf(11, color: AppColors.muted))),
        ],
      ),
    );
  }
}
