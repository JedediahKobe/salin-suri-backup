import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../data/maintenance_records.dart';
import '../data/notification_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import 'maintenance_history_screen.dart' show MaintenanceCard;
import 'monitoring_history_screen.dart' show FiltrationRecordCard;
import 'notification_screen.dart' show AlertTile;

enum BinKind { archived, deleted }

/// Which kind of record a bin row is (Figma "Record Type Filter Menu" 949:1017).
enum RecordType {
  filtration('Filtration History'),
  maintenance('Maintenance History'),
  notification('Notification');

  const RecordType(this.label);
  final String label;
}

class _Entry {
  _Entry(this.type, this.search, this.sort, this.card, this.restore);

  final RecordType type;
  final String search;
  final DateTime sort;
  final Widget Function(VoidCallback onTap) card;
  final VoidCallback restore;
}

/// Archived Records (Figma 949:824) and Recently Deleted (949:1024): one list that mixes
/// filtration runs, maintenance records and notifications, with a search field and a
/// record-type filter in the bottom bar. Tap a row to restore it.
class RecordsBinScreen extends StatefulWidget {
  const RecordsBinScreen({super.key, required this.kind, this.initialType});

  final BinKind kind;
  final RecordType? initialType;

  @override
  State<RecordsBinScreen> createState() => _RecordsBinScreenState();
}

class _RecordsBinScreenState extends State<RecordsBinScreen> {
  final _filtration = FiltrationStore.instance;
  final _notifications = NotificationStore.instance;
  String _query = '';
  late RecordType? _type = widget.initialType;

  bool get _archived => widget.kind == BinKind.archived;

  List<_Entry> _entries() {
    final f = _archived ? _filtration.archived : _filtration.deleted;
    final m = _archived
        ? MaintenanceRecord.archived.value
        : MaintenanceRecord.deleted.value;
    final n = _archived ? _notifications.archived : _notifications.deleted;
    return [
      for (final r in f)
        _Entry(
          RecordType.filtration,
          '${r.title} ${r.time}'.toLowerCase(),
          DateTime(2026, 10, 26).add(Duration(minutes: r.number)),
          (tap) => FiltrationRecordCard(record: r, inBin: true, onTap: tap),
          () => _filtration.restore(r, f),
        ),
      for (final r in m)
        _Entry(
          RecordType.maintenance,
          '${r.title} ${r.time}'.toLowerCase(),
          r.when,
          (tap) => MaintenanceCard(record: r, onTap: tap),
          () => MaintenanceRecord.restore(
              r, _archived ? MaintenanceRecord.archived : MaintenanceRecord.deleted),
        ),
      for (final a in n)
        _Entry(
          RecordType.notification,
          '${a.title} ${a.body} ${a.time}'.toLowerCase(),
          DateTime(2026, 10, 24),
          (tap) => AlertTile(alert: a, onTap: tap),
          () => _notifications.restore(a, n),
        ),
    ];
  }

  Future<void> _restore(_Entry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Restore this record?', style: AppText.sf(18)),
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
    if (ok == true) e.restore();
  }

  Future<void> _showNote() {
    final top = MediaQuery.of(context).padding.top + 56 + 4;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: top, right: 12),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.barBorder),
              ),
              child: SizedBox(
                width: 152,
                child: Text('Items will be deleted permanently after 30 days',
                    style: AppText.sf(15)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _archived ? 'Archived Records' : 'Recently Deleted',
        showBack: true,
        trailing: _archived
            ? null
            : GestureDetector(
                onTap: _showNote,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: AppColors.iconChip, shape: BoxShape.circle),
                  child: Icon(Icons.info_outline_rounded,
                      size: 20, color: AppColors.accent),
                ),
              ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _filtration,
          _notifications,
          MaintenanceRecord.archived,
          MaintenanceRecord.deleted,
        ]),
        builder: (context, _) {
          final q = _query.trim().toLowerCase();
          final items = _entries()
              .where((e) =>
                  (_type == null || e.type == _type) &&
                  (q.isEmpty || e.search.contains(q)))
              .toList();
          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text('Nothing here yet',
                            style: AppText.sf(14, color: AppColors.muted)))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(11, 11, 11, 24),
                        children: [
                          for (final e in items) ...[
                            e.card(() => _restore(e)),
                            const SizedBox(height: 9),
                          ],
                        ],
                      ),
              ),
              _BottomBar(
                hint: _archived
                    ? 'Search archived records'
                    : 'Search deleted records',
                type: _type,
                onQuery: (v) => setState(() => _query = v),
                onType: (t) => setState(() => _type = t),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bottom "Search Bar and Filter" (Figma 961:446): 82px high with a top border.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.hint,
    required this.type,
    required this.onQuery,
    required this.onType,
  });

  final String hint;
  final RecordType? type;
  final ValueChanged<String> onQuery;
  final ValueChanged<RecordType?> onType;

  // Row heights straight from Figma: 29 / 41 / 26, 15 top padding.
  static const _heights = [29.0, 41.0, 26.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.fromLTRB(
          5, 0, 5, MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.barBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceInner,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  AppIcon(AppIconType.search, size: 16, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: onQuery,
                      style: AppText.sf(15),
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: AppText.sf(15, color: AppColors.muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 3),
          PopupMenuButton<RecordType>(
            padding: EdgeInsets.zero,
            position: PopupMenuPosition.over,
            offset: const Offset(0, -140),
            color: AppColors.surface,
            elevation: 0,
            constraints: const BoxConstraints(minWidth: 179, maxWidth: 179),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.divider, width: 0.5),
            ),
            onSelected: (t) => onType(type == t ? null : t),
            itemBuilder: (_) => [
              for (final t in RecordType.values)
                PopupMenuItem(
                  value: t,
                  height: _heights[t.index],
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(t.label,
                        style: AppText.sf(15,
                            color: t == type ? AppColors.accent : null)),
                  ),
                ),
            ],
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.iconChip,
                shape: BoxShape.circle,
                border: type == null ? null : Border.all(color: AppColors.accent),
              ),
              child: AppIcon(AppIconType.filterLines,
                  color: AppColors.accent, size: 25),
            ),
          ),
        ],
      ),
    );
  }
}
