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

/// Search field + [DateFilterButton] toolbar (Figma "Search Bar and Filter" 921:331 / 921:319):
/// a 50px field (radius 40, 15px text) and the 50px button, 3px apart, spanning the screen
/// with 5px side margins - so it bleeds 6px past the lists' 11px padding.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.hint,
    required this.onQuery,
    required this.value,
    required this.onFilter,
  });

  final String hint;
  final ValueChanged<String> onQuery;
  final DateFilter? value;
  final ValueChanged<DateFilter?> onFilter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => OverflowBox(
        minWidth: c.maxWidth + 12,
        maxWidth: c.maxWidth + 12,
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                        AppIcon(AppIconType.search,
                            size: 16, color: AppColors.muted),
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
                DateFilterButton(value: value, onChanged: onFilter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
