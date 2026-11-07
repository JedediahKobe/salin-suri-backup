import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Top bar: dark strip with centered heavy title, optional back button and trailing chip.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;

  static const double _barHeight = 56;

  /// Scaffold sizes the app bar from this, so it must include the status-bar inset
  /// (the SafeArea below consumes it).
  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return Size.fromHeight(_barHeight + view.padding.top / view.devicePixelRatio);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bar,
        border: Border(bottom: BorderSide(color: AppColors.barBorder)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _barHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(title,
                  style: AppText.sf(20, weight: FontWeight.w900)),
              if (showBack)
                Positioned(
                  left: 15,
                  child: CircleChip(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              if (trailing != null) Positioned(right: 14, child: trailing!),
            ],
          ),
        ),
      ),
    );
  }
}

/// 32px circular icon button used in the top bar (back, notification, bulb, history).
class CircleChip extends StatelessWidget {
  const CircleChip({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 32,
    this.dot = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
            color: AppColors.iconChip, shape: BoxShape.circle),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.accent, size: size * 0.62),
            if (dot)
              Positioned(
                top: size * 0.18,
                right: size * 0.2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: AppText.sf(22, weight: FontWeight.w700)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.radius = 15,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Small green text button with a chevron-down, e.g. "Pre-filtration v" or "Last 7 days v".
/// Opens a popup menu and reports the picked option.
class DropdownPill extends StatelessWidget {
  const DropdownPill({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      color: AppColors.surfaceInner,
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem(value: o, child: Text(o, style: AppText.inter(13))),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: AppText.inter(11,
                    weight: FontWeight.w500, color: AppColors.accent)),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class StatCell {
  const StatCell({required this.label, required this.value, this.valueWidget});

  final String label;
  final String value;

  /// Overrides [value] when you need an icon next to the number (e.g. arrow for "Change").
  final Widget? valueWidget;
}

/// Row of "label over value" cells separated by thin vertical lines (Live dashboard,
/// Real-time monitoring, History summary).
class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.cells,
    this.color = AppColors.surface,
    this.header,
    this.height = 100,
  });

  final List<StatCell> cells;
  final Color color;
  final Widget? header;
  final double height;

  @override
  Widget build(BuildContext context) {
    final row = IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0)
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.divider),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cells[i].label, style: AppText.inter(12)),
                  const SizedBox(height: 10),
                  cells[i].valueWidget ??
                      Text(cells[i].value,
                          style: AppText.sf(17, weight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return SurfaceCard(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: header == null
          ? row
          : Column(children: [header!, const SizedBox(height: 14), row]),
    );
  }
}

/// Floating pill bottom navigation (Home / Filter / Settings).
class PillNavBar extends StatelessWidget {
  const PillNavBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.filter_alt_outlined, 'Filter'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: Container(
          height: 67,
          decoration: BoxDecoration(
            color: AppColors.bar,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.barBorder),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                          end: i == index ? AppColors.accent : Colors.white),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, color, _) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_items[i].$1, color: color, size: 30),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: i == index
                                ? Text(_items[i].$2,
                                    style: AppText.sf(14,
                                        weight: FontWeight.w700,
                                        color: AppColors.accent))
                                : const SizedBox(height: 0, width: 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Image from assets/images with an icon fallback, so the app runs before the
/// illustrations are exported from Figma.
class AssetOrIcon extends StatelessWidget {
  const AssetOrIcon({
    super.key,
    required this.asset,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final IconData fallback;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(fallback,
              size: (height ?? width ?? 96) * 0.5, color: AppColors.accent),
        ),
      ),
    );
  }
}
