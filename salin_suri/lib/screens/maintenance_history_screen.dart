import 'package:flutter/material.dart';

import '../data/maintenance_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/date_filter_button.dart';
import 'maintenance_details_screen.dart';


/// Maintenance History (Figma 689:169): search, date filter, and a list of
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
              const _SummaryCard(),
              const SizedBox(height: 15),
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
                                hintText: 'Search date or maintenance number',
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
              style: AppText.sf(18, weight: FontWeight.w600)),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(done, 'Completed'),
              _Stat(pending, 'Pending'),
              _Stat(done + pending, 'Total Records'),
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
          children: [
            Text('$value', style: AppText.sf(35, weight: FontWeight.w700)),
            Text(label,
                style: AppText.sf(15,
                    weight: FontWeight.w500, color: AppColors.muted)),
          ],
        ),
      );
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.record, required this.onTap});

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
        child: Container(
          height: 73,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(record.title,
                    style: AppText.sf(20, weight: FontWeight.w700)),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(done ? 'Completed' : 'Pending',
                      style: AppText.sf(10,
                          color: done ? AppColors.accent : AppColors.alert)),
                  const SizedBox(height: 4),
                  Text(record.time,
                      style: AppText.sf(10, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
