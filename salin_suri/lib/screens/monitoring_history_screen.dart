import 'package:flutter/material.dart';

import '../data/filtration_records.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/segmented_tabs.dart';
import 'history_details_screen.dart';

/// Monitoring History (Figma 623:831): All / Pre / Post tabs, search, and a list of
/// filtration runs that open their report (623:954).
class MonitoringHistoryScreen extends StatefulWidget {
  const MonitoringHistoryScreen({super.key});

  @override
  State<MonitoringHistoryScreen> createState() =>
      _MonitoringHistoryScreenState();
}

class _MonitoringHistoryScreenState extends State<MonitoringHistoryScreen> {
  static const _tabs = ['All', 'Pre', 'Post'];

  int _tab = 0;
  String _query = '';
  bool _newestFirst = false; // Figma lists oldest first

  List<FiltrationRecord> get _visible {
    final q = _query.trim().toLowerCase();
    final list = FiltrationRecord.all.where((r) {
      if (_tab == 1 && !r.isPre) return false;
      if (_tab == 2 && r.isPre) return false;
      return q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.time.toLowerCase().contains(q) ||
          r.stage.toLowerCase().contains(q);
    }).toList();
    return _newestFirst ? list.reversed.toList() : list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    return Scaffold(
      appBar: const AppTopBar(title: 'Monitoring History', showBack: true),
      body: ListView(
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
                      const Icon(Icons.search_rounded,
                          size: 16, color: Color(0xFFB7B7B7)),
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
                                AppText.sf(12, color: const Color(0xFFB7B7B7)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Sort button: toggles oldest/newest first.
              GestureDetector(
                onTap: () => setState(() => _newestFirst = !_newestFirst),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.iconChip, shape: BoxShape.circle),
                  child: const Icon(Icons.filter_list_rounded,
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
                child: Text('No filtrations found',
                    style: AppText.sf(14, color: AppColors.muted)),
              ),
            ),
          for (final r in items) ...[
            _RecordCard(
              record: r,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => HistoryDetailsScreen(record: r))),
            ),
            const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});

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
                              color: const Color(0xFFB8B8B8))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.stage,
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
