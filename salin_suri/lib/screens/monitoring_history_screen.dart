import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/date_filter_button.dart';
import '../widgets/modals/confirm_dialog.dart';
import '../widgets/segmented_tabs.dart';
import 'filtration_bin_screen.dart';
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

  Future<void> _openMenu(BuildContext anchor) async {
    final box = anchor.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final choice = await showMenu<String>(
      context: context,
      color: AppColors.surface,
      elevation: 0,
      position: RelativeRect.fromLTRB(
          pos.dx - 150, pos.dy + box.size.height + 6, 12, 0),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      items: [
        _menuItem('select', 'Select Messages', Icons.check_circle_outline_rounded),
        const PopupMenuDivider(height: 1),
        _menuItem('archived', 'Archived Record', Icons.archive_outlined),
        const PopupMenuDivider(height: 1),
        _menuItem('deleted', 'Recently Deleted', Icons.delete_outline_rounded),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'select':
        setState(() => _selecting = true);
      case 'archived':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FiltrationBinScreen(kind: BinKind.archived)));
      case 'deleted':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FiltrationBinScreen(kind: BinKind.deleted)));
    }
  }

  PopupMenuItem<String> _menuItem(String value, String label, IconData icon) =>
      PopupMenuItem(
        value: value,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: AppText.inter(15, weight: FontWeight.w500))),
            Icon(icon, size: 20, color: AppColors.text),
          ],
        ),
      );

  Future<void> _apply({required bool delete}) async {
    if (_selected.isEmpty) return;
    final many = _selected.length > 1;
    final verb = delete ? 'deleted' : 'archived';
    final ok = await showConfirmation(
      context,
      message: many
          ? 'These filtration histories will be $verb.'
          : 'This filtration history will be $verb.',
      actionLabel: delete ? 'Delete' : 'Archive',
    );
    if (!ok || !mounted) return;
    final picked = _selected.toList();
    delete ? _store.delete(picked) : _store.archive(picked);
    _exitSelect();
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
          leading: _selecting
              ? GestureDetector(
                  onTap: _exitSelect,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 24),
                  ),
                )
              : null,
          trailing: _selecting
              ? null
              : Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => _openMenu(ctx),
                    child: Container(
                      width: 53,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.divider, width: 0.5),
                      ),
                      child: Text('Edit', style: AppText.sf(11)),
                    ),
                  ),
                ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  size: 16, color: AppColors.muted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _query = v),
                                  style: AppText.sf(12),
                                  cursorColor: AppColors.accent,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: 'Search date or filtration number',
                                    hintStyle:
                                        AppText.sf(12, color: AppColors.muted),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
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
                      ],
                    ),
                    const SizedBox(height: 11),
                  ],
                ],
              ),
            ),
            if (_selecting)
              Container(
                height: 82,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                color: AppColors.background,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        if (allSelected) {
                          _selected.clear();
                        } else {
                          _selected.addAll(items);
                        }
                      }),
                      child: Container(
                        width: 110,
                        height: 39,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(allSelected ? 'Deselect All' : 'Select All',
                            style: AppText.sf(15, weight: FontWeight.w500)),
                      ),
                    ),
                    const Spacer(),
                    _RoundAction(
                        icon: Icons.archive_outlined,
                        enabled: _selected.isNotEmpty,
                        onTap: () => _apply(delete: false)),
                    const SizedBox(width: 10),
                    _RoundAction(
                        icon: Icons.delete_outline_rounded,
                        enabled: _selected.isNotEmpty,
                        onTap: () => _apply(delete: true)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction(
      {required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: AppColors.text),
          ),
        ),
      );
}

/// Run card shared by Filtration History and its archived / deleted bins.
class FiltrationRecordCard extends StatelessWidget {
  const FiltrationRecordCard({required this.record, required this.onTap});

  final FiltrationRecord record;
  final VoidCallback onTap;

  // Figma tag colors: pre #0059FF, post #2BFF00.
  static const _preColor = Color(0xFF0059FF);
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.isPre ? 'Pre-Filtration' : 'Post-Filtration',
                        style: AppText.sf(10,
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
