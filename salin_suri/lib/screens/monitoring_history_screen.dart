import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/date_filter_button.dart';
import '../widgets/modals/actions_menu.dart';
import '../widgets/modals/confirm_dialog.dart';
import '../widgets/swipe_actions.dart';
import '../widgets/segmented_tabs.dart';
import 'records_bin_screen.dart';
import 'history_details_screen.dart';

/// Filtration History (Figma 623:831): All / Pre / Post tabs, search, and a list of
/// filtration runs that open their report (623:954). The Edit pill opens the actions
/// menu (873:187) and select mode (873:213) for archiving / deleting runs.
class MonitoringHistoryScreen extends StatefulWidget {
  const MonitoringHistoryScreen({super.key});

  @override
  State<MonitoringHistoryScreen> createState() =>
      _MonitoringHistoryScreenState();
}

class _MonitoringHistoryScreenState extends State<MonitoringHistoryScreen> {
  static const _tabs = ['All', 'Pre', 'Post'];

  final _store = FiltrationStore.instance;
  int _tab = 0;
  String _query = '';
  DateFilter? _dateFilter; // null = all dates
  bool _selecting = false;
  final _selected = <FiltrationRecord>{};

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() => setState(() {});

  List<FiltrationRecord> get _visible {
    final q = _query.trim().toLowerCase();
    return _store.active.where((r) {
      if (_tab == 1 && !r.isPre) return false;
      if (_tab == 2 && r.isPre) return false;
      if (_dateFilter != null && !_dateFilter!.matches(r.daysAgo)) return false;
      return q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.time.toLowerCase().contains(q) ||
          r.stage.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.number.compareTo(a.number));
  }

  void _exitSelect() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  Future<void> _openMenu() async {
    final choice = await showActionsMenu(context, items: const [
      ActionsMenuItem('select', 'Select Filtration', AppIconType.circleCheck),
      ActionsMenuItem('archived', 'Archived Record', AppIconType.archive),
      ActionsMenuItem('deleted', 'Recently Deleted', AppIconType.trash),
    ], width: 184);
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'select':
        setState(() => _selecting = true);
      case 'archived':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RecordsBinScreen(kind: BinKind.archived, initialType: RecordType.filtration)));
      case 'deleted':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RecordsBinScreen(kind: BinKind.deleted, initialType: RecordType.filtration)));
    }
  }

  Future<void> _apply({required bool delete, List<FiltrationRecord>? only}) async {
    final picked = only ?? _selected.toList();
    if (picked.isEmpty) return;
    final many = picked.length > 1;
    final verb = delete ? 'deleted' : 'archived';
    final ok = await showConfirmation(
      context,
      message: many
          ? 'These filtration histories will be $verb.'
          : 'This filtration history will be $verb.',
      actionLabel: delete ? 'Delete' : 'Archive',
    );
    if (!ok || !mounted) return;
    delete ? _store.delete(picked) : _store.archive(picked);
    if (_selecting) _exitSelect();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final allSelected =
        items.isNotEmpty && items.every(_selected.contains);
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSelect();
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: 'Filtration History',
          showBack: !_selecting,
          leading: _selecting ? SelectModeExit(onTap: _exitSelect) : null,
          trailing: _selecting ? null : EditPill(onTap: _openMenu),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(11, 11, 11, 24),
                children: [
                  SegmentedTabs(
                    labels: _tabs,
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 15),
                  SearchFilterBar(
 hint: 'Search date or filtration number',
 onQuery: (v) => setState(() => _query = v),
 value: _dateFilter,
 onFilter: (f) => setState(() => _dateFilter = f),
 ),
                  const SizedBox(height: 11),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('No filtrations found',
                            style: AppText.sf(14, color: AppColors.muted)),
                      ),
                    ),
                  for (final r in items) ...[
                    Row(
                      children: [
                        if (_selecting) ...[
                          AppCheck(
                            selected: _selected.contains(r),
                            onTap: () => setState(() => _selected.contains(r)
                                ? _selected.remove(r)
                                : _selected.add(r)),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: SwipeActionRow(
                            enabled: !_selecting,
                            onArchive: () => _apply(delete: false, only: [r]),
                            onDelete: () => _apply(delete: true, only: [r]),
                            child: FiltrationRecordCard(
                            record: r,
                            onTap: _selecting
                                ? () => setState(() => _selected.contains(r)
                                    ? _selected.remove(r)
                                    : _selected.add(r))
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            HistoryDetailsScreen(record: r))),
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
        ),
      ),
    );
  }
}

/// Run card shared by Filtration History and its archived / deleted bins.
class FiltrationRecordCard extends StatelessWidget {
  const FiltrationRecordCard(
      {required this.record, required this.onTap, this.inBin = false});

  final FiltrationRecord record;
  final VoidCallback onTap;

  /// Archived / Recently Deleted (Figma 949:824): no Pre/Post tag, the details link
  /// sits top-right.
  final bool inBin;

  // Figma tag colors: pre #6097FC, post #2BFF00.
  static const _preColor = Color(0xFF6097FC);
  static const _postColor = Color(0xFF2BFF00);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 83,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 14, 10),
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
                          style: AppText.sf(13,
                              color: AppColors.muted)),
                    ],
                  ),
                ),
                if (inBin)
                  Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: Text('View Filtration Details →',
                        style: AppText.sf(10, color: AppColors.accent)),
                  )
                else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.isPre ? 'Pre-Filtration' : 'Post-Filtration',
                        style: AppText.sf(11,
                            color: record.isPre ? _preColor : _postColor)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('View Filtration Details →',
                          style: AppText.sf(10, color: AppColors.accent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
