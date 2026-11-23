import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Device Information & Connection (Figma 947:378), opened from Settings > Device.
class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  static const _sensors = [
    'DFRobot Gravity Analog pH Sensor V2',
    'DFRobot Analog TDS Sensor',
    'DFRobot Analog Turbidity Sensor',
    'DS18B20 Waterproof Temperature Sensor',
    'YF-S201 Water Flow Sensor',
  ];

  @override
  Widget build(BuildContext context) {
    final small = AppText.sf(11, color: AppColors.muted);
    return Scaffold(
      appBar: const AppTopBar(title: 'Information & Connection', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
        children: [
          Text('Device Information', style: AppText.sf(25, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text('Salin-Suri Mobile App', style: AppText.sf(22, weight: FontWeight.w700)),
          Text('Water Quality Monitoring System',
              style: AppText.sf(15, color: AppColors.muted)),
          const SizedBox(height: 16),
          Text('Sensors Used', style: AppText.sf(22, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final s in _sensors)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(s,
                  style: AppText.sf(15, weight: FontWeight.w500, color: AppColors.muted)),
            ),
          const SizedBox(height: 9),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          Text('Device Connection', style: AppText.sf(25, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Connection Status', style: AppText.sf(22, weight: FontWeight.w700)),
              Text('Connected', style: AppText.sf(13, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.wifi_rounded, size: 48, color: AppColors.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salin-Suri Device', style: AppText.sf(22, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('ESP-32 Monitoring Device', style: small),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Device ID: ESP-1234-6789', style: small),
          const SizedBox(height: 4),
          Text('Last Updated: October 31, 2026, 10:38 am', style: small),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Connection Type', style: AppText.sf(15)),
              Text('Wi-Fi', style: AppText.sf(13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: const Color(0xFFF5F5F5),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              onPressed: () {},
              child: Text('Disconnect Device',
                  style: AppText.sf(15, weight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
