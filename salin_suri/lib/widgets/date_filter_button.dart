import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Options of the date-range menu (Figma "Date Range Filter" 641:211).
enum DateFilter {
  week('7 days', 29),
  month('30 days', 41),
  older('More than 30 days', 26);

  const DateFilter(this.label, this.height);

  final String label;

  /// Row heights straight from Figma.
  final double height;

  bool matches(int daysAgo) => switch (this) {
        week => daysAgo <= 7,
        month => daysAgo <= 30,
        older => daysAgo > 30,
      };
}

/// The round "filter" button with the date-range popup, shared by Filtration History and
/// Maintenance History. Selecting the active option again clears the filter.
class DateFilterButton extends StatelessWidget {
  const DateFilterButton({super.key, required this.value, required this.onChanged});

  final DateFilter? value;
  final ValueChanged<DateFilter?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateFilter>(
      tooltip: 'Filter by date',
      offset: const Offset(0, 44),
      color: AppColors.surface,
      elevation: 0,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 125, maxWidth: 125),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      onSelected: (f) => onChanged(value == f ? null : f),
      itemBuilder: (_) => [
        for (final f in DateFilter.values)
          PopupMenuItem(
            value: f,
            height: f.height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(f.label,
                style: AppText.inter(11, weight: FontWeight.w500)),
          ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.iconChip,
          shape: BoxShape.circle,
          border: value == null ? null : Border.all(color: AppColors.accent),
        ),
        child: Icon(Icons.filter_list_rounded, color: AppColors.accent, size: 22),
      ),
    );
  }
}
