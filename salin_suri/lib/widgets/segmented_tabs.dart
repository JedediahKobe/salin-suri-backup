import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "Tabs" component from the History screen: a rounded track with a green pill that
/// slides between "Pre-filtration" and "Post-filtration", while the labels cross-fade
/// between bold and regular weight.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 39,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeInOutCubic,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final Duration duration;
  final Curve curve;

  static const double _inset = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final segmentWidth = constraints.maxWidth / labels.length;
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            // Sliding pill
            AnimatedPositioned(
              duration: duration,
              curve: curve,
              left: selectedIndex * segmentWidth + _inset,
              top: _inset,
              bottom: _inset,
              width: segmentWidth - _inset * 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selectedIndex,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            curve: curve,
                            style: AppText.inter(
                              15,
                              weight: i == selectedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                            child: Text(labels[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Animated content for a tab: new content slides in from the direction of travel
/// (left->right when moving to a higher tab index) while the old one fades out.
class TabContentSwitcher extends StatefulWidget {
  const TabContentSwitcher({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  final int index;

  /// Should already be built for [index]; it's re-keyed by index internally.
  final Widget child;
  final Duration duration;

  @override
  State<TabContentSwitcher> createState() => _TabContentSwitcherState();
}

class _TabContentSwitcherState extends State<TabContentSwitcher> {
  int _previous = 0;

  @override
  void didUpdateWidget(covariant TabContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _previous = oldWidget.index;
  }

  @override
  Widget build(BuildContext context) {
    final forward = widget.index >= _previous;
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey<int>(widget.index);
        final dx = (isIncoming ? 1 : -1) * (forward ? 0.12 : -0.12);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isIncoming ? dx : 0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      ),
      child: KeyedSubtree(
        key: ValueKey<int>(widget.index),
        child: widget.child,
      ),
    );
  }
}
