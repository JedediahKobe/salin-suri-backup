import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'monitoring_history_screen.dart';

enum BinKind { archived, deleted }

/// Archived Record / Recently Deleted lists (reached from the Filtration History Edit
/// menu and Settings). No Figma frame yet: reuses the history cards, tap to restore.
class FiltrationBinScreen extends StatelessWidget {
  const FiltrationBinScreen({super.key, required this.kind});

  final BinKind kind;

  @override
  Widget build(BuildContext context) {
    final store = FiltrationStore.instance;
    final title =
        kind == BinKind.archived ? 'Archived Record' : 'Recently Deleted';
    return Scaffold(
      appBar: AppTopBar(title: title, showBack: true),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list =
              kind == BinKind.archived ? store.archived : store.deleted;
          if (list.isEmpty) {
            return Center(
              child: Text('Nothing here yet',
                  style: AppText.sf(14, color: AppColors.muted)),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(11, 11, 11, 24),
            children: [
              for (final r in list) ...[
                FiltrationRecordCard(
                  record: r,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Restore ${r.title}?',
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
                    if (ok == true) store.restore(r, list);
                  },
                ),
                const SizedBox(height: 11),
              ],
            ],
          );
        },
      ),
    );
  }
}
