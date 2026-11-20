import 'package:flutter/material.dart';

import '../data/app_prefs.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = AppPrefs.notifications;

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
              _Row(label: 'Device Connection', onTap: () {}),
              _Row(label: 'Device Information', onTap: () {}),
            ],
          ),
          _Section(
            title: 'App',
            caption: 'Customize your app experience and preferences.',
            rows: [
              _Row(
                label: 'Dark Mode',
                trailing: AppToggle(
                  value: AppTheme.isDark,
                  onChanged: (v) => AppTheme.mode.value =
                      v ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              _Row(
                label: 'Notifications',
                trailing: AppToggle(
                  value: _notifications,
                  onChanged: (v) {
                    AppPrefs.setNotifications(v);
                    setState(() => _notifications = v);
                  },
                ),
              ),
              _Row(label: 'About Salin-Suri', onTap: () {}),
            ],
          ),
          _Section(
            title: 'Support',
            caption: 'Need help? Contact our team.',
            rows: [
              _Row(label: 'Contact Us', onTap: () {}),
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
  const _Section({required this.title, required this.caption, required this.rows});

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
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, thickness: 1, color: AppColors.divider),
                  InkWell(
                    onTap: rows[i].onTap,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rows[i].label,
                              style: AppText.sf(16, weight: FontWeight.w500)),
                          rows[i].trailing ??
                              Icon(Icons.chevron_right_rounded,
                                  size: 16, color: AppColors.text),
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
