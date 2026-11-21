import 'package:flutter/material.dart';

import '../data/notification_store.dart';
import '../main.dart' show AppShell;
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/modals/actions_menu.dart';
import '../widgets/modals/confirm_dialog.dart';
import '../widgets/swipe_actions.dart';
import 'notification_bin_screen.dart';
import 'ph_alert_details_screen.dart';

/// Read / unread filter (Figma "Read/Unread Filter" 931:400).
enum _ReadFilter { read, unread }

/// Notification list (Figma 117:1198; select mode 931:464 / 931:593). Shown as a tab in
/// the app shell; pass [standalone] when it is pushed as a route (e.g. from the Sensors
/// screen) to get a back button.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _store = NotificationStore.instance;
  _ReadFilter? _filter;
  bool _selecting = false;
  final _selected = <AlertItem>{};

  void _open(AlertItem a) {
    _store.markRead(a);
    if (a.opensPhDetails) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PhAlertDetailsScreen()));
    }
  }

  void _setSelecting(bool v) {
    setState(() {
      _selecting = v;
      if (!v) _selected.clear();
    });
    AppShell.hideNav.value = v;
  }

  @override
  void dispose() {
    if (_selecting) AppShell.hideNav.value = false;
    super.dispose();
  }

  void _toggle(AlertItem a) => setState(
      () => _selected.contains(a) ? _selected.remove(a) : _selected.add(a));

  List<AlertItem> get _visible => _store.alerts.where((a) {
        return switch (_filter) {
          _ReadFilter.read => !a.unread,
          _ReadFilter.unread => a.unread,
          null => true,
        };
      }).toList();

  Future<void> _openMenu() async {
    final choice = await showActionsMenu(
      context,
      weight: FontWeight.w400,
      dividerBefore: 2,
      alignment: Alignment.topLeft,
      left: 9,
      items: const [
        ActionsMenuItem('select', 'Select Notification', AppIconType.circleCheck),
        ActionsMenuItem('read', 'Mark as read', AppIconType.mailRead),
        ActionsMenuItem('archived', 'Archived Record', AppIconType.archive),
        ActionsMenuItem('deleted', 'Recently Deleted', AppIconType.trash),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'select':
        _setSelecting(true);
      case 'read':
        _store.markAllRead();
      case 'archived':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                const NotificationBinScreen(kind: NotificationBin.archived)));
      case 'deleted':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                const NotificationBinScreen(kind: NotificationBin.deleted)));
    }
  }

  Future<void> _openFilter() async {
    final choice = await showGeneralDialog<_ReadFilter>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(ctx).padding.top + 56 + 4, right: 10),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 195,
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final f in _ReadFilter.values)
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(f),
                      child: Container(
                        height: 39,
                        alignment: Alignment.center,
                        child: Text(
                          f == _ReadFilter.read
                              ? 'Read Notifications'
                              : 'Unread Notifications',
                          style: AppText.inter(15,
                              color: _filter == f ? AppColors.accent : null),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (choice != null && mounted) {
      setState(() => _filter = _filter == choice ? null : choice);
    }
  }

  Future<void> _apply({required bool delete}) async {
    final picked = _selected.toList();
    if (picked.isEmpty) return;
    final verb = delete ? 'deleted' : 'archived';
    final ok = await showConfirmation(
      context,
      message: picked.length > 1
          ? 'These notifications will be $verb.'
          : 'This notification will be $verb.',
      actionLabel: delete ? 'Delete' : 'Archive',
    );
    if (!ok || !mounted) return;
    delete ? _store.delete(picked) : _store.archive(picked);
    _setSelecting(false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = _visible;
        final today = items.where((a) => a.today).toList();
        final earlier = items.where((a) => !a.today).toList();
        final allSelected = items.isNotEmpty && items.every(_selected.contains);
        return PopScope(
          canPop: !_selecting,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _setSelecting(false);
          },
          child: Scaffold(
            appBar: AppTopBar(
              title: 'Salin-Suri',
              showBack: widget.standalone && !_selecting,
              leading: _selecting
                  ? SelectModeExit(onTap: () => _setSelecting(false))
                  : widget.standalone
                      ? null
                      : EditPill(onTap: _openMenu, width: 68, height: 30),
              trailing: _selecting
                  ? null
                  : GestureDetector(
                      onTap: _openFilter,
                      child: Container(
                        width: 35,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.iconChip,
                          shape: BoxShape.circle,
                          border: _filter == null
                              ? null
                              : Border.all(color: AppColors.accent),
                        ),
                        child: AppIcon(AppIconType.filterLines,
                            size: 22,
                            color: AppColors.accent,
                            strokeWidth: 1.8),
                      ),
                    ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(9, 11, 9, _selecting ? 16 : 110),
                    children: [
                      Text('Notification',
                          style: AppText.sf(24, weight: FontWeight.w900)),
                      const SizedBox(height: 11),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text('No notifications',
                                style: AppText.sf(14, color: AppColors.muted)),
                          ),
                        ),
                      if (today.isNotEmpty) ...[
                        Text('Today',
                            style: AppText.sf(20, weight: FontWeight.w900)),
                        const SizedBox(height: 11),
                        for (final a in today) _row(a),
                      ],
                      if (earlier.isNotEmpty) ...[
                        Text('Earlier',
                            style: AppText.sf(20, weight: FontWeight.w900)),
                        const SizedBox(height: 11),
                        for (final a in earlier) _row(a),
                      ],
                    ],
                  ),
                ),
                if (_selecting)
                  SelectionBar(
                    topBorder: true,
                    allSelected: allSelected,
                    hasSelection: _selected.isNotEmpty,
                    onToggleAll: () => setState(() {
                      if (allSelected) {
                        _selected.clear();
                      } else {
                        _selected.addAll(items);
                      }
                    }),
                    onArchive: () => _apply(delete: false),
                    onDelete: () => _apply(delete: true),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(AlertItem a) => Padding(
        padding: const EdgeInsets.fromLTRB(7, 0, 0, 11),
        child: Row(
          children: [
            if (_selecting) ...[
              AppCheck(selected: _selected.contains(a), onTap: () => _toggle(a)),
              const SizedBox(width: 13),
            ],
            Expanded(
              child: AlertTile(
                alert: a,
                onTap: _selecting ? () => _toggle(a) : () => _open(a),
              ),
            ),
          ],
        ),
      );
}

/// One notification row (Figma 931:413): alert glyph, title and time, body, divider.
class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, required this.onTap});

  final AlertItem alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Unread: white semibold. Read: grey regular.
    final color = alert.unread ? AppColors.text : AppColors.muted;
    final weight = alert.unread ? FontWeight.w600 : FontWeight.w400;
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: AppColors.iconChip, shape: BoxShape.circle),
            child: const AppIcon(AppIconType.circleAlert,
                color: AppColors.alertRed, size: 32, strokeWidth: 1.8),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(alert.title,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sf(18, weight: weight, color: color)),
                    ),
                    Text(alert.time,
                        style: AppText.sf(alert.unread ? 11 : 13,
                            weight: weight, color: color)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(alert.body,
                    textAlign: TextAlign.justify,
                    style: AppText.sf(13, weight: weight, color: color)),
                const SizedBox(height: 8),
                Divider(height: 1, thickness: 1, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
