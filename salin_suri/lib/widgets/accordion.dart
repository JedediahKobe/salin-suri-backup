import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A single accordion item matching the Figma "Monitoring Chart Card" component:
///  * collapsed variant -> 71px tall header (title, subtitle, chevron-down)
///  * expanded variant  -> same header with chevron flipped (chevron-up) + body below
///
/// It can be used uncontrolled (give [initiallyExpanded]) or controlled
/// (give [expanded] and react to [onChanged], which is what [AccordionGroup] does).
class AccordionCard extends StatefulWidget {
  const AccordionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.initiallyExpanded = false,
    this.expanded,
    this.onChanged,
    this.titleStyle,
    this.subtitleStyle,
    this.headerHeight = 71,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOutCubic,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final bool initiallyExpanded;

  /// If non-null the card is controlled by the parent.
  final bool? expanded;
  final ValueChanged<bool>? onChanged;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double headerHeight;
  final Duration duration;
  final Curve curve;

  @override
  State<AccordionCard> createState() => _AccordionCardState();
}

class _AccordionCardState extends State<AccordionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded ?? widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: _expanded ? 1 : 0,
    );
    _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(covariant AccordionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlled = widget.expanded;
    if (controlled != null && controlled != _expanded) {
      // No setState needed: this runs as part of the rebuild already in progress.
      _expanded = controlled;
      controlled ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setExpanded(bool value, {required bool notify}) {
    setState(() => _expanded = value);
    value ? _controller.forward() : _controller.reverse();
    if (notify) widget.onChanged?.call(value);
  }

  void _toggle() {
    final next = !_expanded;
    if (widget.expanded != null) {
      // Controlled: let the parent decide; it will push the new value back in.
      widget.onChanged?.call(next);
    } else {
      _setExpanded(next, notify: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: _expanded,
      label: widget.title,
      child: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _toggle,
              child: SizedBox(
                height: widget.headerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: widget.titleStyle ??
                                  AppText.sf(17, weight: FontWeight.w500),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style:
                                    widget.subtitleStyle ?? AppText.sf(12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // chevron-down (collapsed) rotates 180deg into chevron-up (expanded)
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 0.5).animate(_curved),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Body: height animates with SizeTransition, content fades in a bit later.
            SizeTransition(
              sizeFactor: _curved,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.35, 1, curve: Curves.easeOut),
                ),
                child: widget.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccordionItemData {
  const AccordionItemData({
    required this.title,
    this.subtitle,
    required this.body,
  });

  final String title;
  final String? subtitle;
  final Widget body;
}

/// A stack of [AccordionCard]s. With [exclusive] true only one item is open at a time
/// (opening one collapses the previously open one), like the Home "Monitoring Insights".
class AccordionGroup extends StatefulWidget {
  const AccordionGroup({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.exclusive = true,
    this.spacing = 10,
  });

  final List<AccordionItemData> items;

  /// Index expanded at first, or null for all collapsed.
  final int? initialIndex;
  final bool exclusive;
  final double spacing;

  @override
  State<AccordionGroup> createState() => _AccordionGroupState();
}

class _AccordionGroupState extends State<AccordionGroup> {
  late Set<int> _open;

  @override
  void initState() {
    super.initState();
    _open = {if (widget.initialIndex != null) widget.initialIndex!};
  }

  void _onChanged(int index, bool value) {
    setState(() {
      if (value) {
        if (widget.exclusive) _open.clear();
        _open.add(index);
      } else {
        _open.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          AccordionCard(
            title: widget.items[i].title,
            subtitle: widget.items[i].subtitle,
            body: widget.items[i].body,
            expanded: _open.contains(i),
            onChanged: (v) => _onChanged(i, v),
          ),
        ],
      ],
    );
  }
}
