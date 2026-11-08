import 'package:flutter/material.dart';

import '../data/sensor_specs.dart';
import '../theme/app_theme.dart';

/// The vertical "Guide" scale from the History screens: a circle marker per level joined
/// by a thin connector, the level value, then a title and description. The marker nearest
/// to [currentValue] is filled in.
class ParameterGuide extends StatelessWidget {
  const ParameterGuide({
    super.key,
    required this.entries,
    required this.currentValue,
    this.valueSize = 25,
    this.markerColor = AppColors.guideBlue,
  });

  final List<GuideEntry> entries;
  final double currentValue;
  final double valueSize;

  /// Blue on History; the pH Alert design uses red.
  final Color markerColor;

  int get _selected {
    var best = 0;
    for (var i = 0; i < entries.length; i++) {
      if ((entries[i].value - currentValue).abs() <
          (entries[best].value - currentValue).abs()) {
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 42,
                    child: Column(
                      children: [
                        _Marker(selected: i == selected, color: markerColor),
                        if (i < entries.length - 1)
                          Expanded(child: Container(width: 1, color: markerColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 64,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(entries[i].valueLabel,
                          style: AppText.sf(valueSize, weight: FontWeight.w700)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entries[i].title,
                              style: AppText.sf(15,
                                  weight: i == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(entries[i].description,
                              style: AppText.sf(12,
                                  color: const Color(0xFFDBDBDB))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: selected ? 28 : 0,
        height: selected ? 28 : 0,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
