import 'package:flutter/material.dart';

import '../data/notification_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'notification_screen.dart' show AlertTile;

enum NotificationBin { archived, deleted }

/// Archived / recently deleted notifications. No Figma frame yet: tap a row to restore it.
class NotificationBinScreen extends StatelessWidget {
  const NotificationBinScreen({super.key, required this.kind});

  final NotificationBin kind;

  @override
  Widget build(BuildContext context) {
    final store = NotificationStore.instance;
    return Scaffold(
      appBar: AppTopBar(
          title: kind == NotificationBin.archived
              ? 'Archived Record'
              : 'Recently Deleted',
          showBack: true),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list =
              kind == NotificationBin.archived ? store.archived : store.deleted;
          if (list.isEmpty) {
            return Center(
                child: Text('Nothing here yet',
                    style: AppText.sf(14, color: AppColors.muted)));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 9, 24),
            children: [
              for (final a in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: AlertTile(
                    alert: a,
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: Text('Restore ${a.title}?',
                              style: AppText.sf(18)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Restore')),
                          ],
                        ),
                      );
                      if (ok == true) store.restore(a, list);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
