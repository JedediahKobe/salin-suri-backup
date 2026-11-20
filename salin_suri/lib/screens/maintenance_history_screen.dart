import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/modals/add_maintenance_sheet.dart';
import 'maintenance_details_screen.dart';
import 'monitoring_history_screen.dart' show DateFilter;

/// Maintenance History (Figma 689:169): search, add (+), date filter, and a list of
/// maintenance entries that open their report (689:298).
class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  String _query = '';
  DateFilter? _dateFilter;

  List<MaintenanceRecord> _visible(List<MaintenanceRecord> all) {
    final q = _query.trim().toLowerCase();
    return all.where((r) {
      if (_dateFilter != null && !_dateFilter!.matches(r.daysAgo)) return false;
      return q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.time.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Maintenance History', showBack: true),
      body: ValueListenableBuilder<List<MaintenanceRecord>>(
        valueListenable: MaintenanceRecord.store,
        builder: (context, all, _) {
          final items = _visible(all);
          return ListView(
            padding: const EdgeInsets.fromLTRB(11, 15, 11, 24),
            children: [
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
                                hintText: 'Search',
                                hintStyle:
                                    AppText.sf(12, color: AppColors.muted),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _RoundButton(
                    child: Icon(Icons.add_rounded,
                        color: AppColors.accent, size: 24),
                    onTap: () => showAddMaintenanceSheet(context),
                  ),
                  const SizedBox(width: 6),
                  PopupMenuButton<DateFilter>(
                    tooltip: 'Filter by date',
                    offset: const Offset(0, 44),
                    color: AppColors.surface,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 105),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColors.divider, width: 0.5),
                    ),
                    onSelected: (f) => setState(
                        () => _dateFilter = _dateFilter == f ? null : f),
                    itemBuilder: (_) => [
                      for (final f in DateFilter.values)
                        PopupMenuItem(
                          value: f,
                          height: 27,
                          child: Center(
                            child: Text(f.label,
                                style: AppText.inter(11,
                                    weight: FontWeight.w500,
                                    color: AppColors.accent)),
                          ),
                        ),
                    ],
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.iconChip,
                        shape: BoxShape.circle,
                        border: _dateFilter == null
                            ? null
                            : Border.all(color: AppColors.accent),
                      ),
                      child: Icon(Icons.filter_list_rounded,
                          color: AppColors.accent, size: 22),
                    ),
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
                _MaintenanceCard(
                  record: r,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MaintenanceDetailsScreen(record: r))),
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

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration:
            BoxDecoration(color: AppColors.iconChip, shape: BoxShape.circle),
        child: child,
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.record, required this.onTap});

  final MaintenanceRecord record;
  final VoidCallback onTap;

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
                Icon(Icons.chevron_right_rounded,
                    size: 28, color: AppColors.text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
