import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class _Alert {
  _Alert(this.title, this.body, this.time, {this.unread = false});

  final String title;
  final String body;
  final String time;
  bool unread;
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _alerts = [
    _Alert(
      'pH Alert',
      'pH Level Outside Reference Range Pre-filtration pH reached 9.8, which is above the reference range.',
      '27 Sep 2026, 9:10 am',
      unread: true,
    ),
    _Alert(
      'Turbidity Alert',
      'High Turbidity Detected Post-filtration turbidity spiked to 4.2 NTU, exceeding the 1.0 NTU threshold.',
      '26 Sep 2026, 3:45 pm',
    ),
    _Alert(
      'Flow Rate Notice',
      'Low Flow Rate Warning Intake flow dropped to 12 L/min, below the expected 20 L/min minimum rate.',
      '24 Sep 2026, 8:05 am',
    ),
  ];

  int get _unread => _alerts.where((a) => a.unread).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Notification',
        showBack: true,
        trailing: TextButton(
          onPressed: _unread == 0
              ? null
              : () => setState(() {
                    for (final a in _alerts) {
                      a.unread = false;
                    }
                  }),
          child: Text(
            _unread == 0 ? 'All read' : 'Read All ($_unread)',
            style: AppText.inter(11,
                weight: FontWeight.w700,
                color: _unread == 0 ? AppColors.muted : AppColors.accent),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 16, 18, 24),
        children: [for (final a in _alerts) _AlertTile(alert: a)],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final _Alert alert;

  @override
  Widget build(BuildContext context) {
    final weight = alert.unread ? FontWeight.w600 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppColors.iconChip, shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded,
                color: AppColors.alertRed, size: 26),
          ),
          const SizedBox(width: 29),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: AppText.sf(15, weight: weight)),
                const SizedBox(height: 8),
                Text(alert.body,
                    textAlign: TextAlign.justify,
                    style: AppText.sf(13, weight: weight)),
                const SizedBox(height: 22),
                Text(alert.time, style: AppText.sf(13, weight: weight)),
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 1, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
