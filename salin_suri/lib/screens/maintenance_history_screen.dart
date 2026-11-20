import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/date_filter_button.dart';
import '../widgets/modals/actions_menu.dart';
import '../widgets/modals/confirm_dialog.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/swipe_actions.dart';
import 'maintenance_bin_screen.dart';
import 'maintenance_details_screen.dart';

/// Maintenance History (Figma 689:169 / select mode 892:615, 892:812): totals card,
/// Total / Pending / Completed tabs, search, date filter and a list of entries that open
/// their report (689:298). Edit opens the actions menu (892:715); rows can also be dragged
/// to reveal archive / delete.
class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  static const _tabs = ['Total', 'Pending', 'Completed'];

  int _tab = 0;
  String _query = '';
  DateFilter? _dateFilter;
  bool _selecting = false;
  final _selected = <MaintenanceRecord>{};

  List<MaintenanceRecord> _visible(List<MaintenanceRecord> all) {
    final q = _query.trim().toLowerCase();
    return all.where((r) {
      if (_tab == 1 && r.completed) return false;
      if (_tab == 2 && !r.completed) return false;
      if (_dateFilter != null && !_dateFilter!.matches(r.daysAgo)) return false;
      return q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.time.toLowerCase().contains(q);
    }).toList();
  }

  void _exitSelect() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  void _toggle(MaintenanceRecord r) => setState(
      () => _selected.contains(r) ? _selected.remove(r) : _selected.add(r));

  Future<void> _openMenu() async {
    final choice = await showActionsMenu(context, items: const [
      ActionsMenuItem('select', 'Select Maintenance', AppIconType.circleCheck),
      ActionsMenuItem('archived', 'Archived Record', AppIconType.archive),
      ActionsMenuItem('deleted', 'Recently Deleted', AppIconType.trash),
    ]);
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'select':
        setState(() => _selecting = true);
      case 'archived':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MaintenanceBinScreen(kind: BinKind.archived)));
      case 'deleted':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MaintenanceBinScreen(kind: BinKind.deleted)));
    }
  }

  Future<void> _apply(
      {required bool delete, List<MaintenanceRecord>? only}) async {
    final picked = only ?? _selected.toList();
    if (picked.isEmpty) return;
    final many = picked.length > 1;
    final verb = delete ? 'deleted' : 'archived';
    final ok = await showConfirmation(
      context,
      message: many
          ? 'These maintenance records will be $verb.'
          : 'This maintenance record will be $verb.',
      actionLabel: delete ? 'Delete' : 'Archive',
    );
    if (!ok || !mounted) return;
    delete ? MaintenanceRecord.delete(picked) : MaintenanceRecord.archive(picked);
    if (_selecting) _exitSelect();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelect();
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: 'Maintenance History',
          showBack: !_selecting,
          leading: _selecting ? SelectModeExit(onTap: _exitSelect) : null,
          trailing: _selecting ? null : EditPill(onTap: _openMenu),
        ),
        body: ValueListenableBuilder<List<MaintenanceRecord>>(
          valueListenable: MaintenanceRecord.store,
          builder: (context, all, _) {
            final items = _visible(all);
            final allSelected = items.isNotEmpty && items.every(_selected.contains);
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(11, 11, 11, 24),
                    children: [
                      const _SummaryCard(),
                      const SizedBox(height: 15),
                      SegmentedTabs(
                        labels: _tabs,
                        selectedIndex: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                children: [
                                  AppIcon(AppIconType.search,
                                      size: 13, color: AppColors.muted),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (v) => setState(() => _query = v),
                                      style: AppText.sf(12),
                                      cursorColor: AppColors.accent,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: 'Search date or maintenance number',
                                        hintStyle: AppText.sf(12,
                                            color: AppColors.muted),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          DateFilterButton(
                            value: _dateFilter,
                            onChanged: (f) => setState(() => _dateFilter = f),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text('No maintenance found',
                                style: AppText.sf(14, color: AppColors.muted)),
                          ),
                        ),
                      for (final r in items) ...[
                        Row(
                          children: [
                            if (_selecting) ...[
                              AppCheck(
                                  selected: _selected.contains(r),
                                  onTap: () => _toggle(r)),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: SwipeActionRow(
                                enabled: !_selecting,
                                onArchive: () => _apply(delete: false, only: [r]),
                                onDelete: () => _apply(delete: true, only: [r]),
                                child: MaintenanceCard(
                                  record: r,
                                  onTap: _selecting
                                      ? () => _toggle(r)
                                      : () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  MaintenanceDetailsScreen(
                                                      record: r))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                      ],
                    ],
                  ),
                ),
                if (_selecting)
                  SelectionBar(
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
            );
          },
        ),
      ),
    );
  }
}

/// "No. of Maintenance Report" totals (Figma 689:169).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final done = MaintenanceRecord.completedCount;
    final pending = MaintenanceRecord.pendingCount;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No. of Maintenance Report',
              style: AppText.sf(24, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(done + pending, 'Total Records'),
              _Stat(pending, 'Pending'),
              _Stat(done, 'Completed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: AppText.sf(35, weight: FontWeight.w700)),
            Text(label,
                style: AppText.sf(15,
                    weight: FontWeight.w500, color: AppColors.muted)),
          ],
        ),
      );
}

/// Maintenance list card (Figma 891:480): title and date on the left, status top-right.
class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({super.key, required this.record, required this.onTap});

  final MaintenanceRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = record.completed;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 83,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 15, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(record.title,
                          style: AppText.sf(20, weight: FontWeight.w700)),
                      Text(record.time,
                          style: AppText.sf(13, color: AppColors.muted)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(done ? 'Completed' : 'Pending',
                        style: AppText.sf(10,
                            color: done ? AppColors.accent : AppColors.alert)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
