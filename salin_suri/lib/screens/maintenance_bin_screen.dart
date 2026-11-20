import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'filtration_bin_screen.dart' show BinKind;
import 'maintenance_history_screen.dart';

export 'filtration_bin_screen.dart' show BinKind;

/// Archived / recently deleted maintenance records. No Figma frame yet: reuses the
/// history cards, tap to restore.
class MaintenanceBinScreen extends StatelessWidget {
  const MaintenanceBinScreen({super.key, required this.kind});

  final BinKind kind;

  @override
  Widget build(BuildContext context) {
    final source = kind == BinKind.archived
        ? MaintenanceRecord.archived
        : MaintenanceRecord.deleted;
    return Scaffold(
      appBar: AppTopBar(
          title: kind == BinKind.archived ? 'Archived Record' : 'Recently Deleted',
          showBack: true),
      body: ValueListenableBuilder<List<MaintenanceRecord>>(
        valueListenable: source,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Center(
                child: Text('Nothing here yet',
                    style: AppText.sf(14, color: AppColors.muted)));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(11, 11, 11, 24),
            children: [
              for (final r in list) ...[
                MaintenanceCard(
                  record: r,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Restore ${r.title}?', style: AppText.sf(18)),
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
                    if (ok == true) MaintenanceRecord.restore(r, source);
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
