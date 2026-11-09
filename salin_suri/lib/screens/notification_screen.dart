import 'package:flutter/material.dart';

import '../data/notification_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'ph_alert_details_screen.dart';

/// Notification list (Figma 117:1198). Shown as a tab in the app shell; pass
/// [standalone] when it is pushed as a route (e.g. from the Sensors screen) to get a back button.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _store = NotificationStore.instance;

  void _open(AlertItem a) {
    _store.markRead(a);
    if (a.opensPhDetails) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PhAlertDetailsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final unread = _store.unreadCount;
        return Scaffold(
          appBar: AppTopBar(
            title: 'Notification',
            showBack: widget.standalone,
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: unread == 0 ? null : _store.markAllRead,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  unread == 0 ? 'All read' : 'Read All ($unread)',
                  style: AppText.inter(11,
                      weight: FontWeight.w700,
                      color: unread == 0 ? AppColors.muted : AppColors.accent),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(23, 18, 19, 110),
            children: [
              for (final a in _store.alerts)
                _AlertTile(alert: a, onTap: () => _open(a)),
            ],
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onTap});

  final AlertItem alert;
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
