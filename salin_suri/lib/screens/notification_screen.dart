import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ph_alert_details_screen.dart';

class _Alert {
  _Alert(this.title, this.body, this.time, {this.unread = false, this.opensPh = false});

  final String title;
  final String body;
  final String time;
  final bool opensPh;
  bool unread;
}

/// Notification list (Figma 117:1198). Shown as a tab in the app shell; pass
/// [standalone] when it is pushed as a route (e.g. from the Sensors screen) to get a back button.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dummy data until alerts come from the backend.
  final _alerts = [
    _Alert(
      'pH Alert',
      'pH Level Outside Reference Range Pre-filtration pH reached 9.8, which is above the...',
      '27/10/26, 9:10 am',
      unread: true,
      opensPh: true,
    ),
    _Alert(
      'Turbidity Alert',
      'High Turbidity Detected Post-filtration turbidity spiked to 4.2 NTU, exceeding the 1.0 NTU thr...',
      '26/10/26, 3:45 pm',
    ),
    _Alert(
      'Flow Rate Notice',
      'Low Flow Rate Warning Intake flow dropped to 12 L/min, below the expected 20 L/min minimu..',
      '24/10/26, 8:05 am',
    ),
  ];

  int get _unread => _alerts.where((a) => a.unread).length;

  void _open(_Alert a) {
    setState(() => a.unread = false);
    if (a.opensPh) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PhAlertDetailsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Notification',
        showBack: widget.standalone,
        trailing: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _unread == 0
              ? null
              : () => setState(() {
                    for (final a in _alerts) {
                      a.unread = false;
                    }
                  }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _unread == 0 ? 'All read' : 'Read All ($_unread)',
              style: AppText.inter(11,
                  weight: FontWeight.w700,
                  color: _unread == 0 ? AppColors.muted : AppColors.accent),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(23, 18, 19, 110),
        children: [
          for (final a in _alerts) _AlertTile(alert: a, onTap: () => _open(a)),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onTap});

  final _Alert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Unread: white semibold. Read: grey #B8B8B8 regular.
    final color = alert.unread ? Colors.white : const Color(0xFFB8B8B8);
    final weight = alert.unread ? FontWeight.w600 : FontWeight.w400;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: AppColors.iconChip, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.alertRed, size: 32),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(alert.title,
                          style: AppText.sf(18, weight: weight, color: color)),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(alert.time,
                            style: AppText.sf(13, weight: weight, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(alert.body,
                      textAlign: TextAlign.justify,
                      style: AppText.sf(13, weight: weight, color: color)),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: AppColors.divider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
