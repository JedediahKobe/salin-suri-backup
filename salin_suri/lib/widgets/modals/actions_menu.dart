import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../app_icons.dart';

class ActionsMenuItem {
  const ActionsMenuItem(this.value, this.label, this.icon);

  final String value;
  final String label;
  final AppIconType icon;
}

/// Edit-pill actions menu (Figma Filtration / Maintenance History Actions Menu 873:187,
/// 892:715): a bordered card under the top bar, each row icon first and then the label,
/// with a divider after the first row. No dimming barrier.
Future<String?> showActionsMenu(
  BuildContext context, {
  required List<ActionsMenuItem> items,
  FontWeight weight = FontWeight.w500,
  Alignment alignment = Alignment.topRight,
  double left = 12,
  int dividerBefore = 1,
  double width = 200,
}) {
  final top = MediaQuery.of(context).padding.top + 56 + 4;
  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (ctx, _, __) => Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(top: top, right: 12, left: left),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.barBorder),
            ),
            child: SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i == dividerBefore)
                      Divider(height: 1, thickness: 1, color: AppColors.divider),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(items[i].value),
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AppIcon(items[i].icon,
                                    size: _iconSize(items[i].icon),
                                    color: AppColors.accent,
                                    strokeWidth: 1.6),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(items[i].label,
                                style: AppText.inter(15, weight: weight)),
                          ],
                        ),
                      ),
                    ),
                    // Figma: 10px between every row and around the divider.
                    if (i != items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Figma icon sizes: archive 16, mail 16, circle-check and trash 20.
double _iconSize(AppIconType t) => switch (t) {
      AppIconType.archive || AppIconType.mailRead => 16,
      AppIconType.circleCheck => 18,
      _ => 20,
    };
