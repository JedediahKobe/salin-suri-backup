import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_icons.dart';

/// Options of the date-range menu (Figma "Date Range Filter" 641:211).
enum DateFilter {
  week('7 days', 44),
  month('30 days', 44),
  older('More than 30 days', 44);

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
  const DateFilterButton(
      {super.key, required this.value, required this.onChanged, this.size = 50});

  final DateFilter? value;
  final ValueChanged<DateFilter?> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateFilter>(
      tooltip: 'Filter by date',
      offset: const Offset(0, 44),
      color: AppColors.surface,
      elevation: 0,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 179, maxWidth: 179),
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
                style: AppText.inter(15, weight: FontWeight.w500)),
          ),
      ],
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.iconChip,
          shape: BoxShape.circle,
          border: value == null ? null : Border.all(color: AppColors.accent),
        ),
        alignment: Alignment.center,
        child: AppIcon(AppIconType.filterLines,
            color: AppColors.accent, size: size * 0.5),
      ),
    );
  }
}
