import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _notificationsEnabled = true;

  void _showDetails(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: AppText.sf(20, weight: FontWeight.w700)),
        content: Text(message,
            style: AppText.inter(14, color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close',
                style: AppText.inter(14,
                    weight: FontWeight.w600, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Salin-Suri'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
        children: [
          _Section(
            title: 'Device',
            caption: 'Manage your device connection and view hardware details.',
            rows: [
              _Row(
                label: 'Device Connection',
                onTap: () => _showDetails(
                  'Device Connection',
                  'Connection status: Connected\n\nSalin-Suri is designed to receive sensor readings from the embedded monitoring device. Live connection details will appear here when the device integration is enabled.',
                ),
              ),
              _Row(
                label: 'Device Information',
                onTap: () => _showDetails(
                  'Device Information',
                  'Device: Salin-Suri\nController: ESP32\nMonitoring: pH, temperature, turbidity, and total dissolved solids (TDS).',
                ),
              ),
            ],
          ),
          _Section(
            title: 'App',
            caption: 'Customize your app experience and preferences.',
            rows: [
              _Row(
                label: 'Dark Mode',
                trailing: Switch(
                  value: _darkMode,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.accent,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.iconChip,
                  onChanged: (value) => setState(() => _darkMode = value),
                ),
              ),
              _Row(
                label: 'Notifications',
                onTap: () => setState(
                    () => _notificationsEnabled = !_notificationsEnabled),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _notificationsEnabled ? 'On' : 'Off',
                      style: AppText.inter(12, color: AppColors.muted),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.chevron_right_rounded,
                        size: 20, color: Colors.white),
                  ],
                ),
              ),
              _Row(
                label: 'About Salin-Suri',
                onTap: () => _showDetails(
                  'About Salin-Suri',
                  'Salin-Suri is a multi-sensor embedded water-quality monitoring system. It presents measurements before and after filtration to help users monitor water quality for household washing and cleaning. The system is not intended to certify water as safe for drinking.',
                ),
              ),
            ],
          ),
          _Section(
            title: 'Support',
            caption: 'Need help? Contact our team.',
            rows: [
              _Row(
                label: 'Help Center',
                onTap: () => _showDetails(
                  'Help Center',
                  'Use the Sensors section to view individual readings, Live Dashboard to compare pre- and post-filtration values, and Monitoring Insights to review measurement trends.',
                ),
              ),
              _Row(
                label: 'Contact Us',
                onTap: () => _showDetails(
                  'Contact Us',
                  'For project support, contact the Salin-Suri development team through your project’s official communication channel.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row {
  const _Row({required this.label, this.onTap, this.trailing});

  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.caption,
    required this.rows,
  });

  final String title;
  final String caption;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.sf(22, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(caption, style: AppText.inter(14, color: AppColors.muted)),
          const SizedBox(height: 14),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.divider,
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: rows[i].onTap,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rows[i].label,
                            style: AppText.sf(16, weight: FontWeight.w500),
                          ),
                          rows[i].trailing ??
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
